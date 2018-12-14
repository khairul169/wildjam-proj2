extends Control

# refs
onready var scene = get_node("/root/scene");
onready var stats_list = $list;

# res
onready var stats_item = $list/item;

func _ready():
	# set skill item as placeholder node
	if (stats_item):
		stats_item.get_parent().remove_child(stats_item);
	
	# signals
	PlayerStats.connect("stats_updated", self, "update_interface");
	
	# exit btn
	$btn_exit.connect("pressed", self, "hide");

func show() -> void:
	.show();
	
	# refresh listing
	update_interface();

func update_interface() -> void:
	# remove current item
	for i in stats_list.get_children():
		i.queue_free();
	
	# available stats point
	$sp.text = str("Points Available: ", int(PlayerStats.stats_point));
	
	# get stats data
	var stats = PlayerStats.get_player_stats();
	
	for i in stats:
		var instance = stats_item.duplicate();
		stats_list.add_child(instance);
		
		# set label text
		instance.get_node("title").text = i.title;
		instance.get_node("sp").text = str(int(i.point), "/", PlayerStats.MAX_STATS_POINT);
		
		# progress
		var progress_width = instance.get_node("progress").rect_size.x - 20;
		instance.get_node("progress/bar").rect_size.x = 20 + progress_width * (float(i.point) / PlayerStats.MAX_STATS_POINT);
		
		# button
		instance.connect("pressed", self, "_add_point", [i.id]);

func _add_point(id: int) -> void:
	PlayerStats.allocate_stats_point(id);
