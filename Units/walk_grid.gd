
extends Node2D

var valid_moves = []
var attacks = []

func _ready():
	make_grid()

	
func make_grid():
	for move in valid_moves:
		var square = preload("res://Units/GridSquare.tscn").instance()
		square.set_pos( get_node("/root/Level/TileMap").map_to_world( move ) )
		add_child( square )
		
	print(attacks)
	for attack in attacks:
		var square = preload("res://Units/GridSquare-Enemy.tscn").instance()
		square.set_pos( get_node("/root/Level/TileMap").map_to_world( attack ) )
		add_child( square )
		
	var tween = Tween.new()
	tween.interpolate_method( self, "set_opacity", 0, 1, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	
	yield( tween, 'tween_complete' )
	tween.queue_free()
		
	
func clear():
	var tween = Tween.new()
	tween.interpolate_method( self, "set_opacity", 1, 0, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	
	yield( tween, 'tween_complete' )
	tween.queue_free()
	
	for child in get_children():
		child.queue_free()