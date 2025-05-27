## A basic enemy that chases the player and then attacks them.
class_name Chaser
extends CharacterBody3D

## The states a chaser can be in
enum States { IDLE, CHASING, BACKING_UP, ATTACKING, DEAD }

## Whether the enemy always knows where the player is
@export var omnipotent := true
@export var move_speed := 5.0
@export var health := 5: set = set_health
@export var damage := 25
@export var attack_cooldown := 2.5
@export var corpse_scene: PackedScene

var state := States.IDLE: set = set_state ## The chaser's current state, defaults to [color=#BCE0FF]IDLE[/color]
var update_frequency := randi_range(15, 22) ## Staggers AI update time by a random amount of frames to avoid stutters
var can_attack := true
var has_hit_player := false ## Prevents the player from being hit multiple times in the same attack

@onready var agent := get_node("NavigationAgent3D") as NavigationAgent3D ## The chaser's [NavigationAgent3D]
@onready var player := get_tree().get_first_node_in_group("player") as Player


## Sets initial state and prepares timers
func _ready() -> void:
	if omnipotent:
		state = States.CHASING
	else:
		state = States.IDLE
	$AttackCooldown.wait_time = attack_cooldown


## Handles AI chase logic and gravity
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= GameManager.gravity
	
	if Engine.get_frames_drawn() % update_frequency == 0:
			update_target_location(player.global_transform.origin)
	
	# Chase player
	if state == States.CHASING or state == States.BACKING_UP:
		
		var next_location := agent.get_next_path_position() as Vector3
		var v := (next_location - global_transform.origin).normalized() * move_speed
		rotation.y = lerp_angle(rotation.y, atan2(-v.x, -v.z), delta * 10.0)
		velocity.x = v.x
		# Back up if required
		velocity.z = v.z if state == States.CHASING else -v.z 
	
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
		States.BACKING_UP:
			set_physics_process(true)
			$AnimationPlayer.speed_scale = -2.0
			$AnimationPlayer.play_backwards("Root_Run")
		States.ATTACKING:
			set_physics_process(true)
		States.DEAD:
			set_physics_process(false)


## Returns [member Chaser.state] as a string for debugging purposes
func state_to_string() -> String:
	match state:
		States.IDLE:
			return "IDLE"
		States.CHASING:
			return "CHASING"
		States.BACKING_UP:
			return "BACKING_UP"
		States.ATTACKING:
			return "ATTACKING"
		States.DEAD:
			return "DEAD"
		_:
			return ""



func attack() -> void:
	if can_attack:
		state = States.ATTACKING
		$AnimationPlayer.play("Attack")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		state = States.CHASING


## Decrements health when hit
##
## @deprecated: This method is redundant and will be replaced with a direct decrament of [member Chaser.health]
func on_hit(dmg: int) -> void:
		health -= dmg


## Creates ragdoll at position, then deletes the chaser
func die() -> void:
	set_physics_process(false)
	state = States.DEAD
	collision_layer = 0
	self.visible = false
	var instance := corpse_scene.instantiate() as Skeleton3D
	instance.global_position = $Root.global_position
	instance.rotation = rotation
	GameManager.main.add_child(instance)
	queue_free()


## Sets target location.
## Do [u]not[/u] call this directly as it would bypass the update staggering (see [member Chaser.update_frequency]).
func update_target_location(target_location: Vector3) -> void:
	agent.set_target_position(target_location)


## Attacks when target is reached
func _on_navigation_agent_3d_target_reached() -> void:
	if can_attack:
		attack()
	else:
		state = States.IDLE


## Allows the chaser to attack again after a cooldown
func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	if state == States.IDLE:
		attack()


## Damages the [Player] when attacking
func _on_hitbox_body_entered(body: Node3D) -> void:
	if state == States.ATTACKING:
		if body is Player and not has_hit_player:
			body.health -= damage
			has_hit_player = true
			$AnimationPlayer.play_backwards("Attack")
		has_hit_player = false
