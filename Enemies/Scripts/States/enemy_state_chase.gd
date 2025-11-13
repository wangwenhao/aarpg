class_name EnemyStateChase extends EnemyState

@export var animation_name: String = "chase"
@export var chase_speed: float = 40.0
@export var turn_rate: float = 0.25

@export_category("AI")
@export var vision_area: VisionArea
@export var attack_area: HurtBox
@export var state_aggro_duration: float = 0.5
@export var next_state: EnemyState

var timer: float = 0.0
var direction: Vector2
var can_see_player: bool = false

func init() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)

func enter() -> void:
	timer = state_aggro_duration
	enemy.update_animation(animation_name)
	if attack_area:
		attack_area.monitoring = true

func exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	can_see_player = false

func process(delta: float) -> EnemyState:
	
	var new_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	direction = lerp(direction, new_direction, turn_rate)
	enemy.velocity = direction * chase_speed
	if enemy.set_direction(direction):
		enemy.update_animation(animation_name)
	
	if !can_see_player:
		timer -= delta
		if timer <= 0:
			return next_state
	else:
		timer = state_aggro_duration
	return null

func physics_process(_delta: float) -> EnemyState:
	return null

func handle_input(_event: InputEvent) -> EnemyState:
	return null

func _on_player_entered() -> void:
	can_see_player = true
	if state_machine.current_state is EnemyStateStun:
		return
	state_machine.change_state(self)

func _on_player_exited() -> void:
	can_see_player = false
	
