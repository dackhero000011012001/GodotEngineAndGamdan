extends Node2D


func _on_h_slider_value_changed(value: float) -> void:
	$TextureProgressBar.value = value
