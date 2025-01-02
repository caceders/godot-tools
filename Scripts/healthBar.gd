extends TextureProgressBar


@export var health: ResourcePool
func _process(delta):
	max_value = health.max_amount

	if health.amount == health.max_amount or health.amount == 0:
		visible = false
	else:
		visible = true
	
	if health.amount < value:
		value -= 100 * delta
	elif health.amount > value:
		value += 100 * delta
