
extends Node2D

func set_length( length ):
	get_node("Beam").set_scale( Vector2( 1, length/8 ) )
	get_node("Beam").show()


