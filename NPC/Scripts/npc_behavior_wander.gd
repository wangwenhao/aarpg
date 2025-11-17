@tool
extends NPCBehavior

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

# 导出可在编辑器中调整的属性：
# - wander_range: NPC 可游荡的格子范围（以瓦片为单位，默认 2）
# - wander_speed: 巡游时的速度（像素/秒）
# - wander_duration: 每次行走的持续时间（秒）
# - idle_duration: 每次静止的基础持续时间（秒）
@export var wander_range: int = 2 :set = _set_wander_range
@export var wander_speed: float = 30.0
@export var wander_duration: float = 1.0
@export var idle_duration: float = 1.0

# 记录 NPC 初始位置，用于限制游荡范围（以像素为单位）。
var original_position: Vector2
# 标志：当 NPC 被迫返回到初始范围时，避免每个物理帧重复反向导致闪烁
var is_returning: bool = false

func _ready() -> void:
	# 编辑器模式下不运行行为逻辑
	if Engine.is_editor_hint():
		return

	# 调用父类初始化
	super()

	# 在运行时移除此节点下的占位 CollisionShape2D（若存在），
	# 因为行为使用的范围检测和碰撞由其他系统控制。
	$CollisionShape2D.queue_free()

	# 记录初始全局位置，后续用于判断是否超出 wander_range
	original_position = npc.global_position

func _process(_delta: float) -> void:
	# 编辑器模式下不运行行为逻辑
	if Engine.is_editor_hint():
		return

	# 以像素为单位计算与初始位置的距离
	var dist := global_position.distance_to(original_position)
	if dist > wander_range * 32:
		# 仅在首次越界或当前朝向是远离原点时触发反向，避免每帧切换方向导致闪烁
		if not is_returning and npc.direction.dot(global_position - original_position) > 0:
			npc.velocity = -npc.velocity
			npc.direction = -npc.direction
			npc.update_direction(global_position + npc.direction)
			npc.update_animation()
			is_returning = true
	else:
		# 当回到允许范围后，重置标志，使下一次越界时可以再次触发反向
		is_returning = false

func start() -> void:
	# 若 NPC 被标记为不执行行为，则退出。
	if !npc.do_behavior:
		return

	# 先进入待机（idle）状态，速度清零并更新动画
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()

	# 等待一个随机时长（在 idle_duration 到 2 * idle_duration 之间）
	await get_tree().create_timer(randf() * idle_duration + idle_duration).timeout

	# 开始行走：随机选择一个方向并设置速度与朝向
	npc.state = "walk"
	var direction: Vector2 = DIRECTIONS[randi_range(0, 3)]
	npc.direction = direction
	npc.velocity = direction * wander_speed
	npc.update_direction(global_position + direction)
	npc.update_animation()

	# 行走一段随机时长（在 wander_duration 到 2 * wander_duration 之间）
	await get_tree().create_timer(randf() * wander_duration + wander_duration).timeout

	# 行走结束后再次检查行为标志，若仍允许则递归启动下一个行为周期
	if !npc.do_behavior:
		return

	start()


func _set_wander_range(value: int) -> void:
	# 当在编辑器或代码中修改 wander_range 时，同时更新 CollisionShape2D 的半径显示（瓦片数 * 32 像素）
	wander_range = value
	$CollisionShape2D.shape.radius = value * 32
