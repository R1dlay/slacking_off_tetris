extends Node

@export var loss_path : String

func load_scene():
	assert(ResourceLoader.exists(loss_path))
	get_tree().change_scene_to_file(loss_path)
