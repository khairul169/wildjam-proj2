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
var enemies = [];
var combat_running = false;

func _ready() -> void:
	# set combat as running
	combat_running = true;
	
	# load enemy
	var shared_data = SceneLoader.get_shared_data();
	if (shared_data && typeof(shared_data) == TYPE_DICTIONARY):
		var enemy_count = 0;
		var enemy_level = 1;
		
		if (shared_data.has('enemy_count')):
			enemy_count = int(clamp(shared_data['enemy_count'], 1, 9));
		if (shared_data.has('enemy_level')):
			enemy_level = int(clamp(shared_data['enemy_level'], 0, 100));
		
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
	if (!combat_running):
		return;
	
	print("Combat end: ", win);
	
	SceneLoader.switch_scene(SceneLoader.SCENE_WORLD);
