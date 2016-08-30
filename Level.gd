
extends Node



var uniques = {}

var troop_order = [ 'Napoleon', 'Grognard', 'Officer' ]
var enemy_order = [ 'Turret', 'Turret1', 'Turret2', 'Turret3', 'Turret4' ]
var turn = 'enemy'
var index = 0

func _ready():
	set_process_input(true)
	next()
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_tree().quit()
	
func next():
	var unit_list
	if turn == 'player':
		unit_list = troop_order
	elif turn == 'enemy':
		unit_list = enemy_order
	
	if index >= unit_list.size():
		if turn == 'player':
			turn = 'enemy'
		elif turn == 'enemy':
			turn = 'player'
		index = 0
		next()
		return
		
	var troop = unit_list[index]
	index += 1
	for unit in get_tree().get_nodes_in_group("Armee") + get_tree().get_nodes_in_group("Enemies"):
		if unit.get_name() == troop:
			troop = unit
			break
			
	if typeof( troop ) != TYPE_STRING:
		troop.activate()
	else:
		next()
