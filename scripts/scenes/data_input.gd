extends Control

func _ready():
	$btn_ok.connect("pressed", self, "_submit_data");

func _submit_data() -> void:
	var player_name = $name.text.strip_edges();
	if (player_name.length() <= 0):
		return;
	
	PlayerStats.player_name = player_name;
	PlayerStats.save_game();
	SceneLoader.switch_scene(SceneLoader.SCENE_INTRO);
