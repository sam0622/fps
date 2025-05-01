class_name Chaser
extends Enemy


func _ready() -> void:
	super()
	$DespawnTimer.wait_time = GameManager.enemy_despawn_time


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity = Vector3.ZERO
	
	# Chase player
	if state == States.CHASING:
		var next_location := agent.get_next_path_position() as Vector3
		velocity = (next_location - global_transform.origin).normalized() * move_speed
		look_at(player.position, Vector3.UP)
		if agent.is_navigation_finished():
			set_state(States.IDLE)


func attack() -> void:
	$AnimationPlayer.play("jump")
	await get_tree().create_timer(0.15)
	$AnimationPlayer.play("attack")
	set_state(States.CHASING)


func die() -> void:
	collision_mask = 0b00000000_00000000_00000000_00000100
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	$DespawnTimer.start()
	await $DespawnTimer.timeout
	queue_free()


func _on_navigation_agent_3d_target_reached() -> void:
	set_state(States.ATTACKING)
