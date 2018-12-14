extends Node

# consts
const BATTLER_GROUP = 'cats';

# refs
onready var battle_condition = $ui_layer/interface/battle_condition;

# enums
enum Team {
	NONE = 0,
	PLAYER,
	ENEMY
};

enum {
	RESULT_NONE = 0,
	RESULT_LOSE,
	RESULT_WIN
};

# signals
signal scene_ready();
signal battler_died(who);

# vars
var player_battler;
var enemies = [];
var world_state;
var enemy_count = 0;
var enemy_level = 1;
var battle_result = RESULT_NONE;
var next_think = 0.0;

func _ready() -> void:
	# load enemy
	var shared_data = SceneLoader.get_shared_data();
	if (shared_data && typeof(shared_data) == TYPE_DICTIONARY):
		# enemy data
		if (shared_data.has('enemy_count')):
			enemy_count = int(clamp(shared_data['enemy_count'], 1, 9));
		if (shared_data.has('enemy_level')):
			enemy_level = int(clamp(shared_data['enemy_level'], 0, 100));
		
		# world state
		if (shared_data.has('world_state')):
			world_state = shared_data['world_state'];
	
	# add enemies
	for i in range(enemy_count):
		enemies.append({
			'level': enemy_level
		});
	
	connect("battler_died", self, "_battler_died");
	emit_signal("scene_ready");

func _process(delta: float) -> void:
	if (battle_result && next_think > 0.0):
		next_think -= delta;
		
		# get back to world
		if (next_think <= 0.0):
			back_to_world();
			set_process(false);

func _battler_died(who) -> void:
	if (battle_result):
		return;
	
	# check for team alive member
	var player_alive = 0;
	var enemy_alive = 0;
	
	# loop through all battler
	for i in get_tree().get_nodes_in_group(BATTLER_GROUP):
		if (!i.has_method('is_alive') || !i.is_alive()):
			continue;
		
		if (!i.has_method('get_team')):
			continue;
		
		match (i.get_team()):
			Team.PLAYER:
				player_alive += 1;
			Team.ENEMY:
				enemy_alive += 1;
	
	# enemy wiped out
	if (enemy_alive <= 0):
		end_combat(true);
	
	# player lose
	elif (player_alive <= 0):
		end_combat(false);

func get_enemies() -> Array:
	return enemies;

func end_combat(win: bool) -> void:
	if (battle_result || !world_state):
		return;
	
	# give player exp point
	PlayerStats.combat_finished(win, enemy_count, enemy_level);
	
	# set result
	if (win):
		battle_result = RESULT_WIN;
		battle_condition.show_hud(battle_condition.BATTLE_CLEAR);
	else:
		battle_result = RESULT_LOSE;
		battle_condition.show_hud(battle_condition.BATTLE_FAILED);
	
	# set player health
	if (player_battler):
		PlayerStats.health = player_battler.cur_health;
	
	if (world_state.has('enemy') && world_state.enemy.size() > 0):
		# set win state
		var enemy_id = world_state.enemy.size()-1;
		world_state.enemy[enemy_id][1] = win;
	
	# set delay to go back to the world
	next_think = 4.0;

func back_to_world() -> void:
	if (!battle_result):
		return;
	
	# go back to world
	if (battle_result == RESULT_WIN):
		SceneLoader.goto_world_level(world_state);
	else:
		SceneLoader.goto_world_level();
