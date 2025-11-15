class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/Scripts/Abilities/Boomerang/boomerang.tscn")

enum abilities {
	BOOMERANG,
	GRAPPLE
}

var selected_ability = abilities.BOOMERANG
var player: Player
var boomerang_instance: Boomerang = null

func _ready() -> void:
	player = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	if !event.is_action_pressed("ability"):
		return
	if selected_ability == abilities.BOOMERANG:
		boomerang_ability()
	
func boomerang_ability() -> void:
	if boomerang_instance:
		return
	var b = BOOMERANG.instantiate() as Boomerang
	player.add_sibling(b)
	b.global_position = player.global_position
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
		
	b.throw(throw_direction)
	boomerang_instance = b
	
