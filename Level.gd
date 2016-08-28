
extends Node



var uniques = {}

var troop_order = [ 'Napoleon', 'Grognard', 'Officer' ]
var enemy_order = [ 'Turret' ]
var turn = 'enemy'
var index = 0

func _ready():
	next()
	
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
