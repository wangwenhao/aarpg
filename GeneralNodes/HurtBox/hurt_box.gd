class_name HurtBox extends Area2D

signal damaged

@export var damage: int = 1


func _ready() -> void:
	area_entered.connect(AreaEntered)


func AreaEntered(area: Area2D) -> void:
	if area is HitBox:
		damaged.emit()
		area.take_damage(self)
		
