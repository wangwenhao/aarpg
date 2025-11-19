@tool
@icon("res://GUI/DialogSystem/Icons/star_bubble.svg")
class_name DialogSystemNode extends CanvasLayer

signal finished
signal letter_added(letter: String)

var is_active: bool = false
var text_in_progress: bool = false

var text_speed: float = 0.02
var text_length: int = 0
var plain_text: String = ""

var dialog_items: Array[DialogItem] = []
var dialog_item_index: int = 0


@onready var dialog_ui: Control = $DialogUI
@onready var content: RichTextLabel = $DialogUI/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogUI/NameLabel
@onready var portrait_sprite: DialogPortrait = $DialogUI/PortraitSprite
@onready var dialog_process_indicator: PanelContainer = $DialogUI/DialogProcessIndicator
@onready var dialog_process_indicator_label: Label = $DialogUI/DialogProcessIndicator/Label
@onready var timer: Timer = $DialogUI/Timer
@onready var audio_stream_player: AudioStreamPlayer = $DialogUI/AudioStreamPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
		return
	timer.timeout.connect(_on_timer_timeout)
	hide_dialog()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if (
		event.is_action_pressed("interact") or 
		event.is_action_pressed("attack") or
		event.is_action_pressed("ui_accept")
	):
		if text_in_progress:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			show_dialog_button_indicator(true)
			return
		dialog_item_index += 1
		if dialog_item_index < dialog_items.size():
			start_dialog()
		else:
			hide_dialog()


func show_dialog(items: Array[DialogItem]) -> void:
	is_active = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = items
	dialog_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	start_dialog()


func hide_dialog() -> void:
	is_active = false
	dialog_ui.visible = false
	dialog_ui.process_mode =Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()


func start_dialog() -> void:
	show_dialog_button_indicator(false)
	var item: DialogItem = dialog_items[dialog_item_index]
	set_dialog_data(item)
	
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()


func start_timer() -> void:
	timer.wait_time = text_speed
	var _char: String = plain_text[content.visible_characters - 1]
	if ".!?:;".contains(_char):
		timer.wait_time *= 4
	elif ", ".contains(_char):
		timer.wait_time *= 2
		
	timer.start()


func _on_timer_timeout() -> void:
	content.visible_characters += 1
	
	if content.visible_characters <= text_length:
		letter_added.emit(plain_text[content.visible_characters - 1])
		timer.start()
	else:
		show_dialog_button_indicator(true)
		text_in_progress = false


func set_dialog_data(item: DialogItem) -> void:
	if item is DialogText:
		content.text = item.text
	name_label.text = item.npc_info.npc_name
	portrait_sprite.texture = item.npc_info.portrait
	portrait_sprite.audio_pitch_base = item.npc_info.dialog_audio_pitch


func show_dialog_button_indicator(_is_visible: bool) -> void:
	dialog_process_indicator.visible = _is_visible
	if dialog_item_index + 1 < dialog_items.size():
		dialog_process_indicator_label.text = "NEXT"
	else:
		dialog_process_indicator_label.text = "END"
