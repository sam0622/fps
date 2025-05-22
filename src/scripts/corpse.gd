## The corpse of a Chaser
class_name Corpse
extends Skeleton3D


## Starts ragdoll simulation. 
## Despawns after [member GameManager.enemy_despawn_time] time
func _ready() -> void:
	$PhysicalBoneSimulator3D.physical_bones_start_simulation()
	await get_tree().create_timer(GameManager.enemy_despawn_time).timeout
	queue_free()
