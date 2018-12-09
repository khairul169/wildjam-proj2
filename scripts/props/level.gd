extends Node2D

# exports
export var level_name = "";
export (NodePath) var _spawn_pos;
export (NodePath) var _map_limit;
export (NodePath) var _navigation;
export (NodePath) var _ysort;

# vars
var spawn_pos: Vector2;
var map_limit: Vector2;
var navigation: Navigation2D;
var ysort: YSort;

func _ready() -> void:
	if (_spawn_pos && _spawn_pos is NodePath):
		var spawn: Node2D = get_node(_spawn_pos);
		if (spawn):
			spawn_pos = spawn.global_transform.origin;
	
	if (_map_limit && _map_limit is NodePath):
		var limit: Node2D = get_node(_map_limit);
		if (limit):
			map_limit = limit.global_transform.origin;
	
	if (_navigation && _navigation is NodePath):
		navigation = get_node(_navigation);
	
	if (_ysort && _ysort is NodePath):
		ysort = get_node(_ysort);

func add_to_ysort(node: Node) -> void:
	if (ysort):
		ysort.add_child(node);
