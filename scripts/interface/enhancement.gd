extends Control

# vars
var cur_wpn = -1;

func _ready():
	# default weapon
	cur_wpn = 0;
	hide();
	
	$btn_exit.connect("pressed", self, "hide");
	$btn_enhance.connect("pressed", self, "enhance_weapon");

func show() -> void:
	.show();
	
	# refresh data
	cur_wpn = 0;
	update_interface();

func update_interface() -> void:
	if (cur_wpn < 0):
		return;
	
	var money = PlayerStats.money;
	$money.text = str("$", int(max(money, 0.0)));
	
	var enhancement_lvl = PlayerStats.get_weapon_enhancement(cur_wpn);
	if (enhancement_lvl > 0):
		$wpnname.text = str("Handgun (+", enhancement_lvl, ")");
	else:
		$wpnname.text = str("Handgun");
	
	var enhance_cost = get_enhancement_cost(enhancement_lvl);
	$btn_enhance.text = str("Enhance ($", enhance_cost, ")");
	
	var wpn_data = PlayerStats.get_weapon_data(cur_wpn);
	if (wpn_data.has('damage')):
		$dmg.text = str(": ", int(wpn_data.damage));
	if (wpn_data.has('rof')):
		$rof.text = str(": ", int(60.0 / wpn_data.rof));

func get_enhancement_cost(lvl) -> int:
	return 100 + (lvl * 36);

func enhance_weapon() -> void:
	if (cur_wpn < 0 || !PlayerStats.has_weapon(cur_wpn)):
		return;
	
	var cur_enhancement = PlayerStats.get_weapon_enhancement(cur_wpn);
	if (cur_enhancement >= PlayerStats.MAX_ENHANCEMENT):
		return;
	
	var cost = get_enhancement_cost(cur_enhancement);
	if (PlayerStats.remove_money(cost)):
		PlayerStats.add_weapon_enhancement(cur_wpn);
		
		# update ui
		update_interface();
