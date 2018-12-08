extends KinematicBody2D

# consts
const SPEED = 250.0;

# refs
onready var body: Node2D = $body;
onready var anims: AnimationPlayer = body.find_node("AnimationPlayer");

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var move_dir: Vector2 = Vector2.ZERO;
	
	if (Input.is_key_pressed(KEY_W)):
		move_dir.y -= 1;
	if (Input.is_key_pressed(KEY_S)):
		move_dir.y += 1;
	if (Input.is_key_pressed(KEY_A)):
		move_dir.x -= 1;
	if (Input.is_key_pressed(KEY_D)):
		move_dir.x += 1;
	
	# normalize move dir
	move_dir = move_dir.normalized();
	
	var is_moving = move_dir.length() > 0.0;
	if (is_moving):
		# set body direction
		if (abs(move_dir.x) > 0.0):
			body.scale.x = sign(move_dir.x);
		
		# play run anims
		set_animation('run');
	else:
		# idle anims
		set_animation('idle');
	
	# move player!
	move_and_slide(move_dir * SPEED, Vector2(0, 0));

func set_animation(anim: String, force: bool = false, speed: float = 1.0, blend_time: float = -1.0):
	if (!anims):
		return;
	
	if (force || anims.current_animation != anim):
		anims.play(anim, blend_time, speed);
