class_name Chaser
extends CharacterBody3D

enum States { IDLE, CHASING, ATTACKING, DEAD }

## Disable if enemy needs to detect player before attacking
@export var omnipotent := true
@export var speed := 5.0
@export var damage := 25

var state := States.IDLE
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float

@onready var agent := $NavigationAgent3D
@onready var player := get_tree().get_first_node_in_group("player")


func _ready() -> void:
	if omnipotent:
		state = States.CHASING

# TODO: Fix this 
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	if state == States.CHASING:
		var current_location := global_position
		var next_location = agent.get_next_path_position()
		velocity = (next_location - global_transform.origin).normalized() * speed
		look_at(player.position)
	if not is_on_floor():
		velocity.y -= gravity
	else:
		velocity.y = 0
	#print(agent.target_position)
	move_and_slide()

func update_target_location(target_location: Vector3) -> void:
	print("Setting target positon to: ", target_location)
	agent.set_target_position(target_location)


func set_state(new_state: States) -> void:
	state = new_state
	match state:
		States.IDLE:
			pass
		States.CHASING:
			pass
		States.ATTACKING:
			pass
		States.DEAD:
			pass
