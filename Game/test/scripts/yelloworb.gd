extends "orb.gd"


func _ready():
	colour = COLOUR.YELLOW


func ActivateAbility():
	print("YELLOW ABILITY")
	#get_parent().HandleAbility(colour,player)
	var combo = get_parent().HandleAbilityCombo(colour,player)
	if(combo != 0):
		get_parent().NewHandleAbility(player)
	