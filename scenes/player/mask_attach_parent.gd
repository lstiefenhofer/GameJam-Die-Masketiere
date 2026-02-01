extends Node2D

@export var anim_idle_offsets : Array[Vector2]
@export var anim_attack_offsets : Array[Vector2]
@export var anim_walk_offsets : Array[Vector2]
@export var anim_hit_offsets : Array[Vector2]

@export var animated_sprite : AnimatedSprite2D

var array_per_offset_list : Dictionary

var current_flip : bool = false


# Death animation is only shown in a different scene without the masks
func _ready() -> void:
	array_per_offset_list["Idle"] = anim_idle_offsets
	array_per_offset_list["Attack"] = anim_attack_offsets
	array_per_offset_list["Walk"] = anim_walk_offsets
	array_per_offset_list["Hit"] = anim_hit_offsets
	
	Globals.recalculate_mask_effects.connect(_on_recalculate_mask_effects)
	_on_recalculate_mask_effects()

func _process(delta: float) -> void:
	if current_flip == animated_sprite.flip_h:
		return
		
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = animated_sprite.flip_h
	current_flip = animated_sprite.flip_h

func _on_player_body_frame_changed() -> void:
	var current_offset_list = array_per_offset_list.get(animated_sprite.animation)
	var flip_multiplier = -1.0 if animated_sprite.flip_h else 1.0
	position = Vector2(current_offset_list[animated_sprite.frame].x * flip_multiplier, current_offset_list[animated_sprite.frame].y)


func _on_recalculate_mask_effects() -> void:
	var children = get_children()
	for child in children:
		child.queue_free()
	
	var highest_prio_per_side : Dictionary[PublicEnums.MaskType, MaskInfo]
	for mask in Globals.collected_masks:
		if !highest_prio_per_side.has(mask.side):
			highest_prio_per_side[mask.side] = mask
			continue
		
		if mask.group > highest_prio_per_side[mask.side].group:
			highest_prio_per_side[mask.side] = mask
	
	# TODO: Show full mask when we have all parts and there are now higher group parts
	for mask_key in highest_prio_per_side.keys():
		if highest_prio_per_side[mask_key].side == PublicEnums.MaskType.FULL: # ignore full masks for now
			continue
			
		var new_sprite = SpriteFlash.new()
		new_sprite.texture = highest_prio_per_side[mask_key].sprite
		new_sprite.offset = Vector2(0, -16)
		add_child(new_sprite)
	
	
	
	
	
	
