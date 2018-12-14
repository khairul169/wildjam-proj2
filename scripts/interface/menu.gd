extends Control

# refs
onready var interface = get_node("../../");

func _ready():
	$btn_continue.connect("pressed", self, "hide");
	$btn_stats.connect("pressed", self, "stats");
	$btn_mainmenu.connect("pressed", self, "mainmenu");
	
	$btn_fullscr.connect("pressed", self, "toggle_fullscreen");

func show() -> void:
	.show();
	get_tree().paused = true;

func hide() -> void:
	.hide();
	get_tree().paused = false;

func stats() -> void:
	# show stats panel
	if (interface):
		interface.show_panel(interface.PANEL_STATS);

func mainmenu() -> void:
	hide();
	SceneLoader.switch_scene(SceneLoader.SCENE_MAINMENU);

func toggle_fullscreen() -> void:
	if (OS.get_name().to_lower() == 'android'):
		return;
	OS.window_fullscreen = !OS.window_fullscreen;
