class_name PlayerStateMachine extends Node


# 玩家状态机：管理和调度 State 子节点的生命周期与切换逻辑
#
# 设计说明：
# - 各个具体状态应继承自 `State`（项目中应有 State 基类定义），并实现如下方法：
#     `init()`、`enter()`、`exit()`、`process(delta)`、`physics_process(delta)`、`handle_input(event)`。
#   这些方法的返回值（通常为 `null` 或另一个 State 实例）用于指示是否需要切换到新状态。
# - 本状态机在 `initialize(player)` 被调用时收集子节点中所有的 State 实例并初始化它们，
#   并将第一个状态设为初始状态。
# - 注意：本实现把 `player` 注入到了 `State` 类上（`State.player = player`），这意味着状态可能
#   通过类变量访问玩家实例；如果希望注入到每个状态实例，请在 `initialize` 中对每个实例赋值。


# 存放所有 State 子节点的数组（初始化时由 `initialize()` 填充）
var states: Array[State]

# 上一个状态的引用（便于在需要时查询或调试）
var previous_state: State

# 当前活跃状态的引用，所有输入/更新都被转发到该对象
var current_state: State

# 下一个待切换的状态（临时保存）
var next_state: State


# 当节点第一次进入场景树时调用（初始化入口）
func _ready() -> void:
	# 默认禁用处理，直到通过 initialize() 正式启用，避免在未准备好时运行状态逻辑
	process_mode = Node.PROCESS_MODE_DISABLED


# 每帧调用（非物理帧），将当前状态的 process 返回值传入 change_state
# 约定：State.process(delta) 返回一个 State（切换目标）或 null（保持当前）
func _process(delta: float) -> void:
	change_state(current_state.process(delta))


# 物理帧调用：将当前状态的 physics_process 返回值传入 change_state
func _physics_process(delta: float) -> void:
	change_state(current_state.physics_process(delta))


# 未处理输入回调：将输入事件转交当前状态处理，状态可选择返回新状态
func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))


# 初始化状态机并注入 player 引用
# 参数：player - 游戏中的 Player 实例
func initialize(player: Player) -> void:
	states = []
	# 从本节点的子节点中过滤出类型为 State 的实例并收集
	for child in get_children().filter(func(child): return child is State):
		states.append(child)

	# 没有状态时直接返回（防御性检查）
	if states.size() == 0:
		return

	# 将 player 注入到 State 类级别（项目中按需使用类变量或实例变量）
	# 注意：这是类级注入，会影响所有 State 实例；如需实例注入，请将下列语句替换为对每个实例赋值。
	State.player = player
	State.state_machine = self

	# 调用每个状态实例的 init() 方法进行各自初始化
	for state in states:
		state.init()

	# 切换到第一个状态作为初始状态，并启用处理（继承父节点的 process 模式）
	change_state(states[0])
	process_mode = Node.PROCESS_MODE_INHERIT


func change_state(new_state: State) -> void:
	# 防御性判断：如果传入为 null 或与当前状态相同，忽略切换
	if new_state == null || new_state == current_state:
		return

	next_state = new_state

	# 如果有当前状态，先调用 exit() 做善后处理（例如停止动画、清理计时器等）
	if current_state:
		current_state.exit()

	# 记录并切换状态，随后调用新状态的 enter() 以开始其逻辑
	previous_state = current_state
	current_state = new_state
	current_state.enter()
