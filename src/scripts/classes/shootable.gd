class_name Shootable
extends Node3D

# Must be overriden
func on_shot(_gun_type: Gun) -> void:
	printerr("The function 'on_shot' of class Shootable must be overriden by a subclass")
