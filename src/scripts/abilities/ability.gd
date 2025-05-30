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
## Gives a longer cooldown if ability is fully expended, only relevant if
## [member Ability.press_type] is set to Hold, and [member Ability.has_cooldown] is [code]true[/code]
@export var has_punishment_cooldown: bool
## Punishment cooldown length is added to base cooldown time
@export var punishment_cooldown_length: float

var is_active := false
var in_use := false
var on_cooldown := false
var punishment := false

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var cooldown_timer := player.get_node("Abilities/AbilityCooldown") as Timer
@onready var use_timer := player.get_node("Abilities/AbilityUseTime") as Timer

#endregion


func _ready() -> void:
	cooldown_timer.wait_time = cooldown_length
	use_timer.wait_time = max_hold_time
	cooldown_timer.connect("timeout", _on_ability_cooldown_timeout)
	use_timer.connect("timeout", _on_ability_use_time_timeout)


func _process(_delta: float) -> void:
	#if Engine.get_frames_drawn() % 20 == 0:
	#	print("\n\nIs active: %s" % is_active)
	#	print("In use: %s" % in_use)
	#	print("On cooldown %s:" % on_cooldown)
	#	print("Cooldown remaining: %s" % cooldown_timer.time_left)
	#	print("Use time remaining: %s" % use_timer.time_left)
	if on_cooldown:
		player.hud.overlay_progress = cooldown_timer.time_left / cooldown_timer.wait_time
	else:
		player.hud.overlay_progress = 0.0

#region Triggering


func _unhandled_input(event: InputEvent) -> void:
	if is_active and not on_cooldown:
		if event.is_action_pressed("use_ablility"):
			trigger()
		elif event.is_action_released("use_ablility") and press_type == KeyPressType.HOLD and in_use:
			detrigger()


func trigger() -> void:
	in_use = true
	if press_type == KeyPressType.HOLD and use_timer.is_stopped():
		use_timer.start()


func detrigger() -> void:
	in_use = false
	use_timer.stop()
	cooldown_timer.start(
			cooldown_length + punishment_cooldown_length if punishment 
			else cooldown_length
	)
	on_cooldown = true


#endregion


func _on_ability_cooldown_timeout() -> void:
	on_cooldown = false
	punishment = false


func _on_ability_use_time_timeout() -> void:
	on_cooldown = true
	punishment = true
	detrigger()
