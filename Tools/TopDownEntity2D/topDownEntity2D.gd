class_name TopDownEntity2D extends Node

## Base for entities in a top down 2D environment. Handles movement of the body. Moves towards given direction with given speed.


# region constants
## Ignore impulses with vector length under the floor
const IMPULSE_FLOOR = .1
const VELOCITY_FLOOR = .3
# endregion


# region @export variables
@export var body: CharacterBody2D 
@export var direction: Vector2
@export var speed: float = 50
@export var impulse_size: float = 10
@export var is_static: bool = false


## Smoothness of velocity change. A higher number means less smoothing.
@export var velocity_lerp_weight: float = 15
## If true will react to impulses through the impulse function.
@export var reacts_to_impulses: bool = true
# endregion


# region public variabes
## Returns true if body has velocity above VELOCITY_FLOOR
var is_moving: bool:
	set(value):
		pass
	get:
		return (body.velocity.length() > VELOCITY_FLOOR)
# endregion


# region private variables
var _impulses: Array[Vector2] = []
# endregion


# region optional built-in virtual _init method
func _ready():
	# Change motion mode from platformer to top down
	body.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
# endregion


# region remaining built-in virtual methods
func _physics_process(delta_time):
	_apply_new_velocity(delta_time)
	if not is_static:
		body.move_and_slide()
# endregion


# region public methods
## Teleports the body to the target position
func teleport(p_position: Vector2):
	body.global_position = body.p_position


## Adds an impulse to the body
func add_impulse(impulse: Vector2):
	_impulses.append(impulse)
# endregion


# region private methods
func _apply_new_velocity(delta_time):
	if not is_static:
		var target_velocity = speed * direction.normalized()
		# The lerping needs to be framerate independent https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
		body.velocity = body.velocity.lerp(target_velocity, 1 - exp(delta_time * -velocity_lerp_weight))

		# Add all impulses
		if reacts_to_impulses:
			for impulse in _impulses:
				body.velocity += (impulse * impulse_size)
			_impulses = []

# endregion
