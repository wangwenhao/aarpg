extends Node  # 作为全局管理器节点，挂载在场景树中以管理关卡加载与瓦片图边界

signal level_load_started  # 当开始加载新关卡时发射（用于 UI、音效或其他预处理）
signal level_loaded  # 当关卡加载完成时发射（用于解除暂停、开始播放等）
signal tile_map_bounds_changed(bounds: Array[Vector2])  # 当瓦片地图边界发生变化时发射，传递边界顶点数组

var current_tile_map_bounds: Array[Vector2]  # 当前瓦片地图的边界（顶点列表）
var target_transition: String  # 记录要使用的场景切换名称或类型（例如传入的过渡参数）
var position_offset: Vector2  # 用于传递加载后玩家/相机的位置偏移

func _ready() -> void:
	# 等待至少一帧以确保场景树初始化完成，然后通知已加载
	await get_tree().process_frame
	level_loaded.emit()

func change_tile_map_bounds(bounds: Array[Vector2]) -> void:
	# 更新当前的瓦片地图边界并发送信号，供其他系统（相机/路径）使用
	current_tile_map_bounds = bounds
	tile_map_bounds_changed.emit(bounds)

func load_new_level(
	level_path: String,
	_target_transition: String,
	_position_offset: Vector2
) -> void:
	# 开始加载新关卡的流程：暂停游戏、播放淡出、切换场景、淡入并恢复

	# 暂停场景树（停止物理与处理），防止加载过程中逻辑继续运行
	get_tree().paused = true

	# 保存传入的过渡信息和位置偏移，用于加载完成后的处理
	target_transition = _target_transition
	position_offset = _position_offset

	# 播放全局的场景淡出效果（该函数为协程式 await）
	await SceneTransition.fade_out()

	# 发射开始加载信号（可以用于显示 loading UI 或触发资源预加载）
	level_load_started.emit()
	# 等待至少一帧，确保信号接收者有机会响应并更新 UI
	await get_tree().process_frame

	# 切换到目标场景文件（立即改变当前场景树的活动场景）
	get_tree().change_scene_to_file(level_path)
	# 等待全局淡入完成（例如 SceneTransition.fade_in 也是 awaitable）
	await SceneTransition.fade_in()

	# 恢复场景树运行（结束暂停），之后可以做位置复位或其他后处理
	get_tree().paused = false
	# 等待一帧以确保新场景的节点准备就绪
	await get_tree().process_frame

	# 发射已加载信号，通知系统关卡已正式加载完成
	level_loaded.emit()
