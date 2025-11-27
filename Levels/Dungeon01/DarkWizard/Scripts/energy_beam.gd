extends Node
class_name EnergyBeam

@export var use_timer: bool = false
@export var time_between_attacks: float = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if use_timer:
		attack_delay()
	
func attack() -> void:
	animation_player.play("attack")
	await animation_player.animation_finished
	animation_player.play("default")
	if use_timer:
		attack_delay()

func attack_delay() -> void:
	await get_tree().create_timer(time_between_attacks).timeout
	attack()
