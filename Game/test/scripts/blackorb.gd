extends "orb.gd"


func _ready():
	colour = COLOUR.BLACK


func ActivateAbility():
	print("BLACK ABILITY")
	get_parent().HandleAbility(colour,player)
	
	#set darkness.visibility = true for x seconds
