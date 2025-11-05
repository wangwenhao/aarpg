class_name EnemyStateWander extends EnemyState

@export var animation_name: String = "walk"
@export var wander_speed: float = 30.0

@export_category("AI")
@export var state_animation_duration: float = 0.7
@export var state_cycles_min: int = 1
@export var state_cycles_max: int = 3
@export var next_state: EnemyState

var timer: float = 0.0
var direction: Vector2

func init() -> void:
	pass

func enter() -> void:
	timer = randi_range(state_cycles_min, state_cycles_max) * state_animation_duration
	var rand = randi_range(0, 3)
	direction = enemy.DIR_4[rand]
	enemy.velocity = direction * wander_speed
	enemy.set_direction(direction)
	enemy.update_animation(animation_name)

func exit() -> void:
	pass

func process(delta: float) -> EnemyState:
	timer -= delta
	if timer <= 0:
		return next_state
	return null

func physics_process(_delta: float) -> EnemyState:
	return null

func handle_input(_event: InputEvent) -> EnemyState:
	return null
