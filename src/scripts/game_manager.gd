## Provides global settings and specific game-related utilities.
extends Node

## @deprecated
enum DamageTypes { BULLET, BLUNT }


# Scene UIDs
#const main_menu: String
#const settings_uid: String
#const arena_uid: String
const death_screen_uid := "uid://5kd854v8y4b1"

var time := Time.get_ticks_msec() ## How long the program has been running.
var fps := Engine.get_frames_per_second()
var gravity := ProjectSettings.get("physics/3d/default_gravity") as float
var last_esc: int  ## Last time the escape key was pressed.
var enemy_despawn_time := 15.0 ## How long unitl a dead [Chaser] is deleted.

@onready var main := get_node_or_null("/root/Main")


## Updates the time.
func _process(_delta: float) -> void:
	time = Time.get_ticks_msec()


## If escape is pressed twice within .5 of a second, exit the game.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("free_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if time - last_esc <= 500:
			get_tree().quit()
		last_esc = time


func load_scene(uid: String) -> void:
	get_tree().change_scene_to_file(uid)
