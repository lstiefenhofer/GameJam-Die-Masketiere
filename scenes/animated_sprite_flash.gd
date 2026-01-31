extends AnimatedSprite2D

class_name AnimatedSpriteFlash

func flash(fade_in_duration: float, fade_out_duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(_set_flash, 0.0, 1.0, fade_in_duration)
	tween.tween_method(_set_flash, 1.0, 0.0, fade_out_duration)

	
func _set_flash(value: float) -> void:
	material.set("shader_parameter/flash", value)
