class_name StateStun extends State

@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0
@export var invulnerable_duration: float = 1.0

var hurt_box: HurtBox
var direction: Vector2
var next_state: State = null

func init() -> void:
	player.player_damaged.connect(on_player_damaged)


func enter() -> void:
	player.animation_player.animation_finished.connect(on_animation_finished)
	
	direction = player.global_position.direction_to(hurt_box.global_position)
	player.velocity = direction * -knockback_speed
	player.set_direction()
	
	player.update_animation("stun")
	
	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	
	PlayerManager.shake_camera( hurt_box.damage )


func exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect(on_animation_finished)


func process(delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * delta
	return next_state


func physics_process(_delta: float) -> State:
	return null


func handle_input(_event: InputEvent) -> State:
	return null


func on_player_damaged(_hurt_box: HurtBox) -> void:
	hurt_box = _hurt_box
	if state_machine.current_state != death:
		state_machine.change_state(self)


func on_animation_finished(_animation_name) -> void:
	next_state = idle
	if player.hp <= 0:
		next_state = death
