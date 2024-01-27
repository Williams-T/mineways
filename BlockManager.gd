@tool
extends Node2D

var debug_colors = [
	Color.AQUAMARINE ,          # 0
	Color.TOMATO ,              # 1
	Color.BLUE_VIOLET ,         # 2
	Color.CRIMSON ,             # 3
	Color.CORAL ,               # 4
	Color.DEEP_PINK ,           # 5
	Color.DEEP_SKY_BLUE ,       # 6
	Color.SPRING_GREEN ,        # 7
	Color.MEDIUM_PURPLE ,       # 8
	Color.ORANGE_RED            # 9
]


var outer_line = []
var inner_lines = []

var noise = FastNoiseLite.new()

var world_size = Vector2(555, 1500)
var tile_size = TextureControl.tile_size
var chunk_size = 32

var m = 0.03
var b = 0.15
var draw_flag = false

var quadtree = preload("res://QuadTree.gd")

var world_array = []
var blocks = []
var chunks = {}
var chunk_quad = quadtree.new(Rect2())
var active_blocks = []
var inactive_blocks = []
var active_chunks = []
var inactive_chunks = []


func _ready():
	#TextureControl.textures.shuffle()
	initialize_lines()
	#generate_tile_array()
	initialize_blocks()
	#adjust_chunks()


func adjust_chunks(location : Vector2):
	var chunked_loc = Vector2(int(location.x / chunk_size), int(location.y / chunk_size))
	for chunk in chunks:
		chunk as Chunk
		if chunk.active == true:
			chunk.deactivate()
	if chunks.has(chunked_loc):
		chunks[chunked_loc].activate()
		chunks[chunked_loc + Vector2(1,0)].activate()
		chunks[chunked_loc + Vector2(-1,0)].activate()
		chunks[chunked_loc + Vector2(0,1)].activate()
		chunks[chunked_loc + Vector2(0,-1)].activate()
		
		pass

func initialize_lines():
	randomize()
	noise.seed = randf() * randf() * 100.0
	noise.fractal_octaves = randi_range(2,8)
	#if world_size.x > 550:
		#if world_size.x > 950:
			##m /= 2.5
			#pass
		#m = (82.5 / world_size.x)
		#b = (16.5 / world_size.x)
		##b /= 2.5
	#elif world_size.x < 450:
		#if world_size.x < 150:
			##m *= 2.5
			#pass
	m = (82.5 / world_size.x)
	b = (16.5 / world_size.x)
		#b *= 2.5
	set_outer_limit()
	set_inner_limits()
	adjust_inner_lines()
	#draw_flag = true

func set_outer_limit():
	outer_line.clear()
	for x in world_size.x:
		x -= (world_size.x / 2)
		var y = ((m * pow(x,2))*b)
		y += noise.get_noise_2d(x,-y) * 33.0
		outer_line.append(Vector2(x,-y))

func set_inner_limits():
	inner_lines.resize(9)
	var divisor = 10.0
	var multiplier
	var gap = 333.3
	
	for i in 9:
		inner_lines[i] = []
		for x in world_size.x:
			x -= (world_size.x / 2)
			#var y = -((m*pow(x,2))*(b/divisor))+gap
			var y = ((-pow(m*x,2))*(b/divisor)) + gap
			y += noise.get_noise_2d(x,-y) * (33.0/((i+1.0)/1.25))
			inner_lines[i].append(Vector2(x,-y))
		divisor /= 2.75
		gap /= 1.15

func adjust_inner_lines():
	# align top inner to outer
	var offset = outer_line[0].y - inner_lines[0][0].y
	if abs(offset) > 0:
		for i in outer_line.size() -1:
			outer_line[i].y = outer_line[i].y - offset
	# trim inner lines
	#for a in inner_lines.size()-1:
		#for b in inner_lines[a].size()-1:
			#if inner_lines[a][b].y > outer_line[b].y :
				#var temp = inner_lines[a][b]
				#inner_lines[a][b] = Vector2()

func generate_tile_array():
	var highest_y = 0
	var lowest_y = 0
	for i in inner_lines[0]:
		if i.y < highest_y:
			highest_y = i.y
	for i in inner_lines[-1]:
		if i.y > lowest_y:
			lowest_y = i.y
	var height = abs(highest_y) + abs(lowest_y)
	print(height)
	
	world_array.resize(world_size.x)
	for x in world_size.x - 1:
		world_array[x] = []
		world_array[x].resize(height)
		for y in height - 1:
			world_array[x][y] = -1
	for i in inner_lines[0].size()-1:
		var _y = inner_lines[0][i].y
		while _y <= outer_line[i].y:
			#print("y: %s. oliy: %s." % [_y, outer_line[i].y])
			var val = 0
			if _y > inner_lines[1][i].y:
				val = 1
			if _y > inner_lines[2][i].y:
				val = 2
			if _y > inner_lines[3][i].y:
				val = 3
			if _y > inner_lines[4][i].y:
				val = 4
			if _y > inner_lines[5][i].y:
				val = 5
			if _y > inner_lines[6][i].y:
				val = 6
			if _y > inner_lines[7][i].y:
				val = 7
			if _y > inner_lines[8][i].y:
				val = 8
			#if _y > inner_lines[9][i].y:
				#val = 9
			world_array[i][_y] = val
			_y += 1
	print()

func initialize_blocks():
	for j in outer_line.size()-1:
		var height = abs(int(outer_line[j].y - inner_lines[0][j].y))
		var _j = j - int(world_size.x / 2)
		#print(height)
		var block : Block
		var chunk_id
		if height > 0:
			for k in height:
				var _k = int(inner_lines[0][j].y) + k
				chunk_id = Vector2(int(_j / chunk_size), int(_k / chunk_size))
				#print(chunk_id)
				if !chunks.has(chunk_id):
					chunks[chunk_id] = Chunk.new(chunk_id)
					add_child(chunks[chunk_id])
				block = Block.new(
					Vector2(_j, _k),
						check_type(j,_k),
						randf_range(3.0,7.0),
						true)
				block.mode = 1
				chunks[chunk_id].add_block(block, block.local_index)
		else:
			chunk_id = Vector2(int(_j / chunk_size), int(inner_lines[0][j].y / chunk_size))
			#print(chunk_id)
			if !chunks.has(chunk_id):
				chunks[chunk_id] = Chunk.new(chunk_id)
				add_child(chunks[chunk_id])
			block = Block.new(
				Vector2(_j,int(inner_lines[0][j].y)),
				check_type(j, int(inner_lines[0][j].y)),
				randf_range(3.0,7.0),
				true)
			block.mode = 1
			chunks[chunk_id].add_block(block, block.local_index)
		
		var counter = int(world_size.x /4.0)
		if j % counter == 0:
			print() # keep this breakpoint on to keep the loading sequence from freezing ;3
	print("Chunk Keys:")
	var keys_string = ""
	var last_key = Vector2.ZERO
	for key in chunks.keys():
		if last_key.x != key.x:
			keys_string += "\n"
		last_key = key
		keys_string += str(key) + ", "
	print(keys_string)

func check_type(x,y):
	var type = 0
	for i in inner_lines.size() - 1:
		#print("1: %s    2: %s" % [inner_lines[i+1][x].y, y])
		if inner_lines[i][x].y < y:
			type = i
	return type

func get_world_size():
	return world_size

func get_world_width():
	return world_size.x

func get_world_height():
	return world_size.y

func set_world_size( size: Vector2):
	world_size = size

func set_world_width(w : int):
	world_size.x = w

func set_world_height(h : int):
	world_size.y = h

func save_chunk_manifest():
	
	pass

func load_chunk_manifest():
	pass

func _draw(): 
	if draw_flag:
		for i in outer_line:
			draw_circle(Vector2(i.x*tile_size, i.y*tile_size), tile_size, debug_colors[0])
		for j in inner_lines.size()-1:
			for ii in inner_lines[j].size()-1:
				draw_circle(Vector2(inner_lines[j][ii].x*tile_size, inner_lines[j][ii].y*tile_size), tile_size, debug_colors[j+1])
