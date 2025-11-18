@tool
@icon("res://GUI/DialogSystem/Icons/chat_bubbles.svg")
class_name DialogInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled: bool = true

var dialog_items: Array[DialogItem]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	for child in get_children():
		if child is DialogItem:
			dialog_items.append(child)
			
func _on_area_entered(_area: Area2D) -> void:
	if not enabled or dialog_items.size() == 0:
		return
	animation_player.play("show")
	PlayerManager.interact_pressed.connect(_player_interact)
	pass

func _on_area_exited(_area: Area2D) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect(_player_interact)
	pass

func _player_interact() -> void:
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.show_dialog(dialog_items)
	DialogSystem.finished.connect(_on_dialog_finished)
	pass
	
func _get_configuration_warnings() -> PackedStringArray:
	if not _check_for_dialog_items():
		return ["Require at least one DialogItem node."]
	else:
		return []

func _check_for_dialog_items() -> bool:
	for child in get_children():
		if child is DialogItem:
			return true
	return false

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
