
@tool
class_name ItemPickup extends CharacterBody2D

signal picked_up

@export var item_data: ItemData: set = set_item_data

# 引用场景中常用子节点：检测区域、精灵、音效播放器
@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	# 刷新显示的贴图（编辑器与运行时都适用）
	update_texture()
	# 编辑器模式下不连接运行时信号，避免编辑器内触发逻辑
	if Engine.is_editor_hint():
		return
	# 运行时连接进入检测：当有物体进入拾取区域时回调 on_body_entered
	area.body_entered.connect(on_body_entered)


func _physics_process(delta: float) -> void:
	# 简单的物理行为：使用 move_and_collide 来处理移动与碰撞反弹
	# 这里假定 velocity 已由外部设置（例如抛掷时给予初速度）
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		# 碰撞时将速度按法线反弹，产生反弹效果
		velocity = velocity.bounce(collision_info.get_normal())
	# 施加线性阻尼以逐渐减速（阻尼系数为 4，可根据需求调整）
	velocity -= velocity * delta * 4

func on_body_entered(body) -> void:
	# 当区域检测到进入体时，如果是 Player，则尝试将道具加入玩家背包
	# 调试日志：记录何时检测到进入者（不含时间戳以兼容不同 Godot 版本）
	print("[ItemPickup] body_entered: item=", name, "pos=", global_position, "by=", body)
	if body is Player:
		if item_data:
			# 使用 PlayerManager 中的 INVENTORY_DATA（有 add_item 接口）进行添加
			var added := PlayerManager.INVENTORY_DATA.add_item(item_data)
			# 调试日志：记录 add_item 的返回结果（不含时间戳）
			print("[ItemPickup] add_item result=", added, " item=", item_data)
			if added:
				# 若成功添加，执行拾取后的处理（播放音效、移除节点等）
				item_picked_up()


func item_picked_up() -> void:
	print("[ItemPickup] item_picked_up called for item:", name)
	# 断开进入检测信号以避免重复触发
	area.body_entered.disconnect(on_body_entered)
	# 播放拾取音效（可选），并隐藏节点
	audio_stream_player.play()
	visible = false
	# 发出被拾取信号，便于外部监听（例如触发任务或 UI 更新）
	picked_up.emit()
	# 等待音效播放完毕再释放节点，保证音效完整播放
	await audio_stream_player.finished
	print("[ItemPickup] item picked up and audio finished, freeing item:", name)
	queue_free()


func set_item_data(value: ItemData) -> void:
	# 当通过导出或代码设置 item_data 时，更新本地引用并刷新贴图
	item_data = value
	update_texture()


func update_texture() -> void:
	# 如果存在 item_data，则将其贴图应用到 sprite（编辑器预览与运行时显示）
	if item_data and sprite:
		sprite.texture =  item_data.texture
