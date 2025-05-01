class_name Enemy
extends CharacterBody3D

enum States { IDLE, CHASING, ATTACKING, DEAD }

@export var omnipotent := true
@export var move_speed := 5.0
@export var health := 2: set = set_health
@export var damage := 25

var state := States.IDLE
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float
var update_frequency = randi_range(15, 22)

@onready var agent := get_node("NavigationAgent3D")
@onready var player := get_tree().get_first_node_in_group("player")


func _ready() -> void:
	if omnipotent:
		state = States.CHASING


func _physics_process(delta: float) -> void:
	if GameManager.frame % update_frequency == 0:
		update_target_location(player.global_transform.origin)
	move_and_slide()


func set_health(new_health: int):
	health = new_health
	print(health <= 0)
	if health <= 0:
		set_state(States.DEAD)


func set_state(new_state: States) -> void:
	state = new_state
	match state:
		States.IDLE:
			pass
		States.CHASING:
			pass
		States.ATTACKING:
			attack()
		States.DEAD:
			die()


func state_to_string() -> String:
	match state:
		States.IDLE:
			return "IDLE"
		States.CHASING:
			return "CHASING"
		States.ATTACKING:
			return "ATTACKING"
		States.DEAD:
			return "DEAD"
		_:
			return ""


func attack():
	pass


func on_hit(damage: int):
	print("hit")
	health -= damage
	print(health)


func die():
	queue_free()


func update_target_location(target_location: Vector3) -> void:
	agent.set_target_position(target_location)


func _on_navigation_agent_3d_target_reached() -> void:
	pass
