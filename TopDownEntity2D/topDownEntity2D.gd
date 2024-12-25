class_name TopDownEntity2D extends CharacterBody2D

## Base for entities in a top down 2D environment. Handles movement of the entity. Moves towards given direction with given speed.



# region constants
## Ignore impulses with vector length under the floor
const IMPULSE_FLOOR = .1
# endregion



# region @export variables
@export var direction: Vector2
@export var speed: float

## Smoothness of velocity change. A higher number means less smoothing.
@export var velocity_lerp_weight: float = 3
## If true will react to impulses through the impulse function.
@export var reacts_to_impulses: bool = true
# endregion



# region private variables
var _impulses : Array[Vector2] = []
# endregion



# region optional built-in virtual _init method
func _init():
	# Change motion mode from platformer to top down
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
# endregion



# region remaining built-in virtual methods
func _physics_process(delta_time):
	_apply_new_velocity(delta_time)
	move_and_slide()
# endregion



# region public methods
## Teleports the entity to the target position
func teleport(p_position: Vector2):
	position = p_position


## Adds an impulse to the entity
func add_impulse(impulse: Vector2):
	_impulses.append(impulse)
# endregion



# region private methods
func _apply_new_velocity(delta_time):
	var target_velocity = speed * direction.normalized()
	# The lerping needs to be framerate independent https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	velocity = velocity.lerp(target_velocity, 1 - exp(delta_time * -velocity_lerp_weight))

	# Add all impulses
	for impulse in _impulses:
		velocity += impulse
	_impulses = []

# endregion
