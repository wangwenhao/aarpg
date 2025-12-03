extends CanvasLayer

# 暂停菜单控制脚本
# 功能：显示/隐藏暂停菜单、保存/载入、切换选项卡、展示物品描述、播放菜单音效

signal shown   # 菜单显示时发出
signal hidden  # 菜单隐藏时发出


@onready var button_save: Button = %Button_Save
@onready var button_load: Button = %Button_Load
@onready var button_quit: Button = %Button_Quit
@onready var item_description: Label = %ItemDescription
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer

var is_paused: bool = false


func _ready() -> void:
	# 启动时隐藏暂停菜单（默认进入游戏时不显示）
	hide_pause_menu()


func _unhandled_input(event: InputEvent) -> void:
	# 处理未捕获的输入：拦截暂停按键并在暂停时响应左右 bumper 切换 Tab
	if event.is_action_pressed("pause"):
		if is_paused:
			hide_pause_menu()
		else:
			# 若有对话系统处于活动状态，则不打开暂停菜单以避免冲突
			if DialogSystem.is_active:
				return
			show_pause_menu()
		# 标记该输入已被处理，避免继续传递给游戏其他逻辑
		get_viewport().set_input_as_handled()

	# 当处于暂停状态时，支持用左右 bumper 快速切换选项卡
	if is_paused:
		if event.is_action_pressed("right_bumper"):
			change_tab(1)
		elif event.is_action_pressed("left_bumper"):
			change_tab(-1)


func change_tab(_i: int = 1) -> void:
	# 在 TabContainer 中循环切换选项卡，并把焦点放到 TabBar 上
	tab_container.current_tab = wrapi(
		tab_container.current_tab + _i,
		0,
		tab_container.get_tab_count()
	)
	tab_container.get_tab_bar().grab_focus()


func show_pause_menu() -> void:
	# 显示暂停菜单并暂停游戏主树的处理
	get_tree().paused = true
	visible = true
	is_paused = true
	tab_container.current_tab = 0
	shown.emit()


func hide_pause_menu() -> void:
	# 隐藏暂停菜单并恢复游戏运行
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()


func _on_button_save_pressed() -> void:
	# 点击保存：仅在处于暂停状态时有效
	if !is_paused:
		return
	SaveManager.save_game()
	hide_pause_menu()


func _on_button_load_pressed() -> void:
	# 点击载入：载入时等待 LevelManager 开始加载新关卡，再关闭暂停菜单
	if !is_paused:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()


func update_item_description(text: String) -> void:
	# 更新物品描述文本（供外部调用以显示当前选中物品信息）
	item_description.text = text


func play_audio(audio: AudioStream) -> void:
	# 在菜单中播放音效（例如选项切换或确认声）
	audio_stream_player.stream = audio
	audio_stream_player.play()


func _on_button_quit_pressed() -> void:
	# 退出游戏（直接结束进程）
	get_tree().quit()
