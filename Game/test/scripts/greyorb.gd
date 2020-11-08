extends "orb.gd"
#this orb appears when a blue orb ability is activated.
#it will spawn on the opposite players board attached to an existing orb
#it can only be destroyed by falling or if two matches are made next to it
var hits = 0

func _ready():
	colour = COLOUR.GREY
	pass

func HookUp():
	GetNeighboringPositions()
	GetNeighbors()

func TakeDamage():
	if(hits == 1):
		print("grey orb died")
		sfx.play("cracking-crunching - Grey orb destroyed")
		Die()
	elif(hits == 0):
		anim.play("crack")
		print("grey orb cracked")
		hits += 1
		sfx.play("crack-2 - Grey orb damage")
	