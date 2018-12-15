extends Node

# consts
const MAX_LEVEL = 100;
const MAX_STATS_POINT = 10;
const MAX_ENHANCEMENT = 25;

const SAVEGAME_PATH = "user://save_game.dat";
const SAVEGAME_ENCRYPTED = false;
const SAVEGAME_KEY = "kkj8912kkl321";

const EXPERIENCE_DATA = preload("res://scripts/player/experience_data.gd");

# stats type
enum {
	STATS_STRENGTH = 0,
	STATS_POWER,
	STATS_AGILITY,
	STATS_INTELLIGENCE
};

# weapon list
enum {
	WPN_NONE = 0,
	WPN_HANDGUN
};

# player data
var player_name: String;
var health = 0.0;
var level: int;
var experience: int;
var stats_point: int;
var stats = {};
var quest_unlocked = {};
var money: int;
var weapon = [];
var savegame_loaded = false;
var exp_data: EXPERIENCE_DATA;

# signals
signal exp_updated();
signal stats_updated();

func _ready():
	# initialize experience data
	exp_data = EXPERIENCE_DATA.new();
	
	reset_data();

func _exit_tree() -> void:
	pass
	#if (savegame_loaded):
	#	save_game();

func reset_data() -> void:
	player_name = 'Khai';
	level = 1;
	health = get_max_health();
	experience = 0;
	stats_point = 0;
	stats[STATS_STRENGTH] = 0;
	stats[STATS_POWER] = 0;
	stats[STATS_AGILITY] = 0;
	stats[STATS_INTELLIGENCE] = 0;
	quest_unlocked = {};
	money = 0;
	weapon = [{
		'id': WPN_HANDGUN,
		'enhancement': 0
	}];

func save_game() -> void:
	var save_data = {};
	save_data['character'] = {
		'name': player_name,
		'hp': health,
		'level': level,
		'exp': experience,
		'sp': stats_point
	};
	save_data['stats'] = {
		'str': stats[STATS_STRENGTH],
		'pow': stats[STATS_POWER],
		'agi': stats[STATS_AGILITY],
		'int': stats[STATS_INTELLIGENCE]
	};
	save_data['quest'] = quest_unlocked;
	save_data['money'] = money;
	save_data['weapon'] = weapon;
	
	var encoded = to_json(save_data);
	var f = File.new();
	var err = -1;
	if (SAVEGAME_ENCRYPTED):
		err = f.open_encrypted_with_pass(SAVEGAME_PATH, File.WRITE, SAVEGAME_KEY);
	else:
		err = f.open(SAVEGAME_PATH, File.WRITE);
	
	if (err != OK):
		print("cannot save game!");
		return;
	
	f.store_string(encoded);
	f.close();
	savegame_loaded = true;

func has_savegame() -> bool:
	var f = File.new();
	return f.file_exists(SAVEGAME_PATH);

func load_game() -> void:
	var f = File.new();
	if (!f.file_exists(SAVEGAME_PATH)):
		return;
	var err = -1;
	if (SAVEGAME_ENCRYPTED):
		err = f.open_encrypted_with_pass(SAVEGAME_PATH, File.READ, SAVEGAME_KEY);
	else:
		err = f.open(SAVEGAME_PATH, File.READ);
	
	if (err != OK):
		print("cannot load game!");
		return;
	
	var content = f.get_as_text();
	f.close();
	
	var data = parse_json(content);
	if (typeof(data) != TYPE_DICTIONARY):
		print("cannot load savegame!");
		return;
	
	# reset player data
	reset_data();
	savegame_loaded = true;
	
	# load data
	if (data.has('character')):
		var char_data = data['character'];
		if (char_data.has('name')):
			player_name = char_data['name'];
		if (char_data.has('hp')):
			health = float(char_data['hp']);
		if (char_data.has('level')):
			level = int(char_data['level']);
		if (char_data.has('exp')):
			experience = int(char_data['exp']);
		if (char_data.has('sp')):
			stats_point = int(char_data['sp']);
	
	if (data.has('stats')):
		var stats_data = data['stats'];
		if (stats_data.has('str')):
			stats[STATS_STRENGTH] = int(stats_data['str']);
		if (stats_data.has('pow')):
			stats[STATS_POWER] = int(stats_data['pow']);
		if (stats_data.has('agi')):
			stats[STATS_AGILITY] = int(stats_data['agi']);
		if (stats_data.has('int')):
			stats[STATS_INTELLIGENCE] = int(stats_data['int']);
	
	if (data.has('quest')):
		quest_unlocked = data['quest'];
	
	if (data.has('money')):
		money = int(data['money']);
	
	if (data.has('weapon')):
		weapon = data['weapon'];
		for i in range(0, weapon.size()):
			weapon[i].id = int(weapon[i].id);
			weapon[i].enhancement = int(weapon[i].enhancement);

func get_stats_modifier(type: int) -> float:
	if (!stats.has(type)):
		return 1.0;
	
	var mod = 0.0;
	match (type):
		STATS_STRENGTH:
			mod = 1.0 + (float(stats[type]) / MAX_STATS_POINT * 1.0); 
		STATS_POWER:
			mod = 1.0 + (float(stats[type]) / MAX_STATS_POINT * 0.5); 
		STATS_AGILITY:
			mod = 1.0 + (float(stats[type]) / MAX_STATS_POINT * 1.0); 
	return mod;

func get_experience_modifier() -> float:
	return 1.0 + (float(level) / float(MAX_LEVEL) * float(MAX_LEVEL/2.0));

func get_experience_cap() -> int:
	return exp_data.get_experience_cap(level);

func get_max_health() -> float:
	var base_health = 100.0;
	base_health += 10 * level;
	if (stats.has(STATS_STRENGTH)):
		base_health = base_health + (stats[STATS_STRENGTH] * 40.0);
	return base_health;

func add_experience(points: int) -> void:
	if (level >= MAX_LEVEL || points <= 0):
		return;
	
	# add experience
	experience = experience + points;
	
	var exp_cap = get_experience_cap();
	if (experience >= exp_cap):
		# level up
		level = int(min(level + 1, MAX_LEVEL));
		experience = int(experience - exp_cap);
		stats_point += 1;
	
	emit_signal("exp_updated");

func combat_finished(win: bool, enemy_count: int, enemy_level: int) -> void:
	var exp_gain = exp_data.calculate_exp_combat(enemy_count, enemy_level);
	
	# reduce exp if lose
	if (!win):
		exp_gain *= 0.2;
	
	# give money
	var money_claimed = (exp_gain * 0.5) + int(rand_range(-10.0, 10.0));
	add_money(money_claimed);
	
	if (exp_gain > 0):
		add_experience(exp_gain);

func is_quest_cleared(type, id, chapter = null) -> bool:
	# variable is not valid
	if (!quest_unlocked || typeof(quest_unlocked) != TYPE_DICTIONARY):
		quest_unlocked = {};
	
	# convert type
	type = str('quest', type);
	id = str('i', id);
	
	if (typeof(chapter) == TYPE_INT):
		chapter = str('chapter', chapter);
	
	# check for quest type
	if (!quest_unlocked.has(type)):
		return false;
	
	if (chapter != null && quest_unlocked[type].has(chapter)):
		var quest_chapter = quest_unlocked[type][chapter];
		if (quest_chapter.has(id)):
			return true;
	else:
		if (quest_unlocked[type].has(id)):
			return true;
	return false;

func set_quest_clear(type, id, chapter = null) -> bool:
	if (is_quest_cleared(type, id, chapter)):
		return false;
	
	# convert type
	type = str('quest', type);
	id = str('i', id);
	
	if (typeof(chapter) == TYPE_INT):
		chapter = str('chapter', chapter);
		
		# new quest type
		if (!quest_unlocked.has(type)):
			quest_unlocked[type] = {};
		
		# create new chapter
		if (!quest_unlocked[type].has(chapter)):
			quest_unlocked[type][chapter] = [];
		
		# add to unlocked list
		quest_unlocked[type][chapter].append(id);
	else:
		# new quest type
		if (!quest_unlocked.has(type)):
			quest_unlocked[type] = [];
		
		# add to unlocked list
		quest_unlocked[type].append(id);
	
	save_game();
	return true;

func get_player_stats() -> Array:
	var st = [];
	st.append({
		'id': STATS_STRENGTH,
		'title': 'Strength',
		'point': int(clamp(stats[STATS_STRENGTH], 0, MAX_STATS_POINT))
	});
	st.append({
		'id': STATS_POWER,
		'title': 'Power',
		'point': int(clamp(stats[STATS_POWER], 0, MAX_STATS_POINT))
	});
	st.append({
		'id': STATS_AGILITY,
		'title': 'Agility',
		'point': int(clamp(stats[STATS_AGILITY], 0, MAX_STATS_POINT))
	});
	st.append({
		'id': STATS_INTELLIGENCE,
		'title': 'Intelligence',
		'point': int(clamp(stats[STATS_INTELLIGENCE], 0, MAX_STATS_POINT))
	});
	return st;

func allocate_stats_point(cat: int) -> void:
	if (stats_point <= 0 || !stats.has(cat)):
		return;
	
	if (stats[cat] >= MAX_STATS_POINT):
		return;
	
	# add point
	stats[cat] = int(clamp(stats[cat] + 1, 0, MAX_STATS_POINT));
	stats_point = int(max(stats_point - 1, 0));
	
	# restore health
	if (cat == STATS_STRENGTH):
		health = get_max_health();
	
	emit_signal("stats_updated");

func add_money(amount: int) -> void:
	if (amount <= 0):
		return;
	print("got money ", amount);
	money += amount;

func remove_money(amount: int) -> bool:
	if (amount <= 0 || money < amount):
		return false;
	money -= amount;
	return true;

func has_weapon(id: int) -> int:
	return (id >= 0 && id < weapon.size());

func weapon_by_id(weapon_id: int) -> int:
	for i in range(0, weapon):
		if (weapon[i].id == weapon_id):
			return i;
	return -1;

func get_weapon_data(id: int) -> Dictionary:
	if (id < 0 || id >= weapon.size()):
		return {};
	
	var base_dmg = 0.0;
	var dmg_increment = 0.0;
	var base_rof = 1.0;
	var rof_decrement = 0.0;
	
	match (weapon[id].id):
		WPN_HANDGUN:
			base_dmg = 8.0;
			dmg_increment = 32.0;
			base_rof = 1.0;
			rof_decrement = 0.3;
	
	var dmg = base_dmg + (dmg_increment * (weapon[id].enhancement / float(MAX_ENHANCEMENT)));
	var rof = base_rof - (rof_decrement * (weapon[id].enhancement / float(MAX_ENHANCEMENT)));
	
	return {
		'damage': dmg,
		'rof': rof
	};

func get_weapon_enhancement(id: int) -> int:
	if (id < 0 || id >= weapon.size()):
		return 0;
	return int(clamp(weapon[id].enhancement, 0, MAX_ENHANCEMENT));

func add_weapon_enhancement(id: int) -> void:
	if (id < 0 || id >= weapon.size()):
		return;
	
	if (weapon[id].enhancement < MAX_ENHANCEMENT):
		weapon[id].enhancement += 1;
