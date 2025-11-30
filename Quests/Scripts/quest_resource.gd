extends Resource
class_name Quest

@export var title: String
@export_multiline var descrition: String
@export var steps: Array[String]
@export var reward_xp: int
@export var reward_items: Array[QuestRewardItem] = []
