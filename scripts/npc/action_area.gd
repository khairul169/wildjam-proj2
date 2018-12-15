extends Area2D

# enums
enum ActionType {
	NONE = 0,
	COMBAT,
	ENHANCEMENT,
	SHOP,
	SKILLS,
	QUEST
};

# exports
export (ActionType) var action_type = ActionType.NONE;

func _ready() -> void:
	pass
