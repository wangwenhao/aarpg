extends CanvasLayer

signal shown
signal hidden

@onready var button_save: Button = %Button_Save
@onready var button_load: Button = %Button_Load
@onready var button_quit: Button = %Button_Quit
@onready var item_description: Label = %ItemDescription
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer

var is_paused: bool = false

func _ready() -> void:
	hide_pause_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused:
			hide_pause_menu()
		else:
			if DialogSystem.is_active:
				return
			show_pause_menu()
		get_viewport().set_input_as_handled()
		
	if is_paused:
		if event.is_action_pressed("right_bumper"):
			change_tab(1)
		elif event.is_action_pressed("left_bumper"):
			change_tab(-1)
			
func change_tab(_i: int = 1) -> void:
	tab_container.current_tab = wrapi(
		tab_container.current_tab + _i,
		0,
		tab_container.get_tab_count()
	)
	tab_container.get_tab_bar().grab_focus()

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	tab_container.current_tab = 0
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


func _on_button_quit_pressed() -> void:
	get_tree().quit()
