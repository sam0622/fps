class_name HoldAbility
extends Ability

## The max amount of time the ability can be used before triggering the cooldown,
@export var max_hold_time: float


func _ready() -> void:
	super()
	set_process(true)
	use_timer.wait_time = max_hold_time
	press_type = KeyPressType.HOLD


func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if (
		trigger_condition
		and event.is_action_released("use_ablility")
		and in_use
	):
		detrigger()


func _process(delta: float) -> void:
	if on_cooldown:
		var t := 1.0 - (cooldown_timer.time_left / cooldown_timer.wait_time)
		player.hud.overlay_progress = lerp(overlay_start_progress, 0.0, t)
	elif in_use and press_type == KeyPressType.HOLD:
		player.hud.overlay_progress = (
			(use_timer.wait_time - use_timer.time_left) / use_timer.wait_time
		)
	else:
		player.hud.overlay_progress = 0.0


func trigger() -> void:
	in_use = true
	use_timer.start()


func detrigger() -> void:
	super()
	var time_used := use_timer.wait_time - use_timer.time_left
	overlay_start_progress = time_used / use_timer.wait_time
	use_timer.stop()
	var cooldown_time := overlay_start_progress * use_timer.wait_time
	cooldown_timer.start(cooldown_time)
