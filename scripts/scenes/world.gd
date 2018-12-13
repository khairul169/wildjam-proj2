extends Node

# signals
signal quest_updated();

# refs
onready var interface = $ui_layer/interface;
onready var world = $world;

# res
onready var scene_player = load("res://scenes/player/player.tscn");

# consts
const GROUP_ENEMIES = 'enemies';
const QUEST_MANAGER = preload("res://scripts/player/quest_manager.gd");

enum {
	QUEST_MAIN = 0,
	QUEST_SIDE
};

# vars
var level_packed;
var level;
var player_node;
var enemies_state = [];
var quest_list = {};
var current_quest;
var next_check = 0.0;

func _ready() -> void:
	var spawn_pos = Vector2.ZERO;
	var show_lvlname = true;
	
	# get state from sceneloader
	var state = SceneLoader.get_shared_data();
	if (typeof(state) == TYPE_DICTIONARY):
		# level scene
		if (state.has('level')):
			level_packed = state.level;
			level = level_packed.instance();
			world.add_child(level);
		
		# player position
		if (state.has('spawn_pos')):
			spawn_pos = state.spawn_pos;
		elif (level):
			spawn_pos = level.spawn_pos;
		
		# state of enemies encountered
		if (state.has('enemy')):
			enemies_state = state.enemy;
		
		# active quest
		if (state.has('quest')):
			current_quest = state.quest;
		
		# level name
		if (state.has('show_lvlname')):
			show_lvlname = state.show_lvlname;
	
	# show level name
	if (show_lvlname && level && interface):
		interface.show_level_name(level.level_name);
	
	# register quests
	var quest_mgr = QUEST_MANAGER.new();
	quest_mgr.setup_quest(self);
	update_quest();
	
	# spawn the player
	player_node = spawn_player(spawn_pos);
	
	# remove dead npc
	if (enemies_state && typeof(enemies_state) == TYPE_ARRAY && enemies_state.size() > 0):
		for i in enemies_state:
			if (!has_node(i[0])):
				continue;
			
			# get node reference
			var node = get_node(i[0]);
			
			# not in group
			if (!node.is_in_group(GROUP_ENEMIES)):
				continue;
			
			# remove object
			var died = i[1];
			if (died):
				node.queue_free();
	
	# check for alive enemy
	next_check = 2.0;

func _process(delta: float) -> void:
	if (next_check > 0.0):
		next_check -= delta;
		
		if (next_check <= 0.0):
			check_enemy();

func spawn_player(pos: Vector2 = Vector2.ZERO) -> Node2D:
	# instance player
	var instance = scene_player.instance();
	
	# add to scene tree
	if (level):
		if (level.navigation):
			instance.nav = level.navigation;
		level.add_to_ysort(instance);
	else:
		print("Cannot find level!");
		world.add_child(instance);
	
	# set player pos
	instance.transform.origin = pos;
	return instance;

func get_player() -> Node2D:
	return player_node;

func get_player_pos() -> Vector2:
	if (player_node):
		return player_node.transform.origin;
	return Vector2.ZERO;

func start_combat(object) -> void:
	if (!object.has_method('get_data')):
		return;
	
	var npc_data = object.get_data();
	enemies_state.append([get_path_to(object), false]);
	
	var shared_data = {
		'enemy_count': npc_data['count'],
		'enemy_level': npc_data['level'],
		'world_state': {
			'level': level_packed,
			'spawn_pos': get_player_pos(),
			'enemy': enemies_state,
			'quest': current_quest,
			'show_lvlname': false
		}
	};
	
	SceneLoader.switch_scene(SceneLoader.SCENE_COMBAT, shared_data);

func register_quest(type: int, caption: String = "", level: String = "", clear_exp: int = 100, new_chapter: bool = false) -> void:
	if (!level || caption.length() <= 0 || level.length() <= 0):
		return;
	
	if (!quest_list.has(type) || typeof(quest_list[type]) != TYPE_ARRAY):
		quest_list[type] = [];
	
	# load level scene
	var level_scene;
	var level_path = "res://levels/" + level + ".tscn";
	if (File.new().file_exists(level_path)):
		level_scene = load(level_path);
	else:
		print(level_path, " doesn't exists!");
		return;
	
	if (type == QUEST_MAIN):
		if (new_chapter || quest_list[type].size() <= 0):
			quest_list[type].append([]);
		
		var chapter = quest_list[type].size() - 1;
		var quest_id = quest_list[type][chapter].size();
		var locked = true;
		
		if (chapter <= 0 && quest_id <= 0):
			locked = false;
		
		if (quest_id <= 0):
			if (chapter <= 0):
				# first quest always unlocked
				locked = false;
			else:
				# check previous chapter
				locked = !PlayerStats.is_quest_cleared(QUEST_MAIN, quest_list[type][chapter-1].size()-1, chapter-1);
		else:
			# check previous quest
			locked = !PlayerStats.is_quest_cleared(QUEST_MAIN, quest_id - 1, chapter);
		
		quest_list[type][chapter].append({
			'title': str('Chapter ', chapter + 1, '-', quest_id + 1),
			'caption': caption,
			'level': level_scene,
			'lock': locked,
			'clear_exp': clear_exp
		});
	
	if (type == QUEST_SIDE):
		var quest_id = quest_list[type].size() - 1;
		var locked = PlayerStats.is_quest_cleared(QUEST_SIDE, quest_id);
		
		quest_list[type].append({
			'title': str('Quest #', quest_id + 1),
			'caption': caption,
			'level': level_scene,
			'lock': locked,
			'clear_exp': clear_exp
		});

func get_quest_list() -> Dictionary:
	return quest_list;

func update_quest() -> void:
	emit_signal("quest_updated");

func start_quest(type, id, chapter = null) -> void:
	if (!quest_list.has(type)):
		return;
	
	var level_scene;
	
	if (type == QUEST_MAIN && typeof(chapter) == TYPE_INT && chapter >= 0 && chapter < quest_list[type].size()):
		if (id < 0 || id >= quest_list[type][chapter].size()):
			return;
		
		var quest = quest_list[type][chapter][id];
		if (quest.has('level')):
			level_scene = quest.level;
	
	if (type == QUEST_SIDE && id >= 0 && id < quest_list[type].size()):
		var quest = quest_list[type][id];
		if (quest.has('level')):
			level_scene = quest.level;
	
	if (level_scene):
		SceneLoader.goto_world_level({
			'level': level_scene,
			'quest': {
				'type': type,
				'id': id,
				'chapter': chapter
			}
		});

func check_enemy() -> void:
	if (!current_quest || typeof(current_quest) != TYPE_DICTIONARY):
		return;
	
	var enemies = get_tree().get_nodes_in_group(GROUP_ENEMIES);
	
	if (enemies.size() <= 0):
		quest_clear(current_quest);
		SceneLoader.goto_world_level();

func quest_clear(quest: Dictionary) -> void:
	if (!quest.has('type') || !quest.has('id')):
		return;
	
	var clear_exp = 100.0;
	
	if (quest.type == QUEST_MAIN):
		if (!quest.has('chapter') || quest.chapter < 0 || quest.chapter >= quest_list[QUEST_MAIN].size()):
			return;
		
		if (quest.id < 0 || quest.id >= quest_list[QUEST_MAIN][quest.chapter].size()):
			return;
		
		var quest_data = quest_list[QUEST_MAIN][quest.chapter][quest.id];
		if (quest_data.has('clear_exp')):
			clear_exp = quest_data.clear_exp;
	
	# set quest clear
	PlayerStats.set_quest_clear(quest.type, quest.id, quest.chapter);
	
	# give player exp
	PlayerStats.add_experience(clear_exp);
