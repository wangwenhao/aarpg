@icon("res://NPC/Icons/npc_behavior.svg")
class_name NPCBehavior extends Node2D

var npc: NPC

func _ready() -> void:
	var parent = get_parent()
	if parent is NPC:
		npc = parent
		npc.do_behavior_enabled.connect(start)
		

func start() -> void:
	pass
