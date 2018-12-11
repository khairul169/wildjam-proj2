extends StaticBody2D

# exports
export var enemy_level = 1;
export var enemy_count = 1;

func _ready():
	# set npc name
	$npc_name/text.text = str("Level ", enemy_level, " Bandit Catto");
	$npc_name.show();

func get_data() -> Dictionary:
	return {
		'level': enemy_level,
		'count': enemy_count
	};
