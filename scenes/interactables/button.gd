extends Interactable

signal button_pressed()

@export var pre_interaction_text: String = ""
@export var post_interaction_text: String = ""
@onready var button_off: Sprite2D = $ButtonOff
@onready var button_on: Sprite2D = $ButtonOn
@onready var text_dialog: PanelContainer = $TextDialog

func _ready() -> void:
	button_off.show()
	button_on.hide()

func interact() -> void:
	super()
	
	if pre_interaction_text != "":
		text_dialog.show_text(pre_interaction_text)
		await text_dialog.dialog_closed
	
	button_off.hide()
	button_on.show()
	button_pressed.emit()

	if post_interaction_text != "":
		text_dialog.show_text(post_interaction_text)
		await text_dialog.dialog_closed
