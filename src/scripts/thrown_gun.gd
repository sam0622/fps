class_name ThrownGun
extends RigidBody3D

@export var damage := 2
@export var forward_velocity := 25
var active := true
var bounced := false

@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	global_position = player.throw_marker.global_position
	rotation = player.current_gun.global_rotation
	rotation.z = 45
	apply_central_impulse(-player.throw_marker.global_transform.basis.z * forward_velocity)
	angular_velocity = Vector3(randi_range(-10, 10), 0, randi_range(-10, 10))
	sleeping = false


func _on_body_entered(body: Node3D) -> void:
	if body is Player or body is ThrownGun:
		return
	if active:
		print(body.to_string())
		if body.is_in_group("shootable"):
			body.on_hit()
		if body.is_in_group("enemy"):
			body.health -= damage
	if bounced:
		# On second impact kill velocity
		active = false
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		await get_tree().create_timer(10.0).timeout
		queue_free()
	else:
		bounced = true
		linear_velocity *= 0.7
