# 吸附道具的触发器节点
class_name ItemMagnet extends Area2D

# 当前被磁吸追踪的 ItemPickup 列表
var items : Array[ItemPickup] = []
# 对应每个被追踪道具的当前速度（像素/秒）
var speeds: Array[float] = []

# 磁力强度（影响速度增长率），可在编辑器中调整
@export var magnet_strength: float = 1.0
# 是否在吸附时播放音效
@export var play_magnet_audio: bool = false

# 本节点下的音源引用（可为空，如果不播放音效则不用）
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# 连接当其他 Area2D 进入本 Area 时的回调
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# 在物理帧中更新被追踪道具的位置，避免非物理帧瞬移导致 Area2D enter 事件丢失
	# 反向遍历 items 列表以便安全删除失效项
	# print("[ItemMagnet] tracking items count=", items.size())
	for index in range(items.size() - 1, -1, -1):
		var item = items[index]
		# 若对象被释放或为 null，则移除对应条目
		if !item:
			items.remove_at(index)
			speeds.remove_at(index)
		else:
			# 计算当前道具与磁铁中心的距离（全局坐标）
			var dist = item.global_position.distance_to(global_position)
			# 如果距离大于当前速度值（速度作为阈值加速控制），则继续加速并让道具靠近
			if dist > speeds[index]:
				# 速度随时间增长，受 magnet_strength 控制
				speeds[index] += magnet_strength * delta
				# 使用全局安全移动：按物理帧步长移动全局位置，避免父坐标系偏差
				item.global_position = item.global_position.move_toward(global_position, speeds[index] * delta)
			else:
				# 已足够接近，直接将道具放置到磁铁中心位置
				item.global_position = global_position

func _on_area_entered(area: Area2D) -> void:
	# 当检测到某个 Area 进入，如果它的父节点是 ItemPickup，则将其加入追踪列表
	if area.get_parent() is ItemPickup:
		var new_item = area.get_parent() as ItemPickup
		items.append(new_item)
		# 初始速度用 magnet_strength 作为基础
		speeds.append(magnet_strength)
		# 禁用其物理处理（由磁铁控制位置），避免与其自身的物理移动冲突
		# 说明：
		# - `ItemPickup` 在被抛掷或掉落时通常依赖其 `_physics_process`（或物理节点）来处理速度、碰撞与阻尼。
		# - 当磁铁开始控制道具位置时，需要禁止道具自身的物理更新，防止两套位置更新相互抵消或产生抖动。
		# - 因为 `ItemMagnet` 直接更新 `item.position` / `item.global_position` 来拉拽，
		#   所以在加入追踪列表时调用 `new_item.set_physics_process(false)` 来交出控制权。
		# - 注意：此脚本并不会在以后显式重新开启被禁用的物理处理；
		#   当道具最终被拾取（`ItemPickup.item_picked_up()`）或被释放并 `queue_free()` 时，
		#   相应对象会被移除或释放；如果需要“停止吸附后恢复物理”的行为，
		#   可在移除 items 列表时重新调用 `set_physics_process(true)`。
		new_item.set_physics_process(false)
		# 根据配置决定是否播放吸附音效（播放从头开始）
		if play_magnet_audio and audio:
			audio.play(0)

		# 调试日志：记录磁铁何时捕获道具（不带时间戳以兼容不同 Godot 版本）
		print("[ItemMagnet] captured:", new_item.name, "item_pos=", new_item.global_position, "magnet_pos=", global_position)
