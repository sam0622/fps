class_name ThrownGun
extends RigidBody3D

@export var damage := 10
@export var forward_velocity := 25
var active := true
var bounced := false

@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	global_position = player.throw_marker.global_position
	rotation.z = player.current_gun.rotation.z
	apply_central_impulse(-player.throw_marker.global_transform.basis.z * forward_velocity)
	self.angular_velocity = Vector3(10, 0, 0)


func _on_body_entered(body: Node) -> void:
	angular_velocity = Vector3.ZERO
	if active:
		if body.is_in_group("enemy"):
			body.hit(damage, GameManager.DamageTypes.BLUNT)
	
	if bounced:
			# On second impact kill velocity
			active = false
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			sleeping = true
			await get_tree().create_timer(10.0).timeout
			queue_free()
	else:
		bounced = true
		linear_velocity *= 0.7
