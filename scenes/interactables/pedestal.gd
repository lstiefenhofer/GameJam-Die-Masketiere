extends Interactable


@onready var sprite_2d: Sprite2D = $Sprite2D

func interact() -> void:
	super()
	sprite_2d.frame = 35
	
