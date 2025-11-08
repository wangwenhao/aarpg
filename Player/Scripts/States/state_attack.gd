class_name StateAttack extends State  # 定义类名 StateAttack，继承自自定义的 State 基类

@export var attack_sound: AudioStream  # 可导出变量：攻击声音资源
@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0  # 可导出范围变量：攻击时速度衰减系数（默认 5.0）

var attacking: bool = false  # 标记当前是否处于攻击阶段
@onready var attack_animation_player: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AttackAnimationPlayer"  # 延迟获取攻击动画的 AnimationPlayer 节点引用
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"  # 延迟获取音频播放器节点引用
@onready var attack_hurt_box: HurtBox = %AttackHurtBox

# 当节点第一次进入场景树时调用（初始化入口），当前未在此实现额外逻辑
func _ready() -> void:
	pass # 这里保留空实现，如果需要额外初始化可以在此添加

func enter() -> void:
	player.update_animation("attack")  # 通知 player 切换到攻击相关的动画状态（逻辑上的命名）
	attack_animation_player.play("attack_" + player.animation_direction())  # 播放与朝向相关的攻击特效动画
	player.animation_player.animation_finished.connect(end_attack)  # 连接动画结束信号到 end_attack 回调

	audio.stream = attack_sound  # 设置音频流为当前攻击音效
	audio.pitch_scale = randf_range(0.9, 1.1)  # 随机微调音高以丰富音效
	audio.play()  # 播放音效

	attacking = true  # 标记为处于攻击中

	await get_tree().create_timer(0.075).timeout  # 等待短时间（等待攻击生效/判定时机）
	attack_hurt_box.monitoring = true  # 启用 HurtBox 的监测以开始造成伤害


func exit() -> void:
	player.animation_player.animation_finished.disconnect(end_attack)  # 断开动画结束信号连接，防止重复触发
	attacking = false  # 清除攻击标志
	attack_hurt_box.monitoring = false  # 关闭 HurtBox 监测，停止造成伤害
	pass  # 保留占位，便于未来添加退出逻辑

func process(delta: float) -> State:
	# 在 process 中施加速度衰减，使角色在攻击时逐渐减速
	player.velocity -= player.velocity * decelerate_speed * delta
	if !attacking:
		# 如果当前不在攻击动作中，根据朝向决定切换到闲置或行走状态
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	# 返回 null 表示不切换状态（保持当前状态）
	return null

func physics_process(_delta: float) -> State:
	# 物理帧暂未处理状态切换，保留返回值类型以便未来扩展
	return null

func handle_input(_event: InputEvent) -> State:
	# 未处理输入，返回 null 表示不切换状态
	return null

func end_attack(_new_animation_name: String) -> void:
	# 当攻击动画结束时调用，取消攻击标志（动画结束并不一定意味着立即关闭 HurtBox，依赖 exit 中的逻辑）
	attacking = false
