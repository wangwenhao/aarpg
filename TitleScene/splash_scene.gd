class_name SplashScene extends Control

signal finished

@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(_name: String) -> void:
	finished.emit()
	self.queue_free()
