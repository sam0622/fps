class_name SprintAbility
extends Ability

@export var sprint_speed_modifier := 3.5

var going_forward := false

@onready var player_base_speed := player.speed


func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	going_forward = Input.is_action_pressed("moveForward") and not Input.is_action_pressed("moveBackward")
	if not going_forward and in_use:
		detrigger()


func trigger() -> void:
	if going_forward:
		super()
		player.speed = player_base_speed + sprint_speed_modifier


func detrigger() -> void:
	super()
	player.speed = player_base_speed
