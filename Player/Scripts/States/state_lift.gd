extends State
class_name StateLift


@export var lift_audio: AudioStream


func enter() -> void:
	player.update_animation("lift")
	player.animation_player.animation_finished.connect(state_complete)
	player.audio.stream = lift_audio
	player.audio.play()


func state_complete(_name: String) -> void:
	player.animation_player.animation_finished.disconnect(state_complete)
	state_machine.change_state(carry)

func exit() -> void:
	pass

func process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null
