class_name HUD
extends Control

@export var show_fps := false


func _ready() -> void:
	$FPSLabel.visible = show_fps


func _process(delta: float) -> void:
	if show_fps:
		$FPSLabel.text = "%s FPS" % Engine.get_frames_per_second()
