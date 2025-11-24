
extends State
class_name StateCarry


# 携带状态：处理玩家抱着可投掷物件时的移动、动画与投掷/放下逻辑
#
# 主要职责：
# - 控制携带时的移动速度与行走动画
# - 在退出该状态时，根据玩家朝向或输入决定投掷方向，播放投掷音效或直接放下


@export var move_speed: float = 80
@export var throw_audio: AudioStream

# 标记当前是否处于行走动画
var is_walking: bool = false
# 被携带的可投掷对象（可为 null，表示目前没有携带）
var throwable: Throwable


func init() -> void:
	# 状态初始化（如需在状态被创建时做一次性设置，可放在这里）
	pass


func _ready() -> void:
	# 如果需要引用场景内其它资源，可以在 ready 时解析（当前没有额外逻辑）
	pass


func enter() -> void:
	# 进入携带状态时播放持物静止的动画并重置行走标志
	player.update_animation("carry")
	is_walking = false


func exit() -> void:
	# 退出携带状态时处理被携带物的投掷或丢弃逻辑
	if throwable:
		# 如果玩家没有给出新的输入方向，则使用 cardinal_direction（面向方向）作为投掷方向
		if player.direction == Vector2.ZERO:
			throwable.throw_direction = player.cardinal_direction
		else:
			# 否则使用当前输入方向作为投掷方向
			throwable.throw_direction = player.direction

		# 如果下一个状态是被击晕(stun)，则把投掷方向反转并调用 drop（模拟被击飞/掉落）
		if state_machine.next_state == stun:
			throwable.throw_direction = throwable.throw_direction.rotated(PI)
			throwable.drop()
		else:
			# 正常投掷流程：播放投掷音效，然后调用 throwable.throw()
			player.audio.stream = throw_audio
			player.audio.play()
			throwable.throw()


func process(_delta: float) -> State:
	# 每帧更新玩家的动画状态：静止 => carry，移动 => carry_walk
	if player.direction == Vector2.ZERO:
		is_walking = false
		player.update_animation("carry")
	elif player.set_direction() or not is_walking:
		# 当玩家首次开始移动或方向发生变化时切换到行走携带动画
		player.update_animation("carry_walk")
		is_walking = true

	# 更新玩家速度（由状态决定移动速度）
	player.velocity = player.direction * move_speed
	return null


func physics_process(_delta: float) -> State:
	# 物理帧无特殊状态切换逻辑，保持当前状态
	return null


func handle_input(_event: InputEvent) -> State:
	# 当玩家按下交互或攻击键时，退出携带状态（返回到 idle）
	if _event.is_action_pressed("interact") or _event.is_action_pressed("attack"):
		return idle
	return null
