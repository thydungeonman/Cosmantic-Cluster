extends "orb.gd"

func _ready():
	colour = COLOUR.RED


func ActivateAbility():
	print("RED ABILITY")
	get_parent().HandleAbility(colour,player)
	#damage enemy health by x amount