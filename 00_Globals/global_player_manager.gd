extends Node

const PLAYER = preload("uid://bf4esf57fcnh8")
const INVENTORY_DATA: InventoryData = preload("uid://din0bypbjigj3")

var player: Player
var player_spawned: bool = false


func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true


func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)


func set_health(hp: int, max_hp: int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)


func set_player_position(new_position: Vector2) -> void:
	player.global_position = new_position


func set_as_parent(parent: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)


func unparent_player(parent: Node2D) -> void:
	parent.remove_child(player)
	
	
