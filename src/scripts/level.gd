extends Node3D

@onready var player := get_node("Player")


func halt_enemy_ai() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.state = Chaser.States.IDLE
