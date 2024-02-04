extends Node2D

var last_chunk = Vector2(-9999,-9999)
var last_position = Vector2(-9999,-9999)
var tile_size = TextureControl.tile_size
var chunk_size = BlockManager.chunk_size
var blocks_ready = false
var chunk_radius = Vector2(4,3)
var active_blocks = []


func _process(delta):
	if get_global_mouse_position() != last_position:
		position = get_global_mouse_position()
		last_position = position
	if BlockManager.dict_ready == true:
			var chunk_key = Vector2(int(last_position.x / (chunk_size * tile_size)), int(last_position.y/(chunk_size * tile_size)))
			if chunk_key != last_chunk:
				#if last_chunk != Vector2(-9999,-9999):
				chunk_scan(chunk_key, chunk_radius)
					#if BlockManager.chunks.has(last_chunk):
						#BlockManager.chunks[last_chunk].deactivate()
				#last_chunk = chunk_key
				#if BlockManager.chunks.has(last_chunk):
						#BlockManager.chunks[last_chunk].activate()

func chunk_scan(chunk_key, radius):
	var _deactivate = []
	var _activate = []
	_activate = _get_chunk_radius(chunk_key, radius)
	if last_chunk != Vector2(-9999,-9999):
		#_deactivate = _get_chunk_radius(last_chunk, radius)
		for i in active_blocks:
			if !_activate.has(i):
				BlockManager.chunks[i].deactivate()
				active_blocks.erase(i)
	for i in _activate:
		if !active_blocks.has(i):
			active_blocks.append(i)
		if BlockManager.chunks[i].visible == false:
			BlockManager.chunks[i].activate()
	last_chunk = chunk_key

func _get_chunk_radius(chunk_key, radius):
	var results = []
	for x in range(chunk_key.x - radius.x, chunk_key.x + radius.x):
		for y in range(chunk_key.y - radius.y, chunk_key.y + radius.y):
			if BlockManager.chunks.has(Vector2(x,y)):
				results.append(Vector2(x,y))
	return results
