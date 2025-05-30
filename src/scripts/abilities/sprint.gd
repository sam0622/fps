class_name SprintAbility
extends Ability

@export var sprint_speed_modifier := 3.5

@onready var player_base_speed := player.speed


func _ready() -> void:
	super()


func trigger() -> void:
	var dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	if dir == Vector2(0.0, -1.0):
		super()
		player.speed = player_base_speed + sprint_speed_modifier


func detrigger() -> void:
	super()
	player.speed = player_base_speed
