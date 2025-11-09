class_name InventoryData extends Resource

@export var slots: Array[SlotData]

func _init() -> void:
	connect_slots()
	

func add_item(item: ItemData, count: int = 1) -> bool:
	for slot in slots:
		if slot:
			if slot.item_data == item:
				slot.quantity += count
				return true
	
	for index in slots.size():
		if slots[index] == null:
			var new_slot = SlotData.new()
			new_slot.item_data = item
			new_slot.quantity = count
			slots[index] = new_slot
			new_slot.changed.connect(slot_changed)
			return true
	
	print("Inventory was full!")
	return false
	

func connect_slots() -> void:
	for slot in slots:
		if slot:
			slot.changed.connect(slot_changed)

func slot_changed() -> void:
	for slot in slots:
		if slot:
			if slot.quantity < 1:
				slot.changed.disconnect(slot_changed)
				var index = slots.find(slot)
				slots[index] = null
				emit_changed()


func get_save_data() -> Array:
	var item_save: Array = []
	for index in slots.size():
		item_save.append(item_to_save(slots[index]))
	return item_save


func item_to_save(slot: SlotData) -> Dictionary:
	var result = {
		item = "",
		quantity = 0
	}
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data:
			result.item = slot.item_data.resource_path
	return result


func parse_save_data(save_data: Array) -> void:
	var array_size = slots.size()
	slots.clear()
	slots.resize(array_size)
	for index in save_data.size():
		slots[index] = item_from_save(save_data[index])
	connect_slots()
	
func item_from_save(save_object: Dictionary) -> SlotData:
	print(save_object)
	if save_object.item == "":
		return null
	var new_slot: SlotData = SlotData.new()
	new_slot.item_data = load(save_object.item)
	new_slot.quantity = int(save_object.quantity)
	return new_slot
