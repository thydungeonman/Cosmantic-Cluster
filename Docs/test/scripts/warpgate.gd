extends Area2D

onready var sfx = get_node("AudioStreamPlayer2D")
onready var checker = get_node("checker1")
var warpedorb
var exit

var inposition = false
#warp gate
#sits at the top of each players board and warps any orbs that go into it to the top
#of the opponents board going the opposite direction

enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if(!inposition):
		if(get_overlapping_bodies().size() > 0):
			for orb in get_overlapping_bodies():
				if(orb.is_in_group("orb")):
					if(!orb.warped and orb.ismoving):
						warpedorb = orb
						if(orb.player == PLAYER.PLAYER1):
							exit = orb.get_position()
							exit.y = 4
							exit.x = 1920 - exit.x
							checker.set_global_position(exit)
							
						elif(orb.player == PLAYER.PLAYER2):
							exit = orb.get_position()
							exit.y = 4
							exit.x = 0 + (1920 - exit.x)
							checker.set_global_position(exit)
						inposition = true
	else: #in position
		if(checker.get_overlapping_bodies().size() > 0):
			for body in checker.get_overlapping_bodies():
				if body.is_in_group("orb"):
					warpedorb.MovingDie()
					print("Died in the warp")
					for body in checker.get_overlapping_bodies():
						print(body.get_name())
						break
		else:
			exit.y = 0
			warpedorb.Warp(exit)
			sfx.play("teleport-morphy - Orb entering warpgate")
		inposition = false
	
#	checker.set_position(Vector2())
#					orb.Warp(exit)
	#wait until kinematic body enters
	#if player1 warp to player2 board
	#elif player2 warp to player1 board

