class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://ny78ah3pemvi")

var focus_index: int = 0

@export var data: InventoryData

func _ready() -> void:
	PauseMenu.shown.connect(update_inventory)
	PauseMenu.hidden.connect(clear_inventory)
	clear_inventory()
	data.changed.connect(on_inventory_changed)

func clear_inventory() -> void:
	for child in get_children():
		child.queue_free()


func update_inventory(index: int = 0) -> void:
	clear_inventory()
	for slot in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot
		new_slot.focus_entered.connect(item_focused)
	
	await get_tree().process_frame
	get_child(index).grab_focus()

func on_inventory_changed() -> void:
	var index = focus_index
	clear_inventory()
	update_inventory(index)

func item_focused() -> void:
	for index in get_children().size():
		if get_child(index).has_focus():
			focus_index = index
			return
