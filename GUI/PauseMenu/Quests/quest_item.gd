extends Button
class_name QuestItem

var quest: Quest

@onready var title_label: Label = $TitleLabel
@onready var step_label: Label = $StepLabel

func initialize(_q_data: Quest, _q_state) -> void:
	quest = _q_data
	title_label.text = _q_data.title
	if _q_state.is_completed:
		step_label.text = "Completed"
		step_label.modulate = Color.LIGHT_GREEN
	else:
		var step_count: int = _q_data.steps.size()
		var completed_count: int = _q_state.completed_steps.size()
		step_label.text = "Quest step: " + str(completed_count) + "/" + str(step_count)
