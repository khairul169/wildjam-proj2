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
	var player_alive = 0;
	var enemy_alive = 0;
	
	# loop through all battler
	for i in get_tree().get_nodes_in_group(BATTLER_GROUP):
		if (!i.has_method('is_alive') || !i.is_alive()):
			continue;
		
		if (!i.has_method('get_team')):
			continue;
		
		match (i.get_team()):
			Team.PLAYER:
				player_alive += 1;
			Team.ENEMY:
				enemy_alive += 1;
	
	# enemy wiped out
	if (enemy_alive <= 0):
		end_combat(true);
	
	# player lose
	elif (player_alive <= 0):
		end_combat(false);

func end_combat(win: bool) -> void:
	if (!combat_running):
		return;
	
	print("Combat end: ", win);
