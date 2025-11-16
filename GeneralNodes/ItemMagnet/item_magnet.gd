class_name ItemMagnet extends Area2D

var items : Array[ItemPickup] = []
var speeds: Array[float] = []

@export var magnet_strngth: float = 1.0
@export var play_magnet_audio: bool = false

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _process(delta: float) -> void:
	for index in range(items.size() - 1, -1, -1):
		var item = items[index]
		if !item:
			items.remove_at(index)
			speeds.remove_at(index)
		elif item.global_position.distance_to(global_position) > speeds[index]:
			speeds[index] += magnet_strngth * delta
			item.position += item.global_position.direction_to(global_position) * speeds[index]
		else:
			item.global_position = global_position	

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is ItemPickup:
		var new_item = area.get_parent() as ItemPickup
		items.append(new_item)
		speeds.append(magnet_strngth)
		new_item.set_physics_process(false)
		if play_magnet_audio:
			audio.play(0)
		
