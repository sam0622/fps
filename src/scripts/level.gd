extends Node3D

@onready var player := get_node("Player")

func _physics_process(delta: float) -> void:
	get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)
