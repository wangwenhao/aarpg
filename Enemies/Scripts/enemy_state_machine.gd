class_name EnemyStateMachine extends Node

var states: Array[EnemyState]  # 存放所有 State 子节点的数组（状态集合）
var previous_state: EnemyState  # 上一个状态的引用
var current_state: EnemyState  # 当前活跃状态的引用

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_state(current_state.process(delta))

	
func _physics_process(delta: float) -> void:
	change_state(current_state.physics_process(delta))
	

func initialize(enemy: Enemy) -> void:
	states = []  # 重置状态数组，准备收集子节点中的 State 实例
	# 使用 filter 筛选出所有是 State 的子节点，然后遍历这些子节点
	for child in get_children().filter(func(child): return child is EnemyState):
		states.append(child)  # 把筛选出的 State 类型子节点加入到 states 列表
		
	for state in states:
		state.enemy = enemy
		state.state_machine = self
		state.init()
		
	if states.size() > 0:
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: EnemyState) -> void:
	if new_state == null || new_state == current_state:
		return  # 如果没有新状态或新状态与当前相同，则不做任何操作

	if current_state:
		current_state.exit()  # 如果存在当前状态，先调用其退出逻辑

	previous_state = current_state  # 保存之前的状态引用
	current_state = new_state  # 设置新的当前状态
	current_state.enter()  # 调用新状态的进入逻辑
