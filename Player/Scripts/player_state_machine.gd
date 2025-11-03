class_name PlayerStateMachine extends Node  # 定义类名为 PlayerStateMachine，并继承自 Godot 的 Node

var states: Array[State]  # 存放所有 State 子节点的数组（状态集合）
var previous_state: State  # 上一个状态的引用
var current_state: State  # 当前活跃状态的引用

# 当节点第一次进入场景树时调用（初始化入口）
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED  # 默认禁用处理，直到初始化完成再启用

# 每帧调用，delta 是与上一帧的时间差（秒）
func _process(delta: float) -> void:
	change_state(current_state.process(delta))  # 将当前状态的 process 返回值作为可能的新状态来切换

func _physics_process(delta: float) -> void:
	change_state(current_state.physics_process(delta))  # 在物理帧调用当前状态的物理处理，并可能切换状态

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))  # 将未处理的输入传递给当前状态，让它决定是否切换状态

func initialize(player: Player) -> void:
	states = []  # 重置状态数组，准备收集子节点中的 State 实例
	# 使用 filter 筛选出所有是 State 的子节点，然后遍历这些子节点
	for child in get_children().filter(func(child): return child is State):
		states.append(child)  # 把筛选出的 State 类型子节点加入到 states 列表

	if states.size() > 0:
		# 注意：这里是把 player 赋值给 State 类的 player（即可能是静态/类属性），
		# 而不是赋给第一个状态实例。如果你想注入到实例，应改为 `states[0].player = player`。
		State.player = player
		change_state(states[0])  # 切换到第一个状态作为初始状态
		process_mode = Node.PROCESS_MODE_INHERIT  # 继承父节点的处理模式（启用正常的 _process/_physics_process）

func change_state(new_state: State) -> void:
	if new_state == null || new_state == current_state:
		return  # 如果没有新状态或新状态与当前相同，则不做任何操作

	if current_state:
		current_state.exit()  # 如果存在当前状态，先调用其退出逻辑

	previous_state = current_state  # 保存之前的状态引用
	current_state = new_state  # 设置新的当前状态
	current_state.enter()  # 调用新状态的进入逻辑

