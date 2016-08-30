
extends KinematicBody2D

var damage

func _ready():
	add_collision_exception_with( get_parent() )
	set_fixed_process(true)
	
func _fixed_process(delta):
	move( get_transform().basis_xform( Vector2(400, 0) ) * delta )
	
	if is_colliding():
		var collider = get_collider()
		
		if is_visible() and collider.is_in_group('Enemies'):
			var tilemap = get_node("/root/Level/TileMap")
			var strike = preload("res://Units/Strike.tscn").instance()
			strike.damage = damage
			
			collider.add_child( strike )
			set_fixed_process(false)
			hide()
			
			yield( strike, "exit_tree" )
			queue_free()
		else:
			get_node("/root/Level").next()
			queue_free()