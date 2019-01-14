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

var charged = false #changes to true if the yellow ability is active

var falling = false

var player = PLAYER.PLAYER1
var colour = COLOUR.NONE

var warped = false #changes to true after sent through a warp

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

func _ready():
	set_fixed_process(true)
	get_node("Label").set_text(str(get_name()))
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
	if(get_pos().y > 1080):
		get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
		EnableLauncher()
		queue_free()
		print("orb went out of bounds")
	if(is_colliding()):
		
		get_parent().get_node("StreamPlayer").play(0)
		
		var collider = get_collider()
		if(collider.is_in_group("wall")):
			trajectory.x *= -1
			get_node("sparkles").set_rotd(get_node("sparkles").get_rotd() *- -1)
		elif(collider.is_in_group("roof")):
			trajectory.y *= -1
		elif(collider.is_in_group("orb")):
			if(collider.inlauncher):
				get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
				EnableLauncher()
				queue_free()
				print("hit launcher orb")
			if(!collider.ismoving and !collider.inlauncher):
				StopSparkle()
				ismoving = false
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
					print("hit top right")
				elif((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 0 and dotproductwest >= -1)): #collided on bottom right side
					set_pos(collider.bottomrightspot)
					collider.bottomright = self
					topleft = collider
					print("hit top left")
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 1 and dotproductwest > 0)):#left
					set_pos(collider.leftspot)
					collider.left = self
					right = collider
					print("hit right")
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#right
					set_pos(collider.rightspot)
					collider.right = self
					left = collider
					print("hit left")
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 1 and dotproductwest > 0)):#topleft
					set_pos(collider.topleftspot)
					collider.topleft = self
					bottomright = collider
					print("hit bottom right")
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#topright
					set_pos(collider.toprightspot)
					collider.topright = self
					bottomleft = collider
					print("hit bottom left")
					
				EnableLauncher()
				GetNeighboringPositions()
				GetNeighbors()
				#print(CountNeighbors())
				var foundmatch = CheckMatch(matchingorbs,leftoverorbs);
				
				if(foundmatch):
					for orb in leftoverorbs:
						if(orb.colour == COLOUR.GREY):
							orb.TakeDamage()
					if(charged):
						var killorbs = []
						for orb in matchingorbs:  #get all of the orbs with the same colour as the match 2 orbs out
							killorbs = orb.Search(2,colour,killorbs)
						var extraleftovers = []
						for orb in matchingorbs:  #remove the original match orbs 
							killorbs.remove(killorbs.find(orb))
						var extraleftovers = []
						for orb in killorbs:
							extraleftovers = orb.Search(1,COLOUR.NONE,extraleftovers)
							orb.Unhook()
							get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
							orb.anim.play("zap")
						for orb in extraleftovers:
							if(!leftoverorbs.has(orb)):
								leftoverorbs.push_back(orb)
					for i in matchingorbs:
						i.Unhook()
						get_parent().orbsonboard.remove(get_parent().orbsonboard.find(i))
					get_parent().leftoverorbs = leftoverorbs
					get_parent().CheckFall()
					
					ActivateAbility()
					
					for orb in matchingorbs:
						print(orb.get_name())
						orb.anim.play("blink")
				else:
					matchingorbs.clear()
					leftoverorbs.clear()


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
	get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
	var leftovers = []
	Search(2,COLOUR.NONE,leftovers)
	print(str(leftovers.size()))
	get_parent().leftoverorbs = leftovers
	self.Unhook()
	get_parent().CheckFall()
	self.queue_free()

func MovingDie():
	get_parent().orbsonboard.remove(get_parent().orbsonboard.find(self))
	EnableLauncher()
	queue_free()


#this function raycasts in each direction, grabbing the closest body and area
#it then casts again only looking for bodies since if the orb is inside of an area it will only detect areas since they are the closest
func GetNeighbors():
	DoCasts()
	ray.set_type_mask(Physics2DDirectSpaceState.TYPE_MASK_KINEMATIC_BODY)
	DoCasts()


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
	if(topleft != null and !topleft.is_in_group("wall")):
		print("topleft")
		if(!crossreforbs.has(topleft)):
			if(topleft.is_in_group("top") or (!topleft.is_in_group("top") and topleft.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on topleft")
				return true
	if(topright != null and !topright.is_in_group("wall")):
		print("topright")
		if(!crossreforbs.has(topright)):
			if(topright.is_in_group("top") or (!topright.is_in_group("top") and topright.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on topright")
				return true
	if(left != null and !left.is_in_group("wall")):
		print("left")
		if(!crossreforbs.has(left)):
			if(left.is_in_group("top") or (!left.is_in_group("top") and left.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on left")
				return true
	if(right != null and !right.is_in_group("wall")):
		print("right")
		if(!crossreforbs.has(right)):
			if(right.is_in_group("top") or (!right.is_in_group("top") and right.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on right")
				return true
	if(bottomleft != null and !bottomleft.is_in_group("wall")):
		print("bottomleft")
		if(!crossreforbs.has(bottomleft)):
			if(bottomleft.is_in_group("top") or (!bottomleft.is_in_group("top") and bottomleft.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on bottomleft")
				return true
	if(bottomright != null and !bottomright.is_in_group("wall")):
		print("bottomright")
		if(!crossreforbs.has(bottomright)):
			if(bottomright.is_in_group("top") or (!bottomright.is_in_group("top") and bottomright.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on bottomright")
				return true
				
	falling = true
	print(str(get_name()) + " did not find top")
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
func Search(level, searchcolour, group):
	level -= 1
	if(level >= 0):
		if(topleft != null):
			if(topleft.is_in_group("orb")):
				if(topleft.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(topleft)):
						group.push_back(topleft)
				topleft.Search(level,searchcolour,group)
		if(topright != null):
			if(topright.is_in_group("orb")):
				if(topright.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(topright)):
						group.push_back(topright)
				topright.Search(level,searchcolour,group)
		if(left != null):
			if(left.is_in_group("orb")):
				if(left.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(left)):
						group.push_back(left)
				left.Search(level,searchcolour,group)
		if(right != null):
			if(right.is_in_group("orb")):
				if(right.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(right)):
						group.push_back(right)
				right.Search(level,searchcolour,group)
		if(bottomleft != null):
			if(bottomleft.is_in_group("orb")):
				if(bottomleft.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(bottomleft)):
						group.push_back(bottomleft)
				bottomleft.Search(level,searchcolour,group)
		if(bottomright != null):
			if(bottomright.is_in_group("orb")):
				if(bottomright.colour == searchcolour or searchcolour == COLOUR.NONE):
					if(!group.has(bottomright)):
						group.push_back(bottomright)
				bottomright.Search(level,searchcolour,group)
		return group


#recursive function that searches outward from a group of orbs one level at a time
#returns all orbs that are a specific colour
func SearchGroup(level, colour, startgroup):
	pass

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
	if(is_colliding()):
		print("Died in the warp")
		MovingDie()

func PrintNeighbors():
	if(topleft != null):
		print("topleft: " + str(topleft) + " " + topleft.get_name())
	else:
		print("topleft: " + "null")
	if(topright != null):
		print("topright: " + str(topright) + " " + topright.get_name())
	else:
		print("topright: " + "null")
	if(left != null):
		print("left: " + str(left) + " " + left.get_name())
	else:
		print("left: " + "null")
	if(right != null):
		print("right: " + str(right) + " " + right.get_name())
	else:
		print("right: " + "null")
	if(bottomleft != null):
		print("bottomleft: " + str(bottomleft) + " " + bottomleft.get_name())
	else:
		print("bottomleft: " + "null")
	if(bottomright != null):
		print("bottomright: " + str(bottomright) + " " +  bottomright.get_name())
	else:
		print("bottomright: " + "null")
	print("")
	
	
	

func _on_orb_mouse_enter():
	PrintNeighbors()

func DoCasts():
	#raycasts to local neighboring positions to find neighboring orbs and then hooks them up
	ray.set_cast_to(ltopleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		topleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomright = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	ray.set_cast_to(lleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		left = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().right = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	ray.set_cast_to(lbottomrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		bottomright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topleft = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
	
	
	ray.set_cast_to(ltoprightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		topright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomleft = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
			
	ray.set_cast_to(lbottomleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		bottomleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topright = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)
			
	ray.set_cast_to(lrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self and !ray.get_collider().is_in_group("warp")):
		right = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().left = self
			#ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .15)

func Sparkle():
	get_node("sparkles").set_emitting(true)
	print("sparkles")
func StopSparkle():
	get_node("sparkles").set_emitting(false)