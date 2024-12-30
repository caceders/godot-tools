class_name ResourcePool extends Node
## A class implementing a resourcepool, - health, stamina, mana, oxygen etc.

## To use add the resourcepool Node to an object. Name the pool something
## relevant.
## The resourcepool can be added to and removed of by any amount through
## add_to and remove_from methods.
## It can be depleted and replenished by an amount per second through
## the start/stop replenish/depletion methods.
## Additional settings for controll and dependencies are given in the inspector
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


@export var has_max_amount: bool = true
@export var has_min_amount: bool = true
@export var max_amount: float = 100
@export var min_amount: float = 0
## Base growth in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_growth: float = 10
## Base decay in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_decay: float = 10

## ACTIVE
## If growth should be enabled
@export var enable_growth: bool = true
## If decay should be enabled
@export var enable_decay: bool = false


## FROM ADDING AND REMOVING
## If adding causes pause in growth
@export var pause_growth_automatically_when_adding: bool = false
## If adding causes pause in decay
@export var pause_decay_automatically_when_adding: bool = false
## If removing causes pause in growth
@export var pause_growth_automatically_when_removing: bool = false
## If removing causes pause in decay
@export var pause_decay_automatically_when_removing: bool = false

## How long should the delays mentioned above be
@export var base_growth_pause_period: float = 2
## How long should the delays mentioned above be
@export var base_decay_pause_period: float = 2

## Read Only
var amount: float:
	get: return get_amount()

var _apply_growth: bool = false
var _apply_decay: bool = false


## The amount of resources in the resourcepool
var _amount: float = 1
#endregion

func _ready():
	_amount = max_amount
	_signal_setup()

func _process(delta):
	_grow_and_decay(delta)


## Method for getting the amount of resource in the pool
func get_amount() -> float:
	return _amount


## Method to be used externaly for adding to resourcepool
func add_to_pool(amount_to_add: float) -> void:
	_increase_amount(amount_to_add)
	resource_amount_added.emit()


## Method to be used externaly for removing from resourcepool
func remove_from_pool(amount_to_remove: float) -> void:
	_decrease_amount(amount_to_remove)
	resource_amount_removed.emit()


## Pauses growth of the resource
func pause_growth() -> void:
	_apply_growth = false


## Pauses growth of the resource
func start_growth() -> void:
	_apply_growth = true


## Pauses decay of the resource
func start_decay() -> void:
	_apply_decay = true

## Pauses decay of the resource
func pause_decay() -> void:
	_apply_decay = false


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
	
	# If amount is maxed (or above) emit signal and reduce to max
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



## Process for growing and decaying resource pool
func _grow_and_decay(delta) -> void:
	# Growth
	if enable_growth:
		_increase_amount((base_growth) * delta)
	# Decay
	if enable_decay:
		_decrease_amount((base_decay) * delta)


## Setting up signals and reactions
func _signal_setup() -> void:
	resource_amount_added.connect(_on_resource_amount_added)
	resource_amount_removed.connect(_on_resource_amount_removed)


func _on_resource_amount_added() -> void:
	# Apply the pausing times if added
	if pause_growth_automatically_when_adding:
		pause_growth()
	if pause_decay_automatically_when_adding:
		pause_decay()


func _on_resource_amount_removed() -> void:
	# Apply the pausing times if added
	if pause_growth_automatically_when_removing:
		pause_growth()
	if pause_decay_automatically_when_removing:
		pause_decay()
#endregion

