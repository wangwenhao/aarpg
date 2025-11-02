class_name Player extends CharacterBody2D

var move_speed: float = 100.0

func _process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction * move_speed

func _physics_process(_delta: float) -> void:
	move_and_slide()
