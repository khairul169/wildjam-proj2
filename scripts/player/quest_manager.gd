extends Reference

# consts
const mainquest_dir = 'main_quest/';

func setup_quest(world: Node):
	if (!world || !world.has_method('register_quest')):
		return;
	
	# Chapter 1
	world.register_quest(world.QUEST_MAIN, "New Journey", main_quest(1, 1), 200);
	world.register_quest(world.QUEST_MAIN, "Second Attempt", main_quest(1, 2), 200);
	world.register_quest(world.QUEST_MAIN, "Deep Place", main_quest(1, 3), 300);
	world.register_quest(world.QUEST_MAIN, "The Hut", main_quest(1, 4), 400);
	world.register_quest(world.QUEST_MAIN, "Revenge", main_quest(1, 5), 500);
	
	# Chapter 2
	# can't, i don't have much time XD
	#world.register_quest(world.QUEST_MAIN, "Part 2: Pertama", main_quest(1, 1), 1000, true);
	#world.register_quest(world.QUEST_MAIN, "Part 2: Kedua", main_quest(1, 2), 1200);

func main_quest(chapter: int, id: int) -> String:
	return mainquest_dir + str('chapter', chapter, '/quest', id);
