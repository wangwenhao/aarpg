extends CanvasLayer

signal shown
signal hidden

@onready var button_save: Button = %Button_Save
@onready var button_load: Button = %Button_Load
@onready var item_description: Label = $Control/ItemDescription
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_paused: bool = false

func _ready() -> void:
	hide_pause_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused:
			hide_pause_menu()
		else:
			show_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()


func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()


func _on_button_save_pressed() -> void:
	if !is_paused:
		return
	SaveManager.save_game()
	hide_pause_menu()


func _on_button_load_pressed() -> void:
	if !is_paused:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()

func update_item_description(text: String) -> void:
	item_description.text = text

func play_audio(audio: AudioStream) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
