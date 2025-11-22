# 玩家状态基类
class_name StateChargeAttack extends State

@export var charge_duration: float = 1.0
@export var move_speed: float = 80.0
@export var sfx_charged: AudioStream
@export var sfx_spin: AudioStream

@onready var charge_hurt_box: HurtBox = %ChargeHurtBox
@onready var charge_spin_hurt_box: HurtBox = %ChargeSpinHurtBox
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var spin_effect_sprite: Sprite2D = $"../../Sprite2D/SpinEffectSprite2D"
@onready var spin_animation_player: AnimationPlayer = $"../../Sprite2D/SpinEffectSprite2D/SpinAnimationPlayer"
@onready var gpu_particles_2d: GPUParticles2D = $"../../Sprite2D/ChargeHurtBox/GPUParticles2D"


var timer: float = 0.0
var is_walking: bool = false
var is_attacking: bool = false
var particles: ParticleProcessMaterial

func init() -> void:
	spin_effect_sprite.visible = false
	particles = gpu_particles_2d.process_material as ParticleProcessMaterial
	gpu_particles_2d.emitting = false
	pass

func _ready() -> void:
	pass

func enter() -> void:
	timer = charge_duration
	is_attacking = false
	is_walking = false
	charge_hurt_box.monitoring = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d.amount = 4
	gpu_particles_2d.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30

func exit() -> void:
	charge_hurt_box.monitoring = false
	charge_spin_hurt_box.monitoring = false
	spin_effect_sprite.visible = false
	gpu_particles_2d.emitting = false

func process(delta: float) -> State:
	if timer > 0:
		timer -= delta
		if timer <= 0:
			timer =0
			charge_completed()
	
	if not is_attacking:
		if player.direction == Vector2.ZERO:
			is_walking = false
			player.update_animation("charge")
		elif player.set_direction() or not is_walking:
			is_walking = true
			player.update_animation("charge_walk")
		
	player.velocity = player.direction * move_speed
	return null

func physics_process(_delta: float) -> State:
	return null

func handle_input(event: InputEvent) -> State:
	if event.is_action_released("attack"):
		if timer > 0:
			return idle
		elif not is_attacking:
			_charge_attack()
	return null


func _charge_attack() -> void:
	is_attacking = true
	player.animation_player.play("charge_attack")
	player.animation_player.seek(get_spin_frame())
	play_audio(sfx_spin)
	spin_effect_sprite.visible = true
	spin_animation_player.play("spin")
	
	var _duration: float = player.animation_player.current_animation_length
	player.make_invulnerable(_duration)
	charge_spin_hurt_box.monitoring = true
	
	await get_tree().create_timer(_duration * 0.875).timeout
	state_machine.change_state(idle)


func get_spin_frame() -> float:
	var interval: float = 0.05
	match player.cardinal_direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		_:
			return interval * 6

func play_audio(audio: AudioStream) -> void:
	audio_stream_player_2d.stream = audio
	audio_stream_player_2d.play()

func charge_completed() -> void:
	play_audio(sfx_charged)
	
	gpu_particles_2d.amount = 50
	gpu_particles_2d.explosiveness = 1
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	await get_tree().create_timer(0.5).timeout
	gpu_particles_2d.amount = 10
	gpu_particles_2d.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30
	
	
