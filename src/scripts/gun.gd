## A base class for guns.
## May be reworked to be less object-oriented 
## as every new gun must have its own class that is a subclass of Gun.
##
## @experimental
class_name Gun
extends Node3D

## The types of guns, will be expanded as guns are added
enum GunType {
	BASE
}

## All the states the gun can be in.
enum GunState {
	IDLE,
	SHOOTING,
	COOLDOWN,
	EMPTY,
}

## Types of firing modes the gun can have.
## Currently unused, may be implemented in the future
enum FireMode {
	SINGLE,
	BURST,
	AUTO
}


static var UID := "uid://b04ta5xdlql6k" ## Binds gun to corresponding scene. May be reworked in the future
static var guns := [Gun] ## All types of guns. May be reworked in the future

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
@export var position_offset: Vector3 ## An offset the gun will spawned at, see [member Player.gun_marker]

var can_shoot: bool
var state: GunState

var thrown_gun_scene := preload("uid://cojbjlwm2w1kh") ## The scene for the thrown gun
@onready var cooldown := $Cooldown ## The firing cooldown timer
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var line := $Muzzle/LineRenderer3D ## Used to draw bullet trails
@onready var player_ray := player.ray as RayCast3D ## See [member Player.ray]


## Returns a scene uid based on the gun's type, see [member Gun.GunType]
static func get_uid(gun: GunType) -> String:
	return guns[gun].UID


## Initializes timers and position
func _ready() -> void:
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position


## Ensures that gun is set as empty, will likely be removed
func _process(_delta: float) -> void:
	if ammo == 0:
		state = GunState.EMPTY


## Gets the position [member Gun.player_ray] is hitting. 
## Used by the [method Gun.shoot] method for bullet trail drawing
func get_target_position() -> Vector3:
	var camera_direction := player.camera.global_transform.basis.z.normalized()
	var ray_origin := $Muzzle.global_position as Vector3
	var ray_end := -(ray_origin + camera_direction * 1000) as Vector3
	
	if player_ray.is_colliding():
		return player_ray.get_collision_point()
	else:
		return ray_end


## Allows the player to shoot the gun 
## Applies [member Gun.damage] damage to target.
## If the shot hits an enemy's head, it does [member Gun.damage] * 2 damage.
## Will draw a line from the muzzle's position to the position [member Gun.player_ray] is hitting.
## Also see [method Gun.get_target_position]
func shoot() -> void:
	if state != GunState.IDLE:
		return
	
	if player_ray.is_colliding():
		var collision := player_ray.get_collider() as Node3D
		if collision.is_in_group("shootable"):
			collision.on_hit()
		elif collision.is_in_group("enemy"):
			var collision_shape_name := player_ray.get_collider().shape_owner_get_owner(player_ray.get_collider_shape()).name as String
			if collision_shape_name == "HeadCollider":
				collision.on_hit(damage * 2)
			else:
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


## Throws the gun and unequips it from the player
func throw() -> void:
	var instance := thrown_gun_scene.instantiate()
	GameManager.main.add_child(instance)
	player.unequip_gun()


## Allows the gun to shoot again when the cooldown is done
func _on_cooldown_timeout() -> void:
	state = GunState.IDLE
