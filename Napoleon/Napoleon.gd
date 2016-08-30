
extends KinematicBody2D

export var max_health = 100.0
onready var health = max_health

export var max_moves = 5
onready var current_moves = max_moves

export var strength = 40
export var can_melee = true
export var can_shoot = true

func _ready():
	var tilemap = get_node("/root/Level/TileMap")
	var current_location = tilemap.world_to_map( get_pos() )
	set_pos( tilemap.map_to_world( current_location ) + Vector2(8,16) )
	
func activate():
	GDLive.set_child( self, Move.new(), 'controls' )
	
func take_damage( damage ):
	get_node("/root/Level/SamplePlayer").play("slash")
	health -= damage
	print(health)
	get_node("Health").update( health / max_health )
	
	if health <= 0:
		get_node("/root/Level/SamplePlayer").play("blood")
		get_node("Particles2D").set_emitting(true)
		
		var timer = Timer.new()
		timer.set_wait_time(1)
		add_child(timer)
		timer.start()
		
		yield( timer, 'timeout' )
		queue_free()
	
func move( direction=Vector2(0,0) ):
	var tilemap = get_node("/root/Level/TileMap")
	
	var current_location = tilemap.world_to_map( get_pos() )
	var new_pos = tilemap.map_to_world( current_location + direction ) + Vector2(8,16)
	
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray( get_pos(), get_pos()+direction*33, [self] )
	if result.empty():
		current_moves -= 1
		get_node("/root/Level/Walk Grid").clear()
		
		var tween = Tween.new()
		tween.interpolate_method( self, "set_pos", get_pos() , new_pos, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT )
		add_child( tween )
		tween.start()
		
		get_node("AnimationPlayer").play("Walk")
		
		get_node('controls').queue_free()
		yield( tween, "tween_complete" )
		tween.queue_free()
		if current_moves > 0:
			GDLive.set_child( self, Move.new(), 'controls' )
		else:
			get_node("/root/Level").next()
			
	elif can_melee:
		if not result.empty() and result.collider.is_in_group("Enemies"):
			var slash = preload("res://Units/Slash.tscn").instance()
			slash.set_pos( direction*33 )
			if direction == Vector2(1,0):
				slash.set_rot( 0.5*PI )
			elif direction == Vector2(-1,0):
				slash.set_rot( 1.5*PI )
			elif direction == Vector2(0,1):
				slash.set_rot( 2*PI )
			elif direction == Vector2(0,-1):
				slash.set_rot( PI )
				
			slash.damage = strength
			
			add_child(slash)
			
			get_node("/root/Level/Walk Grid").clear()
			get_node('controls').queue_free()
		
func generate_grid():
	var tilemap = get_node("/root/Level/TileMap")
	var current_pos = tilemap.world_to_map( get_pos() )
	var valid_moves = []
	var valid_attacks = []
	
	var cells = get_new_cells(current_pos, 0, current_pos, valid_moves)
	var moves = cells[0]
	
	var attacks = []
	for attack in cells[1]:
		attacks.push_back( attack[0] )
	
	while moves.size() > 0:
		var cell = moves[0]
		moves.pop_front()
		
		var dist = cell[1]
		if dist <= current_moves:
			cell = cell[0]
			
			if not cell in valid_moves:
				valid_moves.push_back(cell)
			
			var cells = get_new_cells(cell, dist, current_pos, valid_moves )
			moves += cells[0]
			
			for new_attack in cells[1]:
				if not new_attack[0] in attacks:
					attacks.push_back( new_attack[0] )
			
	
	
	var grid = get_node("/root/Level/Walk Grid")
	grid.valid_moves = valid_moves
	if can_melee:
		grid.attacks = attacks
	grid.make_grid()

func get_new_cells( cell, dist, current_pos, valid_moves ):
	var offset = Vector2(8,16)
	var tilemap = get_node("/root/Level/TileMap")
	
	var moves = []
	var attacks = []
	
	for next_cell in [ cell+Vector2(1,0), cell+Vector2(-1,0), cell+Vector2(0,1), cell+Vector2(0,-1) ]:
		if not next_cell in valid_moves:
			var start
			if cell == tilemap.world_to_map( get_pos() ):
				start = get_pos() - Vector2(0,1)
			else:
				start = tilemap.map_to_world(cell)+offset
			
			var space_state = get_world_2d().get_direct_space_state()
			var result = space_state.intersect_ray( start, tilemap.map_to_world(next_cell)+offset, [self] )
			
#			var ray_draw = preload( "res://Ray Draw.tscn").instance()
#			if not result.empty():
#				ray_draw.set( tilemap.map_to_world(cell)+offset, result.position )
#			get_node("/root/Level/Walk Grid").add_child(ray_draw)
			
			if next_cell != current_pos and ( result.empty() == true or result.collider == self ):
				moves.push_back( [next_cell,dist+1] )
			if not result.empty() and result.collider.is_in_group("Enemies"):
				attacks.push_back( [next_cell,dist+1] )
	return [moves, attacks]
	

class Move extends Node:
	onready var _ = get_parent()
	
	func _ready():
		_.generate_grid()
		set_process_input(true)
	
	func _input(event):
		
		if event.is_action_pressed('up') and not event.is_echo():
			_.move( Vector2(0,-1) )
		if event.is_action_pressed('down') and not event.is_echo():
			_.move( Vector2(0,1) )
		if event.is_action_pressed('left') and not event.is_echo():
			_.move( Vector2(-1,0) )
		if event.is_action_pressed('right') and not event.is_echo():
			_.move( Vector2(1,0) )

		if _.can_shoot and event.is_action_pressed('fire') and not event.is_echo():
			GDLive.set_child( _, _.Fire.new(), 'controls' )




class Fire extends Node:
	onready var _ = get_parent()
	
	var aim
	
	func _ready():
		get_node("/root/Level/Walk Grid").clear()
		aim = preload("res://Units/Aim.tscn").instance()
		aim.set_pos( Vector2(-1,0) )
		_.add_child( aim )
		set_fixed_process(true)
		
	func _fixed_process(delta):
		if Input.is_action_pressed('up'):
			aim.set_rot( 0.5 * PI )
			aim.aim()
		if Input.is_action_pressed('down'):
			aim.set_rot( 1.5 * PI )
			aim.aim()
		if Input.is_action_pressed('left'):
			aim.set_rot( PI )
			aim.aim()
		if Input.is_action_pressed('right'):
			aim.set_rot( 2 * PI )
			aim.aim()

		if not Input.is_action_pressed('fire'):
			if aim.complete:
				get_node("/root/Level/SamplePlayer").play("gunshot")
				var bullet = preload("res://Units/Bullet.tscn").instance()
				bullet.damage = _.strength
				bullet.set_transform( aim.get_transform() )
				_.add_child(bullet)
				
				aim.queue_free()
				set_fixed_process(false)
				
				yield( bullet, "exit_tree" )
				queue_free()


			else:
				aim.queue_free()
				queue_free()
				GDLive.set_child( _, _.Move.new(), 'controls' )