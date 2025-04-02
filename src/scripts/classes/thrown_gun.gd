class_name ThrownGun
extends RigidBody3D

var active := true
var damage: int
var velocity: float
var collider: Shape3D
var model: MeshInstance3D
var model_material: BaseMaterial3D
var bounced := false

@onready var player := get_parent() as Player

func create(
	damage: int,
	velocity: float,
	model: MeshInstance3D,
	model_material: BaseMaterial3D = null
) -> void:
	self.damage = damage
	self.velocity = velocity
	self.model = model
	self.model_material = model_material


func _ready() -> void:
	$Model.mesh = model.mesh
	var shape := ConvexPolygonShape3D.new()
	shape.points = model.mesh.get_faces()
	$Collider.shape = shape
	global_position = player.throw_marker.global_position
	rotation.z = player.equipped_gun.rotation.z
	apply_central_impulse(-global_transform.basis.z * velocity)
	self.angular_velocity = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))


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
