extends Control

# refs
onready var character_info = $hud/character_info;
onready var panel_menu = $panel/menu;
onready var panel_quest = $panel/quest;
onready var panel_stats = $panel/stats;
onready var lvl_name = $level_name;
onready var battle_condition = $hud/battle_condition;

# panels
enum {
	PANEL_MENU = 0,
	PANEL_QUEST,
	PANEL_STATS
};

func _ready():
	# hide all panel
	show_panel(-1);
	lvl_name.hide();

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && event.pressed):
		if (event.scancode == KEY_ESCAPE):
			if (panel_menu.visible):
				show_panel(-1);
			else:
				show_panel(PANEL_MENU);
		
		if (event.scancode == KEY_TAB):
			if (panel_stats.visible):
				show_panel(-1);
			else:
				show_panel(PANEL_STATS);

func show_panel(panel: int) -> void:
	if (panel == PANEL_MENU):
		panel_menu.show();
	else:
		panel_menu.hide();
	
	if (panel == PANEL_QUEST):
		panel_quest.show();
	else:
		panel_quest.hide();
	
	if (panel == PANEL_STATS):
		panel_stats.show();
	else:
		panel_stats.hide();

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
