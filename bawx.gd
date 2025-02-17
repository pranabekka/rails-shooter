extends Area2D


# TODO: switch dictionary to string and parse as json
@export_enum("speed_multiplier") var effect: String = "speed_multiplier"
@export var data: Dictionary = { "multiplier": 2.0, "duration_sec": 1.0 }


func _process(delta):
	rotation_degrees = rotation_degrees + (1.5 * (data.multiplier - 1))
