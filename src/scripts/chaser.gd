class_name Chaser
extends CharacterBody3D

enum States { IDLE, CHASING, ATTACKING, DEAD }

@export var omnipotent := true
@export var move_speed := 5.0
@export var health := 2: set = set_health
@export var damage := 25
@export var corpse_scene: PackedScene

var state := States.IDLE
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float
var update_frequency := randi_range(15, 22)
var can_attack := false

@onready var agent := get_node("NavigationAgent3D")
@onready var player := get_tree().get_first_node_in_group("player")


func _ready() -> void:
	if omnipotent:
		state = States.CHASING
	$DespawnTimer.wait_time = GameManager.enemy_despawn_time


func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity
	# Chase player
	if state == States.CHASING:
		if Engine.get_frames_drawn() % update_frequency == 0:
			update_target_location(player.global_transform.origin)
		var next_location := agent.get_next_path_position() as Vector3
		velocity = (next_location - global_transform.origin).normalized() * move_speed
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
			$AnimationPlayer.play("Root_Idle")
		States.CHASING:
			set_physics_process(true)
			$AnimationPlayer.play("Root_Run")
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
	print("attacking")
	await get_tree().create_timer(.5).timeout
	can_attack = false
	$AttackCooldown.start()
	set_state(States.ATTACKING)


func on_hit(damage: int) -> void:
	if state != States.DEAD:
		health -= damage
		print(health)


func die() -> void:
	set_physics_process(false)
	set_state(States.DEAD)
	collision_layer = 0
	self.visible = false
	var instance := corpse_scene.instantiate() as RigidBody3D
	instance.global_position = global_position
	instance.rotation = rotation
	GameManager.main.add_child(instance)
	queue_free()


func update_target_location(target_location: Vector3) -> void:
	agent.set_target_position(target_location)


func _on_navigation_agent_3d_target_reached() -> void:
	velocity = Vector3.ZERO
	print("nav finished")
	if can_attack:
		attack()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
