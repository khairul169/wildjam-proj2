extends CanvasLayer

# scenes
enum {
	SCENE_MAINMENU = 0,
	SCENE_WORLD,
	SCENE_COMBAT
};

var scenes = {
	SCENE_MAINMENU: "res://scenes/main_menu.tscn",
	SCENE_WORLD: "res://scenes/world.tscn",
	SCENE_COMBAT: "res://scenes/combat.tscn"
};

# refs
onready var ui_node: Control = $ui;

# vars
var shared_data;
var current_scene = -1;

# world levels
onready var level_basecamp = load_level('basecamp');

func _ready():
	# load scenes
	for i in scenes.keys():
		scenes[i] = load(scenes[i]);
	
	# hide ui
	ui_node.hide();

func switch_scene(scene_id: int, data = null) -> void:
	if (!scenes.has(scene_id)):
		return;
	
	# save game
	PlayerStats.save_game();
	
	# set data
	shared_data = data;
	ui_node.show();
	
	yield(get_tree(), "idle_frame");
	yield(get_tree(), "idle_frame");
	
	# change scene
	if (scene_id == current_scene):
		get_tree().reload_current_scene();
	else:
		get_tree().change_scene_to(scenes[scene_id]);
	
	current_scene = scene_id;
	OS.delay_msec(500);
	ui_node.hide();

func goto_world_level(state = null) -> void:
	if (!state || typeof(state) != TYPE_DICTIONARY || !state.size()):
		# start level
		state = {'level': level_basecamp};
	
	# switch to world scene
	switch_scene(SCENE_WORLD, state);

func get_shared_data():
	return shared_data;

func load_level(fname: String) -> Resource:
	return load("res://levels/" + fname + ".tscn");
