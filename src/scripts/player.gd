## The player. Can move around and shoot.
class_name Player
extends CharacterBody3D

#region Variables

const JUMP_VELOCITY := 4.5

@export var speed := 5.0  ## How fast the player walks.
@export var health := 100:
	set = set_health
@export var starting_gun: Gun.GunType  ## The [Gun] the player spawns with.
@export var ability: Ability:
	set = set_ability
var mouse_sensitivity := 1200
var current_gun: Gun  ## The currently equipped [Gun].

@onready var camera := get_viewport().get_camera_3d()
@onready var hud := $%HUD ## The player's HUD.
@onready var gun_marker := get_node("%GunMarker") as Marker3D  ## Indicates where the gun model should be.
@onready var throw_marker := get_node("%ThrowMarker") as Marker3D  ## Indicates where a thrown gun should be spawned from.
@onready var ray := get_node("%RayCast3D") as RayCast3D  ## A [RayCast3D] coming out of the player's head, used to register gunshot hits.

#endregion


## Does anything that can't be an [annotation @GDScript.@onready] variable.
func _ready() -> void:
	ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	assert(hud, "Critical error: Player HUD not found")
	equip_gun(starting_gun)
	if ability:
		ability.is_active = true


#region Physics and input


## Handles gravity, jumping and movement input.
func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GameManager.gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	print(input_dir)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()


## Handles mouse input.
func _input(event: InputEvent) -> void:
	## Rotates camera according to mouse movement.
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
					else:
						current_gun.shoot()


#endregion


func set_health(new_health: int) -> void:
	health = new_health
	if health <= 0:
		health = 0
		die()


## @experimental: This function is incomplete.
func die() -> void:
	pass


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


func set_ability(new_ability: Ability) -> void:
	if ability:
		ability.is_active = false
	ability = new_ability
	ability.is_active = true
