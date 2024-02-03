#extends Node
#class_name Chunk
#
#var id 
#var chunk_size
#var tile_size
#var blocks = []
#
#func _init(_id, _ch, _ti):
	#id = _id
	#chunk_size = _ch
	#tile_size = _ti
	#
	#pass
#
#func get_position():
	#return Vector2(id.x * (chunk_size * tile_size), id.y * (chunk_size * tile_size) )

extends Node2D
class_name Chunk

var tile_size = TextureControl.tile_size
var chunk_id
var chunk_size = Vector2(16, 16)  # Size of the chunk in terms of blocks
var blocks = {}  # Dictionary to store blocks, keyed by their local position within the chunk

var debug_mode = false

# Initialization: position in the grid of chunks
func _init(chunk_position: Vector2):
	#position = chunk_position * chunk_size * tile_size
	chunk_id = chunk_position
	name = "Chunk_" + str(chunk_position)
	if debug_mode:
		modulate = Color(randf_range(0.2, 1.0), randf_range(0.2, 1.0), randf_range(0.2, 1.0), randf_range(0.88, 1.0))
	

# Method to add a block to this chunk
func add_block(block: Block, local_position: Vector2):
	var relative_position = local_position - chunk_id
	blocks[relative_position] = block
	#block.position = local_position * Block.get_block_size()
	add_child(block)

# Activate the chunk (called when the chunk is within active radius of the player)
func activate():
	visible = true
	for block in blocks.values():
		self.add_child.call_deferred(block)
	# You can add more logic here if needed, such as enabling physics processing

# Deactivate the chunk (called when the chunk is outside the active radius of the player)
func deactivate():
	visible = false
	# Additional deactivation logic can be added here
	for child in get_children():
		self.remove_child.call_deferred(child)
# Optionally, if you need to process each block in the chunk
func _process(delta: float) -> void:
	if not visible:
		return
	# Process logic for active blocks

func save_chunk(mode := 0):
	var chunk_data = {
		"chunk_id" = chunk_id,
		"blocks" = []
	}
	for block in blocks.values():
		chunk_data["blocks"].append(
			{
				"position" = block.position,
				"type" = block.type,
				"health" = block.health
			}
		)
	if mode == 0:
		var save_file = FileAccess.open("user://chunks/" + str(chunk_id) + ".chunk", FileAccess.WRITE)
		var json_string = JSON.stringify(chunk_data)
		save_file.store_line(json_string)
		return 0
	if mode == 1:
		return chunk_data
	
	


func load_chunk():
	pass

func get_blocks():
	return blocks

# Clean-up if needed, like when unloading the chunk
func clear():
	for block in blocks.values():
		block.queue_free()  # Free each block
	blocks.clear()
