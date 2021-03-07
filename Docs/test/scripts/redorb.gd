extends "orb.gd"

func _ready():
	colour = COLOUR.RED


func ActivateAbility():
	print("RED ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	#damage enemy health by x amount
