extends  MarginContainer

# === Signals === (snake_case)

# === Enums === (PascalCase, members CONSTANT_CASE)

# === Constants === (CONSTANT_CASE)

# === Exported Vars === (snake_case)

# === Public Vars === (snake_case)

# === Private Vars === (_underscored_snake_case)

# === Godot Methods ===

func  _ready() -> void:
	update_vp_size(Vector2i(1920, 1080))
	
	pass

func  _physics_process(delta: float) -> void:
	pass

# === Further Methods === (public snake_case, private _underscored_snake_case, local vars snake_case)

func load_scene(scene_path: String, scene_size: Vector2i) :
	assert(ResourceLoader.exists(scene_path))
	update_vp_size(scene_size)
	get_tree().change_scene_to_file(scene_path)

# update the size to the given new size. Rescale the window to fit as well
func update_vp_size(new_size: Vector2i) :
	# grab sizes
	var old_content_size = get_window().content_scale_size
	

	
	# calc scale factor (un-normalized)
	var scale_factor = (new_size as Vector2) / (old_content_size as Vector2)
	# normalize it, then scale it so y dimension is 1. This keeps y scale at 1
	scale_factor = scale_factor.normalized()
	scale_factor = scale_factor / scale_factor.y
	
	print(scale_factor)
	
	# set the content size
	get_window().content_scale_size = new_size
	
	# set the window size, scaling so the Y is constant
	get_window().size = Vector2i((get_window().size as Vector2) * scale_factor)
	
	pass
