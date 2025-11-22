# 玩家状态基类
class_name State extends Node

static var player: Player
static var state_machine: PlayerStateMachine

#region /// 玩家状态的引用
@onready var idle: StateIdle = %Idle
@onready var walk: StateWalk = %Walk
@onready var attack: StateAttack = %Attack
@onready var stun: StateStun = %Stun
@onready var charge_attack: StateChargeAttack = %ChargeAttack
#endregion

func init() -> void:
	pass

func _ready() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null
