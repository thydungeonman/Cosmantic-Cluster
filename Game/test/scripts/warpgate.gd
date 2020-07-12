extends Area2D

onready var checker = get_node("checker")
onready var sfx = get_node("SamplePlayer2D")
#warp gate
#sits at the top of each players board and warps any orbs that go into it to the top
#of the opponents board going the opposite direction

enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(get_overlapping_bodies().size() > 0):
		for orb in get_overlapping_bodies():
			if(orb.is_in_group("orb")):
				if(!orb.warped and orb.ismoving):
					if(orb.player == PLAYER.PLAYER1):
						var exit = orb.get_pos()
						exit.y = 40
						exit.x = 1920 - exit.x
						checker.set_global_pos(exit)
						var g = preload("res://test/scenes/godot.tscn").instance()
						add_child(g)
						g.set_global_pos(checker.get_global_pos())
						if(checker.get_overlapping_bodies().size() > 0):
							for body in checker.get_overlapping_bodies():
								if body.is_in_group("orb"):
									orb.MovingDie()
									print("Died in the warp")
									for body in checker.get_overlapping_bodies():
										print(body.get_name())
									break
						else:
							exit.y = 0
							orb.Warp(exit)
							sfx.play("teleport-morphy - Orb entering warpgate")
					elif(orb.player == PLAYER.PLAYER2):
						var exit = orb.get_pos()
						exit.y = 40
						exit.x = 0 + (1920 - exit.x)
						checker.set_global_pos(exit)
						if(checker.get_overlapping_bodies().size() > 0):
							for body in checker.get_overlapping_bodies():
								if body.is_in_group("orb"):
									orb.MovingDie()
									print("Died in the warp")
									break
						else:
							exit.y = 0
							orb.Warp(exit)
							sfx.play("teleport-morphy - Orb entering warpgate")
	checker.set_pos(Vector2())
#					orb.Warp(exit)
	#wait until kinematic body enters
	#if player1 warp to player2 board
	#elif player2 warp to player1 board
