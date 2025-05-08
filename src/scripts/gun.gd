class_name Gun
extends Node3D


enum GunType {
	BASE
}


enum GunState {
	IDLE,
	SHOOTING,
	COOLDOWN,
	EMPTY,
}

## Unused
enum FireMode {
	SINGLE,
	BURST,
	AUTO
}

# Binds class to corresponding scene
static var UID := "uid://b04ta5xdlql6k"
static var guns := [Gun]

@export var ammo := 5:
	set(value):
		ammo = value
		if ammo <= 0:
			ammo = 0
			state = GunState.EMPTY

@export var damage := 2
@export var health := 10
@export var fire_cooldown := 0.35
@export var fire_mode: FireMode
@export var position_offset: Vector3

var can_shoot: bool
var state: GunState
var thrown_gun_scene := preload("uid://cojbjlwm2w1kh")

@onready var cooldown := $Cooldown
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var line := $Muzzle/LineRenderer3D
@onready var player_ray := player.ray as RayCast3D


static func get_uid(gun: GunType) -> String:
	return guns[gun].UID


func _ready() -> void:
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position


func _process(_delta: float) -> void:
	if ammo == 0:
		state = GunState.EMPTY


func get_target_position() -> Vector3:
	var camera_direction := player.camera.global_transform.basis.z.normalized()
	var ray_origin := $Muzzle.global_position as Vector3
	# Needs to be negated because of how Godot's coord system works
	var ray_end := -(ray_origin + camera_direction * 1000) as Vector3
	
	if player_ray.is_colliding():
		return player_ray.get_collision_point()
	else:
		return ray_end


func shoot() -> void:
	if state != GunState.IDLE:
		return
	
	if player_ray.is_colliding():
		var collision := player_ray.get_collider() as Node3D
		if collision.is_in_group("shootable"):
			collision.on_hit()
		elif collision.is_in_group("enemy"):
			collision.on_hit(damage)
	
	line.show()
	line.points[0] = $Muzzle.global_position
	line.points[1] = get_target_position()
	state = GunState.SHOOTING
	ammo -= 1
	await get_tree().create_timer(0.1).timeout # Wait 0.1 sec
	state = GunState.COOLDOWN
	cooldown.start()
	line.hide()


func throw() -> void:
	var instance := thrown_gun_scene.instantiate()
	GameManager.main.add_child(instance)
	player.unequip_gun()


func _on_cooldown_timeout() -> void:
	state = GunState.IDLE
