@tool
extends Node2D

# debug variables
var db_world_size
var db_world_size_x
var db_world_size_y
var db_m
var db_b
var db_noise_seed
var db_octaves
var db_init_div
var db_init_gap
var db_div_steps = []
var db_gap_steps = []
var db_noise_multipliers = []
var db_limits = []
var current_block_square = Vector2(-9999, -9999)


signal finished
signal layer
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

var world_size = Vector2(333, 333)
var tile_size = TextureControl.tile_size
var chunk_size = 16

var done = false
var dict_ready = false
var data = []

var m = 0.03
var b = 0.15
var draw_flag = true

var quadtree

var world_array = []
var blocks = []
var chunks = {}
var active_blocks = []
var inactive_blocks = []
var active_chunks = []
var inactive_chunks = []

var next_step = 0

var steps = [
#	initialize_lines(),
	"set_outer_limit",
	"set_inner_limits",
	"adjust_inner_lines",
	"initialize_blocks",
	"populate_debug",
	"unload_to_dict"
]

func _ready():
	randomize()
	initialize_values()
	world_size.x = db_world_size_x
	world_size.y = db_world_size_y
	print("world size :   %s" % world_size.x)
	populate_debug()
	TextureControl.textures.shuffle()
	# use increment process
	#initialize_lines()
	#initialize_blocks()
	#populate_debug()

func increment_process():
	if next_step < steps.size():
		print("executing the following function: " + steps[next_step])
		if next_step != steps.size() - 1:
			call(steps[next_step])
		else:
			await call(steps[next_step])
		next_step += 1
		if next_step < steps.size():
			print("Next function: " + steps[next_step])
			queue_redraw()

func initialize_values():
	db_world_size_x = randi_range(222, 2222)
	db_world_size_y = randi_range(222, 444)
	db_m = (8.5 / world_size.x)
	db_b = (16.5 / world_size.y)
	m = db_m
	b = db_b
	db_noise_seed = randf() * randf() * 100.0
	db_octaves = randi_range(2,8)
	db_init_div = randf_range(2.2, 4.5)
	db_init_gap = 444.4

func populate_debug():
	data = send_debug_panel_data()
	done = true
	await get_tree().process_frame
	emit_signal('finished')

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
	noise.seed = db_noise_seed
	noise.fractal_octaves = db_octaves
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
		y += (noise.get_noise_2d(x,-y) + noise.get_noise_2d(-x,y)) * 33.0
		outer_line.append(Vector2(x,-y))
	#var info = measure_height(outer_line)
	#var height = info[1] - info[0]
	#print("first height: %s" % height)
	#if height > world_size.y:
		#var gap = float(height / world_size.y)
		#print("gap: %s" % gap)
		#for i in outer_line.size()-1:
			#outer_line[i].y -= (outer_line[i].y * (1.0 - gap))
	#info = measure_height(outer_line)
	#height = info[1] - info[0]
	#print("final height: %s" % height)

func set_inner_limits():
	inner_lines.resize(9)
	#var divisor = randf_range(2.2, 4.5)
	var divisor = db_init_div
	#db_init_div = divisor
	var multiplier
	#var gap = 333.3
	#var gap = 33.33
	#db_init_gap = gap
	var gap = db_init_gap
		
		
	for i in 9:
		inner_lines[i] = []
		#print("Line %s : \ndiv: %s, gap: %s" % [i,divisor, gap])
		var shift = int( ( world_size.x / 2 ) * randf_range(0.5, 1.5) )
		for x in world_size.x:
			x -= world_size.x / 2
		
			var y
			if i < -1:
				y = ((-pow(m*x,2))*(b*(divisor / 1.5))) + gap
			else:
				y = ((-pow(m*x,2))*(b/divisor)) + gap
			
			y += (noise.get_noise_2d(x,-y) * noise.get_noise_2d(-x,y)) * (33.0/((i+1.0)/1.5))
			inner_lines[i].append(Vector2(x,-y))
		var size_x = world_size.x * (0.001)
		#if size_x < 222:
			#divisor /= 1.9
		#elif size_x < 555:
			#divisor /= 2.1
		#elif size_x < 888:
			#divisor /= 2.3
		#else:
		var divisor_step = randf_range(1.1, 1.3)
		db_div_steps.append([divisor_step, size_x, divisor/divisor_step + size_x])
		var gap_step = randf_range(0.9, 1.5)
		db_gap_steps.append([gap_step, gap*gap_step])
		divisor /= divisor_step + size_x  # 2.5 or lower = wider curve 2.75 or higher = tighter curve
		gap /= gap_step # 1.15

func adjust_inner_lines():
	
	# align top inner to outer
	var offset = outer_line[0].y - inner_lines[0][0].y
	if abs(offset) > 0:
		for i in outer_line.size() -1:
			outer_line[i].y = outer_line[i].y - offset
	
	for i in inner_lines.size()-2:
		var noise_multiplier = randf_range(20.0,50.0)
		db_noise_multipliers.append(noise_multiplier)
		if typeof(inner_lines[i]) != TYPE_NIL:
			for j in inner_lines[i].size()-1:
				inner_lines[i][j].y += (noise.get_noise_3d(i, j, i * 10)) * noise_multiplier
	
	var full_gap = compare_lines(inner_lines[0], outer_line)
	var base_gap = int(( measure_height(outer_line)[1]) / inner_lines.size()-2)
	for id in inner_lines.size()-1:
		var gaps = compare_lines(inner_lines[id], inner_lines[id+1])
		if gaps[1] < base_gap:
			for _i in inner_lines[id + 1].size()-1:
				inner_lines[id + 1][_i].y += base_gap - gaps[1]
	
	# align top inner to outer
	offset = outer_line[0].y - inner_lines[0][0].y
	if abs(offset) > 0:
		for i in outer_line.size() -1:
			outer_line[i].y = outer_line[i].y - offset

func initialize_blocks():
	for j in outer_line.size()-1:
		var height = abs(int(outer_line[j].y - inner_lines[0][j].y))
		var _j = j - int(world_size.x / 2)
		#print(height)
		var block : Block
		var chunk_id
		if height > 0:
			for k in height:
				var _k = int(inner_lines[0][j].y) + (k)
				chunk_id = Vector2(int(_j / chunk_size), int(_k / chunk_size))
				#print(chunk_id)
				if !chunks.has(chunk_id):
					chunks[chunk_id] = Chunk.new(chunk_id)
					add_child.call_deferred(chunks[chunk_id])
				var _type = check_type(j,_k)
				#current_block_square = Vector2(_j, _k)
				#queue_redraw()
				block = Block.new(
					Vector2(_j, _k),
						_type,
						randf_range(0.5, 10.0),
						false)
				block.mode = 1
				chunks[chunk_id].add_block(block, block.local_index)
		else:
			chunk_id = Vector2(int(_j / chunk_size), int(inner_lines[0][j].y / chunk_size))
			#print(chunk_id)
			if !chunks.has(chunk_id):
				chunks[chunk_id] = Chunk.new(chunk_id)
				add_child.call_deferred(chunks[chunk_id])
			var _type = check_type(j, int(inner_lines[0][j].y))
			#current_block_square = Vector2(j, int(inner_lines[0][j].y))
			#queue_redraw()
			block = Block.new(
				Vector2(_j,int(inner_lines[0][j].y)),
				_type,
				randf_range(0.5, 10.0),
				false)
			block.mode = 1
			chunks[chunk_id].add_block(block, block.local_index)
		
		var counter = int(world_size.x /5.0)
		if j % counter == 0:
			continue # keep this breakpoint on to keep the loading sequence from freezing ;3
	dict_ready = true
	#print("Chunk Keys:")
	#var keys_string = ""
	#var last_key = Vector2.ZERO
	#for key in chunks.keys():
		#if last_key.x != key.x:
			#keys_string += "\n"
		#last_key = key
		#keys_string += str(key) + ", "
	#print(keys_string)

func check_type(x,y):
	var type = 0
	for i in inner_lines.size() - 1:
		#print("1: %s    2: %s" % [inner_lines[i+1][x].y, y])
		if inner_lines[i][x].y < y:
			type = i
	return type

func send_to_tree():
	quadtree = QuadTree.new(
		Rect2(
			Vector2(
				outer_line[0].x * tile_size, 
				measure_height(inner_lines[0]).x * tile_size),
				world_size * tile_size )
			)
	add_child(quadtree)
	for key in chunks.keys():
		quadtree.insert(chunks[key])
	if quadtree.subnodes.size() == 0:
		for i in quadtree.objects:
			i as Chunk
			print(i.chunk_id)
	else:
		for i in quadtree.subnodes.size() -1:
			#print("subnode %s: %s" % [i, quadtree.subnodes[i].objects])
			pass
	#print()

func measure_height(line : Array):
	var highest = 99999
	var lowest = -99999
	var height = 0
	for i in line:
		if i.y > lowest:
			lowest = i.y
		if i.y < highest:
			highest = i.y
	return Vector2(highest, lowest)

func compare_lines(top_line, bottom_line):
	var biggest_gap = -999999
	var smallest_gap = 99999
	var gaps = []
	for i in top_line.size()-1:
		var top = top_line[i]
		var bottom = bottom_line[i]
		var gap = bottom.y - top.y
		if gap > biggest_gap:
			biggest_gap = gap
		if gap < smallest_gap:
			smallest_gap = gap
		gaps.append(gap)
	return [biggest_gap, smallest_gap]

func save_chunk_manifest():
	
	pass

func load_chunk_manifest():
	pass

func send_debug_panel_data():
	var data = [
		db_world_size_x,
		db_world_size_y,
		snapped(db_m, 0.01),
		snapped(db_b, 0.01), 
		snapped(db_noise_seed, 0.0001),
		snapped(db_octaves, 0.01),
		snapped(db_init_div, 0.01),
		snapped(db_init_gap, 0.01),
		db_div_steps,
		db_gap_steps,
		db_noise_multipliers,
		db_limits ]
	return data

func _draw(): 
	if draw_flag:
		if current_block_square != Vector2(-9999, -9999):
			draw_rect(Rect2(current_block_square * Vector2(tile_size, tile_size), Vector2(tile_size, tile_size)), Color.WHITE_SMOKE, false, 3.0)
		for i in outer_line:
			draw_circle(Vector2(i.x*tile_size, i.y*tile_size), tile_size, debug_colors[0])
		for j in inner_lines.size()-1:
			if typeof(inner_lines[j]) != TYPE_NIL:
				for ii in inner_lines[j].size()-1:
					draw_circle(Vector2(inner_lines[j][ii].x*tile_size, inner_lines[j][ii].y*tile_size), tile_size, debug_colors[j+1])
