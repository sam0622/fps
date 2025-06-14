class_name Arena
extends Node3D

@export var starting_wave := 1
@export var enemy_increase_frequency := 2 ## Add an enemy every number waves

var wave := starting_wave

@onready var player := get_tree().get_first_node_in_group("player")
@onready var enemies := get_tree().get_nodes_in_group("enemy")
@onready var spawners := get_tree().get_nodes_in_group("spawner")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	spawn_enemies(4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_enemies(enemies_to_spawn: int) -> void:
	var enemies_spawned := 0
	while enemies_spawned < enemies_to_spawn:
		for spawner in spawners:
			spawner.spawn_enemy()
			enemies_spawned += 1


func halt_enemies() -> void:
	for enemy in enemies:
		enemy.state = Chaser.States.IDLE


func update_enemies() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")


func _on_child_entered_tree(node: Node) -> void:
	if node is Chaser:
		update_enemies()


func _on_child_exiting_tree(node: Node) -> void:
	if node is Chaser:
		update_enemies()


func _on_player_died() -> void:
	halt_enemies()
	player = null
