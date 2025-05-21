class_name Corpse
extends Skeleton3D

func _ready() -> void:
	$PhysicalBoneSimulator3D.physical_bones_start_simulation()
	#await get_tree().create_timer(GameManager.enemy_despawn_time).timeout
	#queue_free()
