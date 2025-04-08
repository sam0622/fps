class_name StaticTarget
extends Shootable

@onready var mesh := $MeshInstance3D
@onready var surf := StandardMaterial3D.new()

func _ready() -> void:
	surf.albedo_color = Color.WHITE  # Set the initial color
	mesh.set_surface_override_material(0, surf)  # Apply the material to the mesh

func hit(_gun_type: Gun = null) -> void:
	surf.albedo_color = Color.RED  # Change the color on shot
	await get_tree().create_timer(2.5).timeout  # Wait for 2.5 seconds
	surf.albedo_color = Color.WHITE  # Reset the color after waiting
