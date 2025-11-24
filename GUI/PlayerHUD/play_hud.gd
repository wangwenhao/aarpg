extends CanvasLayer

@export var button_focus_audio: AudioStream = preload("res://TitleScene/Audio/menu_focus.wav")
@export var button_press_audio: AudioStream = preload("res://TitleScene/Audio/menu_select.wav")

var hearts: Array[HeartGUI] = []

@onready var game_over: Control = $Control/GameOver
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in $Control/HFlowContainer.get_children().filter(func(child): return child is HeartGUI):
		hearts.append(child)
		child.visible = false
	
	hide_game_over_screen()
	continue_button.focus_entered.connect(play_audio.bind(button_focus_audio))
	title_button.focus_entered.connect(play_audio.bind(button_focus_audio))
	title_button.pressed.connect(title_screen)
	continue_button.pressed.connect(load_game)
	LevelManager.level_load_started.connect(hide_game_over_screen)

func update_hp(hp: int, max_hp: int) -> void:
	update_max_hp(max_hp)
	for index in max_hp:
		update_heart(index, hp)

func update_heart(index: int, hp: int) -> void:
	var value: int = clampi(hp - index * 2, 0, 2)
	hearts[index].value = value
	pass

func update_max_hp(max_hp: int) -> void:
	var heart_count: int = roundi(max_hp * 0.5)
	for i in hearts.size():
		if i < heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func play_audio(audio: AudioStream) -> void:
	audio_player.stream = audio
	audio_player.play()

func load_game() -> void:
	play_audio(button_press_audio)
	await fade_to_black()
	SaveManager.load_game()

func fade_to_black() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	PlayerManager.player.revive_player()
	return true

func title_screen() -> void:
	play_audio(button_press_audio)
	await fade_to_black()
	LevelManager.load_new_level("res://TitleScene/title_scene.tscn", "", Vector2.ZERO)
	
func show_game_over_screen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var can_continue: bool = SaveManager.get_save_file() != null
	continue_button.visible = can_continue
	
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	
	if can_continue:
		continue_button.grab_focus()
	else:
		title_button.grab_focus()


func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1, 1, 1, 0)
