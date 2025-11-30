extends Node

signal quest_updated(quest)

const QUEST_DATA_LOCATION: String = "res://Quests/"

var quests: Array[Quest]
var current_quests: Array = []

func _ready() -> void:
	gather_quest_data()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		#print(find_quest(load("res://Quests/recover_lost_flute.tres") as Quest))
		#print(find_quest_by_title("Short Quest"))
		#print(get_quest_index_by_title("Recover Lost Magical Flute"))
		update_quest("short quest")
		update_quest("Recover Lost Magical Flute", "Find the Magical Flute")
		update_quest("long quest", "", true)
		print(current_quests)
	pass


func gather_quest_data() -> void:
	var quest_files: PackedStringArray = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for _quest in quest_files:
		quests.append(load(QUEST_DATA_LOCATION + "/" + _quest) as Quest)
	

func update_quest(_title: String, _completed_step: String = "", _is_complete: bool = false) -> void:
	var quest_index: int = get_quest_index_by_title(_title)
	if quest_index == -1:
		var new_quest: Dictionary = {
			title = _title,
			is_completed = _is_complete,
			completed_steps = []
		}
		if _completed_step != "":
			new_quest.completed_steps.append(_completed_step)
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)
	else:
		var q = current_quests[quest_index]
		if _completed_step != "" and not q.completed_steps.has(_completed_step):
			q.completed_steps.append(_completed_step)
		q.is_completed = _is_complete
		
		quest_updated.emit(q)
		
		if q.is_completed:
			disperse_quest_rewards(find_quest_by_title(q.title))
	pass
	
func disperse_quest_rewards(_quest: Quest) -> void:
	PlayerManager.reward_xp(_quest.reward_xp)
	for _item in _quest.reward_items:
		PlayerManager.INVENTORY_DATA.add_item(_item.item, _item.quantity)
	pass
	
func find_quest(_quest: Quest) -> Dictionary:
	for _q in current_quests:
		if _q.title == _quest.title:
			return _q
	return {title = "not found", is_completed = false, completed_steps = [''] }
	
func find_quest_by_title(_title: String) -> Quest:
	for _q in quests:
		if _q.title.to_lower() == _title.to_lower():
			return _q
	return null
	
func get_quest_index_by_title(_title: String) -> int:
	for _i in current_quests.size():
		if current_quests[_i].title.to_lower() == _title.to_lower():
			return _i
	return -1
	
func sort_quests() -> void:
	var active_quests: Array = []
	var completed_quests: Array = []
	for _q in current_quests:
		if _q.is_completed:
			completed_quests.append(_q)
		else:
			active_quests.append(_q)
			
	active_quests.sort_custom(func(a, b): return a.title < b.title)
	completed_quests.sort_custom(func(a, b): return a.title < b.title)
	print(active_quests)
	print(completed_quests)
	current_quests = active_quests
	current_quests.append_array(completed_quests)
	pass
