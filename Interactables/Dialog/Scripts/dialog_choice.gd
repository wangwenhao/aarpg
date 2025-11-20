@tool
@icon("res://GUI/DialogSystem/Icons/question_bubble.svg")
class_name DialogChoice extends DialogItem

var dialog_branches: Array[DialogBranch]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for child in get_children():
		if child is DialogBranch:
			dialog_branches.append(child)

func _get_configuration_warnings() -> PackedStringArray:
	if not _check_for_dialog_branches():
		return ["Require at least 2 DialogBranches node."]
	else:
		return []
		
func _check_for_dialog_branches() -> bool:
	return get_children().filter(func (child): return child is DialogBranch).size() > 1
