class_name EnemyStateStun extends EnemyState

@export var animation_name: String = "stun"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export_category("AI")
@export var next_state: EnemyState

var damage_position: Vector2
var direction: Vector2
var animation_finished: bool = false

func init() -> void:
	enemy.emeny_damaged.connect( on_enemy_damaged )

func enter() -> void:
	
	animation_finished = false
	enemy.invulnerable = true

	direction = enemy.global_position.direction_to(damage_position)
	
	enemy.set_direction(direction)
	enemy.velocity = direction * -knockback_speed
	
	enemy.update_animation(animation_name)
	enemy.animation_player.animation_finished.connect(on_animation_finished)

func exit() -> void:
	enemy.invulnerable = false
	enemy.animation_player.animation_finished.disconnect(on_animation_finished)
	pass

func process(delta: float) -> EnemyState:
	if animation_finished:
		return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * delta
	return null

func physics_process(_delta: float) -> EnemyState:
	return null

func handle_input(_event: InputEvent) -> EnemyState:
	return null
	
func on_enemy_damaged(hurt_box: HurtBox) -> void:
	damage_position = hurt_box.global_position
	state_machine.change_state(self)
	
func on_animation_finished(_animation_name) -> void:
	animation_finished = true
