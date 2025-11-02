class_name StateAttack extends State

@export var attack_sound: AudioStream
@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0

var attacking: bool = false
@onready var attack_animation_player: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AttackAnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter() -> void:
	player.update_animation("attack")
	attack_animation_player.play("attack_" + player.animition_direction())
	player.animation_player.animation_finished.connect(end_attack)
	
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
	attacking = true

func exit() -> void:
	player.animation_player.animation_finished.disconnect(end_attack)
	attacking = false
	pass

func process(delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * delta
	if !attacking:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null
	
func physics_process(_delta: float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null

func end_attack(_new_animation_name: String) -> void:
	attacking = false
