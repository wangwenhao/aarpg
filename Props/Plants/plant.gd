class_name Plate extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HitBox.damaged.connect(take_damage)


func take_damage(_damage: int) -> void:
	queue_free()
