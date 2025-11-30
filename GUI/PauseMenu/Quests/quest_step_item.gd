extends Control
class_name QuestStepItem

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func initialize(step: String, is_completed: bool) -> void:
	label.text = step
	if is_completed:
		sprite.frame = 1
	else:
		sprite.frame = 0
