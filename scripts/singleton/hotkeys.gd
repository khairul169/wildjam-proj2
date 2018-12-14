extends Node

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && event.pressed):
		if (event.scancode == KEY_F1):
			OS.window_fullscreen = !OS.window_fullscreen;
