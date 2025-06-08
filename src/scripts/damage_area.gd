extends Area3D

@export var damage := 10

@onready var player := get_tree().get_first_node_in_group("player")


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health -= damage
