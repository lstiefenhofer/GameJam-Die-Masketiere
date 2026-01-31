extends PanelContainer

signal dialog_closed()

@export var text_delay: float = 0.02
@onready var label: Label = $MarginContainer/Label

func show_text(text: String) -> void:
	show()
	label.text = text
	label.visible_characters = 0
	var total_characters = text.length()
	for i in total_characters + 1:
		label.visible_characters = i
		await get_tree().create_timer(text_delay).timeout
		if Input.is_action_just_pressed("Attack"):
			label.visible_characters = -1
			await get_tree().process_frame
			break
	
func _process(_delta: float) -> void:
	if label.visible_ratio >= 1:
		if Input.is_action_just_pressed("Attack"):
			hide()
			dialog_closed.emit()
