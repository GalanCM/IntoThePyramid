
extends Node2D

var damage

func _ready():
	yield( get_node("AnimationPlayer"), 'finished' )
	
	get_node("/root/Level").next()
	queue_free()


