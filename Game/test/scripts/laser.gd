extends Area2D

enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}
enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}
var moving = false
var trajectory = Vector2(0,0)
var angle = 0
var bounced = false
var bouncing = false
onready var x = 0
onready var sfx = get_node("SamplePlayer")
var y = 0
var newy = 0
var recalculated = false
var colour = COLOUR.RED
var player
var leftovers = []

var greyorbs = []
var oldposition
var position
var numfollowers = 5
var followers = []


func _ready():
	set_fixed_process(true)
	for i in range(numfollowers):
		followers.push_back(preload("res://test/scenes/laserfollower.tscn").instance())
		get_parent().add_child(followers[i])
	for i in range(0,numfollowers-1):
		followers[i].after = followers[i+1]
	

func _fixed_process(delta):
	if(moving):
		#print(str(get_pos()) + " " + str(y) + " " + str(get_rot()))
		oldposition = position
		Move(delta)
		Bounce2()
		position = get_global_pos()
		followers[0].oldposition = followers[0].position
		if(oldposition != null):
			followers[0].set_global_pos(oldposition)
		followers[0].position = followers[0].get_global_pos()
		for i in followers:
			i.Move()

func Move(delta):
	set_pos(get_pos() + (trajectory * 1.5 * delta) * .5)
	if(get_overlapping_bodies().size() > 0):
		var d = get_overlapping_bodies()
		for orb in d:
			if(orb.is_in_group("orb")):
				if(orb.colour == colour):
					orb.spawnBurnOrb()
					sfx.play("Orange ability impact")
				if(orb.colour == COLOUR.GREY and !greyorbs.has(orb)):
					greyorbs.push_back(orb)
					orb.TakeDamage()
					sfx.play("Orange ability impact")

func Bounce():
	if(get_pos().y <= y):
			#print("bounce")
		if(bounced and !recalculated):
			RecalculateBounce()
		bounced = true
		if(bounced and !bouncing):
			trajectory.x *= -1
			set_rot(get_rot() * -1)
			bouncing = true
	if(get_pos().y < 0):
		EnableLauncher()
		for i in followers:
			i.queue_free()
		queue_free()
	if(bounced and get_pos().y < newy):
		EnableLauncher()
		for i in followers:
			i.queue_free()
		queue_free()

func Bounce2():
	var pos = get_global_pos()
	if(player == PLAYER.PLAYER1):
		if!bounced:
			if(pos.x < 8):
				pos.x = 8
				set_global_pos(pos)
				bounced = true
				trajectory.x *= -1
				set_rot(get_rot() * -1)
				sfx.play("Orange ability bounce")
			if(pos.x > 920):
				pos.x = 920
				set_global_pos(pos)
				bounced = true
				trajectory.x *= -1
				set_rot(get_rot() * -1)
				sfx.play("Orange ability bounce")
		else:
			if(pos.x < 8 or pos.x > 920):
				EnableLauncher()
				for i in followers:
					i.queue_free()
				queue_free()
	elif(player == PLAYER.PLAYER2):
		if!bounced:
			if(pos.x < 1000):
				pos.x = 1000
				set_global_pos(pos)
				bounced = true
				trajectory.x *= -1
				set_rot(get_rot() * -1)
				sfx.play("Orange ability bounce")
			if(pos.x > 1912):
				pos.x = 1912
				set_global_pos(pos)
				bounced = true
				trajectory.x *= -1
				set_rot(get_rot() * -1)
				sfx.play("Orange ability bounce")
		else:
			if(pos.x < 1000 or pos.x > 1912):
				EnableLauncher()
				for i in followers:
					i.queue_free()
				queue_free()
	if(pos.y < 0):
		EnableLauncher()
		for i in followers:
			i.queue_free()
		queue_free()
	


func Fire():
	moving = true
	CalculateBounce()

#Since the area2d class has trouble bouncing off of static bodies
#this function calculates the y value of where the bounce will take place
#the x value is unnesessary as it is constant at 440
func CalculateBounce():
	y = (1040 - (abs(tan(x)) * 451)) #maybe rename x to theta or angle
	set_rotd((rad2deg(x) + 90) * -1)
func RecalculateBounce():
	newy = (1040 - (abs(tan(x)) * 1368)) #this is the correct number, no idea why. It should be 912 but whatever, it works.
	recalculated = true
	print(y)

func Charge(trajectory,x):
	self.x = x
	self.trajectory.x = (trajectory.x * cos(x))
	self.trajectory.y = (trajectory.y * sin(x))

func EnableLauncher():
	if(player == PLAYER.PLAYER1):
		get_parent().get_node("p1launcher").Enable()
	elif(player == PLAYER.PLAYER2):
		get_parent().get_node("p2launcher").Enable()