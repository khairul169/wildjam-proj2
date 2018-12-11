extends Node2D

# exports
export (Color) var skin_color = Color(1, 1, 1);
export var _randomize_color = false;
export (NodePath) var _body;
export (NodePath) var _head;
export (NodePath) var _hand_l;
export (NodePath) var _hand_r;
export (NodePath) var _leg_l;
export (NodePath) var _leg_r;
export (NodePath) var _tail;

# enums
enum BodyPart {
	BODY = 0,
	HEAD,
	HAND_LEFT,
	HAND_RIGHT,
	LEG_LEFT,
	LEG_RIGHT,
	TAIL,
	
	MAX
};

# vars
var body_parts = [];

func _ready():
	# init body part
	body_parts.resize(BodyPart.MAX);
	
	# get skin references
	body_parts[BodyPart.BODY] = get_node(_body);
	body_parts[BodyPart.HEAD] = get_node(_head);
	body_parts[BodyPart.HAND_LEFT] = get_node(_hand_l);
	body_parts[BodyPart.HAND_RIGHT] = get_node(_hand_r);
	body_parts[BodyPart.LEG_LEFT] = get_node(_leg_l);
	body_parts[BodyPart.LEG_RIGHT] = get_node(_leg_r);
	body_parts[BodyPart.TAIL] = get_node(_tail);
	
	# set own material
	for i in body_parts:
		if (!i || !i is CanvasItem || !i.material):
			continue;
		
		# set sprite modulate
		i.material = i.material.duplicate();
	
	# set base skin color
	if (_randomize_color):
		randomize_color();
	else:
		set_skin_color(skin_color);

func set_skin_color(col: Color) -> void:
	for i in body_parts:
		if (!i || !i is CanvasItem || !i.material):
			continue;
		
		# set sprite modulate
		i.material.set_shader_param('skin_color', col);

func randomize_color() -> void:
	var col = Color(1, 1, 1);
	col.r = 0.5 + (randf() * 0.5);
	col.g = 0.5 + (randf() * 0.5);
	col.b = 0.5 + (randf() * 0.5);
	set_skin_color(col);
