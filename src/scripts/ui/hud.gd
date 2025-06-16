## The [Player]'s HUD. Displays health, ammo, and ability information.
class_name HUD
extends Control

const GREEN := Color.GREEN
const YELLOW := Color.YELLOW
const RED := Color.RED

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var wave_counter := $WaveCounter

## The progress of the ability cooldown overlay.
var overlay_progress := 0.0:
	set = set_overlay_progress

## The progress of the gun icon's overlay
var gun_overlay_progress := 0.0:
	set = set_gun_overlay_progress


func _ready() -> void:
	$FPSLabel.visible = Settings.show_fps


## Updates text labels.
func _process(_delta: float) -> void:
	var health := player.health as int
	var ammo := -1 if not player.current_gun else player.current_gun.ammo
	if Settings.show_fps:
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
	$AbilityIcon.material.set_shader_parameter("overlay_progress", overlay_progress)


func set_gun_overlay_progress(value: float) -> void:
	gun_overlay_progress = value
	$GunIcon.material.set_shader_parameter("overlay_progress", gun_overlay_progress)


func set_health_color(color: Color) -> void:
	$HealthLabel.set("theme_override_colors/default_color", color)


func update_ability_icon(ability: Ability) -> void:
	$AbilityIcon.texture = ability.icon
