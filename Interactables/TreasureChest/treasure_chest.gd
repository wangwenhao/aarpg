@tool
class_name TreasureChest extends Node2D

@export var item_data: ItemData: set = _set_item_data
@export var quantity: int = 1: set = _set_quantity

var is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var label: Label = $ItemSprite/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $Area2D
@onready var is_open_data: PersistentDataHandler = $IsOpen

func _ready() -> void:
	_update_texture()
	_update_label()
	if Engine.is_editor_hint():
		return
		
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)
	is_open_data.data_loaded.connect(_set_chest_state)
	_set_chest_state()
	

func _set_chest_state() -> void:
	is_open = is_open_data.value
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func _set_item_data(value: ItemData) -> void:
	item_data = value
	_update_texture()

func _set_quantity(value: int) -> void:
	quantity = value
	_update_label()

func _update_texture() -> void:
	if item_data and sprite:
		item_sprite.texture = item_data.texture
		
func _update_label() -> void:
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "x" + str(quantity)

func player_interact() -> void:
	if is_open:
		return
	is_open = true
	is_open_data.set_value()
	animation_player.play("open_chest")
	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
	else:
		printerr("No items in the chest")
		push_error("No items in the chest")
	pass

func _on_area_entered(_area: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)
	pass
	
func _on_area_exited(_area: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
	pass
