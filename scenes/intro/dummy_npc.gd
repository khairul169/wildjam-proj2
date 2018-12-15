extends Node2D

enum State {
	NONE = 0,
	SHOOTING,
	DYING
};

export (State) var state = State.NONE;

onready var anims = find_node("AnimationPlayer");

var next_think = 0.0;
var last_pos = Vector2.ZERO;

func _ready():
	last_pos = transform.origin;

func _process(delta: float) -> void:
	if (next_think > 0.0):
		next_think -= delta;
		return;
	
	if (state == State.DYING):
		set_animation('dying');
		set_process(false);
		return;
	
	if (state == State.SHOOTING):
		set_animation('shoot-hg', true);
		next_think = 0.9;
		return;
	
	var delta_pos = transform.origin - last_pos;
	if (delta_pos.length() > 0.1):
		set_animation('run-hg');
		scale.x = abs(scale.x) * sign(delta_pos.x);
	else:
		set_animation('idle-hg');
	last_pos = transform.origin;

func set_animation(anim: String, force: bool = false, speed: float = 1.0, blend_time: float = -1.0):
	if (!anims):
		return;
	
	if (force || anims.current_animation != anim):
		anims.play(anim, blend_time, speed);
