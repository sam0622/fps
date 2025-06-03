class_name Ability
extends Node3D

#region Variables

enum KeyPressType { TAP, HOLD }

@export var ability_name: String
@export_multiline var description: String
@export var icon: CompressedTexture2D
@export var press_type: KeyPressType
## The max amount of time the ability can be used before triggering the cooldown,
## only relevant if [member Ability.press_type] is set to Hold
@export var max_hold_time: float
@export var has_cooldown: bool
## Only relevant if [member Ability.has_cooldown] is [code]true[/code]
@export var cooldown_length: float

var is_active := false
var in_use := false
var on_cooldown := false
var punishment := false
var time_used := 0.0
var overlay_start_progress: float

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var cooldown_timer := player.get_node("Abilities/AbilityCooldown") as Timer
@onready var use_timer := player.get_node("Abilities/AbilityUseTime") as Timer

#endregion

#region Basic Overrides


func _ready() -> void:
	cooldown_timer.wait_time = cooldown_length
	use_timer.wait_time = max_hold_time
	cooldown_timer.connect("timeout", _on_ability_cooldown_timeout)
	use_timer.connect("timeout", _on_ability_use_time_timeout)


func _process(_delta: float) -> void:
	if on_cooldown:
		if press_type == KeyPressType.HOLD:
			var t := 1.0 - (cooldown_timer.time_left / cooldown_timer.wait_time)
			player.hud.overlay_progress = lerp(overlay_start_progress, 0.0, t)
		else:
			player.hud.overlay_progress = cooldown_timer.time_left / cooldown_timer.wait_time
	elif in_use and press_type == KeyPressType.HOLD:
		player.hud.overlay_progress = (
			(use_timer.wait_time - use_timer.time_left) / use_timer.wait_time
		)
	else:
		player.hud.overlay_progress = 0


#endregion

#region Triggering


func _unhandled_input(event: InputEvent) -> void:
	if is_active and not on_cooldown:
		if event.is_action_pressed("use_ablility"):
			trigger()
		elif (
			event.is_action_released("use_ablility") and press_type == KeyPressType.HOLD and in_use
		):
			detrigger()


func trigger() -> void:
	in_use = true
	if press_type == KeyPressType.HOLD and use_timer.is_stopped():
		use_timer.start()


func detrigger() -> void:
	in_use = false
	var cooldown_time: float
	if press_type == KeyPressType.HOLD:
		var time_used := use_timer.wait_time - use_timer.time_left
		# Figure out where to start cooldown
		overlay_start_progress = (use_timer.wait_time - use_timer.time_left) / use_timer.wait_time
		use_timer.stop()

		# Figure out cooldown time
		cooldown_time = overlay_start_progress * use_timer.wait_time

	cooldown_timer.start(cooldown_length if press_type == KeyPressType.TAP else cooldown_time)
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
