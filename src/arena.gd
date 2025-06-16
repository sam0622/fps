class_name Arena
extends Node3D

@export var starting_wave := 1
@export var wave_coundown := 3 ## How long the pre-wave countdown should be
@export var enemy_increase_frequency := 2 ## Adds an enemy every specified amount of waves
@export var post_wave_healing := 50


var wave := starting_wave - 1
var wave_ongoing := false

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var enemies := get_tree().get_nodes_in_group("enemy")
@onready var spawners := get_tree().get_nodes_in_group("spawner")
@onready var active_enemies := len(enemies) ## All enemies that are not dead
@onready var wave_counter := player.hud.wave_counter as RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave = starting_wave - 1
	start_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#region Waves


## Starts a new wave. First, it gives the player a new gun,
## then counts down [member Arena.wave_countdown] seconds, updates wave counter, and spawns enemies.[br]
## See [method Arena.countdown] and [method Arena.spawn_enemies]
func start_wave() -> void:
	if player.current_gun == null:
		(player.get_node("NewGunCooldown") as Timer).stop()
		player.hud.gun_overlay_progress = 0
		player.equip_gun(Gun.GunType.BASE)
	else:
		player.current_gun.ammo = player.current_gun.starting_ammo
		
	await countdown(wave_coundown)
	wave_ongoing = true
	wave += 1
	wave_counter.text = "Wave %s" % wave
	var enemies_to_spawn := 1 + int(wave / enemy_increase_frequency)
	spawn_enemies(enemies_to_spawn)


## Heals player by [member Arena.post_wave_healing] health, waits a bit, then calls [method Arena.start_wave]
func end_wave() -> void:
	wave_ongoing = false
	wave_counter.text = "Wave cleared"
	player.health += post_wave_healing
	await get_tree().create_timer(3).timeout
	start_wave()


## Iterates through [member Arena.spawners] until specified amount of enemies have been spawned
func spawn_enemies(enemies_to_spawn: int) -> void:
	var enemies_spawned := 0
	while enemies_spawned < enemies_to_spawn:
		for spawner in spawners:
			if enemies_spawned >= enemies_to_spawn:
				break
			spawner.spawn_enemy()
			enemies_spawned += 1
			print(enemies_spawned)


# Sets all enemy states to idle
func halt_enemies() -> void:
	for enemy in enemies:
		if enemy != null and enemy.state != Chaser.States.DEAD:
			enemy.state = Chaser.States.IDLE


## Display a seconds long countdown in the wave counter
func countdown(seconds: int) -> void:
	for i in range(seconds, 0, -1):
		wave_counter.text = str(i)
		await get_tree().create_timer(1).timeout


#endregion


## Updates [member Arena.enemies] and [member Arena.active_enemies]
func update_enemies() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")
	active_enemies = 0
	for enemy in enemies:
		if enemy.state != Chaser.States.DEAD:
			active_enemies += 1


#region Signals


## Updates [member Arena.enemies] if new enemy spawned
func _on_child_entered_tree(node: Node) -> void:
	if node is Chaser:
		update_enemies()


## Updates [member Arena.enemies] and ends wave if no enemies left.
## See [method Arena.end_wave]
func _on_child_exiting_tree(node: Node) -> void:
	if node is Chaser:
		update_enemies()
		if wave_ongoing and active_enemies <= 0:
			end_wave()


## Halt enemies on player death
func _on_player_died() -> void:
	halt_enemies()
	player = null


#endregion
