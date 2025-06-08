class_name DashAbility
extends TapAbility

const ENEMY_COLLISON_BIT := 4

@export var speed_multiplier := 10
@export var has_iframes := true
@export var pass_through_enemies := true

var input_dir: Vector2

@onready var player_base_speed := player.speed


func _ready() -> void:
	super()


func _process(delta: float) -> void:
	input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	trigger_condition = input_dir != Vector2.ZERO


func trigger() -> void:
	super()
	player.dash_direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.speed *= speed_multiplier
	player.is_dashing = true
	if has_iframes:
		player.can_be_hit = false
	if pass_through_enemies:
		player.set_collision_mask_value(ENEMY_COLLISON_BIT, false)


func detrigger() -> void:
	super()
	player.speed = player_base_speed
	player.is_dashing = false
	player.can_be_hit = true
	if pass_through_enemies:
		player.set_collision_mask_value(ENEMY_COLLISON_BIT, true)
