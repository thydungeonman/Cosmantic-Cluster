extends "orb.gd"

func _ready():
	colour = COLOUR.GREEN


func ActivateAbility():
	print("GREEN ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	#gain x health up to max
