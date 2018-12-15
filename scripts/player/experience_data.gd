extends Reference

# experience gain
var exp_clear_combat = 60.0;
var exp_enemy_per_lvl = 10.0;
var exp_enemy_per_num = 20.0;

# experience needed to level up
var exp_cap = [
	200,			# 1
	800,
	1600,
	2000,
	2600,			# 5
	3000,
	5000,
	8000,
	10000,
	12000,			# 10
	13000,
	15000,
	16000,
	18000,
	20000,			# 15
	21000,
	22000,
	24000,
	28000,
	30000,			# 20
	32000,
	34000,
	35000,
	36000,
	38000,			# 25
	40000,
	42000,
	44000,
	45000,
	46000			# 30
];

func calculate_exp_combat(num, level) -> int:
	return exp_clear_combat + (num * exp_enemy_per_num) + (level * exp_enemy_per_lvl);

func get_experience_cap(level: int) -> int:
	level -= 1;
	if (level < 0 || level >= exp_cap.size()):
		return 0;
	return exp_cap[level];

func get_max_level() -> int:
	return exp_cap.size();
