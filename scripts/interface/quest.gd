extends Control

# consts
const CONTAINER_H_MAIN = 330;
const CONTAINER_H_SIDE = 390;

# res
onready var scene_questitem = $container/quest_list/quest;

# refs
onready var scene = get_node("/root/scene");
onready var container = $container;
onready var node_quest = $container/quest_list;

# vars
var quest_list;

func _ready():
	# set quest container height
	container.rect_size.y = CONTAINER_H_MAIN;
	
	# set quest item as placeholder node
	scene_questitem.get_parent().remove_child(scene_questitem);
	
	if (scene):
		scene.connect("quest_updated", self, "quest_updated");
	
	# exit btn
	$btn_exit.connect("pressed", self, "hide");
	
	# chapter btn
	$chapters/chapter_list/chap1.connect("pressed", self, "select_chapter", [0]);
	#$chapters/chapter_list/chap2.connect("pressed", self, "select_chapter", [1]);

func display_quests(list: Array) -> void:
	for i in node_quest.get_children():
		i.queue_free();
	
	for i in range(0, list.size()):
		# instance quest item
		var instance = scene_questitem.duplicate();
		node_quest.add_child(instance);
		
		# set list item data
		instance.get_node("title").text = list[i].title;
		instance.get_node("caption").text = list[i].caption;
		
		if (list[i].lock):
			instance.mouse_default_cursor_shape = Control.CURSOR_ARROW;
			instance.get_node("bg").hide();
			instance.get_node("bg_lock").show();
			instance.disabled = true;
		else:
			instance.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
			instance.get_node("bg").show();
			instance.get_node("bg_lock").hide();
			instance.connect("pressed", self, "_quest_item_pressed", [i]);

func quest_updated() -> void:
	# update quest list
	select_chapter(0);

func _quest_item_pressed(id) -> void:
	if (!scene || id < 0 || id >= quest_list.size()):
		return;
	
	if (typeof(quest_list[id]) != TYPE_DICTIONARY || !quest_list[id].has('data')):
		return;
	
	if (!quest_list[id].has('lock') || quest_list[id].lock):
		return;
	
	var data = quest_list[id].data;
	if (scene.has_method('start_quest') && data.size() >= 2):
		if (data.size() > 2):
			scene.start_quest(data[0], data[1], data[2]);
		else:
			scene.start_quest(data[0], data[1]);

func select_chapter(chapter: int) -> void:
	if (!scene || !scene.has_method('get_quest_list')):
		return;
	
	var list = scene.get_quest_list();
	quest_list = [];
	
	if (list.has(scene.QUEST_MAIN)):
		if (chapter < 0 || chapter >= list[scene.QUEST_MAIN].size()):
			return;
		
		if (typeof(list[scene.QUEST_MAIN][chapter]) != TYPE_ARRAY):
			return;
		
		for id in range(0, list[scene.QUEST_MAIN][chapter].size()):
			var quest = list[scene.QUEST_MAIN][chapter][id];
			quest_list.append({
				'title': quest.title,
				'caption': quest.caption,
				'lock': quest.lock,
				'data': [scene.QUEST_MAIN, id, chapter]
			});
	
	# update quest
	display_quests(quest_list);
