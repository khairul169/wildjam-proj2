extends Node

# consts
const BATTLER_GROUP = 'cats';

# enums
enum Team {
	NONE = 0,
	PLAYER,
	ENEMY
}

# signals
signal scene_ready();
signal battler_died(who);

# vars
var player_battler;
var enemies = [];
var combat_running = false;
var world_state;
var enemy_count = 0;
var enemy_level = 1;

func _ready() -> void:
	# set combat as running
	combat_running = true;
	
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
			'str': 1.0 + (enemy_level / 100.0 * 10.0),
			'pow': 1.0 + (enemy_level / 100.0 * 8.0),
			'agi': 1.0 + (enemy_level / 100.0 * 4.0)
		});
	
	connect("battler_died", self, "_battler_died");
	emit_signal("scene_ready");

func _battler_died(who) -> void:
	if (!combat_running):
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
	if (!combat_running || !world_state):
		return;
	
	# give player exp point
	PlayerStats.combat_finished(enemy_count, enemy_level);
	
	# set player health
	if (player_battler):
		PlayerStats.health = player_battler.cur_health;
	
	if (world_state.has('enemy') && world_state.enemy.size() > 0):
		# set win state
		var enemy_id = world_state.enemy.size()-1;
		world_state.enemy[enemy_id][1] = win;
	
	# go back to world
	SceneLoader.goto_world_level(world_state);
