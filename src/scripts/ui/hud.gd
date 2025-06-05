class_name HUD
extends Control

const GREEN := Color.GREEN
const YELLOW := Color.YELLOW
const RED := Color.RED

@export var show_fps := false
@onready var player := get_tree().get_first_node_in_group("player") as Player

var overlay_progress := 0.0:
	set = set_overlay_progress


func _ready() -> void:
	$FPSLabel.visible = show_fps


func _process(_delta: float) -> void:
	var health := player.health as int
	var ammo := -1 if not player.current_gun else player.current_gun.ammo
	if show_fps:
		$FPSLabel.text = "%s FPS" % Engine.get_frames_per_second()

	if health >= 75:
		set_health_color(GREEN)
	elif health <= 25:
		set_health_color(RED)
	else:
		set_health_color(YELLOW)
	$HealthLabel.text = str(health)

	$AmmoCounter.text = str(ammo) if ammo != -1 else ""


func set_overlay_progress(value: float) -> void:
	overlay_progress = clamp(value, 0.0, 1.0)
	print(overlay_progress)
	$AbilityIcon.material.set_shader_parameter("overlay_progress", overlay_progress)


func set_health_color(color: Color) -> void:
	$HealthLabel.set("theme_override_colors/default_color", color)


func update_ability_icon(ability: Ability) -> void:
	$AbilityIcon.texture = ability.icon
