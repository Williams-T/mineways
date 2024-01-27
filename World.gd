extends Node2D

@export var noise = NoiseTexture2D.new()

var cam : Camera2D

func _ready():
	cam = $Camera2D
	pass

func _input(event):
	var cam_rect := cam.get_viewport_rect()
	if event.is_action('cam_down'):
		print(cam_rect)
		cam.global_translate(Vector2(0, (cam_rect.size.y / cam.zoom.y) / 8.0))
		pass
	if event.is_action('cam_up'):
		cam.global_translate(Vector2(0, (-cam_rect.size.y / cam.zoom.y) / 8.0))
		pass
	if event.is_action('cam_left'):
		cam.global_translate(Vector2((-cam_rect.size.x / cam.zoom.x) / 8.0, 0))
		pass
	if event.is_action('cam_right'):
		cam.global_translate(Vector2((cam_rect.size.x / cam.zoom.x) / 8.0, 0))
		pass
	if event.is_action('cam_zoom_in'):
		cam.zoom *= 2.0
		pass
	if event.is_action('cam_zoom_out'):
		cam.zoom /= 2.0
		pass
