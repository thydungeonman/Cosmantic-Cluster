extends "orb.gd"

# class member variables go here, for example:
# var a = 2
func _ready():
	colour = COLOUR.PURPLE


func ActivateAbility():
	print("PURPLE ABILITY")
	get_parent().HandleAbility(colour,player)