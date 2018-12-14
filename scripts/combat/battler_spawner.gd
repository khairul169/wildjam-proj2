extends Node2D

# enums
enum Team {
	NONE = 0,
	PLAYER,
	ENEMY
}

# exports
export (Team) var team = Team.NONE;
export (NodePath) var camera;
export (NodePath) var spawn_position;

# res
onready var player_cat = load("res://scenes/combat/player_cat.tscn");
onready var enemy_cat = load("res://scenes/combat/enemy_cat.tscn");

# refs
onready var scene = get_node("/root/scene");

# vars
var spawn_pos = [];
var next_spawn_pos = -1;
var set_cam = false;

func _ready() -> void:
	if (camera is NodePath):
		camera = get_node(camera);
		set_cam = true;
	
	# add spawn pos list
	if (spawn_position is NodePath):
		for i in get_node(spawn_position).get_children():
			spawn_pos.append(i.transform.origin);
		get_node(spawn_position).queue_free();
	
	if (scene):
		scene.connect("scene_ready", self, "scene_ready");

func scene_ready() -> void:
	# spawn cats
	if (team == Team.PLAYER):
		scene.player_battler = spawn_cat({
			'pow': PlayerStats.get_stats_modifier(PlayerStats.STATS_POWER),
			'agi': PlayerStats.get_stats_modifier(PlayerStats.STATS_AGILITY)
		});
	
	if (team == Team.ENEMY && scene && scene.has_method("get_enemies")):
		var enemies = scene.get_enemies();
		for i in enemies:
			spawn_cat(i);

func spawn_cat(stats: Dictionary) -> Node2D:
	if (!scene || spawn_pos.empty() || !team):
		return null;
	
	# instance the cat
	var instance;
	match (team):
		Team.PLAYER:
			instance = player_cat.instance();
		Team.ENEMY:
			instance = enemy_cat.instance();
	
	# set cat position
	var spawn_position = Vector2.ZERO;
	next_spawn_pos = max(next_spawn_pos + 1, 0);
	if (next_spawn_pos >= spawn_pos.size()):
		next_spawn_pos = 0;
	spawn_position = spawn_pos[next_spawn_pos];
	instance.transform.origin = spawn_position;
	
	# set battler stats
	instance.team = team;
	instance.range_bonus = abs(spawn_position.x);
	
	if (team == Team.PLAYER):
		instance.health = PlayerStats.get_max_health();
		instance.cur_health = max(PlayerStats.health, 0.1);
		
		# power
		if (stats.has('pow')):
			instance.damage = max(instance.damage * float(stats['pow']), 0.0);
			instance.attack_speed = clamp(instance.attack_speed - (float(stats['pow']) * 0.05), 0.1, 2.0);
		
		# agility
		if (stats.has('agi')):
			instance.evasion = clamp(instance.evasion * float(stats['agi']), 0.0, 0.9);
	
	if (team == Team.ENEMY && instance.has_method('set_level') && stats.has('level')):
		instance.set_level(stats.level);
	
	# set camera follow
	if (set_cam && camera):
		camera.get_parent().remove_child(camera);
		instance.add_child(camera);
		camera.make_current();
		set_cam = false;
	
	# add to world
	add_child(instance);
	return instance;
