class_name SprintAbility
extends Ability

@export var sprint_speed_modifier := 3.5

@onready var player_base_speed := player.speed


func trigger() -> void:
	player.speed = player_base_speed + sprint_speed_modifier


func detrigger() -> void:
	player.speed = player_base_speed
