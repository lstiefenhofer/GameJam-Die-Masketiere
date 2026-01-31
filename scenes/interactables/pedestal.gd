@tool
extends Interactable

@onready var pedestal_item: Sprite2D = $PedestalItem
@onready var text_dialog: PanelContainer = $TextDialog

@export var interaction_text: String = ""

@export_range(0, 4) var pedestal_item_frame: int = 0:
	set(value):
		pedestal_item_frame = value
		if pedestal_item:
			pedestal_item.frame = value + 37


func interact() -> void:
	super()
	if interaction_text != "":
		text_dialog.show_text(interaction_text)
		await text_dialog.dialog_closed
	pedestal_item.hide()
	
