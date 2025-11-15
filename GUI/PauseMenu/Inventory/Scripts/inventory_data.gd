class_name InventoryData extends Resource  # 定义可复用的资源类，用于管理背包数据

@export var slots: Array[SlotData]  # 导出的槽位数组，编辑器中可配置 SlotData 列表

func _init() -> void:
	# 构造时连接所有非空槽位的 changed 信号，确保 UI/系统能收到变化通知
	connect_slots()


func add_item(item: ItemData, count: int = 1) -> bool:
	# 尝试把物品叠加到已有相同物品的槽位中
	for slot in slots:
		if slot:
			if slot.item_data == item:
				slot.quantity += count
				return true

	# 如果没有可叠加的槽位，查找第一个空槽并放入新 SlotData
	for index in range(slots.size()):
		if slots[index] == null:
			var new_slot = SlotData.new()
			new_slot.item_data = item
			new_slot.quantity = count
			slots[index] = new_slot
			new_slot.changed.connect(slot_changed)  # 连接槽位变化信号
			return true

	# 如果没有空位，返回失败并打印提示（仅用于开发调试）
	print("Inventory was full!")
	return false


func connect_slots() -> void:
	# 遍历 slots，将已有槽位的 changed 信号连接到本对象的 slot_changed 回调
	for slot in slots:
		if slot and not slot.changed.is_connected(slot_changed):
			slot.changed.connect(slot_changed)


func slot_changed() -> void:
	# 当某个槽位发出 changed 时，检查所有槽位并清理数量为 0 的槽位
	for slot in slots:
		if slot and slot.quantity < 1:
			if slot.changed.is_connected(slot_changed):
				slot.changed.disconnect(slot_changed)  # 断开信号连接以避免重复触发
			var index = slots.find(slot)
			slots[index] = null  # 将槽位置空
	emit_changed()  # 通知资源已更改（Resource 的通用回调）


func get_save_data() -> Array:
	# 把所有槽位序列化为可保存的数据结构（数组），用于写入存档
	var item_save: Array = []
	for index in range(slots.size()):
		item_save.append(item_to_save(slots[index]))
	return item_save


func item_to_save(slot: SlotData) -> Dictionary:
	# 将单个槽位转换为字典形式，包含资源路径与数量，空槽返回默认值
	var result = {
		item = "",
		quantity = 0
	}
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data:
			result.item = slot.item_data.resource_path  # 使用资源路径来保存引用
	return result


func parse_save_data(save_data: Array) -> void:
	# 从存档数据中恢复槽位信息：清空当前 slots 并按原大小重建，然后填充数据
	var array_size = slots.size()
	slots.clear()
	slots.resize(array_size)
	for index in range(save_data.size()):
		slots[index] = item_from_save(save_data[index])
	connect_slots()  # 恢复信号连接


func item_from_save(save_object: Dictionary) -> SlotData:
	# 从单个保存对象构造 SlotData；如果 item 字段为空则返回 null（表示空槽）
	if save_object.item == "":
		return null
	var new_slot: SlotData = SlotData.new()
	new_slot.item_data = load(save_object.item)  # 使用 load 加载资源路径对应的资源
	new_slot.quantity = int(save_object.quantity)
	return new_slot

func use_item(item: ItemData, count: int = 1) -> bool:
	for slot in slots:
		if slot and slot.item_data == item and slot.quantity >= count:
			slot.set_quantity(slot.quantity - count)
			return true
	
	return false
			
