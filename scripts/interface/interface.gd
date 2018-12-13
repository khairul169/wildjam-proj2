extends Control

# refs
onready var character_info = $hud/character_info;
onready var quest_panel = $panel/quest;
onready var lvl_name = $level_name;
onready var battle_condition = $hud/battle_condition;

func _ready():
	# hide all panel
	quest_panel.hide();
	lvl_name.hide();

func _process(delta: float) -> void:
	# player name
	character_info.get_node("name").text = PlayerStats.player_name;
	
	# player level
	character_info.get_node("level").text = str("Lvl ", PlayerStats.level);
	
	# health bar
	var health_bar = character_info.get_node("health/bar");
	health_bar.rect_size.x = (health_bar.get_parent().rect_size.x - 2.0) * clamp(PlayerStats.health / PlayerStats.get_max_health(), 0.0, 1.0);
	
	# experience
	var exp_bar = character_info.get_node("experience/bar");
	exp_bar.rect_size.x = (exp_bar.get_parent().rect_size.x - 2.0) * clamp(float(PlayerStats.experience) / PlayerStats.get_experience_cap(), 0.0, 1.0);

func show_level_name(name) -> void:
	if (!name || typeof(name) != TYPE_STRING || name.length() <= 0):
		return;
	
	lvl_name.get_node("name").text = name;
	lvl_name.get_node("AnimationPlayer").play("fade");
