class_name Gun
extends Node3D

enum GunState {
	IDLE,
	SHOOTING,
	COOLDOWN,
	EMPTY,
}

# UID of the corresponding scene
static var uid := "uid://b04ta5xdlql6k"

@export var ammo := 5
@export var damage := 10
@export var fire_cooldown := 0.25
@export var scene_uid: String
@export var position_offset: Vector3

var can_shoot: bool

@onready var cooldown := get_node("Cooldown") as Timer
@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	cooldown.wait_time = fire_cooldown
	self.position = player.get_node("Head/Camera3d/GunMarker").position
