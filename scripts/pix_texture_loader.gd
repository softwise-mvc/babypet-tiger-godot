class_name PixTextureLoader
extends RefCounted

static func load_png(path: String) -> Texture2D:
	var image: Image = Image.new()
	var err: int = image.load(path)
	if err != OK:
		push_warning("Failed to load PNG: %s, error=%d" % [path, err])
		return null
	return ImageTexture.create_from_image(image)
