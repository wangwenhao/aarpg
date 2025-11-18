class_name PlayerAbilities extends Node

# 玩家能力管理器（作为玩家节点的子节点或同层节点使用）
# 负责处理玩家技能输入并实例化相应能力对象（如回旋镖）

# 预加载能力场景/资源以便快速实例化
const BOOMERANG = preload("res://Player/Abilities/Boomerang/boomerang.tscn")

# 能力枚举：用于在运行时选择当前激活的能力
enum abilities {
	BOOMERANG,
	GRAPPLE
}

# 当前选中的能力（可扩展为 UI 切换）
var selected_ability = abilities.BOOMERANG
# 引用玩家实例（从 PlayerManager 获取）
var player: Player
# 对于一次性/独特的能力实例，保存引用以避免重复投掷或重复实例化
var boomerang_instance: Boomerang = null

func _ready() -> void:
	# 在节点就绪时从全局 PlayerManager 获取玩家引用
	player = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	# 处理未被其他节点消费的输入。按下配置的 "ability" 动作时触发当前技能
	if !event.is_action_pressed("ability"):
		return

	# 根据当前选择的能力分发到相应函数
	if selected_ability == abilities.BOOMERANG:
		boomerang_ability()

func boomerang_ability() -> void:
	# 如果已有回旋镖实例在场（尚未回收），则忽略本次投掷，防止重复投掷
	if boomerang_instance:
		return

	# 实例化回旋镖并将其放在玩家同层（便于在场景树中管理）
	var b = BOOMERANG.instantiate() as Boomerang
	player.add_sibling(b)
	b.global_position = player.global_position

	# 计算投掷方向：优先使用玩家当前输入方向（连续向量），若无输入则使用玩家的四向主朝向
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction

	# 发起投掷并记录实例引用（用于后续检测或冷却）
	b.throw(throw_direction)
	boomerang_instance = b

