extends Node

# consts
const BATTLER_GROUP = 'cats';

# enums
enum Team {
	NONE = 0,
	PLAYER,
	ENEMY
}

# signals
signal scene_ready();
signal battler_died(who);

# vars
var combat_running = false;

func _ready() -> void:
	connect("battler_died", self, "_battler_died");
	emit_signal("scene_ready");
	
	# set combat as running
	combat_running = true;

func _battler_died(who) -> void:
	if (!combat_running):
		return;
	
	# check for team alive member
	var total_alive = {'player': 0, 'enemy': 0};
	
	for i in get_tree().get_nodes_in_group(BATTLER_GROUP):
		if (!i.has_method('is_alive') || !i.is_alive()):
			continue;
		
		if (!i.has_method('get_team')):
			continue;
		
		match (i.get_team()):
			Team.PLAYER:
				total_alive.player += 1;
			Team.ENEMY:
				total_alive.enemy += 1;
	
	if (total_alive.enemy <= 0):
		end_combat(true);
	elif (total_alive.player <= 0):
		end_combat(false);

func end_combat(win: bool) -> void:
	if (!combat_running):
		return;
	
	print("Combat end: ", win);
