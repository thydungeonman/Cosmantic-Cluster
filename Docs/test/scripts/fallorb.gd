extends Sprite

enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

const YELLOW = "res://test/sprites/yellow orb.png"
const BLUE = "res://test/sprites/blue orb.png"
const ORANGE = "res://test/sprites/orange orb.png"
const PURPLE = "res://test/sprites/purple orb.png"
const BLACK = "res://test/sprites/black orb.png"
const GREEN = "res://test/sprites/green orb.png"
const WHITE = "res://test/sprites/white orb.png"
const RED = "res://test/sprites/red orb.png"
const GREY = "res://test/sprites/grey orb new.png"

var colour
var right = 0
var clock = 0


func changeColour(colour):
	if(colour == COLOUR.RED):
		set_texture(preload(RED))
	elif(colour == COLOUR.YELLOW):
		set_texture(preload(YELLOW))
	elif(colour == COLOUR.BLUE):
		set_texture(preload(BLUE))
	elif(colour == COLOUR.ORANGE):
		set_texture(preload(ORANGE))
	elif(colour == COLOUR.PURPLE):
		set_texture(preload(PURPLE))
	elif(colour == COLOUR.BLACK):
		set_texture(preload(BLACK))
	elif(colour == COLOUR.GREEN):
		set_texture(preload(GREEN))
	elif(colour == COLOUR.WHITE):
		set_texture(preload(WHITE))
	elif(colour == COLOUR.GREY):
		set_texture(preload(GREY))

func setRot(rotation):
	set_rotation(rotation)

func _ready():
	#get appropriate rotation and sprite
	#start fall animation
	randomize()
	var right = rand_range(0,1)
	var clock = rand_range(0,1)
	get_node("AnimationPlayer").play("fall")
	set_physics_process(true)


func _physics_process(delta):
	#pick fall direction and spin direction
	if(right > .5):
		fallRight(delta)
	else:
		fallLeft(delta)
	if(clock > .5):
		spinClock(delta)
	else:
		spinAntiClock(delta)



func fallRight(delta):
	var pos = get_global_position()
	pos.x += 1
	set_global_position(pos)
	pass
	#move slightly to the right


func fallLeft(delta):
	var pos = get_global_position()
	pos.x -= 1
	set_global_position(pos)
	#move sligtly to the left

func spinClock(delta):
	rotate(PI/180)
	pass
	#rotate clockwise

func spinAntiClock(delta):
	rotate(PI/-180)
	pass
	#rotate anticlock



