extends Reference

# consts
const mainquest_dir = 'main_quest/';

func setup_quest(world: Node):
	if (!world || !world.has_method('register_quest')):
		return;
	
	# Chapter 1
	world.register_quest(world.QUEST_MAIN, "Pertama", main_quest(1, 1), 200);
	world.register_quest(world.QUEST_MAIN, "Kedua", main_quest(1, 1), 300);
	world.register_quest(world.QUEST_MAIN, "Ketiga", main_quest(1, 1), 400);
	world.register_quest(world.QUEST_MAIN, "Keempat", main_quest(1, 1), 500);
	world.register_quest(world.QUEST_MAIN, "Kelima", main_quest(1, 1), 800);

func main_quest(chapter: int, id: int) -> String:
	return mainquest_dir + str(chapter, '_', id);
