class_name SprintAbility
extends HoldAbility

@export var sprint_speed_modifier := 3.5

var going_forward := false

@onready var player_base_speed := player.speed


func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	going_forward = (
		Input.is_action_pressed("moveForward") and not Input.is_action_pressed("moveBackward")
	)
	trigger_condition = going_forward
	if not going_forward and in_use:
		detrigger()


func trigger() -> void:
	super()
	player.speed = player_base_speed + sprint_speed_modifier


func detrigger() -> void:
	super()
	player.speed = player_base_speed
