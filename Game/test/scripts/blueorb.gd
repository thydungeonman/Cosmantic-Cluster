extends "orb.gd"

func _ready():
	colour = COLOUR.BLUE


func ActivateAbility():
	print("BLUE ABILITY")
	get_parent().HandleAbility(colour,player)
	#instance x amount of grey orbs
	#they spawn attatched to orbs that have available bottom left or right spots
