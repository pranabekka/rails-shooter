extends Node2D


# TODO: prefix `signal_` for signals
#       they're more brittle than regular functions
#       there's no errors at runtime even if the args are wrong
#       so it's good to know where they are


const BULLET_SCENE = preload("res://bullet.tscn")

var player = { "speed_multiplier": 1.0 }

var laps = {
	"best": null,
	"last": null,
	"current": 0.0
}


func _ready() -> void:
	var player_colour = Color.from_ok_hsl(randf(), 1.0, 0.7)
	
	%outline.default_color = player_colour
	%fill.color = player_colour
	
	# cooldown_bar background
	var stylebox_bg = %cooldown_bar.get_theme_stylebox("background").duplicate()
	stylebox_bg.border_color = player_colour
	%cooldown_bar.add_theme_stylebox_override("background", stylebox_bg)
	%cooldown_bar2.add_theme_stylebox_override("background", stylebox_bg)
	
	# cooldown_bar fill
	var stylebox_fill = %cooldown_bar.get_theme_stylebox("fill").duplicate()
	stylebox_fill.bg_color = player_colour
	%cooldown_bar.add_theme_stylebox_override("fill", stylebox_fill)
	%cooldown_bar2.add_theme_stylebox_override("fill", stylebox_fill)
	
	%hint_controls.play("default")
	
	%cooldown_timer.timeout.connect(cooldown_over)
	
	%lap_end_area.area_exited.connect(lap_over)


func _draw() -> void:
	var polyline = %rail.curve.get_baked_points() * %rail.get_global_transform().inverse()
	draw_polyline(polyline, Color.from_ok_hsl(randf(), 0.5, 0.5), 4)


func _process(delta: float) -> void:
	%PathFollow2D.progress += 200 * player.speed_multiplier * delta
	
	# TODO: add input buffering
	# TODO: cooldown overload/override where you spam a bit, like 3 taps within cooldown
	#       but then the cooldown takes even longer
	if Input.is_action_just_pressed("action") and %cooldown_timer.time_left == 0:
		# TODO: animate cooldown start
		shoot()

	%cooldown_bar.value = %cooldown_timer.wait_time - %cooldown_timer.time_left
	%cooldown_bar2.value = %cooldown_timer.wait_time - %cooldown_timer.time_left
	
	# TODO: detect laps
		# - reaching end of lap
		# - reset current lap
		# - record last lap
		# - test last lap against best and record
	laps.current += delta
	var time_display = {}
	time_display.my_best = "MY BEST: 7.88s | "
	time_display.best = "BEST: %.2fs | " % laps.best if laps.best else "BEST: ??? | "
	time_display.last = "LAST: %.2fs | " % laps.last if laps.last else "LAST: ??? | "
	time_display.current = "CURR: %.2fs" % laps.current
	%lap_time_display.text = time_display.my_best + time_display.best + time_display.last + time_display.current
	
	# TODO: keep animation speed fast for input hint, but slowly increase delay over time
	#       so the tapping animation is quick-ish, but there's a delay before it taps again


func shoot():
	%cooldown_timer.start()

	var bullet = BULLET_SCENE.instantiate()
	bullet.transform = %bullet_spawner.get_global_transform()
	bullet.area_entered.connect(_on_bullet_area_entered.bind(bullet))
	add_child(bullet)


func _on_bullet_area_entered(area: Area2D, bullet):
	if area.is_in_group("bawx"):
		bullet.queue_free()
		var bawx = area
		# TODO: parse bawx data as json, cause it's easier than making a dict in the editor
		if bawx.effect == "speed_multiplier":
			player.speed_multiplier = bawx.data.multiplier
			var timer_old = find_child("*Timer*", false, false)
			if timer_old:
				# NOTE: this implementation keeps the boost a little longer.
				# it's probably not a reliable amount of duration,
				# but rewards you for consecutive shots within time.
				# consider making a manual timer using a float subtracted by delta
				# and adding in a bonus if timer already exists
				var time_new = bawx.data.duration_sec + timer_old.time_left
				timer_old.stop()
				timer_old.wait_time = time_new
				timer_old.start()
			else:
				var timer = Timer.new()
				timer.one_shot = true
				add_child(timer)
				timer.start(bawx.data.duration_sec)
				await timer.timeout
				timer.queue_free()
				player.speed_multiplier = 1


func cooldown_over():
	# TODO: exaggerate animation further
	# TODO: animate to x scale 0 and y scale 1.5 or so at the end
	#       like a portal closing animation
	var anim_step_duration = .1
	var tweener = create_tween()
	tweener.tween_property(%cooldown_bar, "scale", Vector2(1.8, .6), anim_step_duration)
	tweener.tween_property(%cooldown_bar, "scale", Vector2(.4, 1.7), anim_step_duration)
	tweener.tween_property(%cooldown_bar, "scale", Vector2(1, 1), anim_step_duration)


func lap_over(area):
	if area.is_in_group("player"):
		print('lap: %.2f' % laps.current)
		laps.last = laps.current
		laps.current = 0.0
		if laps.best == null or laps.last < laps.best:
			laps.best = laps.last
