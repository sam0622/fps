## A special ability that can be used by the [Player].
class_name Ability
extends Node3D

#region Variables

enum Abilities { DASH, SPRINT }

enum KeyPressType { TAP, HOLD }

@export var ability_name: String
@export_multiline var description: String
@export var icon: CompressedTexture2D
@export var has_cooldown: bool
## Only relevant if [member Ability.has_cooldown] is true.
@export var cooldown_length: float

var is_active := false: set = set_is_active ## If the ability is the player's current ability.
var in_use := false ## If the abilies effect is currently active, NOT the same as [member Ability.is_active].
var on_cooldown := false
var overlay_start_progress: float ## Where the overlay of the ability HUD icon should start.
var trigger_condition := true ## Optional condition required to trigger ability.
var press_type: KeyPressType ## Whether the ability key should be tapped or held.

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var cooldown_timer := player.get_node("Abilities/AbilityCooldown") as Timer
@onready var use_timer := player.get_node("Abilities/AbilityUseTime") as Timer

#endregion

#region Basic Overrides


## Connects signals.
func _ready() -> void:
	cooldown_timer.wait_time = cooldown_length
	cooldown_timer.connect("timeout", _on_ability_cooldown_timeout)
	use_timer.connect("timeout", _on_ability_use_time_timeout)


#endregion

#region Triggering


## Triggers the ability if the following conditons are true:[br]
## [member Ability.is_active] is true[br].
## [member Ability.trigger_condition] is true[br].
## [member Ability.on_cooldown] is false[br].
func _unhandled_input(event: InputEvent) -> void:
	if is_active and not on_cooldown and player.can_move:
		if event.is_action_pressed("use_ablility") and trigger_condition:
			trigger()


## What the ability does, must be implemented in subclasses.
func trigger() -> void:
	pass


## Reverses the effects of the ability, must be implemented in subclasses.
func detrigger() -> void:
	in_use = false
	on_cooldown = true


#endregion

#region Signals


func _on_ability_cooldown_timeout() -> void:
	on_cooldown = false


func _on_ability_use_time_timeout() -> void:
	on_cooldown = true
	detrigger()

#endregion


func set_is_active(value: bool) -> void:
	is_active = value
	set_process(is_active)
