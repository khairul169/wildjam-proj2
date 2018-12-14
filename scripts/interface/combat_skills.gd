extends Control

# definition
const SKILL_INPUT = [
	[KEY_Q, 'Q'],
	[KEY_W, 'W'],
	[KEY_E, 'E']
];

# signals
signal skill_activated(id);

# refs
onready var skill_list = $container;
onready var skill_item = $container/skill;

# vars
var skills = [];
var skill_shortcut = {};
var cooldown = [];

func _ready():
	# initialize skill item
	skill_item.get_parent().remove_child(skill_item);
	
	# clear current skills
	for i in skill_list.get_children():
		i.queue_free();

func _input(event: InputEvent) -> void:
	# keyboard skill shortcut
	if (event is InputEventKey && event.pressed):
		if (skill_shortcut.has(event.scancode)):
			activate_skill(skill_shortcut[event.scancode]);

func _process(delta: float) -> void:
	for i in range(0, cooldown.size()):
		if (cooldown[i] > 0.0):
			cooldown[i] = max(cooldown[i] - delta, 0.0);
		update_cooldown_ui(i);

func update_cooldown_ui(i) -> void:
	if (i < 0 || i >= skills.size() || !skills[i].has('instance')):
		return;
	
	var instance = skills[i].instance;
	
	if (cooldown[i] > 0.0):
		instance.get_node("icon").modulate = Color(0.8, 0.8, 0.8);
		instance.get_node("cd").visible = true;
		instance.get_node("cd").text = str(int(ceil(cooldown[i])));
	else:
		instance.get_node("icon").modulate = Color(1, 1, 1);
		instance.get_node("cd").visible = false;

func set_skills(skills_data: Array) -> void:
	# clear current skills
	skill_shortcut.clear();
	
	# remove all skills button
	for i in skill_list.get_children():
		i.queue_free();
	
	# set skills item
	skills = skills_data;
	cooldown.clear();
	
	for i in range(0, skills.size()):
		var instance = skill_item.duplicate();
		skill_list.add_child(instance);
		skills[i]['instance'] = instance;
		
		# skill data
		var skill = skills[i];
		var is_passive = false;
		
		if (skill.has('passive')):
			is_passive = skill.passive;
		
		var cooldown_time = 0.0;
		if (skill.has('initial_cd')):
			cooldown_time = skill.initial_cd;
		elif (skill.has('cd')):
			cooldown_time = skill.cd;
		
		# add cd timer
		cooldown.append(cooldown_time);
		
		# icon
		if (skill.has('icon')):
			instance.get_node("icon").texture = skill.icon;
		else:
			instance.get_node("icon").hide();
		
		# button signal
		if (!is_passive):
			instance.connect("pressed", self, "activate_skill", [i]);
		
		# add skill shortcut
		if (!is_passive && i >= 0 && i < SKILL_INPUT.size()):
			var key = SKILL_INPUT[i];
			skill_shortcut[key[0]] = i;
			instance.get_node("key").text = str(key[1]);
		else:
			instance.get_node("key").hide();
		
		# skill description
		if (skill.has('desc')):
			instance.hint_tooltip = str(skill.desc);

func activate_skill(id) -> void:
	if (id < 0 || id >= cooldown.size() || id >= skills.size()):
		return;
	
	if (cooldown[id] > 0.0):
		return;
	
	# activate skill
	emit_signal("skill_activated", id);
	
	if (skills[id].has('cd')):
		cooldown[id] = skills[id].cd;
	else:
		cooldown[id] = 10.0;
