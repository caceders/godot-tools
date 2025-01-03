class_name HitBox extends CollisionShape2D

@export var use_sprite_as_hitbox: bool = true
@onready var sprite : Sprite2D = get_node("../Sprite2D")
@onready var rectangle_shape = RectangleShape2D.new()  # Assuming a rectangular hitbox

func _process(_delta):
	if use_sprite_as_hitbox:
		# Ensure the CollisionShape2D has a shape assigned
		shape = rectangle_shape

		# Get the sprite's size (scaled)
		var sprite_size = sprite.texture.get_size() * sprite.scale

		# Set the size of the RectangleShape2D to match the sprite
		rectangle_shape.extents = sprite_size / 2  # RectangleShape2D extents are half-size

		# Align the hitbox position (if necessary)
		position = Vector2(0, 0)  # Aligns the hitbox with the sprite's center
