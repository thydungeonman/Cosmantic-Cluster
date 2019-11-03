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
var y = 0
var newy = 0
var recalculated = false
var colour = COLOUR.RED
var player
var leftovers = []

var greyorbs = []


func _ready():
	set_fixed_process(true)
	

func _fixed_process(delta):
	if(moving):
		#print(str(get_pos()) + " " + str(y) + " " + str(get_rot()))
		Move(delta)
		Bounce()

func Move(delta):
	set_pos(get_pos() + (trajectory * 1.5 * delta))
	if(get_overlapping_bodies().size() > 0):
		var d = get_overlapping_bodies()
		for orb in d:
			if(orb.is_in_group("orb")):
				if(orb.colour == colour):
					orb.anim.play("burn")
				if(orb.colour == COLOUR.GREY and !greyorbs.has(orb)):
					greyorbs.push_back(orb)
					orb.TakeDamage()

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
		queue_free()
	if(bounced and get_pos().y < newy):
		EnableLauncher()
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