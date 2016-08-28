
extends Node

var uniques = {}

var troop_order = [ 'Napoleon', 'Grognard', 'Officer' ]
var index = 0

func _ready():
	next()
	
func next():
	if index > troop_order.size():
		return
		
	var troop = troop_order[index]
	index += 1
	for unit in get_tree().get_nodes_in_group("Armee"):
		if unit.get_name() == troop:
			troop = unit
			break
			
	if typeof( troop ) != TYPE_STRING:
		troop.activate()
	else:
		next()
