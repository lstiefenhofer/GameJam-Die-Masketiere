@tool
extends Interactable

@onready var pedestal_item: Sprite2D = $PedestalItem

@export_range(33, 37) var pedestal_item_frame: int = 33:
	set(value):
		pedestal_item_frame = value
		if pedestal_item:
			pedestal_item.frame = value


func interact() -> void:
	super()
	pedestal_item.hide()
	
