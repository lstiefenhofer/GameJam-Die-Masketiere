extends Node2D
class_name OverlapCheck

var radius : float = 50.0
var maximum_intersections : int = 6

signal on_colliders_collected(intersections : Array[Dictionary])

static func create_physics_overlap(in_context : Node, in_position : Vector2, in_radius : float, in_maximum_intersections : int = 6) -> OverlapCheck:
	#var new_overlap_check = OverlapCheck.new(in_radius, in_maximum_intersections)
	var new_overlap_check = OverlapCheck.new()
	new_overlap_check.radius = in_radius
	new_overlap_check.maximum_intersections = in_maximum_intersections
	new_overlap_check.global_position = in_position
	in_context.add_child(new_overlap_check)
	return new_overlap_check
	

#func _setup(in_radius : float, in_maximum_intersections : int = 6) -> void:
#	radius = in_radius
#	maximum_intersections = in_maximum_intersections
	

func _physics_process(delta: float) -> void:
	var circle_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(circle_rid, radius)
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape_rid = circle_rid
	params.transform = global_transform
	params.collision_mask = 0b0110 # Players and enemies

	var space_state = get_world_2d().direct_space_state
	var intersections : Array[Dictionary] = space_state.intersect_shape(params, maximum_intersections)
	on_colliders_collected.emit(intersections)
	PhysicsServer2D.free_rid(circle_rid)
		
	queue_free()
	
