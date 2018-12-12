extends Control

# refs
onready var hud = $hud;

func _ready():
	pass

func _process(delta: float) -> void:
	# player name
	hud.get_node("character_info/name").text = PlayerStats.player_name;
	
	# player level
	hud.get_node("character_info/level").text = str("Lvl ", PlayerStats.level);
	
	# health bar
	var health_bar = hud.get_node("character_info/health/bar");
	health_bar.rect_size.x = (health_bar.get_parent().rect_size.x - 2.0) * clamp(PlayerStats.health / PlayerStats.get_max_health(), 0.0, 1.0);
	
	# experience
	var exp_bar = hud.get_node("character_info/experience/bar");
	exp_bar.rect_size.x = (exp_bar.get_parent().rect_size.x - 2.0) * clamp(float(PlayerStats.experience) / PlayerStats.get_level_expcap(), 0.0, 1.0);
