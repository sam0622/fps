class_name Ability
extends Node3D

#region Variables

enum KeyPressType {
	TAP,
	HOLD
}

@export var ability_name: String
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
@export var punishment_cooldown_length: float

var is_active := false

@onready var player := get_tree().get_first_node_in_group("player") as Player

#endregion


func _unhandled_input(event: InputEvent) -> void:
	if is_active:
		if event.is_action_pressed("use_ablility"):
			trigger()
		elif press_type == KeyPressType.HOLD:
			detrigger()


func trigger() -> void:
	pass


func detrigger() -> void:
	pass
