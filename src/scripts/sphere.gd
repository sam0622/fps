@tool
extends RigidBody3D

@export var physics := false
@export var material: StandardMaterial3D

func _ready() -> void:
	$MeshInstance3D.set_surface_override_material(0, material)
	freeze = !physics


func _process(delta: float) -> void:
	$MeshInstance3D.set_surface_override_material(0, material)
