class_name PlayerStateMachine extends Node

var states: Array[State]
var previous_state: State
var current_state: State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
	change_state(current_state.physics_process(delta))
	
func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))

func initialize(player: Player) -> void:
	states = []
	for chind in get_children():
		if chind is State:
			states.append(chind)
	
	if states.size() > 0:
		states[0].player = player
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: State) -> void:
	if new_state == null || new_state == current_state:
		return

	if current_state:
		current_state.exit()
	
	previous_state = current_state
	current_state = new_state
	current_state.enter()
	
