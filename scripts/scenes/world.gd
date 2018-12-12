extends Node

# refs
onready var interface = $ui_layer/interface;
onready var world = $world;

# res
onready var scene_player = load("res://scenes/player/player.tscn");

# vars
var level_packed;
var level;
var player_node;
var enemies_state = [];

func _ready() -> void:
	var spawn_pos = Vector2.ZERO;
	
	# get state from sceneloader
	var state = SceneLoader.get_shared_data();
	if (typeof(state) == TYPE_ARRAY):
		# level scene
		if (state.size() > 0):
			level_packed = state[0];
			level = level_packed.instance();
			world.add_child(level);
		
		# player position
		if (state.size() > 1):
			spawn_pos = state[1];
		elif (level):
			spawn_pos = level.spawn_pos;
		
		# state of enemies encountered
		if (state.size() > 2):
			enemies_state = state[2];
	
	# spawn the player
	player_node = spawn_player(spawn_pos);
	
	# remove dead npc
	if (enemies_state && typeof(enemies_state) == TYPE_ARRAY && enemies_state.size() > 0):
		for i in enemies_state:
			if (!has_node(i[0])):
				continue;
			
			var node = get_node(i[0]);
			var died = i[1];
			if (died):
				node.queue_free();

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
		'world_state': [level_packed, get_player_pos(), enemies_state]
	};
	
	print("starting combat with ", object.name);
	SceneLoader.switch_scene(SceneLoader.SCENE_COMBAT, shared_data);
