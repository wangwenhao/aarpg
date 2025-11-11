class_name EnemyStateDestory extends EnemyState

const PICKUP = preload("res://Items/ItemPickup/item_pickup.tscn")

@export var animation_name: String = "destory"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export_category("AI")

@export_category("Item Drops")
@export var drops: Array[DropData]

var damage_position: Vector2
var direction: Vector2

func init() -> void:
	enemy.emeny_destoryed.connect( on_enemy_destroyed )

func enter() -> void:
	enemy.invulnerable = true

	direction = enemy.global_position.direction_to(damage_position)
	
	enemy.set_direction(direction)
	enemy.velocity = direction * -knockback_speed
	
	enemy.update_animation(animation_name)
	enemy.animation_player.animation_finished.connect(on_animation_finished)
	disable_hurt_box()
	drop_items()


func exit() -> void:
	pass

func process(delta: float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * delta
	return null

func physics_process(_delta: float) -> EnemyState:
	return null

func handle_input(_event: InputEvent) -> EnemyState:
	return null
	
func on_enemy_destroyed(hurt_box: HurtBox) -> void:
	damage_position = hurt_box.global_position
	state_machine.change_state(self)
	
func on_animation_finished(_animation_name) -> void:
	enemy.queue_free()
	
func disable_hurt_box() -> void:
	var hurt_box: HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false


func drop_items() -> void:
	if drops.size() == 0:
		return
		
	for index in drops.size():
		if drops[index] == null or drops[index].item == null:
			continue
		var drop_count: int = drops[index].get_drop_count()
		for i in drop_count:
			var drop: ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[index].item
			enemy.get_parent().call_deferred("add_child", drop)
			drop.global_position = enemy.global_position
			drop.velocity = enemy.velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
		
