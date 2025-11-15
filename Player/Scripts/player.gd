class_name Player extends CharacterBody2D  # 定义 Player 类，继承自 CharacterBody2D（2D 角色控制基础节点）

const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP  # 以顺时针顺序定义四个基准方向：右、下、左、上
]
var cardinal_direction: Vector2 = Vector2.DOWN  # 当前的主方向（四向之一），默认朝下
var direction: Vector2 = Vector2.ZERO  # 实际输入方向（来自输入轴），在没有输入时为 Vector2.ZERO
var invulnerable: bool = false
var hp: int = 6
var max_hp: int = 6

@onready var animation_player: AnimationPlayer = $AnimationPlayer  # 延迟获取动画播放器节点引用
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var sprite: Sprite2D = $Sprite2D  # 延迟获取精灵节点引用（用于翻转贴图）
@onready var state_machine: PlayerStateMachine = $StateMachine  # 延迟获取玩家状态机节点引用
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D

signal direction_changed(new_direction: Vector2)  # 当主要方向变更时发出的信号，携带新的方向向量
signal player_damaged(hurt_box: HurtBox)

func _ready() -> void:
	PlayerManager.player = self
	# 初始化时将自身注入到状态机（让状态机知道 player 实例）
	state_machine.initialize(self)
	hit_box.damaged.connect(take_damage)
	update_hp(99)
	

func _process(_delta: float) -> void:
	# 每帧读取输入轴并将其标准化为方向向量
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

func _physics_process(_delta: float) -> void:
	# 物理帧中使用 CharacterBody2D 提供的方法进行移动（由 velocity 决定）
	move_and_slide()

func set_direction() -> bool:
	# 根据当前 `direction` 计算并更新四向基准 `cardinal_direction`
	# 返回值表示方向是否发生变化（true = 发生变化）

	if direction == Vector2.ZERO:
		# 没有输入方向，保持原方向
		return false

	# 通过将方向向量转换为角度并映射到 DIR_4 索引来找到最近的基准方向。
	# 加上 cardinal_direction * 0.1 是为了在接近边界时给当前朝向一个小的偏置，避免频繁抖动。
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction = DIR_4[direction_id]

	if new_direction == cardinal_direction:
		# 方向没有变化，返回 false
		return false

	# 更新主方向，触发信号，并根据朝向水平翻转精灵
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
	if invulnerable:
		return
	update_hp(-hurt_box.damage)
	if hp > 0:
		player_damaged.emit(hurt_box)
	else:
		player_damaged.emit(hurt_box)
		update_hp(99)
	pass

func update_hp(delta: int) -> void:
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHud.update_hp(hp, max_hp)
	pass
	
func make_invulnerable(duration: float = 1.0) -> void:
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer(duration).timeout
	invulnerable = false
	hit_box.monitoring = true
