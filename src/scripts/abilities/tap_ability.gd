class_name TapAbility
extends Ability

@export var time_in_effect: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	press_type = KeyPressType.TAP


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if on_cooldown:
		var t := 1.0 - (cooldown_timer.time_left / cooldown_length)
		player.hud.overlay_progress = lerp(1.0, 0.0, t)


func trigger() -> void:
	super()
	in_use = true
	use_timer.start(time_in_effect)
	await use_timer.timeout
	detrigger()


func detrigger() -> void:
	super()
	cooldown_timer.start(cooldown_length)
