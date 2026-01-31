extends Interactable

@export var mask: int = 0

func interact() -> void:
	super()
	queue_free()
	Globals.mask_collected.emit(mask)
