## A basic enemy that chases the player and then attacks them.
class_name Chaser
extends CharacterBody3D

enum States { IDLE, CHASING, ATTACKING, DEAD }

## Whether the enemy always knows where the player is
@export var omnipotent := true
@export var move_speed := 5.0
@export var health := 5: set = set_health
@export var damage := 25
@export var corpse_scene: PackedScene

var state := States.IDLE: set = set_state ## The chaser's current state, defaults to [code]IDLE[/code]
var update_frequency := randi_range(15, 22) ## Staggers AI update time by a random amount of frames to avoid stutters
var can_attack := false

@onready var agent := get_node("NavigationAgent3D") as NavigationAgent3D ## The chaser's [NavigationAgent3D]
@onready var player := get_tree().get_first_node_in_group("player") as Player


## Sets initial state and prepares timers
func _ready() -> void:
	if omnipotent:
		state = States.CHASING
	else:
		state = States.IDLE
	$DespawnTimer.wait_time = GameManager.enemy_despawn_time


## Handles AI chase logic and GameManager.gravity
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= GameManager.gravity
	# Chase player
	if state == States.CHASING:
		if Engine.get_frames_drawn() % update_frequency == 0:
			update_target_location(player.global_transform.origin)
		
		var next_location := agent.get_next_path_position() as Vector3
		var v := (next_location - global_transform.origin).normalized() * move_speed
		velocity.x = v.x
		velocity.z = v.z
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		if agent.is_navigation_finished():
			attack()

	move_and_slide()


## If health is zero or less, die
func set_health(new_health: int) -> void:
	health = new_health
	if health <= 0:
		die()


## Sets the chaser's state
## Will play animations and set other things according to state
func set_state(new_state: States) -> void:
	state = new_state
	match state:
		States.IDLE:
			set_physics_process(true)
			$AnimationPlayer.play("Root_Idle")
		States.CHASING:
			set_physics_process(true)
			$AnimationPlayer.speed_scale = 2.0
			$AnimationPlayer.play("Root_Run")
		States.ATTACKING:
			set_physics_process(true)
		States.DEAD:
			set_physics_process(false)


## Returns the chaser's [code]state[/code] as a string for debugging purposes
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
	state = States.ATTACKING
	print("attacking")
	await get_tree().create_timer(.5).timeout
	can_attack = false
	$AttackCooldown.start()
	state = States.ATTACKING


## Decrements health when hit by player
func on_hit(dmg: int) -> void:
		health -= dmg


## Creates ragdoll at position, then deletes the chaser
func die() -> void:
	set_physics_process(false)
	state = States.DEAD
	collision_layer = 0
	self.visible = false
	var instance := corpse_scene.instantiate() as Skeleton3D
	instance.global_position = global_position
	instance.rotation = rotation
	GameManager.main.add_child(instance)
	queue_free()


## Can be called to manually update targets location
## Not recommended for use as it bypasses the update staggering
##
## @deprecated
func update_target_location(target_location: Vector3) -> void:
	agent.set_target_position(target_location)



func _on_navigation_agent_3d_target_reached() -> void:
	velocity = Vector3.ZERO
	print("nav finished")
	if can_attack:
		attack()


## Allows the chaser to attack again
func _on_attack_cooldown_timeout() -> void:
	can_attack = true


## Will handle damaging the [player] when attacking, currently unimplemented
##
## @experimental
func _on_hitbox_body_entered(body: Node3D) -> void:
	if state == States.ATTACKING:
		pass
