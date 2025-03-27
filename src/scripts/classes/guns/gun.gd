class_name Gun
extends Node3D

signal shot(damage: int)

enum GunState {
	IDLE,
	SHOOTING,
	COOLDOWN,
	EMPTY,
}

# Unused for the time being, may implement it later
enum FireMode {
	SINGLE,
	BURST,
	AUTO
}

# Binds class to corresponding scene
static var UID := "uid://b04ta5xdlql6k"

@export var ammo := 5
@export var damage := 10
@export var fire_cooldown := 0.35
@export var fire_mode: FireMode
@export var position_offset: Vector3

var can_shoot: bool
var state: GunState

@onready var cooldown := $Cooldown
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var line := $Muzzle/LineRenderer3D
@onready var player_ray := player.ray as RayCast3D


func _ready() -> void:
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position


func _process(delta: float) -> void:
	# Keeps bullet trail on the gun while shooting
	# TODO: Just make this run once, bullet trails dont glue themselves to the barrel irl??
	if state == GunState.SHOOTING:
		line.points[0] = $Muzzle.global_position
		line.points[1] = get_target_position()


func get_target_position() -> Vector3:
	var camera_direction = player.camera.global_transform.basis.z.normalized()
	var ray_origin = $Muzzle.global_position
	# Needs to be negated because of how Godot's coord system works
	var ray_end = -(ray_origin + camera_direction * 1000)
	
	if player_ray.is_colliding():
		return player_ray.get_collision_point()
	else:
		return ray_end


func get_colliding_ray() -> RayCast3D:
	if player_ray.is_colliding():
		return player_ray
	elif $Muzzle/RayCast3D.is_colliding():
		return $Muzzle/RayCast3D
	else:
		return null


func shoot() -> void:
	if state == GunState.IDLE:
		if not get_colliding_ray() == null:
			var collision := get_colliding_ray().get_collider()
			if collision.has_method("_on_shot"):
				collision = collision as Shootable
				collision._on_shot(self)
		
		line.show()
		state = GunState.SHOOTING
		await get_tree().create_timer(0.1).timeout # Wait 0.1 sec
		state = GunState.COOLDOWN
		cooldown.start()
		line.hide()


func _on_cooldown_timeout() -> void:
	state = GunState.IDLE
