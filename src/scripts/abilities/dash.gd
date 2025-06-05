class_name DashAbility
extends TapAbility

const ENEMY_COLLISON_BIT := 4

@export var speed_multiplier := 10
@export var has_iframes := true
@export var pass_through_enemies := true

@onready var player_base_speed := player.speed


func _ready() -> void:
	super()


func trigger() -> void:
	super()
	player.speed *= speed_multiplier
	if has_iframes:
		player.can_be_hit = false
	if pass_through_enemies:
		player.set_collision_mask_value(ENEMY_COLLISON_BIT, false)


func detrigger() -> void:
	super()
	player.speed = player_base_speed
	player.can_be_hit = true
	if pass_through_enemies:
		player.set_collision_mask_value(ENEMY_COLLISON_BIT, true)
