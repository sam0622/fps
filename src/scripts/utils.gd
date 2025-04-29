class_name NodeUtils
extends Node


static func get_node_of_type(parent: Node, type: String) -> Node:
	for node in parent.get_children():
		if node.get_class() == type:
			return node
	return null


static func purge_nodes_of_type(parent: Node, type: String) -> void:
	for node in parent.get_children():
		if node.get_class() == type:
			node.queue_free()
