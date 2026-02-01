@tool
extends Interactable

@export var mask: int = 0
@export var interaction_text: String = ""
@export var mask_info : MaskInfo:
	set(value):
		mask_info = value
		update_mask_sprite()

@onready var text_dialog: PanelContainer = $TextDialog
@onready var mask_sprite: Sprite2D = $MaskSprite


func update_mask_sprite():
	if !mask_sprite:
		return
	if mask_info:
		mask_sprite.texture = mask_info.sprite
	else:
		mask_sprite.texture = load("res://art/sprites/mask_placeholder.png")

func _ready() -> void:
	update_mask_sprite()
	

func interact() -> void:
	if Engine.is_editor_hint(): # Tool script abort
		return
	
	super()
	if interaction_text != "":
		text_dialog.show_text(interaction_text)
		await text_dialog.dialog_closed
	Globals.mask_collected.emit(mask, mask_info)
	queue_free()
