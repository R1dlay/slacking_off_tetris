extends Control

@export var menu_path : String

func load_main_menu():
	assert(ResourceLoader.exists(menu_path))
	get_tree().change_scene_to_file(menu_path)
