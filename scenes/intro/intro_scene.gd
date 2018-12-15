extends Node2D

func _ready():
	pass

func end_intro() -> void:
	SceneLoader.goto_world_level();
