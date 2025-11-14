class_name Enemy extends CharacterBody2D

signal direction_changed(new_direction: Vector2)
signal enemy_damaged(hurt_box: HurtBox)
signal enemy_destroyed(hurt_box: HurtBox)

const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP  # 以顺时针顺序定义四个基准方向：右、下、左、上
]

@export var hp: int = 3

var cardinal_direction: Vector2 = Vector2.DOWN  # 当前的主方向（四向之一），默认朝下
var direction: Vector2 = Vector2.ZERO  # 实际输入方向（来自输入轴），在没有输入时为 Vector2.ZERO
var player: Player
var invulnerable: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(take_damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	
func set_direction(_new_direction: Vector2) -> bool:
	direction = _new_direction

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
	hp -= hurt_box.damage
	if hp > 0:
		enemy_damaged.emit(hurt_box)
	else:
		enemy_destroyed.emit(hurt_box)
