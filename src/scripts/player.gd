class_name Player
extends CharacterBody3D

const speed := 5.0
const JUMP_VELOCITY := 4.5

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var mouse_sensitivity := 1200
var mouse_relative_x := 0
var mouse_relative_y := 0

@onready var camera := get_viewport().get_camera_3d()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		camera.rotation.x -= event.relative.y / mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
