@tool
@icon("res://GUI/DialogSystem/Icons/question_bubble.svg")
class_name DialogChoice extends DialogItem

var dialog_branches: Array[DialogBranch]

func _ready() -> void:
	super()
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

func _set_editoer_display() -> void:
	_set_related_text()
	if dialog_branches.size() < 2:
		return
	example_dialog.set_dialog_choice(self)


func _set_related_text() -> void:
	var _text = get_parent().get_child(self.get_index() - 1)
	if _text and _text is DialogText:
		example_dialog.set_dialog_text(_text)
		example_dialog.content.visible_characters = -1
