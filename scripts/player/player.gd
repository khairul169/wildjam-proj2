extends KinematicBody2D

# consts
const SPEED = 250.0;

# refs
onready var body: Node2D = $body;
onready var anims: AnimationPlayer = body.find_node("AnimationPlayer");
onready var nav: Navigation2D = get_node("../nav");
onready var space_state: Physics2DDirectSpaceState = get_world_2d().direct_space_state;

# vars
var nav_path = [];

func _ready() -> void:
	if (anims):
		anims.playback_default_blend_time = 0.1;

func _unhandled_input(event: InputEvent) -> void:
	if (OS.has_touchscreen_ui_hint()):
		if (event is InputEventScreenTouch && event.pressed):
			_calculate_navpath();
	else:
		if (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed):
			_calculate_navpath();

func _calculate_navpath() -> void:
	# mouse global pos
	var pos = get_global_mouse_position();
	
	var test_intersect = space_state.intersect_point(pos, 4, [self]);
	if (test_intersect && test_intersect.size()):
		return;
	
	# set path
	nav_path = get_navpath_to(pos);

func get_navpath_to(pos: Vector2) -> Array:
	var path = [];
	if (nav):
		var start = nav.get_closest_point(global_transform.origin);
		path = Array(nav.get_simple_path(start, nav.get_closest_point(pos)));
		path.remove(0);
	else:
		path.append(pos);
	return path;

func _physics_process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO;
	var input: Vector2 = Vector2.ZERO;
	
	# calculate velocity from nav
	if (nav_path.size()):
		var next_path = Vector2.ZERO;
		if (global_transform.origin.distance_to(nav_path[0]) <= SPEED * delta):
			if (nav_path.size() > 1):
				next_path = nav_path[1];
			nav_path.remove(0);
		else:
			next_path = nav_path[0];
		
		if (next_path.length() > 0.0):
			velocity = next_path - global_transform.origin;
			velocity = velocity.normalized();
	
	# player movement
	if (Input.is_key_pressed(KEY_W)):
		input.y -= 1;
	if (Input.is_key_pressed(KEY_S)):
		input.y += 1;
	if (Input.is_key_pressed(KEY_A)):
		input.x -= 1;
	if (Input.is_key_pressed(KEY_D)):
		input.x += 1;
	
	# normalize move dir
	if (input.length() > 0.0):
		nav_path.clear();
		velocity = input.normalized();
	
	var is_moving = velocity.length() > 0.0;
	if (is_moving):
		# set body direction
		if (abs(velocity.x) > 0.0):
			body.scale.x = sign(velocity.x);
		
		# play run anims
		set_animation('run-hg');
	else:
		# idle anims
		set_animation('idle-hg');
	
	# move player!
	move_and_slide(velocity * SPEED, Vector2(0, 0));

func set_animation(anim: String, force: bool = false, speed: float = 1.0, blend_time: float = -1.0):
	if (!anims):
		return;
	
	if (force || anims.current_animation != anim):
		anims.play(anim, blend_time, speed);
