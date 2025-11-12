extends Node  # 全局保存管理器，负责读取和写入游戏存档

const SAVE_PATH = "user://"  # 存档根路径，使用 Godot 的用户数据目录

signal game_loaded  # 当存档加载并完成后发射
signal game_saved  # 当存档成功保存后发射

var current_save: Dictionary = {  # 当前内存中的存档数据结构（示例/初始值）
	scene_path = "",  # 场景路径（字符串）
	player = {
		hp = 1,  # 玩家当前生命值
		max_hp = 1,  # 玩家最大生命值
		pos_x = 0,  # 玩家在场景中的 X 坐标
		pos_y = 0  # 玩家在场景中的 Y 坐标
	},
	items = [],  # 玩家背包或道具的序列化数据
	persistence = [],  # 可选：持久化的全局状态数据
	quests = []  # 可选：任务进度数据
}


func save_game() -> void:
	# 将当前游戏状态写入到磁盘（JSON 格式的单行存档）
	update_scene_path()  # 更新当前场景路径到 current_save
	update_player_data()  # 更新玩家位置和血量到 current_save
	update_item_data()  # 更新玩家物品数据到 current_save

	# 打开（或创建）存档文件并以写模式写入 JSON 字符串
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	var save_json = JSON.stringify(current_save)  # 把字典序列化为 JSON 字符串
	file.store_line(save_json)  # 将 JSON 写为一行（便于读取）

	# 发射保存完成信号，供 UI 或其他系统响应
	game_saved.emit()


func load_game() -> void:
	# 从磁盘读取存档并应用到当前游戏状态
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)  # 以只读方式打开存档
	var json := JSON.new()
	json.parse(file.get_line())  # 解析存档文件中的 JSON（假设为单行）
	var save_dict : Dictionary = json.data as Dictionary
	current_save = save_dict  # 将解析得到的字典放入 current_save

	# 使用 LevelManager 加载存档中记录的场景，并等待加载开始信号
	LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	await LevelManager.level_load_started

	# 加载后设置玩家位置与生命等数据
	PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	PlayerManager.set_health(current_save.player.hp, current_save.player.max_hp)
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)  # 将物品数据解析到背包系统

	# 等待场景真正加载完成，再通知其他系统
	await LevelManager.level_loaded

	# 发射存档加载完成信号
	game_loaded.emit()


func update_player_data() -> void:
	# 从 PlayerManager 中读取玩家当前状态并写回到 current_save
	var player: Player = PlayerManager.player
	current_save.player.hp = player.hp
	current_save.player.max_hp = player.max_hp
	current_save.player.pos_x = player.global_position.x
	current_save.player.pos_y = player.global_position.y


func update_scene_path() -> void:
	# 在场景树中查找当前活跃的 Level 节点，获取其 scene_file_path 并保存
	var path: String = ""
	for child in get_tree().root.get_children():
		if child is Level:
			path = child.scene_file_path
	current_save.scene_path = path


func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()

func add_persistent_value(value: String) -> void:
	if check_persistent_value(value):
		return
	current_save.persistence.append(value)

func check_persistent_value(value: String) -> bool:
	var p = current_save.persistence as Array
	return p.has(value)
