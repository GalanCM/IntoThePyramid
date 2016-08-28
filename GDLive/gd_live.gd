
extends Node

func set_child(node1, node2, name):
	if node1.has_node(name):
		var old = node1.get_node(name)
		node1.remove_child( old )
		old.queue_free()

	node2.set_name(name)
	node1.add_child(node2)