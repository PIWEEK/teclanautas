extends Node2D

var meteor_scene: PackedScene = preload("res://commander_meteor.tscn")
var missile_scene: PackedScene = preload("res://missile.tscn")

var m_areas = []
var cities = []
var alive_cities = []
var meteors = []
var missiles = []
var playing = false
var current_level = 0

var missile_speed = 1500
var meteor_speed = 500
var remaining_meteors = 0
var word_size = 0
var cadence = 0
var next_meteor_in = 0
var score = 0
var writing_to = null
var city_score = 100
var meteor_score = 50
var level_meteors = 0
var destroyed_meteors = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_areas = [$MissileArea1, $MissileArea2, $MissileArea3]
	cities = [$City1, $City2, $City3, $City4, $City5]
	$LevelSelection.init(exit_to_menu, start)
	$LevelSelection.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		add_meteors(delta)
		move_meteors(delta)
		move_missiles(delta)
		if remaining_meteors == 0 and len(meteors) == 0:
			win()


func start():
	$WinPopup.visible = false
	$LevelSelection.visible = false
	$Progress.visible = true
	$Remaining.visible = true
	$MissileArea1.visible = true
	$MissileArea2.visible = true
	$MissileArea3.visible = true
	alive_cities = [$City1, $City2, $City3, $City4, $City5]
	for c in cities:
		c.reset()
	while len(meteors) > 0:
		delete_meteor(meteors[0])
	while len(missiles) > 0:
		delete_meteor(missiles[0])

	load_level()

	for ma in m_areas:
		update_missile_area(ma)

	score = 0
	$Progress/Score.text = str(score)
	playing = true


func load_level():
	var starting_meteors = 3 + round(current_level / 8)
	remaining_meteors = current_level + 10 - starting_meteors
	cadence = 60 / remaining_meteors
	level_meteors = remaining_meteors + starting_meteors
	destroyed_meteors = 0
	word_size = 2 + round(current_level / 8)


	next_meteor_in = cadence

	meteor_speed = 50 + current_level * 5

	$Remaining/Label.text = str(destroyed_meteors) + " / " + str(level_meteors)

	for i in range(starting_meteors):
		create_meteor()


func create_meteor():
	var x = cities[randi_range(0,4)].position.x
	var y = -30
	var target_city = alive_cities.pick_random()
	var target = target_city.position
	target.x += $City1.size.x/2
	target.y += $City1.size.y/2

	var speed = meteor_speed * randf_range(0.25, 2)

	var m: Node = meteor_scene.instantiate()
	meteors.append(m)
	m.position.x = x
	m.position.y = y
	m.set_target(target, target_city.num, speed)
	add_child(m)

func delete_meteor(item):
	if item != null:
		meteors.erase(item)
		item.queue_free()
		remove_child(item)
		destroyed_meteors += 1
		$Remaining/Label.text = str(destroyed_meteors) + " / " + str(level_meteors)

func delete_missile(item):
	if item != null:
		missiles.erase(item)
		item.queue_free()
		remove_child(item)

func add_meteors(delta):
	next_meteor_in -= delta
	if remaining_meteors > 0 and next_meteor_in <= 0:
		next_meteor_in = cadence
		remaining_meteors -= 1
		create_meteor()

func move_meteors(delta):
	var to_delete = []
	for m in meteors:
		Globals.move(m, m.target, meteor_speed, delta)
		if m.position.distance_to(m.target) <= 25:
			to_delete.append(m)
			if cities[m.target_num].alive:
				score -= city_score
				$Progress/Score.text = str(score)
				cities[m.target_num].kill()
				alive_cities.erase(cities[m.target_num])
				$CityDestroyed.play()


	for m in to_delete:
		delete_meteor(m)

	if len(alive_cities) == 0:
		lose()

func move_missiles(delta):
	var to_delete = []
	for m in missiles:
		Globals.move(m, m.target, missile_speed, delta)
		if m.position.distance_to(m.target) <= 25:
			on_missile_explossion(m.target_num)
			to_delete.append(m)
	for m in to_delete:
		delete_missile(m)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				exit_to_menu()
			elif playing:
				if writing_to != null and not writing_to.alive:
					writing_to = null
				var character = char(event.unicode)
				if writing_to != null:
					writing_to.add_letter(character)
				else:
					for ma in m_areas:
						if ma.word[0] == character:
							ma.add_letter(character)
							writing_to = ma
							break
					if writing_to == null:
						_on_letter_failed()


func _on_letter_failed():
	score -= 5
	$Progress/Score.text = str(score)
	writing_to = null
	$Error.play()

func win():
	playing = false
	$Progress/Score.text = str(score)




	var best_scores = []
	best_scores.resize(40)
	best_scores.fill(0)
	best_scores = Globals.config.get_value("commander", "best_scores", best_scores)
	if best_scores[current_level]== 0 or (score > best_scores[current_level]):
		best_scores[current_level] = score
		Globals.config.set_value("commander", "best_scores", best_scores)

	var max_score = level_meteors * meteor_score

	var stars = 1
	if score == max_score:
		stars = 3
	elif score > max_score * 2/3:
		stars = 2

	$WinPopup.init("¡Has ganado!", "Puntuación: " + str(score), "Mejor puntuación: " + str(best_scores[current_level]), stars, current_level+1, exit_to_menu, next_level)


	var max_level = Globals.config.get_value("commander", "level", -1)
	if current_level+1 > max_level:
		Globals.config.set_value("commander", "level", current_level + 1)
	Globals.save_config()

	await get_tree().create_timer(1).timeout
	$Progress.visible = false
	$Remaining.visible = false
	$WinPopup.visible = true


func lose():
	playing = false

	while len(meteors) > 0:
		delete_meteor(meteors[0])
	while len(missiles) > 0:
		delete_meteor(missiles[0])

	$MissileArea1.visible = false
	$MissileArea2.visible = false
	$MissileArea3.visible = false

	await get_tree().create_timer(1.25).timeout

	$WinPopup.init("Has perdido :(", "¿Quieres jugar otra vez?", "", 0, current_level+1, exit_to_menu, start)
	$Progress.visible = false
	$Remaining.visible = false
	$WinPopup.visible = true

func next_level():
	current_level = min(current_level+1, 39)
	start()

func exit_to_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_level_selection_level_select(level: Variant) -> void:
	current_level = level


func update_missile_area(ma):
	var letters = m_areas.map(func(s): return s.word[0])
	var word = Globals.next_word(word_size, letters)
	ma.set_word(word)


func _on_missile_area_finished(num: Variant) -> void:
	var a = m_areas[num]
	writing_to = null
	update_missile_area(a)
	a.prepare_explossion()
	launch_missile(a)


func on_missile_explossion(num):
	$Explosion.play()
	var a = m_areas[num]
	a.explode()
	update_missile_area(a)

	var to_delete = []
	for m in meteors:
		if m.position.distance_to(center(a)) < a.size.x / 2:
			to_delete.append(m)
	for m in to_delete:
		delete_meteor(m)
		score += meteor_score
		$Progress/Score.text = str(score)

func center(item):
	var center = Vector2()
	center.x += item.position.x + item.size.x / 2
	center.y += item.position.y + item.size.x / 2
	return center


func launch_missile(a):
	var min_dist = 10000
	var launch_city = null
	var launch_center = null
	var center = center(a)


	for c in alive_cities:
		var city_center = center(c)
		var dist = city_center.distance_to(center)
		if dist < min_dist:
			min_dist = dist
			launch_city = c
			launch_center = city_center


	var m: Node = missile_scene.instantiate()
	missiles.append(m)
	m.position = launch_center
	m.target = center
	m.target_num = a.num_area
	m.look_at(center)
	add_child(m)
