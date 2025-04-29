class_name Chaser
extends Enemy


func _ready() -> void:
	super()


func die():
	collision_mask = 0b00000000_00000000_00000000_00000100
	$AnimationPlayer.play("die")
	await get_tree().create_timer(GameManager.enemy_despawn_time)
	#queue_free()
