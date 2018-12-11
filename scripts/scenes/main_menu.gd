extends Control

func _ready() -> void:
	$button_continue.connect("pressed", self, "_continue");
	$button_newgame.connect("pressed", self, "_newgame");
	$button_quit.connect("pressed", self, "_quit");

func _continue() -> void:
	pass

func _newgame() -> void:
	# create new savegame
	PlayerStats.reset_data();
	PlayerStats.save_game();
	SceneLoader.goto_world_level();

func _quit() -> void:
	get_tree().quit();
