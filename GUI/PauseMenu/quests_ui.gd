extends Control
class_name QuestUI

# 任务界面控制器
# 说明：
# - 展示当前任务列表，并在选中任务时显示该任务的标题、描述与步骤
# - 当界面可见时，从 `QuestManager` 加载并实例化任务项（`quest_item.tscn`）
# - 任务项获得焦点时触发 `_update_quest_details` 来填充右侧的任务详情

const QUEST_ITEM: PackedScene = preload("res://GUI/PauseMenu/Quests/quest_item.tscn")
const QUEST_STEP_ITEM: PackedScene = preload("res://GUI/PauseMenu/Quests/quest_step_item.tscn")

# UI 节点引用（在场景中通过路径挂载）
@onready var quest_item_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var details_container: VBoxContainer = $VBoxContainer


func _ready() -> void:
	# 启动时清空详情区并监听可见性变化
	clear_quest_details()
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	# 当界面显示状态改变时刷新任务项列表与详情
	# 先释放旧的任务项节点，避免重复
	for i in quest_item_container.get_children():
		i.queue_free()

	clear_quest_details()

	# 仅在面板可见时加载并创建任务项（节省资源）
	if visible:
		# 让 QuestManager 按某种标准排序（例如重要性或时间）
		QuestManager.sort_quests()
		# 打印当前任务数组（便于调试）
		print(QuestManager.current_quests)
		for _q in QuestManager.current_quests:
			# 通过标题查找完整的任务定义数据（包含步骤、描述等）
			var quest_data: Quest = QuestManager.find_quest_by_title(_q.title)
			if not quest_data:
				continue

			# 实例化任务条目并初始化显示数据
			var new_quest_item = QUEST_ITEM.instantiate()
			quest_item_container.add_child(new_quest_item)
			new_quest_item.initialize(quest_data, _q)

			# 当该任务项获得焦点时，更新右侧详情区域
			# 这里使用 bind 把对应的任务数据绑定到回调参数上
			new_quest_item.focus_entered.connect(_update_quest_details.bind(new_quest_item.quest))


func _update_quest_details(_quest: Quest) -> void:
	# 填充任务详情：标题、描述以及每个步骤的完成状态
	clear_quest_details()
	title_label.text = _quest.title
	description_label.text = _quest.description

	# 从保存的数据中查询该任务的进度，用于判断哪些步骤已完成
	var quest_save = QuestManager.find_quest(_quest)

	for step in _quest.steps:
		var new_step: QuestStepItem = QUEST_STEP_ITEM.instantiate()
		var step_is_complete: bool = false
		# 如果保存数据存在，检测该步骤是否在 completed_steps 集合中
		if quest_save.title != "not found":
			step_is_complete = quest_save.completed_steps.has(step.to_lower())
		details_container.add_child(new_step)
		new_step.initialize(step, step_is_complete)


func clear_quest_details() -> void:
	# 清空详情区域的文本与步骤项
	title_label.text = ""
	description_label.text = ""
	# 仅释放属于 QuestStepItem 的子节点，避免误释放其他节点
	for child in details_container.get_children().filter(func(_c): return _c is QuestStepItem):
		child.queue_free()
