class_name EnemyStateChase extends EnemyState  # 追击状态，继承自 EnemyState

@export var animation_name: String = "chase"  # 使用的动画名称
@export var chase_speed: float = 40.0  # 追击移动速度
@export var turn_rate: float = 0.25  # 朝向插值速率（越大转向越快）

@export_category("AI")
@export var vision_area: VisionArea  # 视觉检测区域（检测玩家进出）
@export var attack_area: HurtBox  # 攻击判定范围（进入时开启监测）
@export var state_aggro_duration: float = 0.5  # 失去视线后继续追击的持续时间（秒）
@export var next_state: EnemyState  # 失去目标后切换到的下一个状态引用

var timer: float = 0.0  # 用于计时失去视线后的冷却
var direction: Vector2  # 当前移动朝向向量（用于平滑转向）
var can_see_player: bool = false  # 是否当前能看到玩家（由 vision_area 控制）

func init() -> void:
	# 初始化时连接 vision_area 的进入/离开信号用于感知玩家
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)

func enter() -> void:
	# 进入追击状态：重置仇恨计时器、播放动画、启用攻击判定
	timer = state_aggro_duration
	enemy.update_animation(animation_name)
	if attack_area:
		attack_area.monitoring = true

func exit() -> void:
	# 退出时关闭攻击判定并清理可见标志
	if attack_area:
		attack_area.monitoring = false
	can_see_player = false

func process(delta: float) -> EnemyState:
	# 计算目标方向（指向玩家）并进行平滑朝向插值
	var new_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	direction = lerp(direction, new_direction, turn_rate)
	# 应用速度与朝向
	enemy.velocity = direction * chase_speed
	if enemy.set_direction(direction):
		# 若 set_direction 返回 true（朝向改变），更新动画以匹配朝向
		enemy.update_animation(animation_name)

	# 当看不到玩家时，开始计时并在超时后切换到 next_state
	if !can_see_player:
		timer -= delta
		if timer <= 0:
			return next_state
	else:
		# 只要还能看到玩家就保持计时器为初始值
		timer = state_aggro_duration
	return null

func physics_process(_delta: float) -> EnemyState:
	# 物理帧未使用特殊处理，保留接口以便扩展
	return null

func handle_input(_event: InputEvent) -> EnemyState:
	# 敌人不处理输入，返回 null 表示不切换状态
	return null

func _on_player_entered() -> void:
	# 视觉区域检测到玩家进入，标记可见并尝试切换到追击状态（除非当前处于眩晕）
	can_see_player = true
	if state_machine.current_state is EnemyStateStun:
		return
	state_machine.change_state(self)

func _on_player_exited() -> void:
	# 视觉区域检测到玩家离开，取消可见标志（开始倒计时）
	can_see_player = false
