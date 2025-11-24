

extends Area2D
class_name Throwable


# 可投掷物：处理被拾起、投掷、下落、碰撞伤害等行为
#
# 设计要点：
# - 该脚本通常作为 `Throwable` 资源的 Area2D 子节点存在（例如放在 scene 的子节点中），
#   通过 `get_parent()` 获取包含可视与碰撞的父节点并对其进行移动与释放。
# - 使用 `object_sprite.position.y` 来模拟垂直高度（视觉上抬起/落下），
#   使用 `vertical_velocity` 与 `gravity_strength` 实现抛物线运动的纵向分量。


# 物理/视觉参数
@export var gravity_strength: float = 980
@export var throw_speed: float = 400.0
@export var throw_height_strength: float = 100.0
@export var throw_starting_height: float = 49


# 状态与运行时引用
var picked_up: bool = false  # 标记是否已被玩家拾取
var throwable: Node2D  # 指向实际被携带/投掷的父节点（场景中的主对象）
var throw_direction: Vector2  # 投掷水平方向向量（单位向量）
var object_sprite: Sprite2D  # 父节点中用于表示物体的 Sprite2D（用于高度模拟）
var vertical_velocity: float = 0  # 垂直速度（用于高度计算，向上为负）
var ground_height: float = 0  # 地面高度（object_sprite 的默认 y 值）
var animation_player: AnimationPlayer  # 可选的动画播放器（用于播放销毁动画）


@onready var hurt_box: HurtBox = $HurtBox  # 伤害检测区域，用于击中玩家/敌人


func _ready() -> void:
	# 连接 Area2D 的 enter/exit 事件以响应玩家交互（在进入范围内绑定交互按键）
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	# `throwable` 指向此 Area2D 的父节点（通常为包含视觉和碰撞的节点）
	throwable = get_parent()
	# 根据场景结构复制/设置 hurt_box 的碰撞形状（便于复用父节点的 shape）
	setup_hurt_box()

	# 在父节点中查找名为 Sprite2D 的子节点作为高度视觉表示
	object_sprite = throwable.find_child("Sprite2D")
	# 记录 sprite 的默认 y 作为地面高度
	ground_height = object_sprite.position.y
	# 查找可选的 AnimationPlayer（用于播放 destroy 动画）
	animation_player = throwable.find_child("AnimationPlayer")

	# 默认禁用物理处理，直到被真正投掷或丢弃
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	# 垂直方向：根据 vertical_velocity 更新 sprite 的 y，实现抛物线高度
	object_sprite.position.y += vertical_velocity * delta
	# 到达或低于地面高度则触发销毁/落地逻辑
	if object_sprite.position.y >= ground_height:
		destroy()
	# 重力影响垂直速度（向下为正）
	vertical_velocity += gravity_strength * delta
	# 水平方向：沿着 throw_direction 以 throw_speed 移动父节点位置
	throwable.position += throw_direction * throw_speed * delta


func setup_hurt_box() -> void:
	# 将 hurt_box 初始设置为不检测（到被投掷后启用）
	hurt_box.monitoring = false
	# 复制当前节点下的 CollisionShape2D 到 hurt_box，以便 hurt_box 与父节点拥有相同的碰撞形状
	for child in get_children():
		if child is CollisionShape2D:
			var _coll: CollisionShape2D = child.duplicate()
			hurt_box.add_child(_coll)
			_coll.debug_color = Color(1, 0, 0, 0.5)


func _on_area_entered(_area: Area2D) -> void:
	# 当玩家（或玩家的检测区域）进入可投掷物的交互范围时，绑定全局的 interact 按键信号
	PlayerManager.interact_pressed.connect(_player_interact)


func _on_area_exited(_area: Area2D) -> void:
	# 玩家离开范围时断开 interact 信号，避免误触
	PlayerManager.interact_pressed.disconnect(_player_interact)


func _player_interact() -> void:
	# 玩家按下交互键后的处理：如果尚未被拾取，则把物体移到玩家的 held_item 下并禁用其碰撞
	if PlayerManager.interact_handled:
		return
	if not picked_up:
		PlayerManager.interact_handled = true
		disable_collisions(throwable)
		# 从父节点移除并把物体添加到玩家的 held_item 节点下
		if throwable.get_parent():
			throwable.get_parent().remove_child(throwable)
		PlayerManager.player.held_item.add_child(throwable)
		throwable.position = Vector2.ZERO
		# 通知玩家对象进行拾取状态的切换（由 player 负责进一步处理）
		PlayerManager.player.pickup_item(self)
		# 既然已被拾取，断开 enter/exit 连接，避免重复绑定
		area_entered.disconnect(_on_area_entered)
		area_exited.disconnect(_on_area_exited)


func throw() -> void:
	# 投掷流程：将物体从玩家节点移回场景根（延迟添加以保证正确树结构操作），
	# 并设置初始的高度、垂直速度与启用物理与伤害检测
	throwable.get_parent().remove_child(throwable)
	PlayerManager.player.get_parent().call_deferred("add_child", throwable)
	throwable.position = PlayerManager.player.position
	object_sprite.position.y = -throw_starting_height
	vertical_velocity = -throw_height_strength
	set_physics_process(true)
	hurt_box.set_deferred("monitoring", true)
	hurt_box.damaged.connect(destroy)


func drop() -> void:
	# 丢下（非投掷）流程：类似投掷但使用较低的初始高度和速度
	throwable.get_parent().remove_child(throwable)
	PlayerManager.player.get_parent().call_deferred("add_child", throwable)
	throwable.position = PlayerManager.player.position
	object_sprite.position.y = -50
	vertical_velocity = -200
	throw_speed = 100
	set_physics_process(true)


func destroy() -> void:
	# 销毁流程：停止物理、禁用伤害检测，播放销毁动画（如有）并在动画完成后释放节点
	set_physics_process(false)
	hurt_box.set_deferred("monitoring", false)
	if animation_player:
		animation_player.play("destroy")
		await animation_player.animation_finished
	throwable.queue_free()


func disable_collisions(node: Node) -> void:
	# 递归禁用一个节点及其子节点下的 CollisionShape2D，避免被玩家拾起后仍与 player 发生碰撞
	for child in node.get_children():
		if child == self:
			continue
		if child is CollisionShape2D:
			child.disabled = true
		else:
			disable_collisions(child)
