extends Node

var tile_size = 9
var chunk_size = 16

var textures = [
	load("res://_working/low_res/01.png"),
	load("res://_working/low_res/02.png"),
	load("res://_working/low_res/03.png"),
	load("res://_working/low_res/04.png"),
	load("res://_working/low_res/05.png"),
	load("res://_working/low_res/06.png"),
	load("res://_working/low_res/07.png"),
	load("res://_working/low_res/08.png"),
	load("res://_working/low_res/09.png"),
	load("res://_working/low_res/10.png")
]

func get_texture(type):
	if type < textures.size():
		return textures[type]
	else:
		print("texture_error")
	return "error"
