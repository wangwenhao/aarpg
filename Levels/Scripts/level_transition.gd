@tool
class_name LevelTransition extends Area2D

# 关卡切换触发区（Area2D）
# 用途：当玩家进入此区域时，请求 LevelManager 加载目标关卡并把玩家放到目标传送点。
# 支持：设置触发边（LEFT/RIGHT/TOP/BOTTOM）、区域大小、是否在切换时将玩家居中等。

enum SIDE {
	LEFT, RIGHT, TOP, BOTTOM
}

@export_file("*.tscn") var level
# 要跳转到的关卡资源（.tscn），在编辑器中选择
@export var target_transition_area: String = "LevelTransition"
# 是否将玩家在目标点居中（忽略原先的偏移）
@export var center_player: bool = false

@export_category("Collision Area Settings")
# 区域在 tile 单位下的扩展（影响 CollisionShape2D 的 size）
@export_range(1, 12, 1, "or_greater") var size: int = 2:
	set(value):
		size = value
		update_area()

@export var side: SIDE = SIDE.LEFT:
	set(value):
		side = value
		update_area()

@export var snap_to_grid: bool = false:
	set(value):
		snap_to_grid = value
		_snap_to_grid()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# 说明：
# - 在编辑器中，节点会绘制区域供设计参考；运行时会根据属性调整碰撞区域大小和位置。
# - `monitoring` 控制 Area2D 是否检测重叠（在运行时我们会在合适时机开启/关闭）。

func _ready() -> void:
	# 根据当前属性更新碰撞区域尺寸与位置（编辑器 + 运行时都要）
	update_area()

	# 编辑器下不做运行时逻辑（避免连接信号等）
	if Engine.is_editor_hint():
		return

	# 初始不监测，先处理玩家放置逻辑（避免刚加载时的即时触发）
	monitoring = false
	place_player()

	# 等待 LevelManager 发出已加载信号（确保关卡系统准备好），然后开启监测并连接信号
	await LevelManager.level_loaded

	monitoring = true
	body_entered.connect(player_entered)

func player_entered(_player: Node2D) -> void:
	# 仅响应主玩家进入（忽略子弹、怪物或其他物体）
	if _player != PlayerManager.player:
		return

	# 如果 LevelManager 正在加载新场景，则忽略此触发（双重保险）
	if LevelManager.is_loading:
		return

	# 触发加载前，立即关闭本 Area 的监测并断开信号连接，防止在加载/放置玩家时被再次触发
	set_deferred("monitoring", false)
	if body_entered.is_connected(player_entered):
		body_entered.disconnect(player_entered)

	# 请求 LevelManager 切换到目标关卡并传入偏移（用于定位玩家在目标场景的位置）
	LevelManager.load_new_level(level, target_transition_area, get_offset())

func place_player() -> void:
	# 如果当前节点不是 LevelManager 指定的目标传送点，则跳过
	if name != LevelManager.target_transition:
		return

	# 将玩家放到本节点位置加上 LevelManager 的偏移（由 load 过程决定）
	PlayerManager.set_player_position(global_position + LevelManager.position_offset)

func get_offset() -> Vector2:
	# 计算玩家在目标场景中相对于目标传送点的偏移。
	# 返回值通常用于在目标关卡放置玩家的位置：target_position = transition.global_position + offset
	var offset: Vector2 = Vector2.ZERO
	var player_position = PlayerManager.player.global_position

	# 横向传送（LEFT/RIGHT）：保持 x 为固定偏移，y 可选择居中或保留相对差值
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		if center_player:
			offset.y = 0
		else:
			offset.y = player_position.y - global_position.y
		offset.x = 16
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		# 纵向传送（TOP/BOTTOM）：保持 y 为固定偏移，x 可选择居中或保留相对差值
		if center_player:
			offset.x = 0
		else:
			offset.x = player_position.x - global_position.x
		offset.y = 16
		if side == SIDE.TOP:
			offset.y *= -1

	# 输出用于调试偏移是否正确
	print(offset)
	return offset


func update_area() -> void:
	# 根据 side 和 size 计算 CollisionShape2D 的尺寸与位置偏移，单位为像素
	var new_rect: Vector2 = Vector2(32, 32)
	var new_position: Vector2 = Vector2.ZERO

	# 横向/纵向拉伸逻辑：size 表示沿主轴的瓦片数（每瓦片 32 像素）
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 16

	# 兼容性检查：确保 collision_shape 已解析
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")

	collision_shape.shape.size = new_rect
	collision_shape.position = new_position


func _snap_to_grid() -> void:
	# 将节点位置对齐到 16 像素网格（tile 大小的一半或具体项目的网格单位）
	position.x = round(position.x / 16) * 16
	position.y = round(position.y / 16) * 16
