extends Node2D

var ufo_scene: PackedScene = preload("res://ufo.tscn")
var ufos = []
var ufos_by_word = Dictionary()
var writing_to_ufo
var playing = false

var current_level

const ROW_SIZE = 235
const UFO_WIDTH = 250
const UFO_HEIGTH = 242
const LEFT = 0
const RIGHT = 2560 - UFO_WIDTH
var ufo_speed = 500
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelSelection.init(exit_to_menu, start)

func restart():
	current_level = 0
	next_level()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				exit_to_menu()
				#get_tree().quit()
			elif playing:
				var character = char(event.unicode)
				if writing_to_ufo != null and writing_to_ufo.alive:
					writing_to_ufo.add_letter(character)
				else:
					for ufo in ufos:
						if ufo.alive and ufo.word[0] == character:
							ufo.add_letter(character)
							writing_to_ufo = ufo
							break
				if writing_to_ufo == null:
					_on_letter_failed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		update_time(delta)
		for ufo in ufos:
			move_ufo(ufo, delta)

func update_time(delta):
	time += delta
	$Background/Time.text = str(floor(time))

func move_ufo(moving_ufo, delta):
	var moving_ufo_row = moving_ufo.data["moving_ufo_row"]
	var target = Vector2(moving_ufo.position.x, moving_ufo.position.y)
	if playing and moving_ufo != null and moving_ufo.active:
		if moving_ufo_row % 2 == 0: #move left
			if moving_ufo.position.x <= LEFT: #move down
				target.y = (moving_ufo_row + 1) * ROW_SIZE
				if moving_ufo.position.y >= target.y: #advance_row
					moving_ufo_row += 1
					moving_ufo.data["moving_ufo_row"] = moving_ufo_row
			else:
				target.x = 0
		else: #move right
			if moving_ufo.position.x >= RIGHT: #move down
				target.y = (moving_ufo_row + 1) * ROW_SIZE
				if moving_ufo.position.y >= target.y: #advance_row
					moving_ufo_row += 1
					moving_ufo.data["moving_ufo_row"] = moving_ufo_row
			else:
				target.x = RIGHT

		if (moving_ufo.position.x > target.x):
			moving_ufo.position.x = max(LEFT, moving_ufo.position.x - delta * ufo_speed)
		elif (moving_ufo.position.x < target.x):
			moving_ufo.position.x = min(RIGHT, moving_ufo.position.x + delta * ufo_speed)

		if (moving_ufo.position.y < target.y):
			moving_ufo.position.y = min(target.y, moving_ufo.position.y + delta * ufo_speed)

		check_end()


func check_end():
	if ufos[0].data["moving_ufo_row"] == 4 and ufos[0].position.x + 30 < $City.position.x + $City.size.x / 2:
		playing = false
		$Explosion.visible = true

		while len(ufos) > 0:
			delete_ufo(ufos[0])

		$WinPopup.init("Has perdido :(", "¿Quieres jugar otra vez?", "", 0, exit_to_menu, start)
		$WinPopup.visible = true


func create_ufos():
	var x = 10
	var y = 10
	var num_ufos = current_level % 5 + 4
	var word_size = min((floor(current_level / 5)) + 2, 7)
	ufo_speed = min(225 + (current_level * 25), 750)

	for i in range(num_ufos):
		create_ufo(Vector2(x + i * 325, y), word_size)

func create_ufo(position, word_size):
	var letters = ufos_by_word.keys().map(func(w): return w[0])
	var word = Globals.next_word(word_size, letters)
	var ufo: Node = ufo_scene.instantiate()
	ufo.set_word(word)
	ufo.position = position

	ufos.append(ufo)
	ufos_by_word[word] = ufo

	ufo.connect("destroyed", _on_ufo_destroyed)
	ufo.connect("letter_failed", _on_letter_failed)

	ufo.data["moving_ufo_row"] = 0

	add_child(ufo)

func _on_ufo_destroyed(word):
	var ufo = ufos_by_word[word]
	if ufo == writing_to_ufo:
		writing_to_ufo = null

	$LaserBeam2D.target_position.x = ufo.position.x + UFO_WIDTH / 2 - $LaserBeam2D.position.x
	$LaserBeam2D.target_position.y = ufo.position.y + UFO_HEIGTH / 2 - $LaserBeam2D.position.y
	$LaserBeam2D.set_is_casting(true)

	await get_tree().create_timer(1.0 - (ufo_speed / 1500.0)).timeout

	$LaserBeam2D.set_is_casting(false)
	delete_ufo(ufo)
	if len(ufos) == 0:
			win()


func delete_ufo(ufo):
	if ufo != null:
		ufo.disconnect("destroyed", _on_ufo_destroyed)
		ufo.disconnect("letter_failed", _on_letter_failed)
		ufos.erase(ufo)
		ufos_by_word.erase(ufo)
		ufo.queue_free()
		remove_child(ufo)

func win():
	playing = false
	var your_time = floor(time)

	var best_times = []
	best_times.resize(40)
	best_times.fill(0)
	best_times = Globals.config.get_value("invaders", "best_times", best_times)
	if best_times[current_level]== 0 or (your_time < best_times[current_level]):
		best_times[current_level] = floor(time)
		Globals.config.set_value("invaders", "best_times", best_times)

	var stars = 1
	var num_ufos = current_level % 5 + 4
	if time < 2 * num_ufos:
		stars = 3
	elif time < 4 * num_ufos:
		stars = 2

	$WinPopup.init("¡Has ganado!", "Tu tiempo: " + str(your_time), "Mejor tiempo: " + str(best_times[current_level]), stars, exit_to_menu, next_level)
	$WinPopup.visible = true

	Globals.config.set_value("invaders", "level", current_level + 2)
	Globals.save_config()

func exit_to_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func next_level():
	current_level = min(current_level+1, 39)
	start()

func start():
	$LevelSelection.visible = false
	$WinPopup.visible = false
	$Explosion.visible = false

	while len(ufos) > 0:
		delete_ufo(ufos[0])

	create_ufos()
	time = 0
	$Background/Level.text = "Nivel: " + str(current_level+1)
	playing = true


func _on_letter_failed():
	writing_to_ufo = null
	$Error.play()


func _on_level_selection_level_select(level: Variant) -> void:
	current_level = level - 1
