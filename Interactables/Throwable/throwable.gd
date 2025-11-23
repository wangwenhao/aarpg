extends Area2D
class_name Throwable

@export var gravity_strength: float = 980
@export var throw_speed: float = 400.0
@export var throw_height_strength: float = 100.0
@export var throw_starting_height: float = 49

var picked_up: bool = false
var throwable: Node2D
var throw_direction: Vector2
var object_sprite: Sprite2D
var vertical_velocity: float = 0
var ground_height: float = 0
var animation_player: AnimationPlayer

@onready var hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	throwable = get_parent()
	setup_hurt_box()
	
	object_sprite = throwable.find_child("Sprite2D")
	ground_height = object_sprite.position.y
	animation_player = throwable.find_child("AnimationPlayer")
	
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	object_sprite.position.y += vertical_velocity * delta
	if object_sprite.position.y >= ground_height:
		destroy()
	vertical_velocity += gravity_strength * delta
	throwable.position += throw_direction * throw_speed * delta

func setup_hurt_box() -> void:
	hurt_box.monitoring = false
	for child in get_children():
		if child is CollisionShape2D:
			var _coll: CollisionShape2D = child.duplicate()
			hurt_box.add_child(_coll)
			_coll.debug_color = Color(1, 0, 0, 0.5)


func _on_area_entered(_area: Area2D) -> void:
	PlayerManager.interact_pressed.connect(_player_interact)


func _on_area_exited(_area: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(_player_interact)


func _player_interact() -> void:
	if PlayerManager.interact_handled:
		return
	if not picked_up:
		PlayerManager.interact_handled = true
		disable_collisions(throwable)
		if throwable.get_parent():
			throwable.get_parent().remove_child(throwable)
		PlayerManager.player.held_item.add_child(throwable)
		throwable.position = Vector2.ZERO
		PlayerManager.player.pickup_item(self)
		area_entered.disconnect(_on_area_entered)
		area_exited.disconnect(_on_area_exited)

func throw() -> void:
	throwable.get_parent().remove_child(throwable)
	PlayerManager.player.get_parent().call_deferred("add_child", throwable)
	throwable.position = PlayerManager.player.position
	object_sprite.position.y = -throw_starting_height
	vertical_velocity = -throw_height_strength
	set_physics_process(true)
	hurt_box.set_deferred("monitoring", true)
	hurt_box.damaged.connect(destroy)
	
func drop() -> void:
	throwable.get_parent().remove_child(throwable)
	PlayerManager.player.get_parent().call_deferred("add_child", throwable)
	throwable.position = PlayerManager.player.position
	object_sprite.position.y = -50
	vertical_velocity = -200
	throw_speed = 100
	set_physics_process(true)


func destroy() -> void:
	set_physics_process(false)
	hurt_box.set_deferred("monitoring", false)
	if animation_player:
		animation_player.play("destroy")
		await animation_player.animation_finished
	throwable.queue_free()

func disable_collisions(node: Node) -> void:
	for child in node.get_children():
		if child == self:
			continue
		if child is CollisionShape2D:
			child.disabled = true
		else:
			disable_collisions(child)
