
extends Node2D

var complete = false

func aim():
	var anim_player = get_node("AnimationPlayer")
	
	if not complete and ( not anim_player.is_playing() or anim_player.get_current_animation() != "Aim"):
		anim_player.play("Aim")
