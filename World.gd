extends Node2D

@export var noise = NoiseTexture2D.new()

var cam : Camera2D
var label : Label

var last_chunk_pos = Vector2()
var last_chunks = []
var chunk_queue = 6

func _ready():
	cam = $Camera2D
	label = $CanvasLayer/DebugPanel/Label
	await BlockManager.done == true
	var cam_factor = 127.4 / float(BlockManager.world_size.x)
	print(cam_factor)
	cam.zoom = Vector2(cam_factor, cam_factor)
	BlockManager.finished.connect(populate_label.bind(BlockManager.data))
	#populate_label(BlockManager.data)
	
	#await take_screenshot()
	#reset_level()

func reset_level():
	BlockManager.set_process(false)
	BlockManager.set_script(null)
	var children = BlockManager.get_children()
	var process_string = ""
	var percentage = int(children.size() / 30)
	var counter = 0
	for i in children:
		var kids = i.get_children()
		for k in kids:
			k.queue_free()
			
		i.queue_free()
		await BlockManager.child_exiting_tree
		if counter % percentage == 0:
			process_string += "."
			print(process_string, "\t\t\t\t\t\t\t\t\t\t", str(counter))
		counter += 1
	BlockManager.set_script(preload("res://BlockManager.gd"))
	BlockManager._ready()
	BlockManager.set_process(true)
	get_tree().reload_current_scene()

func delete_chunk(index, chunk, kids, kids_count):
	#var kids = BlockManager.get_child(index).get_children()
	for k in kids:
		k.queue_free()
		#k.queue_free()
	chunk.queue_free()
	await BlockManager.child_exiting_tree
	

func populate_label(data):
	var label_text = "\nWorld Size: %s, %s\nm: %s   b: %s\nnoise seed: %s\noctaves: %s\ninit divisor: %s, gap: %s " % [data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]]
	label_text += "\n\n\n\tdivisor steps: \n"
	var c = 0
	for i in data[8]:
		if c > 0 and c % 2 == 0:
			label_text += "\n\t"
		label_text += " [ %s, %s, %s ]" % [str(snapped(i[0], 0.01)), str(snapped(i[1], 0.01)), str(snapped(i[2], 0.01))]
		c += 1
	label_text += "\n\n\n\tgap steps: \n"
	c = 0
	for i in data[9]:
		if c > 0 and c % 2 == 0:
			label_text += "\n\t"
		label_text += " [ %s , %s ]" % [str(snapped(i[0], 0.01)), str(snapped(i[1], 0.01))]
		c += 1
	label_text += "\n\n\n\tnoise multipliers: \n"
	c = 0
	for i in data[10]:
		if c > 0 and c % 2 == 0:
			label_text += "\n\t"
		label_text += "[ %s ]" % str(snapped(i, 0.01))
		c += 1
	label_text += "\n\n\n\tlimits: \n\t"
	c = 0
	for i in data[11]:
		if c > 0 and c % 2 == 0:
			label_text += "\n"
		label_text += "[ %s , %s ] " % [str(snapped(i[0], 0.01)), str(snapped(i[1], 0.01))]
		c += 1
	label.text = label_text

func take_screenshot():
	#await get_tree().create_timer(1.0).timeout
	var capture = get_window().get_viewport().get_texture().get_image()
	
	#var _time = Time.get_datetime_string_from_system()
	#for i in _time.length() -1:
		#if _time[i] == ":" or _time[i] == "-":
			#_time[i] = "_"
		#elif _time[i] == "T":
			#_time[i] = "__"
	
	var _data = BlockManager.data
	var data_string = ""
	for i in _data.size()-4:
		var str
		if typeof(_data[i]) != TYPE_ARRAY:
			if typeof(_data[i]) == TYPE_FLOAT or typeof(_data[i]) == TYPE_VECTOR2: 
				str = str(snapped(_data[i], 0.01))
			else:
				str = str(_data[i])
		else:
			for ii in _data[i].size()-1:
				if typeof(_data[i][ii]) == TYPE_FLOAT or typeof(_data[i][ii]) == TYPE_VECTOR2: 
					str = str(snapped(_data[i][ii], 0.01))
				else:
					str = str(_data[i][ii])
		for ii in str.length() -1:
			if str[ii] == "-" or str[ii] == "[" or str[ii] == "]" or str[ii] == "(" or str[ii] == ")":
				str[ii] = "_"
			elif  str[ii] == ":" or str[ii] == "." or str[ii] == ",":
				str[ii] = "-"
		data_string += str
	for i in data_string.length()-2:
		if data_string[i] == ' ':
			data_string = data_string.erase(i)
	var filename = "user://world_settings/{0}.png".format({"0":data_string})
	#await BlockManager.finished
	print(data_string)
	#await get_tree().create_timer(10.0).timeout
	for tick in 10:
		await get_tree().process_frame
	#await draw
	print("saving %s" % filename)
	capture.save_png(filename)

func _input(event):
	var cam_rect := cam.get_viewport_rect()
	if event.is_action_pressed('cam_down'):
		print(cam_rect)
		cam.global_translate(Vector2(0, (cam_rect.size.y / cam.zoom.y) / 8.0))
		pass
	if event.is_action_pressed('cam_up'):
		cam.global_translate(Vector2(0, (-cam_rect.size.y / cam.zoom.y) / 8.0))
		pass
	if event.is_action_pressed('cam_left'):
		cam.global_translate(Vector2((-cam_rect.size.x / cam.zoom.x) / 8.0, 0))
		pass
	if event.is_action_pressed('cam_right'):
		cam.global_translate(Vector2((cam_rect.size.x / cam.zoom.x) / 8.0, 0))
		pass
	if event.is_action_pressed('cam_zoom_in'):
		cam.zoom *= 2.0
		pass
	if event.is_action_pressed('cam_zoom_out'):
		cam.zoom /= 2.0
		pass
	if event.is_action_released('take_screenshot'):
		take_screenshot()
		pass
	if event.is_action_released('reset_level'):
		reset_level()
		pass
	if event.is_action_released('increment'):
		BlockManager.increment_process()
	
	if event.is_action_released('increment_layer'):
		BlockManager.emit_signal('layer')
		#if BlockManager.next_step == BlockManager.steps.size():
			#populate_label(BlockManager.data)
		pass

#func _process(delta):
	#var chunk_mouse = get_global_mouse_position()
	#if chunk_mouse != last_chunk_pos:
		#if BlockManager.chunks.has(Vector2(int(chunk_mouse.x / BlockManager.chunk_size), int(chunk_mouse.y / BlockManager.chunk_size))):
			#var chunk = BlockManager.chunks[Vector2(int(chunk_mouse.x) / BlockManager.chunk_size, int(chunk_mouse.y) / BlockManager.chunk_size)]
			#last_chunks.append(chunk)
			#if chunk.visible != true:
				#chunk.activate()
		#if last_chunks.size() > chunk_queue:
			#var del = last_chunks[0]
			#del.deactivate()
			#last_chunks.remove_at(0)
	#last_chunk_pos == chunk_mouse
	#if last_chunks.size() > 0:
		#for i in last_chunks:
			#if i.visible != true:
				#i.activate()




func _on_debug_panel_obscured():
	populate_label(BlockManager.data)
	pass # Replace with function body.
