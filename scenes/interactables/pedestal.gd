@tool
extends Interactable

@onready var pedestal: Sprite2D = $Pedestal
@onready var pedestal_item: Sprite2D = $PedestalItem
@onready var text_dialog: PanelContainer = $TextDialog

@export var interaction_text: String = ""
@export var pedestal_item_frame: int = 0:
	set(value):
		if value < 0:
			value = 0
		pedestal_item_frame = value
		_update_sprite()

@export_subgroup("Do not change outside the pedestal scene")
@export var base_frame: int = 37
@export var hide_item: bool = true
## Instead of switching the item frame, switch the pedestal sprite to frame 0.
@export var switch_pedestal_sprite: bool = false

func _ready() -> void:
	_update_sprite()
	
func _update_sprite() -> void:
	if switch_pedestal_sprite:
		if pedestal:
			if pedestal_item_frame + base_frame >= pedestal.hframes * pedestal.vframes:
				pedestal_item_frame = pedestal.hframes * pedestal.vframes - base_frame - 1
			pedestal.frame = pedestal_item_frame + base_frame
	else:
		if pedestal_item:
			if pedestal_item_frame + base_frame >= pedestal_item.hframes * pedestal_item.vframes:
				pedestal_item_frame = pedestal_item.hframes * pedestal_item.vframes - base_frame - 1

			pedestal_item.frame = pedestal_item_frame + base_frame

func interact() -> void:
	hide_interaction_hint()
	if interaction_text != "":
		text_dialog.show_text(interaction_text)
		await text_dialog.dialog_closed
	
	super()
	if hide_item:
		pedestal_item.hide()
	if switch_pedestal_sprite:
		pedestal_item_frame = 0
