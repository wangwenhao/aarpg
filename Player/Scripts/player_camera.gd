class_name PlayerCamera extends Camera2D


# 玩家摄像机控制（基于 Camera2D）
# 功能：
# - 控制摄像机摇动效果（基于 "trauma" 概念）
# - 在地图边界变化时更新摄像机的限制（limit_left/top/right/bottom）


@export_range(0, 1, 0.05, "or_greater") var shake_power: float = 0.5   # 摇动强度系数（与 trauma 组合后平方）
@export var shake_max_offset: float = 5.0                              # 摇动时的最大像素偏移
@export var shake_decay: float = 1.0                                    # trauma 衰减速率（每秒）

var shake_trauma: float = 0.0  # 当前的 trauma 值，0 表示无摇动


func _ready() -> void:
	# 监听地图边界变化以更新摄像机边界限制
	LevelManager.tile_map_bounds_changed.connect(update_limits)
	update_limits(LevelManager.current_tile_map_bounds)
	# 订阅全局的摄像机抖动信号，外部通过 PlayerManager.camera_shook 发起抖动
	PlayerManager.camera_shook.connect(add_camera_shake)


func _physics_process(delta: float) -> void:
	# 在物理帧中逐步衰减 trauma 并在需要时触发 shake
	if shake_trauma > 0:
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		shake()


func add_camera_shake(value: float) -> void:
	# 外部调用接口：设置或覆盖当前的 trauma 值（通常由事件驱动，如爆炸/受击）
	shake_trauma = value


func shake() -> void:
	# 根据当前 trauma 计算抖动量：先乘以 shake_power 再平方以实现非线性加强效果
	var amount: float = pow(shake_trauma * shake_power, 2)
	# 随机在一个小范围内偏移摄像机的 offset，从而产生抖动视觉
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_max_offset * amount


func update_limits(bounds: Array[Vector2]) -> void:
	# 更新摄像机的限制值，bounds 期望为两个 Vector2：左上与右下
	if bounds.size() < 2:
		return
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
