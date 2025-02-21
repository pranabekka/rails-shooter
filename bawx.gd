extends Area2D


@export_enum("speed_multiplier") var effect: String = "speed_multiplier"
@export_multiline var data_input: String


var data: Dictionary


func _ready():
	data = JSON.parse_string(data_input)
	

func _process(delta):
	rotation_degrees = rotation_degrees + (1.5 * (data.multiplier - 1))
