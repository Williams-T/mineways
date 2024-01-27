extends Node2D
var tile_size = TextureControl.tile_size
var type = 0

var ground_level = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_stack(x, y):
	for i in x:
		if i > 3:
			for ii in y:
				if ii > ground_level:
					randomize()
					var _type = 0
					if ii > 15:
						_type = 0
					if ii > 18:
						_type = 1
					if ii > 21:
						_type = 2
					if ii > 25:
						_type = 3
					if ii > 29:
						_type = 4
					if ii > 31:
						_type = 5
					if ii > 37:
						_type = 6
					if ii > 44:
						_type = 7
					if ii > 51:
						_type = 8
					if ii > 60:
						_type = 9
					var timer = (randf() * 10.0) + 3.0
					var block = Block.new(
						self,
						Vector2(i, ii),
						#randi() % 10,
						_type,
						timer,
						true
					)
					#block.position = Vector2(i * tile_size, ii * tile_size)
					add_child(block)

func _input(event):
	if event.is_action_pressed('left_click'):
		var pos = get_global_mouse_position()
		var block = Block.new(self, Vector2(0,0), type, randi() % 9 + 1, true)
		block.position = pos
		add_child(block)
	if event.is_action_pressed('right_click'):
		spawn_stack(120, 70)
	if event.is_action_released('1'):
		type = 1
		pass
	if event.is_action_released('2'):
		type = 2
		pass
	if event.is_action_released('3'):
		type = 3
		pass
	if event.is_action_released('4'):
		type = 4
		pass
	if event.is_action_released('5'):
		type = 5
		pass
	if event.is_action_released('6'):
		type = 6
		pass
	if event.is_action_released('7'):
		type = 7
		pass
	if event.is_action_released('8'):
		type = 8
		pass
	if event.is_action_released('9'):
		type = 9
		pass
	if event.is_action_released('0'):
		type = 0
		pass

