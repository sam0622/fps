class_name Gun
extends Node3D

signal shot(damage: int)

enum GunState {
	IDLE,
	SHOOTING,
	COOLDOWN,
	EMPTY,
}

enum FireMode {
	SINGLE,
	BURST,
	AUTO
}

const UID := "uid://b04ta5xdlql6k"

@export var ammo := 5
@export var damage := 10
@export var fire_cooldown := 0.25
@export var fire_mode: FireMode
@export var position_offset: Vector3

var can_shoot: bool
var state: GunState

@onready var cooldown := $Cooldown
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var line := $Muzzle/LineRenderer3D


func _ready() -> void:
	print(get_tree_string_pretty())
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position


func _process(delta: float) -> void:
	if state == GunState.SHOOTING:
		line.points[0] = $Muzzle.global_position
		line.points[1] = get_target_position()


func get_target_position() -> Vector3:
	var camera_direction = player.camera.global_transform.basis.z.normalized()
	var ray_origin = $Muzzle.global_position
	var ray_end = -(ray_origin + camera_direction * 1000)
	
	if player.ray.is_colliding():
		return player.ray.get_collision_point()
	else:
		print(ray_end)
		return ray_end


func shoot() -> void:
	print(player.ray.is_colliding())
	line.show()
	state = GunState.SHOOTING
	await get_tree().create_timer(0.1).timeout
	state = GunState.COOLDOWN
	line.hide()


func _on_cooldown_timeout() -> void:
	state = GunState.IDLE
