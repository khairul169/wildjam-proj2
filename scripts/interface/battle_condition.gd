extends Control

# enums
enum {
	BATTLE_CLEAR = 0,
	BATTLE_FAILED,
	QUEST_CLEAR
};

func _ready():
	# hide hud
	hide();

func show_hud(condition: int) -> void:
	# set sprite visibility
	$base/clear.visible = (condition == BATTLE_CLEAR);
	$base/fail.visible = (condition == BATTLE_FAILED);
	$base/quest.visible = (condition == QUEST_CLEAR);
	
	# play animation
	$AnimationPlayer.play("fade");
