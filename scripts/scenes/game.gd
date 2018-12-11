extends Node

# exports
export (PackedScene) var _level_scene;
export (NodePath) var level;

# refs
onready var hud = $ui_layer/ui/hud;
onready var interface = $ui_layer/ui/interface;
onready var world = $world;

# res
onready var scene_player = load("res://scenes/player/player.tscn");

func _ready() -> void:
	if (level && level is NodePath):
		level = get_node(level);
	
	elif (_level_scene):
		level = _level_scene.instance();
		world.add_child(level);
	
	# spawn player
	if (level):
		spawn_player(level.spawn_pos);
	else:
		spawn_player();

func spawn_player(pos: Vector2 = Vector2.ZERO) -> void:
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
	
