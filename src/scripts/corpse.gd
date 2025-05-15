class_name Corpse
extends RigidBody3D

func _ready() -> void:
	await get_tree().create_timer(GameManager.enemy_despawn_time).timeout
	queue_free()
