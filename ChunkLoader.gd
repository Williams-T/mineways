extends Node

# Constants (adjust as needed)
const CHUNK_SIZE = 32  # Adjust based on your chunk dimensions
const INITIAL_CHUNK_COUNT = 16  # Initial chunks to load around the player
const ACTIVE_CHUNK_RANGE = 4  # Number of chunks active in each direction

# Variables
var tile_size = TextureControl.tile_size
var chunk_pool = []
var active_chunks = {}
var dirty_chunks = []
var worker_thread = Thread.new()
var chunk_mutex = Mutex.new()

var player : Node2D


func _ready():
	# Initialize chunk pool and load initial chunks
	worker_thread.start(_thread_function)
	load_initial_chunks()

func position_to_chunk_key(pos : Vector2):
	for i in pos:
		i = floor(i / (CHUNK_SIZE * tile_size) )
	return pos

func _thread_function():
	# Handle chunk saving, clearing, and relocation in the worker thread
	while true:
		await get_tree().create_idle_signal().timeout
		process_chunk_signals()

func load_initial_chunks():
	# Get the player's current chunk key
	var player_chunk_key = position_to_chunk_key(get_node("Player").position)

	# Loop through the initial chunk range in each direction
	for y in range(-ACTIVE_CHUNK_RANGE, ACTIVE_CHUNK_RANGE + 1):
		for x in range(-ACTIVE_CHUNK_RANGE, ACTIVE_CHUNK_RANGE + 1):
			# Calculate the current chunk key
			var chunk_key = Vector2(player_chunk_key.x + x, player_chunk_key.y + y)

			# If the chunk doesn't exist, load and activate it
			if not chunk_key in active_chunks:
				load_and_activate_chunk(chunk_key)

func load_and_activate_chunk(chunk_key, ):
	# Check if the chunk already exists in the pool
	var chunk = chunk_pool.find(func(c): return c.chunk_key == chunk_key)

	# If not, create a new chunk instance
	if not chunk:
		chunk = Chunk.new(chunk_key)
		chunk_pool.append(chunk)

	# Load chunk data (replace with your actual loading logic)
	# ... (e.g., load from file or generate new data)
	chunk.blocks = BlockManager.chunks[chunk_key]

	# Add the chunk to the scene tree
	add_child(chunk)
	chunk.position = chunk_key * CHUNK_SIZE * tile_size

	# Mark the chunk as active
	active_chunks[chunk_key] = chunk


func _process(delta):
	# Check for player movement and trigger chunk updates
	if player_moved_to_new_chunk():
		update_chunks()
	pass

func player_moved_to_new_chunk():
	var current_chunk_key = position_to_chunk_key(player.position)
	if current_chunk_key != player.last_chunk_key:
		player.last_chunk_key = current_chunk_key
		return true
	return false

func update_chunks():
	# Mark furthest chunks for deactivation and signal worker thread
	var chunks_to_update = get_furthest_active_chunks()
	for chunk in chunks_to_update[0]:
		deactivate_chunk(chunk.chunk_key)
		#queue_chunk_for_relocation(chunk)
	for key in chunks_to_update[1]:
		pass

func get_furthest_active_chunks():
	# Determine which active chunks to be marked for deactivation based on distance
	var p_key = position_to_chunk_key(player.position)
	var left_key = Vector2(p_key.x - ACTIVE_CHUNK_RANGE - 1, p_key.y)
	var right_key = Vector2(p_key.x + ACTIVE_CHUNK_RANGE - 1, p_key.y)
	var up_key = Vector2(p_key.x, p_key.y - ACTIVE_CHUNK_RANGE - 1)
	var down_key = Vector2(p_key.x, p_key.y + ACTIVE_CHUNK_RANGE - 1)
	var marked_keys = []
	var marked_chunks = []
	var to_load = []
	
	
	if active_chunks.has(left_key):
		marked_keys = get_line_of_chunks(Vector2(left_key.x, 0))
		to_load = get_line_of_chunks(Vector2(right_key.x, 0))
	if active_chunks.has(right_key):
		marked_keys = get_line_of_chunks(Vector2(right_key.x, 0))
		to_load = get_line_of_chunks(Vector2(left_key.x, 0))
	if active_chunks.has(up_key):
		marked_keys = get_line_of_chunks(Vector2(0, up_key.y))
		to_load = get_line_of_chunks(Vector2(0, down_key.y))
	if active_chunks.has(down_key):
		marked_keys = get_line_of_chunks(Vector2(0, down_key.y))
		to_load = get_line_of_chunks(Vector2(0, up_key.y))
	for i in marked_keys:
		marked_chunks.append(active_chunks[i])
	return [marked_chunks, to_load]

func get_line_of_chunks(id):
	var line = []
	if id.x != 0:
		for key in active_chunks.keys():
			if key.x == id.x:
				line.append(key)
	elif id.y != 0:
		for key in active_chunks.keys():
			if key.y == id.y:
				line.append(key)
	return line

func deactivate_chunk(chunk_key):
	# Mark chunk as inactive, save data, and queue for relocation
	var chunk = active_chunks[chunk_key]
	# mark as inactive
	chunk.deactivate()
	# save data
	BlockManager.chunks[chunk_key].blocks = chunk.blocks
	# queue for relocation
	queue_chunk_for_relocation(chunk)
	
	pass

func queue_chunk_for_relocation(chunk):
	# Signal the worker thread to relocate the chunk
	emit_signal("chunk_relocate", chunk.chunk_key)

# Worker thread functions
func process_chunk_signals():
		# Handle signals for clearing and relocating chunks
		await get_tree().create_idle_signal().timeout
		for _signal in self.get_signal_connection_list("chunk_relocate"):
			var chunk_key = _signal.arguments[0]
			clear_and_relocate_chunk(chunk_key)

func clear_and_relocate_chunk(chunk_key):
	# Clear chunk data, calculate new location, and reinitialize
	chunk_mutex.lock()
	var chunk = active_chunks[chunk_key]
	chunk.deactivate()
	active_chunks.erase(chunk_key)
	chunk_pool.append(chunk)

	# Calculate new chunk key based on relocation strategy
	var player_chunk_key = position_to_chunk_key(player.position)
	var new_chunk_key = Vector2(
		chunk_key.x + sign(player_chunk_key.x - chunk_key.x) * ACTIVE_CHUNK_RANGE,
		chunk_key.y + sign(player_chunk_key.y - chunk_key.y) * ACTIVE_CHUNK_RANGE
	)

	# Reactivate chunk in new location
	chunk = chunk_pool.pop_front()
	chunk.chunk_key = new_chunk_key
	chunk.load_data()  # Load data for the new chunk region
	chunk.position = new_chunk_key * CHUNK_SIZE * tile_size
	add_child(chunk)
	active_chunks[new_chunk_key] = chunk
	chunk_mutex.unlock()

#func clear_and_relocate_chunk(chunk_key, new_chunk_key):
	# Clear chunk data, calculate new location, and reinitialize
	# ... (implementation for clearing, relocating, and reinitializing)
	#var chunk = active_chunks[chunk_key]
	#active_chunks.erase(chunk_key)
	#chunk.deactivate()
	#chunk = Chunk.new(new_chunk_key)
	#chunk.blocks = BlockManager.blocks[new_chunk_key]
	#chunk.activate()
	#pass
