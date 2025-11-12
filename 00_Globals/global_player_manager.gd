extends Node  # 全局玩家管理器：负责创建、持有玩家实例以及提供全局玩家相关 API

const PLAYER = preload("uid://bf4esf57fcnh8")  # 预加载玩家场景资源（使用 Godot 的 UID 引用）
const INVENTORY_DATA: InventoryData = preload("uid://din0bypbjigj3")  # 预加载背包数据资源/脚本

signal interact_pressed

var player: Player  # 当前在场景中的玩家实例引用（在 add_player_instance 后赋值）
var player_spawned: bool = false  # 标记玩家是否已生成并被添加到场景树


func _ready() -> void:
	# 节点准备好后立即创建玩家实例并稍作延迟以等待其他系统准备完毕
	add_player_instance()
	await get_tree().create_timer(0.2).timeout  # 等待短时间（例如等待相机/关卡节点初始化）
	player_spawned = true


func add_player_instance() -> void:
	# 实例化预加载的玩家资源并将其加入到当前节点下作为子节点
	player = PLAYER.instantiate()
	add_child(player)


func set_health(hp: int, max_hp: int) -> void:
	# 设置玩家的最大生命和当前生命值，然后更新 UI（或内部显示）
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)  # 通过 update_hp 触发 UI 或其它依赖的刷新（参数为变化量，可为 0）


func set_player_position(new_position: Vector2) -> void:
	# 直接设置玩家全局位置（通常在场景切换或复位后调用）
	player.global_position = new_position


func set_as_parent(parent: Node2D) -> void:
	# 把玩家从当前父节点移除并添加到指定父节点下（改变节点层级）
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)


func unparent_player(parent: Node2D) -> void:
	# 将玩家从给定父节点中移除（注意：移除后需确保玩家被重新加入到场景树的某处或被销毁）
	parent.remove_child(player)
