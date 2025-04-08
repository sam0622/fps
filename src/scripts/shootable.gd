class_name Shootable
extends Node3D

# Must be overriden
func hit() -> void:
	printerr("The function 'hit' of class Shootable must be overriden by a subclass")
