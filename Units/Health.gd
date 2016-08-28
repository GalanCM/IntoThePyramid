
extends Node2D

func resize( size ):
	get_node("Bar").set_region_rect( Rect2( Vector2(0,0), Vector2(size, 4) ) )

func update( percent ):
	var tween = Tween.new()
	tween.interpolate_method( self, "resize", get_node("Bar").get_region_rect().size.x, 32*percent, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	add_child(tween)
	tween.start()

	yield( tween, 'tween_complete' )
	tween.queue_free()
