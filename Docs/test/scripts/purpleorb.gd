extends "orb.gd"

# class member variables go here, for example:
# var a = 2
func _ready():
	colour = COLOUR.PURPLE


func ActivateAbility():
	print("PURPLE ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	if(combo != 0):
		get_parent().NewHandleAbility(player)
