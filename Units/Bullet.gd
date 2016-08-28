
extends KinematicBody2D


func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	move( get_transform().basis_xform( Vector2(400, 0) ) * delta )