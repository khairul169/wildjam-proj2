extends Area2D

# enums
enum ActionType {
	NONE = 0,
	COMBAT,
	ENCHANTMENT,
	SHOP,
	STATS,
	SKILLS,
	HEADQUARTER
};

# exports
export (ActionType) var action_type = ActionType.NONE;

func _ready() -> void:
	pass
