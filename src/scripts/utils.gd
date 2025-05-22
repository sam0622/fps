## Provides several general utility methods.
## More general than the utilities GameManager provides, as those are
## specifically for use in management of the game
class_name Utils
extends Node


## Returns [code]parent[/code]'s first child of [code]type[/code]
static func get_node_of_type(parent: Node, type: String) -> Node:
	for node in parent.get_children():
		if node.get_class() == type:
			return node
	return null


## Remove all of [code]parent[/code]'s children of [code]type[/code]
static func purge_nodes_of_type(parent: Node, type: String) -> void:
	for node in parent.get_children():
		if node.get_class() == type:
			node.queue_free()
