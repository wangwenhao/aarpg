extends Node2D
class_name EnergyOrb

@export var speed: float = 200
@export var shoot_audio: AudioStream
@export var hit_audio: AudioStream

var direction: Vector2 = Vector2.DOWN

@onready var hurt_box: HurtBox = $HurtBox
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	hurt_box.damaged.connect(hit_player)
	play_audio(shoot_audio)
	get_tree().create_timer(5).timeout.connect(destroy)
	direction = global_position.direction_to(PlayerManager.player.global_position)
	flicker()


func _process(delta: float) -> void:
	position += direction * speed * delta


func flicker() -> void:
	modulate.a = randf() * 0.7 + 0.3
	await get_tree().create_timer(0.05).timeout
	flicker()


func hit_player() -> void:
	play_audio(hit_audio)
	hurt_box.set_deferred("monitoring", false)


func play_audio(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()


func destroy() -> void:
	queue_free()
