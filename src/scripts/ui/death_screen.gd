## Screen that shows when [Player] dies.
class_name DeathScreen
extends Control

## All death messages that can appear.
const DEATH_MESSAGES := [
	"You dead as hell 🫵🤣",
	"Skill issue",
	"Maybe try harder next time",
	"You know you have to click to shoot, right?",
	"Switching to your secondary is always faster than reloading",
	"Maybe invest in a gaming chair",
	"Easy mode can now be selected",
	"You really suck at this",
	"Are you really getting beat by 150 lines of code?"
]


## Picks a random message from [constant DeathScreen.DEATH_MESSAGES].
func _ready() -> void:
	$VBoxContainer/Label.text = Utils.random_choice(DEATH_MESSAGES)


func _on_restart_button_pressed() -> void:
	GameManager.load_arena()


func _on_menu_button_pressed() -> void:
	pass # Replace with function body.


func fade_in() -> void:
	$AnimationPlayer.play("load_death_screen")
