extends "orb.gd"


func _ready():
	colour = COLOUR.BLACK


func ActivateAbility():
	print("BLACK ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	
	#set darkness.visibility = true for x seconds
