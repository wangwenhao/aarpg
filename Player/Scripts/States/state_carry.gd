extends State
class_name StateCarry

@export var move_speed: float = 80
@export var throw_audio: AudioStream

var is_walking: bool = false
var throwable: Throwable

func init() -> void:
	pass

func _ready() -> void:
	pass

func enter() -> void:
	player.update_animation("carry")
	is_walking = false

func exit() -> void:
	if throwable:
		if player.direction == Vector2.ZERO:
			throwable.throw_direction = player.cardinal_direction
		else:
			throwable.throw_direction = player.direction
		
		if state_machine.next_state == stun:
			throwable.throw_direction = throwable.throw_direction.rotated(PI)
			throwable.drop()
		else:
			player.audio.stream = throw_audio
			player.audio.play()
			throwable.throw()


func process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		is_walking = false
		player.update_animation("carry")
	elif player.set_direction() or not is_walking:
		player.update_animation("carry_walk")
		is_walking = true
		
	player.velocity = player.direction * move_speed
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("interact") or _event.is_action_pressed("attack"):
		return idle
	return null
