extends Area2D


const SPEED = 300.0 # does this mean 300 pixels per second?


func _process(delta: float) -> void:
	position += transform.y * SPEED * delta


func _on_visibility_checker_screen_exited() -> void:
	queue_free()
