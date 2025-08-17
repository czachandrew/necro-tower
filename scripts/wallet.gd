extends Node

signal balance_changed(balance:int, delta:int, reason:String)

@export var starting_balance = 100
var current_balance: int

func _ready() -> void:
	current_balance = starting_balance
	emit_signal("balance_changed", current_balance, 0, "init")
	
func can_afford(amount:int) -> bool:
	return current_balance >= amount
	
func try_spend(amount: int, reason: String = "spend") -> bool: 
	if not can_afford(amount):
		return false
	else:
		current_balance -= amount
		emit_signal("balance_changed", current_balance, 0, reason)
		return true
		
		
	
