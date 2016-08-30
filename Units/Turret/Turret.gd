
extends StaticBody2D

var max_health = 200
var health = max_health

func activate():
	var targets = []
	
	for direction in [ Vector2(0,480), Vector2(848,0), Vector2(-848,0) ]:
		var pos = get_global_pos()
		var space_state = get_world_2d().get_direct_space_state()
		var result = space_state.intersect_ray( pos, pos+direction, [self] )
		
#		var ray_draw = preload( "res://Ray Draw.tscn").instance()
#		if not result.empty():
#			ray_draw.set( pos, pos+direction )
#		get_node("/root/Level").add_child(ray_draw)
		
		if not result.empty() and result.collider.is_in_group('Armee'):
			targets.push_back( result.collider )
	
	var lazer
	if targets.size() > 0:
		var pick = int( rand_range(0,targets.size()) ) # not random enough!!
		pick = targets[pick]
		
		var ray = ( pick.get_global_pos() - get_global_pos() )
		var direction = ray.normalized()
		
		if direction != Vector2(0,-1):
			if direction == Vector2(-1,0):
				get_node("Top").play("turn left")
			elif direction == Vector2(1,0):
				get_node("Top").play("turn right")
			
			var timer = Timer.new()
			timer.set_wait_time(0.7)
			add_child(timer)
			timer.start()
			
			yield( timer, 'timeout' )
			get_node("Top").stop()
			timer.queue_free()
		
		lazer = preload( "res://Units/Turret/Lazer.tscn" ).instance()
		if direction == Vector2(-1,0):
			lazer.set_rot( 1.5*PI )
			lazer.set_pos( Vector2(-6,-3) )
		elif direction == Vector2(1,0):
			lazer.set_rot( 0.5*PI )
			lazer.set_pos( Vector2(6,-3) )
		add_child(lazer)
		
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_method( lazer.get_node("Flare"), 'set_opacity', 0, 1, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT )
		tween.start()
		
		yield( tween, 'tween_complete' )
		
		get_node("/root/Level/SamplePlayer").play("lazer")
		tween.interpolate_method( lazer, 'set_length', 0, ray.length(), ray.length()/1000, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
		tween.start()
		
		yield( tween, 'tween_complete' )
		tween.queue_free()
		
		pick.take_damage(40)
		
	var timer = Timer.new()
	timer.set_wait_time(0.2)
	add_child(timer)
	timer.start()
	
	yield( timer, 'timeout' )
	timer.queue_free()
	if lazer:
		lazer.queue_free()
		
	get_node("/root/Level").next()
	
	
func take_damage( damage ):
	get_node("/root/Level/SamplePlayer").play("slash")
	health -= damage
	
	if health <= 0:
		get_node("/root/Level/SamplePlayer").play("crash")
		get_node("Particles2D").set_emitting(true)
		
		var timer = Timer.new()
		timer.set_wait_time(1)
		add_child(timer)
		timer.start()
		
		yield( timer, 'timeout' )
		queue_free()