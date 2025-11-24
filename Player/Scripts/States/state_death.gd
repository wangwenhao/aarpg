extends State
class_name StateDeath

@export var exhaust_audio: AudioStream
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

func init() -> void:
	pass

func _ready() -> void:
	pass

func enter() -> void:
	player.animation_player.play("death")
	audio.stream = exhaust_audio
	audio.play()
	PlayerHud.show_game_over_screen()
	AudioManager.play_music(null)
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null
