## Provides global settings and specific game-related utilities.
extends Node

## @deprecated
enum DamageTypes { BULLET, BLUNT }


var time := Time.get_ticks_msec() ## How long the program has been running.
var fps := Engine.get_frames_per_second()
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float
var last_esc: int  ## Last time the escape key was pressed.
var enemy_despawn_time := 15.0 ## How long unitl a dead [Chaser] is deleted.

@onready var main := get_node_or_null("/root/Main")


## Updates the time.
func _process(_delta: float) -> void:
	time = Time.get_ticks_msec()
	if main == null:
		main = get_node_or_null("/root/Main")


## If escape is pressed twice within .5 of a second, exit the game.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("free_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if time - last_esc <= 500:
			get_tree().quit()
		last_esc = time


## Exits the game with optional exit code
func quit(exit_code: int = 0) -> void:
	get_tree().quit(exit_code)


## Loads a new active scene
func load_scene(uid: String) -> void:
	get_tree().change_scene_to_file(uid)
	main = get_node_or_null("/root/Main")


## Loads the arena
func load_arena() -> void:
	load_scene("uid://dveakhbhm8c5d")


## Loads the main menu
func load_main_menu() -> void:
	load_scene("uid://svae0j87csnw")


func load_settings() -> void:
	load_scene("uid://dnxcrjkc525tj")
