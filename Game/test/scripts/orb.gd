extends KinematicBody2D
#an orb should always have the board as its parent
#even when instanced by the launcher


enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}
enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}

export(Vector2) var trajectory = Vector2(0,0)
export(bool) var ismoving = false
var inlauncher = false #if an orb is neither in the launcher nor moving then it is on the board
onready var width = get_node("Sprite").get_texture().get_width() * get_node("Sprite").get_scale().x #maybe should be renamed to diameter
onready var ray = get_node("RayCast2D")
var matchingorbs = []
var leftoverorbs = [] #these orbs are the ones that were touching the orbs that were just matched
var crossreforbs = [] # these orbs are the ones that were found while looking for the top
# they will be cross referenced with the leftover orbs so that no orb is looked through twice to find the top
onready var pos = get_pos()
onready var inversescale = 1/get_scale().x
onready var anim = get_node("AnimationPlayer")
onready var sfx = get_node("SamplePlayer2D")

var onboard #whos side of the board the orb is on

var touchingwallleft = false
var touchingwallright = false

var charged = false #changes to true if the yellow ability is active

var falling = false

var player = PLAYER.PLAYER1
var colour = COLOUR.NONE

var warped = false #changes to true after sent through a warp

var isflag = false #should be a better way to do this
var istouchingflag = false
var istouchingtop = false

#neighboring orbs  Kinematic bodies
var topleft
var topright
var left
var right
var bottomleft
var bottomright
#neighboring orb global positions  Vector2s
var topleftspot
var toprightspot
var leftspot
var rightspot
var bottomleftspot
var bottomrightspot
#neighboring orb local positions for raycast Vector2s only
onready var ltopleftspot = Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var ltoprightspot = Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var lleftspot = Vector2(-width,0)
onready var lrightspot = Vector2(width ,0)
onready var lbottomleftspot = Vector2(-width,width) * Vector2(1.07337749,1.8417709).normalized()
onready var lbottomrightspot = Vector2(width,width) * Vector2(1.07337749,1.8417709).normalized()

var timespathedupon = 0
var isexcluded = false # from looking for top and maybe searching

var number = 0

func _ready():
	set_fixed_process(true)
	#get_node("Label").set_text(str(get_name()))
	get_node("Label").set_text(get_name())
	set_process_input(true)

func _input(event):
	pass

func _fixed_process(delta):
	
	if(ismoving):
		Move(delta)

func GetNeighboringPositions():
	#calculates the positions that neighboring orbs will be set too, creates a hexagon shape.
	var pos = get_pos()
	#print(width)
	
	topleftspot = pos + (Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized())
	toprightspot = pos + (Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized())
#	leftspot = pos + (Vector2(-width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
#	rightspot = pos + (Vector2(width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
	leftspot = pos + (Vector2(-width,0))
	rightspot = pos + (Vector2(width ,0))
	bottomleftspot = pos + (Vector2(-width,width) * Vector2(1.07337749,1.8417709).normalized())
	bottomrightspot = pos + (Vector2(width,width) * Vector2(1.07337749,1.8417709).normalized())

func Move(delta):
	get_node("Sprite").rotate(.1)
	#main function. 
	#moves orb, checks for collision,if wall: bounces back
	#if orb: determines axis of collision and moves orb to correct spot 
	#then checks for a match, removing the correct orbs, activating ability and checking for falls if a match is made
	move(trajectory * delta)
	if(get_pos().y > 1080 or get_pos().y < -400):
		#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
		EnableLauncher()
		queue_free()
		print("orb went out of bounds")
	if(is_colliding()):
		
		
		var collider = get_collider()
		if(collider.is_in_group("wall")):
			trajectory.x *= -1
			get_node("sparkles").set_rotd(get_node("sparkles").get_rotd() *- -1)
			sfx.play("retro-video-game-sfx-bounce - orb bouncing off wall")
		elif(collider.is_in_group("roof")):
			trajectory.y *= -1
		elif(collider.is_in_group("orb")):
			if(collider.inlauncher):
				#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
				EnableLauncher()
				queue_free()
				print("hit launcher orb")
			if(!collider.ismoving and !collider.inlauncher):
				StopSparkle()
				AddToPlayer()
				sfx.play("beer-bottles - orbs collide together")
				ismoving = false
				#print("playing sfx")
				var positiondifference = get_pos() - collider.get_pos()
				positiondifference = positiondifference.normalized()
				var dotproductnorth = positiondifference.dot(Vector2(0,-1))
				var dotproductwest = positiondifference.dot(Vector2(-1,0))
#				print(dotproductnorth)
#				print(dotproductwest)
				
				if((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 1 and dotproductwest > 0)): #collided on bottomleft
					set_pos(collider.bottomleftspot)
					collider.bottomleft = self
					topright = collider
					#print("hit top right")
				elif((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 0 and dotproductwest >= -1)): #collided on bottom right side
					set_pos(collider.bottomrightspot)
					collider.bottomright = self
					topleft = collider
					#print("hit top left")
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 1 and dotproductwest > 0)):#left
					set_pos(collider.leftspot)
					collider.left = self
					right = collider
					#print("hit right")
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#right
					set_pos(collider.rightspot)
					collider.right = self
					left = collider
					#print("hit left")
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 1 and dotproductwest > 0)):#topleft
					set_pos(collider.topleftspot)
					collider.topleft = self
					bottomright = collider
					#print("hit bottom right")
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#topright
					set_pos(collider.toprightspot)
					collider.topright = self
					bottomleft = collider
					#print("hit bottom left")
				if(collider.is_in_group("flag")):
					istouchingflag = true
				EnableLauncher()
				GetNeighboringPositions()
				GetNeighbors()
				#print(CountNeighbors())
				var foundmatch = CheckMatch(matchingorbs,leftoverorbs);
				
				if(foundmatch):
					sfx.play("glass-shatter-3 - Group of orbs removed")
					for orb in leftoverorbs:
						if(orb.colour == COLOUR.GREY):
							orb.TakeDamage()
					if(charged):
						get_parent().get_node("lightningarea").set_pos(get_global_pos())
						get_parent().anim.play("yellowability")
						sfx.play("electric-zap - Yellow abilty used removed orbs")
						var killorbs = []
						var greyorbs = []
						for orb in matchingorbs:  #get all of the orbs with the same colour as the match 2 orbs out
							killorbs = orb.Search(2,colour,killorbs)
						for orb in matchingorbs:
							greyorbs = orb.Search(2,COLOUR.GREY,greyorbs)
							
							
						var extraleftovers = []
						for orb in matchingorbs:  #remove the original match orbs
							killorbs.remove(killorbs.find(orb))
						for orb in greyorbs:
							print(orb)
							orb.TakeDamage()
						var extraleftovers = []
						for orb in killorbs:
							extraleftovers = orb.Search(1,COLOUR.NONE,extraleftovers)
							orb.Unhook()
							get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
							orb.RemoveFromPlayer()
							orb.anim.play("zap")
						for orb in extraleftovers:
							if(!leftoverorbs.has(orb)):
								leftoverorbs.push_back(orb)
					for i in matchingorbs:
						i.Unhook()
						get_parent().orbsonboard.remove(get_parent().orbsonboard.find(i))
						i.RemoveFromPlayer()
					get_parent().leftoverorbs = leftoverorbs
					get_parent().CheckFall()
					
					#get_parent().HandleAbilityCombo(colour,player)
					ActivateAbility()
					
					
					for orb in matchingorbs:
						#print(orb.get_name())
						orb.anim.play("blink")
						if(orb.isflag):
							if(orb.player == PLAYER.PLAYER1):
								get_parent().GameOver("Player two wins",PLAYER.PLAYER2)
							elif(orb.player == PLAYER.PLAYER2 or player == PLAYER.AI):
								get_parent().GameOver("Player one wins",PLAYER.PLAYER1)
				else:
					get_parent().NewHandleAbility(player)
					matchingorbs.clear()
					leftoverorbs.clear()
					if(WentOverDeathLine()):
						SignalGameOver()


func click():
	pass
	#debugging function
#	var mousepos = get_viewport().get_mouse_pos()
#	ray.set_cast_to(mousepos - get_pos())
#	print(ray.get_collider())
	#var positiondifference = mousepos - get_pos()
	#positiondifference = positiondifference.normalized()
	#var dotproductnorth = positiondifference.dot(Vector2(0,-1))
	#var dotproductwest = positiondifference.dot(Vector2(-1,0))

func Unhook():
	#unhooks an orbs neighbors from itself and it from its neighbors
	if(topleft != null and topleft.is_in_group("orb")):
		topleft.bottomright = null
	if(topright != null and topright.is_in_group("orb")):
		topright.bottomleft = null
	if(left != null and left.is_in_group("orb")):
		left.right = null
	if(right != null and right.is_in_group("orb")):
		right.left = null
	if(bottomleft != null and bottomleft.is_in_group("orb")):
		bottomleft.topright = null
	if(bottomright != null and bottomright.is_in_group("orb")):
		bottomright.topleft = null
	topleft = null
	topright = null
	left = null
	right = null
	bottomleft = null
	bottomright = null

func Die():
	#this function perform all of the necessary actions before an orb can be freed and then frees it
	#removes itself from the list of orbs, unhooks from its neighbors, and checks if orbs around it will fall after its freed
	RemoveFromPlayer()
	var index = get_parent().orbsonboard.find(self)
	if(index != -1):
		get_parent().orbsonboard.remove(index)
	var leftovers = []
	Search(2,COLOUR.NONE,leftovers)
	if(leftovers.size() > 0):
		leftovers.remove(leftovers.find(self))
	#print("leftover size: " + str(leftovers.size()))
	get_parent().leftoverorbs = leftovers
	Unhook()
	get_parent().CheckFall()
	
	if(isflag):
		if(player == PLAYER.PLAYER1):
			get_parent().GameOver("Player two wins",PLAYER.PLAYER2)
		elif(player == PLAYER.PLAYER2 or player == PLAYER.AI):
			get_parent().GameOver("Player one wins",PLAYER.PLAYER1)
	get_parent().CheckPlayerBoard(player)
	
	
	queue_free()


func GetLeftovers():
	#grabs the surrounding orbs and sets them as leftovers for checking falls
	var leftovers = []
	Search(2,COLOUR.NONE,leftovers)
	if(leftovers.size() > 0):
		leftovers.remove(leftovers.find(self))
	#print("leftover size: " + str(leftovers.size()))
	get_parent().leftoverorbs = leftovers
	
func MovingDie():
	var index = get_parent().orbsonboard.find(self)
	if(index != -1):
		get_parent().orbsonboard.remove(index)
	RemoveFromPlayer()
	EnableLauncher()
#	var trajectoryangle = trajectory.angle_to(Vector2(0,1))
#	var dyingsparks = preload("res://test/scenes/dead orb sparks.tscn").instance()
#	get_parent().add_child(dyingsparks)
#	dyingsparks.set_global_pos(get_global_pos())
#	dyingsparks.rotate(trajectoryangle)
#	dyingsparks.get_node("AnimationPlayer").play("sparkle")
	queue_free()

func AddToPlayer(): #this function adds the orb to the boards list of orbs and the players list of orbs
	get_parent().orbsonboard.push_front(self)
	if(onboard == PLAYER.PLAYER1):
		get_parent().orbsonboardp1.push_back(self)
	elif(onboard == PLAYER.PLAYER2):
		get_parent().orbsonboardp2.push_back(self)
#	elif(onboard == PLAYER.AI):
#		get_parent().orbsonboardai.push_back(self)

func RemoveFromPlayer():
	if(onboard == PLAYER.PLAYER1):
		var index = get_parent().orbsonboardp1.find(self)
		if(index != -1):
			get_parent().orbsonboardp1.remove(index)
	elif(onboard == PLAYER.PLAYER2):
		var index = get_parent().orbsonboardp2.find(self)
		if(index != -1):
			get_parent().orbsonboardp2.remove(index)
#	elif(onboard == PLAYER.AI):
#		var index = get_parent().orbsonboardai.find(self)
#		if(index != -1):
#			get_parent().orbsonboardai.remove(index)

#this function raycasts in each direction, grabbing the closest body and area
#it then casts again only looking for bodies since if the orb is inside of an area it will only detect areas since they are the closest
func GetNeighbors():
	DoCasts()
	#print("mask: " + str(ray.get_type_mask()))
	ray.set_type_mask(Physics2DDirectSpaceState.TYPE_MASK_KINEMATIC_BODY)
	DoCasts()
	#print("mask: " + str(ray.get_type_mask()))


func CheckMatch(matchingorbs, leftoverorbs): #accepts array of kinematic bodies2d
	#this function checks all neighbors to see if any of them are the same colour
	#matching neighbors will check their neighbors and so on until there are no more matches
	#returns true if their are more than three orbs touching with the same colour
	
	var match = false
	
	matchingorbs.push_front(self)
	if(topleft != null):
		if(topleft.is_in_group("orb")):
			if(topleft.colour == self.colour):
				if(!matchingorbs.has(topleft)):
					topleft.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(topleft)):
					leftoverorbs.push_back(topleft)
	if(topright != null):
		if(topright.is_in_group("orb")):
			if(topright.colour == self.colour):
				if(!matchingorbs.has(topright)):
					topright.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(topright)):
					leftoverorbs.push_back(topright)
	if(left != null):
		if(left.is_in_group("orb")):
			if(left.colour == self.colour):
				if(!matchingorbs.has(left)):
					left.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(left)):
					leftoverorbs.push_back(left)
	if(right != null):
		if(right.is_in_group("orb")):
			if(right.colour == self.colour):
				if(!matchingorbs.has(right)):
					right.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(right)):
					leftoverorbs.push_back(right)
	if(bottomleft != null):
		if(bottomleft.is_in_group("orb")):
			if(bottomleft.colour == self.colour):
				if(!matchingorbs.has(bottomleft)):
					bottomleft.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(bottomleft)):
					leftoverorbs.push_back(bottomleft)
	if(bottomright != null):
		if(bottomright.is_in_group("orb")):
			if(bottomright.colour == self.colour):
				if(!matchingorbs.has(bottomright)):
					bottomright.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(bottomright)):
					leftoverorbs.push_back(bottomright)
	if(matchingorbs.size() >= 3):
		match = true
	return match



#the topmost orbs neighbor an area that is in the group "top"
#this function takes an array or orbs that have already been checked and then checks to see if it has the top as itn neighbor
#if its neighbor is not the top, that neighbor will then check if it neighbors the top and so on
func LookForTop(crossreforbs):
	crossreforbs.push_back(self)
	if(topleft != null and !topleft.is_in_group("wall") ):
		#print("topleft")
		if(!crossreforbs.has(topleft)):
			if(topleft.is_in_group("top") or (!topleft.is_in_group("top") and topleft.LookForTop(crossreforbs)) and !topleft.isexcluded):
				#print(str(get_name()) + " found top on topleft")
				return true
	if(topright != null and !topright.is_in_group("wall")):
		#print("topright")
		if(!crossreforbs.has(topright)):
			if(topright.is_in_group("top") or (!topright.is_in_group("top") and topright.LookForTop(crossreforbs)) and !topright.isexcluded):
				#print(str(get_name()) + " found top on topright")
				return true
	if(left != null and !left.is_in_group("wall")):
		#print("left")
		if(!crossreforbs.has(left)):
			if(left.is_in_group("top") or (!left.is_in_group("top") and left.LookForTop(crossreforbs)) and !left.isexcluded):
				#print(str(get_name()) + " found top on left")
				return true
	if(right != null and !right.is_in_group("wall")):
		#print("right")
		if(!crossreforbs.has(right)):
			if(right.is_in_group("top") or (!right.is_in_group("top") and right.LookForTop(crossreforbs)) and !right.isexcluded):
				#print(str(get_name()) + " found top on right")
				return true
	if(bottomleft != null and !bottomleft.is_in_group("wall")):
		#print("bottomleft")
		if(!crossreforbs.has(bottomleft)):
			if(bottomleft.is_in_group("top") or (!bottomleft.is_in_group("top") and bottomleft.LookForTop(crossreforbs)) and !bottomleft.isexcluded):
				#print(str(get_name()) + " found top on bottomleft")
				return true
	if(bottomright != null and !bottomright.is_in_group("wall")):
		#print("bottomright")
		if(!crossreforbs.has(bottomright)):
			if(bottomright.is_in_group("top") or (!bottomright.is_in_group("top") and bottomright.LookForTop(crossreforbs)) and !bottomright.isexcluded):
				#print(str(get_name()) + " found top on bottomright")
				return true
				
	falling = true
	#print(str(get_name()) + " did not find top")
	return false


func ActivateAbility():
	#virtual method. Activates when this orb matches with two or more other orbs
	pass

#returns the current number of neighboring orbs
func CountNeighbors():
	var count = 0
	if(topleft != null):
		count+=1
	if(topright != null):
		count+=1
	if(left != null):
		count+=1
	if(right != null):
		count+=1
	if(bottomleft != null):
		count+=1
	if(bottomright != null):
		count+=1
	get_node("count").set_text(str(count))
	return count


#recursive function that searches outward from an orb one level at a time
#returns all orbs that are a specific colour
#searching for COLOUR.NONE will return all orbs
#searching deeper than one level will also return the original orb
#the group is needed so that orbs are not added twice
#exclude on for there to need to be a path of like coloured orbs to same coloured orbs
func Search(level, searchcolour, group, exclude = false):
	level -= 1
	if(level >= 0):
		if(topleft != null):
			if(topleft.is_in_group("orb")):
				if(topleft.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(topleft)):
						group.push_back(topleft)
				if(exclude == false or topleft.colour == searchcolour):
					topleft.Search(level,searchcolour,group,exclude)
		if(topright != null):
			if(topright.is_in_group("orb")):
				if(topright.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(topright)):
						group.push_back(topright)
				if(exclude == false or topright.colour == searchcolour):
					topright.Search(level,searchcolour,group,exclude)
		if(left != null):
			if(left.is_in_group("orb")):
				if(left.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(left)):
						group.push_back(left)
				if(exclude == false or left.colour == searchcolour):
					left.Search(level,searchcolour,group,exclude)
		if(right != null):
			if(right.is_in_group("orb")):
				if(right.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(right)):
						group.push_back(right)
				if(exclude == false or right.colour == searchcolour):
					right.Search(level,searchcolour,group,exclude)
		if(bottomleft != null):
			if(bottomleft.is_in_group("orb")):
				if(bottomleft.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(bottomleft)):
						group.push_back(bottomleft)
				if(exclude == false or bottomleft.colour == searchcolour):
					bottomleft.Search(level,searchcolour,group,exclude)
		if(bottomright != null):
			if(bottomright.is_in_group("orb")):
				if(bottomright.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(bottomright)):
						group.push_back(bottomright)
				if(exclude == false or bottomright.colour == searchcolour):
					bottomright.Search(level,searchcolour,group,exclude)
		return group


#recursive function that searches outward from an orb looking for the target orb
func SearchFor(level,searchcolour,target,exclude = false):
	level -= 1
	if(level >= 0):
		if(topleft != null):
			if(topleft.is_in_group("orb")):
				if(topleft == target):
					return true
				if(exclude == false or topleft.colour == searchcolour):
					if(topleft.SearchFor(level,searchcolour,target,exclude)):
						return true
		if(topright != null):
			if(topright.is_in_group("orb")):
				if(topright == target):
					return true
				if(exclude == false or topright.colour == searchcolour):
					if(topright.SearchFor(level,searchcolour,target,exclude)):
						return true
		if(left != null):
			if(left.is_in_group("orb")):
				if(left == target):
					return true
				if(exclude == false or left.colour == searchcolour):
					if left.SearchFor(level,searchcolour,target,exclude):
						return true
		if(right != null):
			if(right.is_in_group("orb")):
				if(right == target):
					return true
				if(exclude == false or right.colour == searchcolour):
					if right.SearchFor(level,searchcolour,target,exclude):
						return true
		if(bottomleft != null):
			if(bottomleft.is_in_group("orb")):
				if(bottomleft == target):
					return true
				if(exclude == false or bottomleft.colour == searchcolour):
					if bottomleft.SearchFor(level,searchcolour,target,exclude):
						return true
		if(bottomright != null):
			if(bottomright.is_in_group("orb")):
				if(bottomright == target):
					return true
				if(exclude == false or bottomright.colour == searchcolour):
					if bottomright.SearchFor(level,searchcolour,target,exclude):
						return true
	return false

#specific version of search to be used when checking charged shots
#returns greys along with searchcolour and excludes orbs that are isexcluded
func ChargeSearch(level, searchcolour, group):
	level -= 1
	if(level >= 0):
		if(topleft != null):
			if(topleft.is_in_group("orb")):
				if((topleft.colour == searchcolour or topleft.colour == COLOUR.GREY) and !topleft.isexcluded):
					if(!group.has(topleft)):
						group.push_back(topleft)
				if(!topleft.isexcluded):
					topleft.ChargeSearch(level, searchcolour, group)
		if(topright != null):
			if(topright.is_in_group("orb")):
				if(topright.colour == searchcolour or topright.colour == COLOUR.GREY) and !topright.isexcluded:
					if(!group.has(topright)):
						group.push_back(topright)
				if(!topright.isexcluded):
					topright.ChargeSearch(level, searchcolour, group)
		if(left != null):
			if(left.is_in_group("orb")):
				if(left.colour == searchcolour or left.colour == COLOUR.GREY) and !left.isexcluded:
					if(!group.has(left)):
						group.push_back(left)
				if(!left.isexcluded):
					left.ChargeSearch(level, searchcolour, group)
		if(right != null):
			if(right.is_in_group("orb")):
				if(right.colour == searchcolour or right.colour == COLOUR.GREY) and !right.isexcluded:
					if(!group.has(right)):
						group.push_back(right)
				if(!right.isexcluded):
					right.ChargeSearch(level, searchcolour, group)
		if(bottomleft != null):
			if(bottomleft.is_in_group("orb")):
				if(bottomleft.colour == searchcolour or bottomleft.colour == COLOUR.GREY) and !bottomleft.isexcluded:
					if(!group.has(bottomleft)):
						group.push_back(bottomleft)
				if(!bottomleft.isexcluded):
					bottomleft.ChargeSearch(level, searchcolour, group)
		if(bottomright != null):
			if(bottomright.is_in_group("orb")):
				if(bottomright.colour == searchcolour or bottomright.colour == COLOUR.GREY) and !bottomright.isexcluded:
					if(!group.has(bottomright)):
						group.push_back(bottomright)
				if(!bottomright.isexcluded):
					bottomright.ChargeSearch(level, searchcolour, group)
		return group


func Charge():
	#this bool signals that the yellow ability was activated for this orb
	charged = true

func EnableLauncher():
	#the launcher will not fire until the last orb is on the board. This enables the launcher.
	if(player == PLAYER.PLAYER1):
		get_parent().get_node("p1launcher").Enable()
	elif(player == PLAYER.PLAYER2):
		get_parent().get_node("p2launcher").Enable()

func Warp(spot):
	trajectory *= -1
	set_pos(spot)
	warped = true
	if(onboard == PLAYER.PLAYER1):
		onboard = PLAYER.PLAYER2
	elif(onboard == PLAYER.PLAYER2):
		onboard = PLAYER.PLAYER1
	if(is_colliding()):
		#print("Died in the warp")
		MovingDie()

func PrintNeighbors():
	print(str(get_global_pos()))
	print(str(get_pos() - get_parent().get_node("p2launcher").get_global_pos()))
	print(str(self.get_name()) + " " + str(self))
	print("Colour: " + str(colour))
	print("touching wall left: " +str(touchingwallleft) + " touching wall right: " + str(touchingwallright))
	if(topleft != null):
		var s = ""
		s += "topleft: " + str(topleft) + " " + topleft.get_name()
		if(topleft.is_in_group("orb")):
			s += (" Colour: " + str(topleft.colour) + " isexcluded = " + str(topleft.isexcluded))
		print(s)
	else:
		print("topleft: " + "null")
	if(topright != null):
		var s = ""
		s += "topright: " + str(topright) + " " + topright.get_name()
		if(topright.is_in_group("orb")):
			s += (" Colour: " + str(topright.colour) + " isexcluded = " + str(topright.isexcluded))
		print(s)
	else:
		print("topright: " + "null")
	if(left != null):
		var s = ""
		s += "left: " + str(left) + " " + left.get_name()
		if(left.is_in_group("orb")):
			s += " Colour: " + str(left.colour) + " isexcluded = " + str(left.isexcluded)
		print(s)
	else:
		print("left: " + "null")
	if(right != null):
		var s = ""
		s += "right: " + str(right) + " " + right.get_name()
		if(right.is_in_group("orb")):
			s += " Colour: " + str(right.colour) + " isexcluded = " + str(right.isexcluded)
		print(s)
	else:
		print("right: " + "null")
	if(bottomleft != null):
		var s = ""
		s += "bottomleft: " + str(bottomleft) + " " + bottomleft.get_name()
		if(bottomleft.is_in_group("orb")):
			s += " Colour: " + str(bottomleft.colour) + " isexcluded = " + str(bottomleft.isexcluded)
		print(s)
	else:
		print("bottomleft: " + "null")
	if(bottomright != null):
		var s = ""
		s += "bottomright: " + str(bottomright) + " " + bottomright.get_name()
		if(bottomright.is_in_group("orb")):
			s += " Colour: " + str(bottomright.colour) + " isexcluded = " + str(bottomright.isexcluded)
		print(s)
	else:
		print("bottomright: " + "null")
	print("")
	

func _on_orb_mouse_enter():
	pass
	PrintNeighbors()
#	var group = []
#	group = Search(5,colour,group,true)
#	
#	print("starting listing")
#	if group.size() > 0:
#		for orb in group:
#			print(orb.get_name() + " with colour " + str(orb.colour))
#	print("done listing")
#	print( SearchFor(3,colour,get_parent().p2flag))
#	
#	print("EXCLUDE ON")
#	print(SearchFor(3,colour,get_parent().p2flag,true))
#	
#	print("")



#	if istouchingtop:
#		print("its good")
#	PrintNeighbors()

func DoCasts():
	#raycasts to local neighboring positions to find neighboring orbs and then hooks them up
	ray.set_cast_to(ltopleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		topleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomright = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	ray.set_cast_to(lleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		left = ray.get_collider()
		if(left != null):
			if(left.is_in_group("wall")):
				touchingwallleft = true
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().right = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	ray.set_cast_to(lbottomrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		bottomright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topleft = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	
	ray.set_cast_to(ltoprightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		topright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomleft = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
			
	ray.set_cast_to(lbottomleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		bottomleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topright = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
			
	ray.set_cast_to(lrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		right = ray.get_collider()
		if(right != null):
			if(right.is_in_group("wall")):
				touchingwallright = true
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().left = self
		if(ray.get_collider().is_in_group("flag")):
			istouchingflag = true
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)

func Sparkle():
	get_node("sparkles").set_emitting(true)

func StopSparkle():
	get_node("sparkles").set_emitting(false)


func WentOverDeathLine(): # check to see if an orb is lower than y = 1000, which would put it right next to the launcher
	return get_global_pos().y >= 930

func SignalGameOver(): #used when an orb goes over the death line
	var s;
	var k;
	if(player == PLAYER.PLAYER1):
		s = "Player 2 Wins"
		k = PLAYER.PLAYER2
	else:
		s = "Player 1 Wins"
		k = PLAYER.PLAYER1
	get_parent().GameOver(s,k)

func BecomeEthereal():
	set_layer_mask_bit(0,false)
	set_collision_mask_bit(0,false)

func PathToTop(crossreforbs):
	crossreforbs.push_back(self)
	if(topleft != null and !topleft.is_in_group("wall")):
		#print("topleft")
		if(!crossreforbs.has(topleft)):
			if(topleft.is_in_group("top") or (!topleft.is_in_group("top") and topleft.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on topleft")
				if(topleft.is_in_group("orb")):
					topleft.timespathedupon += 1
				return true
	if(topright != null and !topright.is_in_group("wall")):
		#print("topright")
		if(!crossreforbs.has(topright)):
			if(topright.is_in_group("top") or (!topright.is_in_group("top") and topright.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on topright")
				if(topright.is_in_group("orb")):
					topright.timespathedupon += 1
				return true
	if(left != null and !left.is_in_group("wall")):
		#print("left")
		if(!crossreforbs.has(left)):
			if(left.is_in_group("top") or (!left.is_in_group("top") and left.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on left")
				if(left.is_in_group("orb")):
					left.timespathedupon += 1
				return true
	if(right != null and !right.is_in_group("wall")):
		#print("right")
		if(!crossreforbs.has(right)):
			if(right.is_in_group("top") or (!right.is_in_group("top") and right.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on right")
				if(right.is_in_group("orb")):
					right.timespathedupon += 1
				return true
	if(bottomleft != null and !bottomleft.is_in_group("wall")):
		#print("bottomleft")
		if(!crossreforbs.has(bottomleft)):
			if(bottomleft.is_in_group("top") or (!bottomleft.is_in_group("top") and bottomleft.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on bottomleft")
				if(bottomleft.is_in_group("orb")):
					bottomleft.timespathedupon += 1
				return true
	if(bottomright != null and !bottomright.is_in_group("wall")):
		#print("bottomright")
		if(!crossreforbs.has(bottomright)):
			if(bottomright.is_in_group("top") or (!bottomright.is_in_group("top") and bottomright.PathToTop(crossreforbs))):
				#print(str(get_name()) + " found top on bottomright")
				if(bottomright.is_in_group("orb")):
					bottomright.timespathedupon += 1
				return true
				
	return false


func spawnFallOrb():
	var fallorb = load("res://test/scenes/fallorb2.tscn").instance()
	get_parent().add_child(fallorb)
	fallorb.set_global_pos(get_global_pos())
	fallorb.changeColour(colour)
	fallorb.setRot(get_node("Sprite").get_rot())