extends "orb.gd"

func _ready():
	colour = COLOUR.BLUE


func ActivateAbility():
	print("BLUE ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	#instance x amount of grey orbs
	#they spawn attatched to orbs that have available bottom left or right spots
