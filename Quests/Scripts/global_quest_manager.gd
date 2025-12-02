extends Node

# 全局任务管理器：负责加载任务数据资源、维护当前进行中的任务进度、发放奖励
# 使用方式：通过 update_quest(title, completed_step, is_complete) 来递增步骤或完成任务
# 对外发信号：quest_updated(quest_dict) —— UI 或日志系统可订阅该信号刷新显示

signal quest_updated(quest)  # 当任务字典被新增或更新时发出，参数为当前任务的字典表示

const QUEST_DATA_LOCATION: String = "res://Quests/"  # 任务资源所在目录，预期存放 .tres 任务配置

var quests: Array[Quest]        # 所有已加载的任务资源（Quest 类型）
var current_quests: Array = []  # 当前正在进行或已完成的任务的字典列表（运行时进度）

func _ready() -> void:
	# 启动时扫描任务资源目录加载所有 Quest 数据
	gather_quest_data()


func _unhandled_input(event: InputEvent) -> void:
	# 调试入口（已注释）：可在此绑定快捷键测试任务相关函数
	# 保留空实现用于避免输入继续冒泡不必要处理
	pass


func gather_quest_data() -> void:
	# 从指定目录读取所有文件并尝试加载为 Quest 资源
	var quest_files: PackedStringArray = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for _quest in quest_files:
		quests.append(load(QUEST_DATA_LOCATION + "/" + _quest) as Quest)


func update_quest(_title: String, _completed_step: String = "", _is_complete: bool = false) -> void:
	# 更新或新增一个任务的进度：
	# _title           任务标题（用于匹配 Quest 资源与当前任务字典）
	# _completed_step  新增已完成的子步骤（可为空字符串表示不添加步骤）
	# _is_complete     是否标记任务为已完成
	var quest_index: int = get_quest_index_by_title(_title)
	if quest_index == -1:
		# 尚未在 current_quests 中，构建一个新的任务字典并加入
		var new_quest: Dictionary = {
			title = _title,
			is_completed = _is_complete,
			completed_steps = []
		}
		if _completed_step != "":
			new_quest.completed_steps.append(_completed_step.to_lower())
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)  # 发出任务更新信号供 UI 刷新
	else:
		# 已存在则增量更新其步骤与完成状态
		var q = current_quests[quest_index]
		if _completed_step != "" and not q.completed_steps.has(_completed_step):
			q.completed_steps.append(_completed_step.to_lower())
		q.is_completed = _is_complete
		quest_updated.emit(q)
		# 若任务完成，触发奖励发放（基于 Quest 资源的奖励定义）
		if q.is_completed:
			disperse_quest_rewards(find_quest_by_title(q.title))


func disperse_quest_rewards(_quest: Quest) -> void:
	# 发放任务奖励：经验 + 物品列表
	PlayerManager.reward_xp(_quest.reward_xp)
	for _item in _quest.reward_items:
		PlayerManager.INVENTORY_DATA.add_item(_item.item, _item.quantity)


func find_quest(_quest: Quest) -> Dictionary:
	# 在当前任务列表中根据 Quest 资源的标题查找对应的字典进度
	for _q in current_quests:
		if _q.title == _quest.title:
			return _q
	# 未找到时返回一个占位字典，用于防御性处理
	return {title = "not found", is_completed = false, completed_steps = [''] }


func find_quest_by_title(_title: String) -> Quest:
	# 在已加载的 Quest 资源中按标题（不区分大小写）查找
	for _q in quests:
		if _q.title.to_lower() == _title.to_lower():
			return _q
	return null


func get_quest_index_by_title(_title: String) -> int:
	# 获取当前任务列表中指定标题的下标，未找到返回 -1
	for _i in current_quests.size():
		if current_quests[_i].title.to_lower() == _title.to_lower():
			return _i
	return -1


func sort_quests() -> void:
	# 按“进行中”与“已完成”分组，然后分别按标题排序，最后合并（进行中在前、已完成在后）
	var active_quests: Array = []
	var completed_quests: Array = []
	for _q in current_quests:
		if _q.is_completed:
			completed_quests.append(_q)
		else:
			active_quests.append(_q)

	# 自定义排序：按标题字母序排列
	active_quests.sort_custom(func(a, b): return a.title < b.title)
	completed_quests.sort_custom(func(a, b): return a.title < b.title)

	current_quests = active_quests
	current_quests.append_array(completed_quests)