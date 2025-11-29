extends Node2D
class_name PathFinder

var vectors: Array[Vector2] = [
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	Vector2(-1, -1)
]

var interests: Array[float]
var obstacles: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
var outcomes: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
var rays: Array[RayCast2D]

var move_dir: Vector2 = Vector2.ZERO
var best_path: Vector2 = Vector2.ZERO

@onready var timer: Timer = $Timer

func _ready() -> void:
	for ray in get_children().filter(func(r) -> bool: return r is RayCast2D):
		rays.append(ray)
		
	for v in vectors:
		v = v.normalized()
		
	set_path()
		
	timer.timeout.connect(set_path)

func _process(delta: float) -> void:
	move_dir = lerp(move_dir, best_path, 10 * delta)

func set_path() -> void:
	var player_dir: Vector2 = global_position.direction_to(PlayerManager.player.global_position)
	
	for i in 8:
		obstacles[i] = 0
		outcomes[i] = 0
	
	for i in 8:
		if rays[i].is_colliding():
			obstacles[i] += 4
			obstacles[get_next_index(i)] += 1
			obstacles[get_prev_index(i)] += 1
	
	if obstacles.max() == 0:
		best_path = player_dir
		return
	
	interests.clear()
	for v in vectors:
		interests.append(v.dot(player_dir))
		
	for i in 8:
		outcomes[i] = interests[i] - obstacles[i]
	
	best_path = vectors[outcomes.find(outcomes.max())]
	


func get_next_index(index: int) -> int:
	var next_index: int = index + 1
	if next_index >= 8:
		return 0
	else:
		return next_index

func get_prev_index(index: int) -> int:
	var prev_index: int = index - 1
	if prev_index < 0:
		return 7
	else:
		return prev_index
