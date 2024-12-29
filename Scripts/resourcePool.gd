class_name ResourcePool extends Node
## A class implementing a resourcepool, - health, stamina, mana, oxygen etc.

## To use add the resourcepool Node to an object. Name the pool something
## relevant.
## The resourcepool can be added to and removed of by any amount through
## add_to and remove_from methods.
## It can be depleted and replenished by an amount per second through
## The start/stop replenish/depletion methods.
## It can have a timed extra growth or decay through the add_growth/add_decay
## methods
## It can have growth and decay enabled or disabled through the controll
## variables "enable_growth" and "enable_decay"
## Additionally settings for controll and dependencies are given in the inspector
## as exported variables

#region Variables
## Signal for ANY change in the amount
signal resource_amount_changed
signal resource_amount_increased
signal resource_amount_decreased

signal resource_reached_max
signal resource_reached_min

## Signal from adding fixed amounts of resources
## Differs from the "amount increased"- and "amount decreased"
## signals by only being emited when a fixed amount is added externally
signal resource_amount_added
## Signal from removing fixed amounts of resources
## Differs from the "amount increased"- and "amount decreased"
## signals by only being emited when a fixed amount is added externally
signal resource_amount_removed

signal replenish_started
signal replenish_stopped

signal depletion_started
signal depletion_stopped

@export var has_max_amount: bool = true
@export var has_min_amount: bool = true
@export var max_amount: float = 100
@export var min_amount: float = 0
## Base growth in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_growth: float = 10
## Base decay in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_decay: float = 0
## Base replenish in unit/second. If no value is given when an external start
## replenish, this base value is applied instead.
@export var base_replenish: float = 10
## Base depletion in unit/second. If no value is given when an external start
## depletion, this base value is applied instead.
@export var base_depletion: float = 10

## ACTIVE
## If growth should be enabled
@export var enable_growth: bool = true
## If decay should be enabled
@export var enable_decay: bool = false

## PAUSES
## If actively depleting the amount pauses growth
@export var pause_growth_automatically_when_depleting: bool = false
## If actively depleting the amount pauses decay
@export var pause_decay_automatically_when_depleting: bool = false
## If actively replenishing the amount pauses growth
@export var pause_growth_automatically_when_replenishing: bool = false
## If actively replenishing the amount pauses decay
@export var pause_decay_automatically_when_replenishing: bool = false

## DELAYS

## FROM REPLENISHING AND DEPLETION
## If stopping depletion causes delay in growth
@export var delay_growth_automatically_when_stop_depleting: bool = false
## If stopping depletion causes delay in decay
@export var delay_decay_automatically_when_stop_depleting: bool = false
## If stopping replenishing causes delay in growth
@export var delay_growth_automatically_when_stop_replenishing: bool = false
## If stopping replenishing causes delay in decay
@export var delay_decay_automatically_when_stop_replenishing: bool = false

## FROM ADDING AND REMOVING
## If adding causes delay in growth
@export var delay_growth_automatically_when_adding: bool = false
## If adding causes delay in decay
@export var delay_decay_automatically_when_adding: bool = false
## If removing causes delay in growth
@export var delay_growth_automatically_when_removing: bool = false
## If removing causes delay in decay
@export var delay_decay_automatically_when_removing: bool = false

## How long should the delays mentioned above be
@export var base_growth_pause_period: float = 2
## How long should the delays mentioned above be
@export var base_decay_pause_period: float = 2

# Externaly accessd amount property ##DUMB, CHANGE THE PRIVATE PROPERTY BELOW THEN >:C##
var amount: float = 1:
	get: return get_amount()

## Variables used to keep track of how many active calls to pause in decay and growth
var _calls_to_pause_growth: int = 0
var _calls_to_pause_decay: int = 0

var _growth_is_pausing: bool = false
var _decay_is_pausing: bool = false

## Extra growth and decay in unit/seconds
var _extra_growth: float = 0
var _extra_decay: float = 0
## Replenish and depletion in unit/seconds.
## Not named "extra" as growth and decay, since these alone decide the replenish
## and depletion rates
var _replenish: float = 0
var _depletion: float = 0

var _is_being_depleted: bool = false
var _is_being_replenished:bool = false

## The amount of resources in the resourcepool
var _amount: float = 1
#endregion

func _ready():
	_amount = max_amount
	_signal_setup()

func _process(delta):
	_replenish_and_deplete(delta)
	_grow_and_decay(delta)


## Method for getting the amount of resource in the pool
func get_amount() -> float:
	return _amount


## Method to be used externaly for adding to resourcepool
func add_to_amount(amount_to_add: float) -> void:
	_increase_amount(amount_to_add)
	resource_amount_added.emit()


## Method to be used externaly for removing from resourcepool
func remove_from_amount(amount_to_remove: float) -> void:
	_decrease_amount(amount_to_remove)
	resource_amount_removed.emit()


## Aplies extra growth on resourcepool for a certain time
func apply_growth(amount_to_grow: float, time: float = 10) -> void:
	_extra_growth += amount_to_grow
	await get_tree().create_timer(time).timeout
	_extra_growth -= amount_to_grow


## Aplies extra decay on resourcepool for a certain time
func apply_decay(amount_to_decay: float, time: float = 10) -> void:
	_extra_decay += amount_to_decay
	await get_tree().create_timer(time).timeout
	_extra_decay -= amount_to_decay


## Starts replenishing the resourcepool by the passed value per second. Remember to stop!
func start_replenishig(amount_to_replenish: float) -> void:
	# Checks wether started replenish from 0 and emit signal
	var last_replenish_amount = _replenish
	_replenish += amount_to_replenish
	if (_replenish != 0) and (last_replenish_amount == 0):
		replenish_started.emit()


## Stops replenishing the resourcepool by the passed value per second
func stop_replenishing(amount_to_stop: float) -> void:
	# Checks wether stopped replenish to 0 from non-0 and emit signal
	var last_replenish_amount = _replenish
	_replenish -= amount_to_stop
	if (_replenish == 0) and (last_replenish_amount != 0):
		replenish_stopped.emit()


## Starts depleting the resourcepool of the passed value per second. Remember to stop!
func start_depletion(amount_to_deplete: float) -> void:
	# Checks wether started depletion from 0 and emit signal
	var last_depletion_amount = _depletion
	_depletion += amount_to_deplete
	if (_depletion != 0) and (last_depletion_amount == 0):
		depletion_started.emit()


## Stops depleting the resourcepool of the passed value per seconds
func stop_depletion(amount_to_stop_deplete: float) -> void:
	# Checks wether stopped depletion to 0 from non-0 and emit signal
	var last_depletion_amount = _depletion
	_depletion -= amount_to_stop_deplete
	if (_depletion == 0) and (last_depletion_amount != 0):
		depletion_stopped.emit()


## Checking wether object is being depleted or not
func is_being_depleted() -> bool:
	return _is_being_depleted


## Checking wether object is being replenished or not
func is_being_replenished() -> bool:
	return _is_being_replenished


## Pauses growth of the resource pool for the given amount of seconds
func pause_growth(time: float = base_growth_pause_period) -> void:
	# Begin pause
	_calls_to_pause_growth += 1
	_growth_is_pausing = true
	
	# pause
	await get_tree().create_timer(time).timeout
	
	# End pause
	_calls_to_pause_growth -= 1
	if _calls_to_pause_growth == 0:
		_growth_is_pausing = false


## Pauses decay of the resource pool for the given amount of seconds
func pause_decay(time: float = base_decay_pause_period) -> void:
	# Begin pause
	_calls_to_pause_decay += 1
	_decay_is_pausing = true
	
	# pause
	await get_tree().create_timer(time).timeout
	
	# End pause
	_calls_to_pause_decay -= 1
	if _calls_to_pause_decay == 0:
		_decay_is_pausing = false


## Internal method for increasing the amount until reached max if given
func _increase_amount(amount_to_add: float) -> void:
	# If passed negative value raise error
	assert(amount_to_add >= 0)
	
	if amount_to_add == 0:
		return
	
	# If no max amount add, emit signal and return
	if not has_max_amount:
		_amount += amount_to_add
		resource_amount_changed.emit()
		return
	
	# If amount already at max do nothing
	if _amount == max_amount:
		return
	
	# Add amount and emit signal
	_amount += amount_to_add
	resource_amount_changed.emit()
	
	# If amount is maxed (or above) emit signal and reduce to madx
	if _amount >= max_amount:
		_amount = max_amount
		resource_reached_max.emit()


## Internal method for decreasing the amount until reached min if given
func _decrease_amount(amount_to_subtract: float) -> void:
	# If passed negative value raise error
	assert(amount_to_subtract >= 0)
	
	if amount_to_subtract == 0:
		return
	
	# If no min amount subtract, emit signal and return
	if not has_min_amount:
		_amount -= amount_to_subtract
		resource_amount_changed.emit()
		return
	
	
	# If amount already at min do nothing
	if _amount == min_amount:
		return
	# Decay
	
	# Subtract amount and emit signal
	_amount -= amount_to_subtract
	resource_amount_changed.emit()
	
	# If amount is at minimum (or below) emit signal and increase to min
	if _amount <= min_amount:
		_amount = min_amount
		resource_reached_min.emit()


## Checking wether object should apply base_growth based on setup variables
func _should_apply_base_grow() -> bool:
	if _growth_is_pausing:
		return false
	if pause_growth_automatically_when_depleting and is_being_depleted():
		return false
	if pause_growth_automatically_when_replenishing and is_being_replenished():
		return false
	return true


## Checking wether object should apply base_decay based on setup variables
func _should_apply_base_decay() -> bool:
	if _decay_is_pausing:
		return false
	if pause_decay_automatically_when_depleting and is_being_depleted():
		return false
	if pause_decay_automatically_when_replenishing and is_being_replenished():
		return false
	return true


## Process for growing and decaying resource pool
func _grow_and_decay(delta) -> void:
	# Growth
	if enable_growth:
		_increase_amount((_extra_growth) * delta)
		if _should_apply_base_grow():
			_increase_amount(base_growth * delta)
	# Decay
	if enable_decay:
		_decrease_amount((_extra_decay) * delta)
		if _should_apply_base_decay():
			_decrease_amount(base_decay * delta)


## Process for depleting and replenishing resource pool
func _replenish_and_deplete(delta) -> void:
	# Replenish
	_increase_amount(_replenish * delta)
	# Deplete
	_decrease_amount(_depletion * delta)


## Setting up signals and reactions
func _signal_setup() -> void:
	replenish_started.connect(_on_replenish_started)
	replenish_stopped.connect(_on_replenish_stopped)
	depletion_started.connect(_on_depletion_started)
	depletion_stopped.connect(_on_depletion_stopped)
	resource_amount_added.connect(_on_resource_amount_added)
	resource_amount_removed.connect(_on_resource_amount_removed)

#region Internal signal reaction methods
func _on_replenish_started() -> void:
	_is_being_replenished = true


func _on_replenish_stopped() -> void:
	_is_being_replenished = false
	
	# Apply the pausing times if added
	if delay_growth_automatically_when_stop_replenishing:
		pause_growth()
	if delay_decay_automatically_when_stop_replenishing:
		pause_decay()


func _on_depletion_started() -> void:
	_is_being_depleted = true


func _on_depletion_stopped() -> void:
	_is_being_depleted = false
	
	# Apply the pausing times if added
	if delay_growth_automatically_when_stop_depleting:
		pause_growth()
	if delay_decay_automatically_when_stop_depleting:
		pause_decay()


func _on_resource_amount_added() -> void:
	# Apply the pausing times if added
	if delay_growth_automatically_when_adding:
		pause_growth()
	if delay_decay_automatically_when_adding:
		pause_decay()


func _on_resource_amount_removed() -> void:
	# Apply the pausing times if added
	if delay_growth_automatically_when_removing:
		pause_growth()
	if delay_decay_automatically_when_removing:
		pause_decay()
#endregion

