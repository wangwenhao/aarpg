extends Control
class_name QuestUI

const QUEST_ITEM: PackedScene = preload("res://GUI/PauseMenu/Quests/quest_item.tscn")
const QUEST_STEP_ITEM: PackedScene = preload("res://GUI/PauseMenu/Quests/quest_step_item.tscn")

@onready var quest_item_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var details_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	clear_quest_details()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	for i in quest_item_container.get_children():
		i.queue_free()
	
	clear_quest_details()
	if visible:
		QuestManager.sort_quests()
		print(QuestManager.current_quests)
		for _q in QuestManager.current_quests:
			var quest_data: Quest = QuestManager.find_quest_by_title(_q.title)
			if not quest_data:
				continue
			var new_quest_item = QUEST_ITEM.instantiate()
			quest_item_container.add_child(new_quest_item)
			new_quest_item.initialize(quest_data, _q)
			new_quest_item.focus_entered.connect(_update_quest_details.bind(new_quest_item.quest))


func _update_quest_details(_quest: Quest) -> void:
	clear_quest_details()
	title_label.text = _quest.title
	description_label.text = _quest.descrition
	
	var quest_save = QuestManager.find_quest(_quest)
	
	for step in _quest.steps:
		var new_step: QuestStepItem = QUEST_STEP_ITEM.instantiate()
		var step_is_complete: bool = false
		if quest_save.title != "not found":
			step_is_complete = quest_save.completed_steps.has(step.to_lower())
		details_container.add_child(new_step)
		new_step.initialize(step, step_is_complete)


func clear_quest_details() -> void:
	title_label.text = ""
	description_label.text = ""
	for child in details_container.get_children().filter(func(_c): return _c is QuestStepItem):
		child.queue_free()
