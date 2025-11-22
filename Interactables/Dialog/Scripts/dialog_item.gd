@tool
@icon("res://GUI/DialogSystem/Icons/chat_bubble.svg")
class_name DialogItem extends Node

@export var npc_info: NPCResource

var editor_selection: EditorSelection
var example_dialog: DialogSystemNode

func _ready() -> void:
	if Engine.is_editor_hint():
		editor_selection = EditorInterface.get_selection()
		editor_selection.selection_changed.connect(_on_selection_changed)
		return
	check_npc_data()
	
func _on_selection_changed() -> void:
	if not editor_selection:
		return
	
	var sel = editor_selection.get_selected_nodes()
	if example_dialog:
		example_dialog.queue_free()
	
	if sel.is_empty():
		return
	if self != sel[0]:
		return
		
	example_dialog = load("res://GUI/DialogSystem/dialog_system.tscn").instantiate() as DialogSystemNode
	if not example_dialog:
		return
	self.add_child(example_dialog)
	example_dialog.offset = get_parent_global_position() + Vector2(32, -200)
	check_npc_data()
	_set_editoer_display()
	
func _set_editoer_display() -> void:
	pass
	
func get_parent_global_position() -> Vector2:
	var _p = self
	var _checking: bool = true
	while _checking:
		_p = _p.get_parent()
		if _p:
			if _p is Node2D:
				return _p.global_position
		else:
			_checking = false
	return Vector2.ZERO

func check_npc_data() -> void:
	if not npc_info:
		var p = self
		var _checking: bool = true
		while _checking:
			p = p.get_parent()
			if p:
				if p is NPC and p.npc_resource:
					npc_info = p.npc_resource
					_checking = false
			else:
				_checking = false
				
