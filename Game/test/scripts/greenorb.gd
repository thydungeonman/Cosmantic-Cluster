extends "orb.gd"

func _ready():
	colour = COLOUR.GREEN


func ActivateAbility():
	print("GREEN ABILITY")
	get_parent().HandleAbility(colour,player)
	#gain x health up to max
