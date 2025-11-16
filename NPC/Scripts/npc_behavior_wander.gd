@tool
extends NPCBehavior

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@export var wander_range: int = 2 :set = _set_wander_range
@export var wander_speed: float = 30.0
@export var wander_duration: float = 1.0
@export var idle_duration: float = 1.0

var orignal_position: Vector2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	$CollisionShape2D.queue_free()
	orignal_position = npc.global_position

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if abs(global_position.distance_to(orignal_position)) > wander_range * 32:
		npc.velocity *= -1
		npc.direction *= -1
		npc.update_direction(global_position + npc.direction)
		npc.update_animation()

func start() -> void:
	if !npc.do_behavior:
		return
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	await get_tree().create_timer(randf() * idle_duration + idle_duration).timeout
	
	npc.state = "walk"
	var direction: Vector2 = DIRECTIONS[randi_range(0, 3)]
	npc.direction = direction
	npc.velocity = direction * wander_speed
	npc.update_direction(global_position + direction)
	npc.update_animation()
	await get_tree().create_timer(randf() * wander_duration + wander_duration).timeout
	
	if !npc.do_behavior:
		return
		
	start()


func _set_wander_range(value: int) -> void:
	wander_range = value
	$CollisionShape2D.shape.radius = value * 32
