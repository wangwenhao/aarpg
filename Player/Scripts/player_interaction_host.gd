class_name PlayerInteractionHost extends Node2D

# 本节点用于承载与玩家朝向相关的交互（如面对方向的提示、交互点朝向等）
# 通常作为玩家节点的子节点或和玩家在同一层级下使用，监听玩家的方向变化并
# 根据玩家朝向旋转自身（例如使交互图标/碰撞箱面向玩家朝向）。

# 通过 NodePath 找到上层的 Player 实例（假定本节点在 Player 的子树下）
@onready var player: Player = $".."


# 生命周期回调：节点进入场景树时连接玩家的方向变化信号
func _ready() -> void:
	# 订阅 Player 的 `direction_changed(Vector2)` 信号，信号触发时调用 `update_direction`
	player.direction_changed.connect(update_direction)


# 根据玩家提供的新方向向量调整本节点的旋转角度（以度为单位）
# 约定：
# - 玩家朝下 (0, 1) -> 本节点朝向 0 度
# - 玩家朝上 (0, -1) -> 本节点朝向 180 度
# - 玩家朝左 (-1, 0) -> 本节点朝向 90 度
# - 玩家朝右 (1, 0) -> 本节点朝向 -90 度
# 其它情况使用默认 0 度。
func update_direction(new_direction: Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
