class_name Boomerang extends Node2D

# 回旋镖能力节点
# 简要说明：回旋镖在被投掷后先向前移动（THROW），速度递减；
# 当速度降到 0 时进入 RETURN 状态，回向玩家并加速，接近玩家时回收并释放节点。
enum State { INACTIVE, THROW, RETURN }

# 运行时引用与状态
var player: Player
# 当前飞行方向（单位向量）
var direction: Vector2
# 当前速度（像素/秒）
var speed: float = 0
# 当前状态（State）
var state

# 导出参数，可在编辑器中调整：
@export var acceleration: float = 500.0  # 加速度（控制加速/减速速率）
@export var max_speed: float = 400.0     # 投掷时的初始最大速度
@export var catch_audio: AudioStream       # 回收时播放的音效资源

# 节点引用（动画与声源）
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# 初始时隐藏回旋镖并置为未激活状态，获取玩家引用
	visible = false
	state = State.INACTIVE
	player = PlayerManager.player

func _physics_process(delta: float) -> void:
	# 物理帧更新：根据当前状态调整速度与方向
	if state == State.THROW:
		# 投掷阶段：速度逐步减小，直至为 0 时开始返回
		speed -= acceleration * delta
		if speed <= 0:
			state = State.RETURN
	elif state == State.RETURN:
		# 返回阶段：朝向玩家并加速
		direction = global_position.direction_to(player.global_position)
		speed += acceleration * delta
		# 靠近玩家则触发回收（播放音效并释放节点）
		if global_position.distance_to(player.global_position) < 10:
			PlayerManager.play_audio(catch_audio)
			queue_free()

	# 应用位移（基于方向、速度与时间增量）
	position += direction * speed * delta

	# 通过速度比例调整音高与动画速度，增加反馈感
	var speed_ratio = speed / max_speed
	audio.pitch_scale = speed_ratio * 0.75 + 0.75
	animation_player.speed_scale = 1 + ( speed_ratio * 0.25)

func throw(throw_direction: Vector2) -> void:
	# 被调用以投掷回旋镖：设置方向、速度、状态并开始播放动画/音效
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("boomerang")
	PlayerManager.play_audio(catch_audio)
	visible = true
