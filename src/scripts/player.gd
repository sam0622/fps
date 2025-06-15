## The player. Can move around and shoot.
class_name Player
extends CharacterBody3D

#region Setup

signal ability_changed(ability: Ability)
signal died

const JUMP_VELOCITY := 4.5

@export var speed := 5.0  ## How fast the player walks.
@export var health := 100:
	set = set_health
@export var invincible := false
@export var starting_gun: Gun.GunType  ## The [Gun] the player spawns with.
@export var starting_ability: Ability.Abilities
@export var dead_player_scene: PackedScene

var ability: Ability:
	set = set_ability
var mouse_sensitivity := Settings.mouse_sensitivity
var current_gun: Gun  ## The currently equipped [Gun].
var can_be_hit := true
var can_move := true
var is_dashing := false
var dash_direction: Vector3

@onready var camera := get_viewport().get_camera_3d()
@onready var hud := %HUD  ## The player's HUD.
@onready var gun_marker := get_node("%GunMarker") as Marker3D  ## Indicates where the gun model should be.
@onready var throw_marker := get_node("%ThrowMarker") as Marker3D  ## Indicates where a thrown gun should be spawned from.
@onready var ray := get_node("%RayCast3D") as RayCast3D  ## A [RayCast3D] coming out of the player's head, used to register gunshot hits.
@onready var death_screen := %DeathScreen




## Does anything that can't be an [annotation @GDScript.@onready] variable.
func _ready() -> void:
	ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	assert(hud, "Critical error: Player HUD not found")
	connect("ability_changed", hud.update_ability_icon)

	match starting_ability:
		Ability.Abilities.DASH:
			ability = $Abilities/DashAbility
		Ability.Abilities.SPRINT:
			ability = $Abilities/SprintAbility

	equip_gun(starting_gun)
	if ability:
		ability.is_active = true


#endregion

#region Physics and input


func _process(_delta: float) -> void:
	if not $NewGunCooldown.is_stopped():
		hud.gun_overlay_progress = lerp(0.0, 1.0, $NewGunCooldown.time_left / $NewGunCooldown.wait_time)


## Handles gravity, jumping and movement input.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() or health <= 0:
		velocity.y -= GameManager.gravity * delta
	
	if can_move and health > 0:
		# Handle Jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_dashing:
				velocity = dash_direction * speed
		elif direction:
			if can_move:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()


## Handles mouse input.
func _input(event: InputEvent) -> void:
	## Rotates camera according to mouse movement.
	if health > 0:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.y -= event.relative.x / mouse_sensitivity
			camera.rotation.x -= event.relative.y / mouse_sensitivity
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

		if event is InputEventMouseButton:
			# Captures mouse if needed
			if event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				return
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				if event.is_action_pressed("left_click"):
					if current_gun:
						# Shoots or throws based on ammo, may be moved to the shoot method of Gun.
						if current_gun.state == Gun.GunState.EMPTY:
							current_gun.throw()
							$NewGunCooldown.start()
						else:
							current_gun.shoot()
				if event.is_action_pressed("right_click") and current_gun != null:
					camera.fov = 22.5
				elif event.is_action_released("right_click"):
					camera.fov = 90


#endregion

#region Managment


func set_health(new_health: int) -> void:
	if invincible:
		return
	
	if new_health > 0:
		new_health = clampi(new_health, 0, 100)
		var is_heal := new_health > health
		if (can_be_hit and not is_heal) or is_heal:
			health = new_health
	else:
		die()

## Spawns a dead player, and deletes player
func die() -> void:
	died.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var instance := dead_player_scene.instantiate() as RigidBody3D
	instance.global_position = $Head/Camera3d.global_position
	instance.rotation = $Head/Camera3d.rotation
	GameManager.main.add_child(instance)
	hide()
	$Collider.disabled = true
	self.queue_free()


## Equips and loads a new [Gun].
func equip_gun(gun: Gun.GunType) -> void:
	if current_gun:
		unequip_gun()
	var uid := load(Gun.get_uid(gun))
	var instance := uid.instantiate() as Node3D
	$Head/Camera3d/GunMarker.add_child(instance)
	current_gun = camera.get_node_or_null("GunMarker/Gun")


## Unequips and unloads the current [Gun].
func unequip_gun() -> void:
	if current_gun:
		current_gun.queue_free()
		current_gun = null


## Sets new [Abiltiy]
func set_ability(new_ability: Ability) -> void:
	if ability:
		ability.is_active = false
	ability = new_ability
	ability.is_active = true
	ability_changed.emit(new_ability)


func _on_new_gun_cooldown_timeout() -> void:
	equip_gun(starting_gun)
	hud.gun_overlay_progress = 0.0


#endregion
