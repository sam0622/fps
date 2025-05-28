class_name HUD
extends Control

const GREEN := Color.GREEN
const YELLOW := Color.YELLOW
const RED := Color.RED

@export var show_fps := false
@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	$FPSLabel.visible = show_fps


func _process(_delta: float) -> void:
	if show_fps:
		$FPSLabel.text = "%s FPS" % Engine.get_frames_per_second()
	var health := player.health as int
	if health >= 75:
		set_health_color(GREEN)
	elif health <= 25:
		set_health_color(RED)
	else:
		set_health_color(YELLOW)
	$HealthLabel.text = str(health)


func set_health_color(color: Color) -> void:
	$HealthLabel.set("theme_override_colors/default_color", color)
