extends Node

func _ready():
	# set fullscreen on release build
	if (!OS.is_debug_build()):
		OS.window_fullscreen = true;

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && event.pressed):
		if (event.scancode == KEY_F1):
			OS.window_fullscreen = !OS.window_fullscreen;
