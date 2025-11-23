extends Area2D
class_name Throwable

@export var gravity_strength: float = 980
@export var throw_speed: float = 400.0
@export var throw_height_strength: float = 100.0
@export var throw_starting_height: float = 49

var picked_up: bool = false
var throwable: Node2D

@onready var hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	throwable = get_parent()
	setup_hurt_box()

func setup_hurt_box() -> void:
	hurt_box.monitoring = false
	for child in get_children():
		if child is CollisionObject2D:
			var _coll: CollisionObject2D = child.duplicate()
			hurt_box.add_child(_coll)
			#_coll.debug_color = Color(1, 0, 0, 0.5)


func _on_area_entered(_area: Area2D) -> void:
	PlayerManager.interact_pressed.connect(_player_interact)


func _on_area_exited(_area: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(_player_interact)


func _player_interact() -> void:
	if not picked_up:
		print("Picked up")
		pass
