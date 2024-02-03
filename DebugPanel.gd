extends Panel

var side = false
var hovered = false
var slide_amount = 260

signal obscured

func _on_mouse_entered():
	hovered = true
	pass # Replace with function body.


func _on_mouse_exited():
	hovered = false
	pass # Replace with function body.


func _on_gui_input(event : InputEvent):
	if hovered and event.is_action_pressed('left_click'):
		if !side:
			create_tween().tween_property(self, 'position', position + Vector2(slide_amount, 0), 0.333)
			create_tween().tween_property($Arrow, 'rotation_degrees', 90  , 0.222)
			side = true
			emit_signal("obscured")
		else:
			create_tween().tween_property(self, 'position', position + Vector2(-slide_amount, 0), 0.333)
			create_tween().tween_property($Arrow, 'rotation_degrees', -90, 0.222)
			side = false
	pass # Replace with function body.
