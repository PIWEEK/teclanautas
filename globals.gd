extends Node

var num_word = 0

var words = [[],[]]



var accents = {
	"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
	"Á": "a", "É": "e", "Í": "i", "Ó": "o", "Ú": "u",
	"à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u",
	"À": "a", "È": "e", "Ì": "i", "Ò": "o", "Ù": "u",
	"ä": "a", "ë": "e", "ï": "i", "ö": "o", "ü": "u",
	"Ä": "a", "Ë": "e", "Ï": "i", "Ö": "o", "Ü": "u",
	"â": "a", "ê": "e", "î": "i", "ô": "o", "û": "u",
	"Â": "a", "Ê": "e", "Î": "i", "Ô": "o", "Û": "u"
}

func remove_accents(char):
	return accents.get(char, char)

func normalize(word):
	var s = ""
	for c in word:
		s += remove_accents(c)
	return s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func next_word(level):
	num_word = (num_word + 1) % len(words[level])
	return words[level][num_word]
