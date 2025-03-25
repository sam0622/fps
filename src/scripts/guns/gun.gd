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

@onready var cooldown := $Cooldown
@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position


func shoot() -> void:
	line(self.position, player.ray.target_position)
	print("shooting")


func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
