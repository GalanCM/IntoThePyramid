
extends Node2D


func _ready():
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		get_tree().change_scene_to( preload("res://Level1.tscn") )


