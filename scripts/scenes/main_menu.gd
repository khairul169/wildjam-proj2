extends Control

func _ready() -> void:
	$button_continue.disabled = !PlayerStats.has_savegame();
	$button_continue.connect("pressed", self, "_continue");
	$button_newgame.connect("pressed", self, "_newgame");
	$button_quit.connect("pressed", self, "_quit");

func _notification(what: int) -> void:
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST || what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST):
		get_tree().quit();

func _continue() -> void:
	# load savegame
	PlayerStats.load_game();
	SceneLoader.goto_world_level();

func _newgame() -> void:
	# create new savegame
	SceneLoader.switch_scene(SceneLoader.SCENE_DATA_INPUT);

func _quit() -> void:
	get_tree().quit();
