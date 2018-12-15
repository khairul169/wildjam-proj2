extends KinematicBody2D

# consts
const SPEED = 250.0;
const MIN_ACTION_DISTANCE = 120.0;
const ACTION_AREA = preload("res://scripts/npc/action_area.gd");

# refs
onready var scene: Node = get_node("/root/scene");
onready var body: Node2D = $body;
onready var anims: AnimationPlayer = body.find_node("AnimationPlayer");
onready var space_state: Physics2DDirectSpaceState = get_world_2d().direct_space_state;
onready var camera: Camera2D = $camera;

# vars
var nav: Navigation2D;
var nav_path = [];
var action_target: Node2D;

func _ready() -> void:
	if (camera && scene && scene.level):
		# get camera limit from level
		var map_limit = scene.level.map_limit;
		
		# set camera limit
		if (map_limit.length() > 0.0):
			camera.limit_right = int(map_limit.x);
			camera.limit_bottom = int(map_limit.y);
	
	if (anims):
		# set default blend time
		anims.playback_default_blend_time = 0.1;

func _process(delta: float) -> void:
	# regenerate health
	if (PlayerStats.health < PlayerStats.get_max_health()):
		PlayerStats.health = clamp(PlayerStats.health + 1.0 * delta, 0.0, PlayerStats.get_max_health());

func _unhandled_input(event: InputEvent) -> void:
	if (OS.has_touchscreen_ui_hint()):
		if (event is InputEventScreenTouch && event.pressed):
			_calculate_navpath();
	else:
		if (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed):
			_calculate_navpath();

func _reset_navpath() -> void:
	# reset target action
	action_target = null;
	
	# clear navigation
	nav_path.clear();
	
func _calculate_navpath() -> void:
	_reset_navpath();
	
	# mouse global pos
	var dest_pos = get_global_mouse_position();
	
	var test_intersect = space_state.intersect_point(dest_pos, 4, [self], 2147483647, true, true);
	if (test_intersect && test_intersect.size()):
		var interupt = true;
		for i in test_intersect:
			if (i.collider is ACTION_AREA):
				action_target = i.collider;
				interupt = false;
				break;
		if (interupt):
			return;
	
	# set path
	nav_path = get_navpath_to(dest_pos);

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
	
	# player movement
	if (Input.is_action_pressed("move_up")):
		input.y -= 1;
	if (Input.is_action_pressed("move_down")):
		input.y += 1;
	if (Input.is_action_pressed("move_left")):
		input.x -= 1;
	if (Input.is_action_pressed("move_right")):
		input.x += 1;
	
	# normalize move dir
	if (input.length() > 0.0):
		_reset_navpath();
		velocity = input.normalized();
	
	if (action_target && nav_path.size()):
		var target_distance = global_transform.origin.distance_to(action_target.global_transform.origin);
		if (target_distance <= MIN_ACTION_DISTANCE):
			execute_action(action_target.action_type, action_target);
			_reset_navpath();
			action_target = null;
	
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

func execute_action(action_type, object) -> void:
	if (!scene):
		return;
	
	match (action_type):
		ACTION_AREA.ActionType.COMBAT:
			scene.start_combat(object.get_parent());
		
		ACTION_AREA.ActionType.SHOP:
			print("SHOP");
		
		ACTION_AREA.ActionType.STATS:
			scene.interface.stats_panel.show();
		
		ACTION_AREA.ActionType.SKILLS:
			print("SKILLS");
		
		ACTION_AREA.ActionType.QUEST:
			if (scene.interface):
				scene.interface.show_panel(scene.interface.PANEL_QUEST);
