extends Node

enum DamageTypes {
	BULLET,
	BLUNT
}

var time := Time.get_ticks_msec()
var last_esc: int
var frame := 0

@onready var main := get_node("/root/Main")

func _process(delta: float) -> void:
	time = Time.get_ticks_msec()
	frame += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("free_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if time - last_esc <= 500:
			get_tree().quit()
		last_esc = time
