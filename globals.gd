extends Node

var num_word = 0

var words = [[],[]]

var config

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_config()
	load_words(2)
	load_words(3)
	load_words(4)
	load_words(5)
	load_words(6)
	load_words(7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_words(num):
	var file = "res://data/" + str(num) + ".txt"
	var f = FileAccess.open(file, FileAccess.READ)
	var data = f.get_as_text(true).split("\n")
	var filtered_array = []
	for string in data:
		if string != "":
			filtered_array.append(string.to_lower())

	filtered_array.shuffle()
	words.append(filtered_array)

func _next_word(level):
	num_word = (num_word + 1) % len(words[level])
	return words[level][num_word]

func next_word(level, letters):
	var word = _next_word(level)
	while letters.has(word[0]):
		word = _next_word(level)
	return word


func save_config():
	config.save("user://teclanautas.cfg")

func load_config():
	# Load data from a file.
	config = ConfigFile.new()
	var err = config.load("user://teclanautas.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		config = ConfigFile.new()
	print(config.encode_to_text())
