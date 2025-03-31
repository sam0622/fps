class_name ThrownGun
extends RigidBody3D

var active := true
var damage: int
var velocity: float
var model: Mesh
var model_material: BaseMaterial3D


func _init(
	damage: int,
	velocity: float,
	model: Mesh,
	model_material: BaseMaterial3D = null
) -> void:
	self.damage = damage
	self.velocity = velocity
	self.model = model
	self.model_material = model_material


func _ready() -> void:
	$Model.mesh = model
	$Collider.shape = $Model.create_convex_collision()
	self.add_constant_central_force(Vector3(velocity, 0, 0))


func _on_body_entered(body: Node) -> void:
	if active:
		if body.is_in_group("enemy"):
			body.hit(damage, GameManager.DamageTypes.BLUNT)
