## An [Ability] that is triggered by holding the use key down.
class_name HoldAbility
extends Ability

## The max amount of time the ability can be used before triggering the cooldown.
@export var max_hold_time: float


func _ready() -> void:
	super()
	use_timer.wait_time = max_hold_time
	press_type = KeyPressType.HOLD


## Calls [method Ability._unhandled_input], but detriggers if the use button is released.
func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if trigger_condition and event.is_action_released("use_ablility") and in_use:
		detrigger()


## Handles setting the cooldown overlay of the HUD.
func _process(delta: float) -> void:
	if on_cooldown:
		var t := 1.0 - (cooldown_timer.time_left / cooldown_timer.wait_time)  # Calculates cooldown completion %
		player.hud.overlay_progress = lerp(overlay_start_progress, 0.0, t)  # Sets the overlay based on that
	elif in_use and press_type == KeyPressType.HOLD:  # Makes the overlay progress upwards when ability is in use
		player.hud.overlay_progress = (
			(use_timer.wait_time - use_timer.time_left) / use_timer.wait_time
		)
	else:
		player.hud.overlay_progress = 0.0


## Sets [member HoldAbility.in_use] to true and starts [member Ability.use_timer].
## Must be overrided in subclasses.
func trigger() -> void:
	in_use = true
	use_timer.start()


## Calculates cooldown based on how long the ability was used.
## All other effects must be implemented in subclass.
func detrigger() -> void:
	super()
	var time_used := use_timer.wait_time - use_timer.time_left
	overlay_start_progress = time_used / use_timer.wait_time
	use_timer.stop()
	var cooldown_time := overlay_start_progress * use_timer.wait_time
	cooldown_timer.start(cooldown_time)
