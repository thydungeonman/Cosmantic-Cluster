extends "orb.gd"


func _ready():
	colour = COLOUR.YELLOW


func ActivateAbility():
	print("YELLOW ABILITY")
	#instance new lighning ball scene
	#lightning ball has a specific diameter
	#if orb collides with lball
		#if orb is correct color
			#orb.anim.play(zap)
	# the actual lightning ball should only be around for a few frames