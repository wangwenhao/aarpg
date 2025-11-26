class_name Enemy extends CharacterBody2D

# 敌人类：负责移动、朝向、受伤与动画播放

# 信号：
# - direction_changed(new_direction): 当主要朝向（四向）改变时发出
# - enemy_damaged(hurt_box): 受到伤害时发出（hp > 0）
# - enemy_destroyed(hurt_box): 被击杀时发出（hp <= 0）
signal direction_changed(new_direction: Vector2)
signal enemy_damaged(hurt_box: HurtBox)
signal enemy_destroyed(hurt_box: HurtBox)

# 四向基准向量，按顺时针顺序定义：右、下、左、上
const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP
]

# 可在编辑器设置的生命值
@export var hp: int = 3

# 当前的主朝向（仅取四向之一），用于选择动画与翻转精灵
var cardinal_direction: Vector2 = Vector2.DOWN
# 实际移动/输入方向（连续向量），为 Vector2.ZERO 表示无输入
var direction: Vector2 = Vector2.ZERO
# 引用主玩家实例，便于追踪或做 AI 目标
var player: Player
# 受伤无敌开关（若为 true 则忽略伤害）
var invulnerable: bool = false

# 运行时节点引用
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine


func _ready() -> void:
	# 初始化状态机并连接受伤信号
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(take_damage)



func _process(_delta: float) -> void:
	# 可在此处理非物理、与渲染相关的逻辑（例如视觉插值、面向摄像机的效果）
	pass


func _physics_process(_delta: float) -> void:
	# 物理帧更新：应用速度并处理碰撞。具体速度由状态机或外部逻辑设置到 velocity
	move_and_slide()


func set_direction(_new_direction: Vector2) -> bool:
	direction = _new_direction

	if direction == Vector2.ZERO:
		# 没有输入方向，保持原方向
		return false

	# 通过将方向向量转换为角度并映射到 DIR_4 索引来找到最近的基准方向。
	# 在边界附近加上微小偏置（cardinal_direction * 0.1）以减少抖动：
	# 当输入方向接近两个基准方向的分界时，偏置会优先保留当前朝向，防止频繁切换。
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction = DIR_4[direction_id]

	if new_direction == cardinal_direction:
		# 方向没有变化，返回 false
		return false

	# 更新主方向，触发信号，并根据朝向水平翻转精灵（左右共用 side 动画）
	cardinal_direction = new_direction
	direction_changed.emit(new_direction)
	sprite.scale.x = -1.0 if cardinal_direction == Vector2.LEFT else 1.0

	return true

func update_animation(state: String) -> void:
	# 播放与当前状态和朝向相关的动画，例如 "attack_down" 或 "walk_side"
	animation_player.play(state + "_" + animation_direction())

func animation_direction() -> String:
	# 根据当前的 cardinal_direction 返回动画使用的方向字符串："down"、"up" 或 "side"
	if (cardinal_direction == Vector2.DOWN):
		return "down"
	elif (cardinal_direction == Vector2.UP):
		return "up"
	else:
		# 左右共用 side 动画（通过精灵的水平翻转表现左右朝向）
		return "side"

func take_damage(hurt_box: HurtBox) -> void:
	# 处理受伤逻辑：支持短暂无敌状态
	if invulnerable:
		return

	hp -= hurt_box.damage
	PlayerManager.shake_camera()
	if hp > 0:
		# 仍有生命，发出 damaged 信号（可以触发击退/闪烁等效果）
		enemy_damaged.emit(hurt_box)
	else:
		# 血量耗尽，发出 destroyed 信号（可由外部进行掉落、播放消失动画、移除节点等）
		enemy_destroyed.emit(hurt_box)
