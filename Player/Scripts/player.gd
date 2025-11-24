class_name Player extends CharacterBody2D


# 玩家控制器（继承自 CharacterBody2D）
# 负责：输入采集、朝向管理、生命值与受伤处理、与状态机的协作等


# 四向基准：以顺时针顺序定义为 右、下、左、上，便于将任意输入向量映射到最近的四向
const DIR_4: Array[Vector2] = [
    Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP
]

# 当前玩家朝向（四向之一），用于决定动画和交互朝向，默认朝下
var cardinal_direction: Vector2 = Vector2.DOWN

# 当前实际输入方向（由输入轴产生），无输入时为 Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

# 无敌标记（受到攻击时短暂无敌，避免连锁伤害）
var invulnerable: bool = false

# 生命值与最大生命值
var hp: int = 6
var max_hp: int = 6


# 常用子节点引用（使用 @onready 延迟获取，避免在未准备好时访问）
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var sprite: Sprite2D = $Sprite2D  # 用于显示角色贴图并做水平翻转
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var lift: StateLift = %Lift
@onready var held_item: Node2D = $Sprite2D/HeldItem
@onready var carry: StateCarry = %Carry


# 信号：当主要朝向改变时发出（供 UI、交互点等订阅），以及受伤事件
signal direction_changed(new_direction: Vector2)
signal player_damaged(hurt_box: HurtBox)


func _ready() -> void:
	# 将本玩家注册到全局 PlayerManager，便于单例访问
	PlayerManager.player = self
	# 初始化状态机并传入 player 引用（让状态机与状态可以访问玩家）
	state_machine.initialize(self)
	# 连接受伤回调（HitBox 发出 damaged 信号时调用 take_damage）
	hit_box.damaged.connect(take_damage)
	# 初始更新 HP（99 似乎是为了在编辑器或测试时强制刷新 HUD）
	update_hp(99)


func _process(_delta: float) -> void:
	# 每帧读取输入轴（左右、上下），并标准化为一个方向向量
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()


func _physics_process(_delta: float) -> void:
	# 使用 CharacterBody2D 的 move_and_slide() 实现基于 velocity 的物理移动
	move_and_slide()


func set_direction() -> bool:
	# 根据当前的 `direction`（输入向量）计算并更新四向基准 `cardinal_direction`
	# 返回值表示方向是否发生变化（true = 发生变化，通常用于触发朝向相关的逻辑）

	# 如果没有输入则不改变朝向
	if direction == Vector2.ZERO:
		return false

	# 将方向向量转换为角度并映射到 DIR_4 的索引
	# 在 angle 映射前加上小的偏置（cardinal_direction * 0.1）以减少边界处的快速抖动
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction = DIR_4[direction_id]

	# 若方向未变化则直接返回
	if new_direction == cardinal_direction:
		return false

	# 更新主方向并发出信号通知订阅者，此外根据左右朝向水平翻转精灵
	cardinal_direction = new_direction
	direction_changed.emit(new_direction)
	sprite.scale.x = -1.0 if cardinal_direction == Vector2.LEFT else 1.0

	return true


func update_animation(state: String) -> void:
	# 播放由状态名 + 朝向后缀组成的动画，例如 state="walk" 且朝下 -> "walk_down"
	animation_player.play(state + "_" + animation_direction())


func animation_direction() -> String:
	# 将 cardinal_direction 转换为动画使用的方向字符串："down"、"up" 或 "side"
	if (cardinal_direction == Vector2.DOWN):
		return "down"
	elif (cardinal_direction == Vector2.UP):
		return "up"
	else:
		# 左右共用 side 动画，使用 sprite 的水平翻转表示左右差异
		return "side"


func take_damage(hurt_box: HurtBox) -> void:
	# 受伤处理：若处于无敌状态则忽略
	if invulnerable:
		return
	# 扣血并触发受伤信号（UI / 音效 / 效果由订阅者处理）
	update_hp(-hurt_box.damage)
	# 简单处理：无论死亡与否，都发出 player_damaged 信号；若死亡则重置 HP（游戏逻辑可调整）
	if hp > 0:
		player_damaged.emit(hurt_box)
	else:
		player_damaged.emit(hurt_box)
		update_hp(99)
	pass


func update_hp(delta: int) -> void:
	# 更新生命值并通知 HUD 刷新显示
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHud.update_hp(hp, max_hp)
	pass


func make_invulnerable(duration: float = 1.0) -> void:
	# 设置短时无敌：禁用 HitBox 的监测以避免再次触发受伤
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer(duration).timeout
	invulnerable = false
	hit_box.monitoring = true


func pickup_item(item: Throwable) -> void:
	# 当玩家通过交互或拾取行为拾取可抛掷物时，切换到拿起/携带状态并记录对象
	state_machine.change_state(lift)
	carry.throwable = item
