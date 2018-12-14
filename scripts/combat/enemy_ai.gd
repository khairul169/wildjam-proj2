extends "res://scripts/combat/battler_ai.gd"

# stats
export var _health = 100.0;
export var _health_incremental = 10.0;
export var _damage = 10.0;
export var _damage_incremental = 10.0;
export var _attack_speed = 1.0;
export var _atkspd_incremental = 10.0;
export var _attack_range = 800.0;
export var _evasion = 0.2;

# vars
var level;

func _ready():
	pass

func calculate_stats() -> void:
	health = _health + (_health_incremental * (level - 1));
	cur_health = health;
	damage = _damage + (_damage_incremental * (level - 1));
	attack_speed = _attack_speed - (_atkspd_incremental * (level - 1));
	attack_range = _attack_range;
	evasion = _evasion;

func set_level(lvl: int) -> void:
	level = lvl;
	calculate_stats();
