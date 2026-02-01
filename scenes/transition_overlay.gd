extends CanvasLayer

@export var color_rect: ColorRect

func fade_to_black(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(
		color_rect,
		"color",
		Color.BLACK,
		duration
	)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.finished

func fade_out(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(
		color_rect,
		"color",
	 Color(0,0,0,0),
		duration
	)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.finished
