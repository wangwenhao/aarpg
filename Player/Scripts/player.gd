class_name Player extends CharacterBody2D

# Player：处理输入→方向→动画；生命与受伤；与状态机协作（移动/携物等）

# 四向基准（顺时针）：用于将任意输入映射到最近方向
const DIR_4: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var cardinal_direction: Vector2 = Vector2.DOWN   # 当前四向朝向
var direction: Vector2 = Vector2.ZERO            # 原始输入方向
var invulnerable: bool = false                   # 是否无敌（禁伤害窗口）
var hp: int = 6
var max_hp: int = 6


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var sprite: Sprite2D = $Sprite2D                 # 精灵，左右翻转
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var lift: StateLift = %Lift
@onready var held_item: Node2D = $Sprite2D/HeldItem
@onready var carry: StateCarry = %Carry
@onready var idle: StateIdle = %Idle


signal direction_changed(new_direction: Vector2) # 四向朝向改变
signal player_damaged(hurt_box: HurtBox)         # 受到伤害（或死亡）


func _ready() -> void:
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect(take_damage)
	update_hp(99) # 强制刷新 HUD


func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()


func _physics_process(_delta: float) -> void:
	move_and_slide()

func _unhandled_input(_event: InputEvent) -> void:
	#if event.is_action_pressed("test"):
		#PlayerManager.shake_camera()
	pass

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction = DIR_4[direction_id]
	if new_direction == cardinal_direction:
		return false
	cardinal_direction = new_direction
	direction_changed.emit(new_direction)
	sprite.scale.x = -1.0 if cardinal_direction == Vector2.LEFT else 1.0
	return true


func update_animation(state: String) -> void:
	animation_player.play(state + "_" + animation_direction())


func animation_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	return "side"


func take_damage(hurt_box: HurtBox) -> void:
	if invulnerable:
		return
	update_hp(-hurt_box.damage)
	player_damaged.emit(hurt_box)


func update_hp(delta: int) -> void:
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHud.update_hp(hp, max_hp)


func make_invulnerable(duration: float = 1.0) -> void:
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer(duration).timeout
	invulnerable = false
	hit_box.monitoring = true


func pickup_item(item: Throwable) -> void:
	state_machine.change_state(lift)
	carry.throwable = item


func revive_player() -> void:
	state_machine.change_state(idle)

