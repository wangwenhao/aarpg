class_name StateIdle extends State

func _ready() -> void:
	pass

func enter() -> void:
	player.update_animation("idle")

func exit() -> void:
	pass

func process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(event: InputEvent) -> State:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_pressed("interact"):
		PlayerManager.emit_interact_pressed()
	return null
