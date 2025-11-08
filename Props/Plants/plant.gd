class_name Plate extends Node2D

func _ready() -> void:
	$HitBox.damaged.connect(take_damage)

func take_damage(_hurt_box: HurtBox) -> void:
	queue_free()
