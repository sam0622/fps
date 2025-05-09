class_name Chaser
extends CharacterBody3D

enum States { IDLE, CHASING, ATTACKING, DEAD }

@export var omnipotent := true
@export var move_speed := 5.0
@export var health := 2: set = set_health
@export var damage := 25

var state := States.IDLE
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float
var update_frequency := randi_range(15, 22)

@onready var agent := get_node("NavigationAgent3D")
@onready var player := get_tree().get_first_node_in_group("player")


func _ready() -> void:
	if omnipotent:
		state = States.CHASING
	$DespawnTimer.wait_time = GameManager.enemy_despawn_time


func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	print($BodyCollider.disabled)
	# Chase player
	if state == States.CHASING:
		if Engine.get_frames_drawn() % update_frequency == 0:
			update_target_location(player.global_transform.origin)
		var next_location := agent.get_next_path_position() as Vector3
		velocity = (next_location - global_transform.origin).normalized() * move_speed
		look_at(player.position)
		if agent.is_navigation_finished():
			attack()
	
	if state == States.DEAD:
		return
	move_and_slide()


func set_health(new_health: int) -> void:
	health = new_health
	print(health <= 0)
	if health <= 0:
		die()


func set_state(new_state: States) -> void:
	state = new_state
	match state:
		States.IDLE:
			set_physics_process(true)
		States.CHASING:
			set_physics_process(true)
		States.ATTACKING:
			set_physics_process(true)
		States.DEAD:
			set_physics_process(false)


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


func attack() -> void:
	set_state(States.ATTACKING)
	$AnimationPlayer.play("jump")
	await get_tree().create_timer(0.15)
	$AnimationPlayer.play("attack")
	#set_state(States.CHASING)


func on_hit(damage: int) -> void:
	if state != States.DEAD:
		health -= damage
		print(health)


func die() -> void:
	set_physics_process(false)
	set_state(States.DEAD)
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	$DespawnTimer.start()
	await $DespawnTimer.timeout
	queue_free()


func update_target_location(target_location: Vector3) -> void:
	agent.set_target_position(target_location)


func _on_navigation_agent_3d_target_reached() -> void:
	velocity = Vector3.ZERO
	attack()
