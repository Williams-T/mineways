extends Node2D
class_name Block

var parent_chunk
var local_index = Vector2i(0,0)
var true_index = Vector2i(0,0)
var _offset = Vector2.ZERO
var type = 0
var mode = 0
var active = false
var timer
var count = 0.0

var width = TextureControl.tile_size
var height = width
var _texture : Texture2D
var texture_size = Vector2.ZERO
var texture_origin = Vector2.ZERO

var integrity = 3
var armor = 0

var square_points = [
	Vector2(-4.5,4.5),
	Vector2(-4.5, 0),
	Vector2(-4.5, -4.5),
	Vector2(4.5, -4.5),
	Vector2(4.5, 0),
	Vector2(4.5, 4.5),
]
var polygon_increment = 3

func _init( loc_id, _type, _timer, _active = false):
	local_index = loc_id
	#local_index = ()
	position = Vector2(loc_id.x * width, loc_id.y * width)
	if _active != false:
		active = _active
	set_type(_type)
	remap_texture()
	timer = _timer
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS

func take_damage(actor, damage):
	var final_damage = damage - armor
	if integrity - final_damage <= 0:
		collapse()

func collapse(type = 11):
	if type == 11:
		# collapse logic here
		pass
	pass

func set_type(_type):
	type = _type
	_texture = TextureControl.get_texture(type)

func remap_texture(new_texture = _texture):
	randomize()
	if new_texture != _texture or texture_size == Vector2.ZERO:
		_texture = new_texture as Texture2D
		texture_size = _texture.get_size()
	texture_origin = Vector2(randi() % int(texture_size.x - width), randi() % int(texture_size.y - height))
	queue_redraw()

func _draw():
	draw_texture_rect_region(
		_texture, 
		Rect2(Vector2(0,0), Vector2(width, width)), 
		Rect2(texture_origin, Vector2(width, width)))

func _process(delta):
	if active:
		count += delta
		if count >= timer:
			count = 0.0
			remap_texture()

