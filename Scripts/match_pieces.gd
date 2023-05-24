extends Node2D

@export var type: String
var matched = false
	


func _on_area_2d_mouse_entered():
	set_scale(Vector2(1.1, 1.1)) 
	pass # Replace with function body.


func _on_area_2d_mouse_exited():
	set_scale(Vector2(1, 1))
	pass # Replace with function body.

func drag(target):
	var move_tween = create_tween()
	move_tween.tween_property(self, "position", target, 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
#	move_tween.tween_property(self, "position", target.position, 0.3)

func dim():
	var sprite = get_node("Area2D/Sprite2D")
	sprite.modulate = Color(1, 1, 1, 0.5)
	
	
