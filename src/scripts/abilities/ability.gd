class_name Ability
extends Node3D

#region Variables

enum Abilities { DASH, SPRINT }

enum KeyPressType { TAP, HOLD }

@export var ability_name: String
@export_multiline var description: String
@export var icon: CompressedTexture2D
@export var has_cooldown: bool
## Only relevant if [member Ability.has_cooldown] is [code]true[/code]
@export var cooldown_length: float

var is_active := false
var in_use := false
var on_cooldown := false
var punishment := false
var time_used := 0.0
var overlay_start_progress: float
var trigger_condition := true
var press_type: KeyPressType

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var cooldown_timer := player.get_node("Abilities/AbilityCooldown") as Timer
@onready var use_timer := player.get_node("Abilities/AbilityUseTime") as Timer

#endregion

#region Basic Overrides


func _ready() -> void:
	cooldown_timer.wait_time = cooldown_length
	cooldown_timer.connect("timeout", _on_ability_cooldown_timeout)
	use_timer.connect("timeout", _on_ability_use_time_timeout)


#endregion

#region Triggering


func _unhandled_input(event: InputEvent) -> void:
	if is_active and not on_cooldown:
		if event.is_action_pressed("use_ablility") and trigger_condition:
			trigger()


func trigger() -> void:
	pass


func detrigger() -> void:
	in_use = false
	on_cooldown = true


#endregion

#region Signals


func _on_ability_cooldown_timeout() -> void:
	on_cooldown = false
	punishment = false


func _on_ability_use_time_timeout() -> void:
	on_cooldown = true
	punishment = true
	detrigger()

#endregion
