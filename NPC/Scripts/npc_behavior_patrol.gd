@tool
extends NPCBehavior

const COLORS = [
	Color(1, 0, 0), Color(1, 1, 0), Color(0, 1, 0), 
	Color(0, 1, 1), Color(0, 0, 1), Color(1, 0, 1)
]

@export var walk_speed: float = 30.0

var patrol_locations: Array[PatrolLocation] = []
var current_location_index: int = 0
var target: PatrolLocation

func _ready() -> void:
	gather_patrol_locations()
	if Engine.is_editor_hint():
		child_entered_tree.connect(gather_patrol_locations)
		child_order_changed.connect(gather_patrol_locations)
		return
	super()
	if patrol_locations.size() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	target = patrol_locations[0]
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if npc.global_position.distance_to(target.target_position) < 1:
		start()
	
func start() -> void:
	if !npc.do_behavior or patrol_locations.size() < 2:
		return
	npc.global_position = target.target_position
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	
	var wait_time: float = target.wait_time
	current_location_index += 1
	if current_location_index >= patrol_locations.size():
		current_location_index = 0
	
	target = patrol_locations[current_location_index]
	
	await get_tree().create_timer(wait_time).timeout
	if !npc.do_behavior:
		return
	npc.state = "walk"
	var direction = global_position.direction_to(target.target_position)
	npc.direction = direction
	npc.velocity = npc.direction * walk_speed
	npc.update_direction(target.target_position)
	npc.update_animation()
	
	
func gather_patrol_locations(_node: Node = null) -> void:
	patrol_locations = []
	for child in get_children():
		if child is PatrolLocation:
			patrol_locations.append(child)
			
	if Engine.is_editor_hint():
		if patrol_locations.size() > 0:
			for index in patrol_locations.size():
				var location = patrol_locations[index]
				if not location.transform_changed.is_connected(gather_patrol_locations):
					location.transform_changed.connect(gather_patrol_locations)
				location.update_label(str(index))
				location.modulate = _get_color_by_index(index)
				
				var next: PatrolLocation
				if index < patrol_locations.size() - 1:
					next = patrol_locations[index + 1]
				else:
					next = patrol_locations[0]
				
				location.update_line(next.position)

func _get_color_by_index(index: int) -> Color:
	var color_count: int = COLORS.size()
	return COLORS[index % (color_count)]
