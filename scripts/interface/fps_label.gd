extends Label

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	text = str("FPS: ", Engine.get_frames_per_second());
