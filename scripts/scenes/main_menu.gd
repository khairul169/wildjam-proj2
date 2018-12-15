extends Control

func _ready() -> void:
	$button_continue.disabled = !PlayerStats.has_savegame();
	$button_continue.connect("pressed", self, "_continue");
	$button_newgame.connect("pressed", self, "_newgame");
	$button_quit.connect("pressed", self, "_quit");

func _continue() -> void:
	# load savegame
	PlayerStats.load_game();
	SceneLoader.goto_world_level();

func _newgame() -> void:
	# create new savegame
	PlayerStats.reset_data();
	PlayerStats.save_game();
	SceneLoader.switch_scene(SceneLoader.SCENE_DATA_INPUT);

func _quit() -> void:
	get_tree().quit();
