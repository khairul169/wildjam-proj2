extends Node2D

# refs
onready var scene = get_node("/root/scene");
onready var body = $body;
onready var base_animplayer = $AnimationPlayer;
onready var anims: AnimationPlayer = $body.find_node("AnimationPlayer");

# res
onready var scene_healthbar = load("res://scenes/combat/battler_healthbar.tscn");

# stats
var speed = 100.0;
var health = 100.0;
var damage = 10.0;
var attack_speed = 1.0;
var attack_range = 800.0;
var evasion = 0.2;

# vars
var move_dir = Vector2.ZERO;
var next_think = 0.0;
var target: Node2D;
var team = 0;
var range_bonus = 0.0;
var cur_health = 0.0;
var health_bar: Control;

func _ready() -> void:
	if (!scene):
		return;
	
	# register cat
	add_to_group(scene.BATTLER_GROUP);
	
	# add healthbar
	if (scene_healthbar):
		health_bar = scene_healthbar.instance();
		add_child(health_bar);
	
	# set health to max
	if (cur_health <= 0.0):
		cur_health = health;
	update_ui();

func _process(delta: float) -> void:
	if (next_think > 0.0):
		next_think -= delta;
	else:
		next_think = 0.1;
		# do process
		cat_think();
	
	# move the cat
	if (move_dir.length() > 0.1 && is_alive()):
		body.scale.x = sign(move_dir.x);
		transform.origin += move_dir * delta * speed;

func set_animation(anim: String, force: bool = false, speed: float = 1.0, blend_time: float = -1.0):
	if (!anims):
		return;
	
	if (force || anims.current_animation != anim):
		anims.play(anim, blend_time, speed);

func get_team() -> int:
	return team;

func is_alive() -> bool:
	return cur_health > 0.0;

func find_enemy() -> Node2D:
	if (target):
		return target;
	
	var cur_target: Node2D = null;
	var cur_distance: float = -1.0;
	
	for enemy in get_tree().get_nodes_in_group(scene.BATTLER_GROUP):
		# check team
		if (!enemy.has_method('get_team') || enemy.get_team() == get_team()):
			continue;
		
		# ignore dead enemy
		if (enemy.has_method('is_alive') && !enemy.is_alive()):
			continue;
		
		var distance = global_transform.origin.distance_to(enemy.global_transform.origin);
		if (cur_distance >= 0.0 && distance >= cur_distance):
			continue;
		
		# set target
		cur_target = enemy;
		cur_distance = distance;
	
	return cur_target;

func cat_think() -> void:
	# reset movement
	move_dir = Vector2.ZERO;
	
	if (!is_alive()):
		clean_corpse();
		return;
	
	# search enemy
	if (!target):
		set_animation('idle-hg');
		
		target = find_enemy();
		next_think = 0.1;
		return;
	else:
		if (!target.is_alive()):
			target = null;
			return;
	
	var enemy_distance = global_transform.origin.distance_to(target.global_transform.origin);
	if (enemy_distance > attack_range + range_bonus):
		# move player to target
		move_dir = Vector2(sign(target.global_transform.origin.x-global_transform.origin.x), 0.0);
		set_animation('run-hg');
		next_think = 0.2;
	
	else:
		# attack target
		set_animation('shoot-hg', true);
		attack_enemy(target);
		next_think = attack_speed + (randf() * 0.1);

func attack_enemy(enemy: Node2D) -> void:
	if (!enemy || !enemy.is_alive()):
		return;
	
	if (enemy.has_method('give_damage')):
		var dmg = damage + (randf() * 2.0);
		enemy.give_damage(self, dmg);

func give_damage(attacker: Node2D, dmg: float) -> void:
	if (cur_health <= 0.0):
		return;
	
	# evade attack
	if (randf() < evasion):
		return;
	
	cur_health = max(cur_health - dmg, 0.0);
	update_ui();
	
	base_animplayer.play("damaged");
	
	if (cur_health <= 0.0):
		set_animation('dying', true);
		next_think = 2.0;
		
		if (scene):
			# tell scene that this battler are died
			scene.emit_signal("battler_died", self);

func clean_corpse() -> void:
	# remove corpse from world
	set_animation('corpse-fadeout', true);
	set_process(false);

func update_ui() -> void:
	if (health_bar):
		if (cur_health <= 0.0 || cur_health >= health):
			health_bar.visible = false;
		else:
			health_bar.visible = true;
			health_bar.get_node("bar").rect_size.x = health_bar.rect_size.x * clamp(cur_health / health, 0.0, 1.0);
