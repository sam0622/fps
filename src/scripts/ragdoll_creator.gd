class_name RagdollCreator
extends Node3D

@export_flags_3d_physics var collision_layer
@export_flags_3d_physics var collision_mask

var parent: PhysicsBody3D
var mesh_instance: MeshInstance3D
var collider: CollisionShape3D


func _ready() -> void:
	parent = get_parent()
	mesh_instance = NodeUtils.get_node_of_type(parent, "MeshInstance3D")
	collider = NodeUtils.get_node_of_type(parent, "CollisionShape3D")
