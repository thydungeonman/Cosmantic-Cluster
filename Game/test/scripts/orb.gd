extends KinematicBody2D

enum COLOUR {BLACK,BLUE,GREEN,GREY,ORANGE,PURPLE,RED,WHITE,YELLOW}
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

var falling = false

var colour = COLOUR.RED
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
#neighboring orb local positions for raycast Vector2s
onready var ltopleftspot = Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var ltoprightspot = Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var lleftspot = Vector2(-width,0)
onready var lrightspot = Vector2(width ,0)
onready var lbottomleftspot = Vector2(-width,width) * Vector2(1.07337749,1.8417709).normalized()
onready var lbottomrightspot = Vector2(width,width) * Vector2(1.07337749,1.8417709).normalized()

func _ready():
	set_fixed_process(true)
	get_node("Label").set_text(str(get_name()))

func _fixed_process(delta):
	if(ismoving):
		Move(delta)

func GetNeighboringPositions():
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
	move(trajectory * delta)
	if(is_colliding()):
		var collider = get_collider()
		if(collider.is_in_group("wall")):
			trajectory.x *= -1
		elif(collider.is_in_group("roof")):
			trajectory.y *= -1
		elif(collider.is_in_group("orb")):
			if(!collider.ismoving):
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
				elif((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 0 and dotproductwest >= -1)): #collided on bottom right side
					set_pos(collider.bottomrightspot)
					collider.bottomright = self
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 1 and dotproductwest > 0)):#left
					set_pos(collider.leftspot)
					collider.topleft = self
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#right
					set_pos(collider.rightspot)
					collider.topright = self
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 1 and dotproductwest > 0)):#topleft
					set_pos(collider.topleftspot)
					collider.topleft = self
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#topright
					set_pos(collider.toprightspot)
					collider.topright = self
				GetNeighboringPositions()
				GetNeighbors()
				#print(CountNeighbors())
				if(CheckMatch(matchingorbs, leftoverorbs)):
					ActivateAbility()
					for orb in matchingorbs:
						print(orb)
						orb.Unhook()
					for i in leftoverorbs:
						print(i.get_name())
						i.set_opacity(1)
						if i != null:
							print("start")
							var s = i.LookForTop(crossreforbs)
							print("end")
							if s == false:
								for i in crossreforbs:
									i.Unhook()
									i.queue_free()
						crossreforbs.clear()
					for orb in matchingorbs:
						#print(orb)
						orb.Unhook()
						orb.queue_free()
					print("unhooked")
						#if(crossreforbs.has(i)): # if we have already checked this orb
							#continue
						#print(i)
						
						
						
#					for i in crossreforbs:
#						if(i.falling == true):
#							i.Unhook()
#							i.queue_free()


func click():
	var mousepos = get_viewport().get_mouse_pos()
	ray.set_cast_to(mousepos - get_pos())
	print(ray.get_collider())
	#var positiondifference = mousepos - get_pos()
	#positiondifference = positiondifference.normalized()
	#var dotproductnorth = positiondifference.dot(Vector2(0,-1))
	#var dotproductwest = positiondifference.dot(Vector2(-1,0))

func Unhook(): #unhooks an orbs neighbors from itself and then frees the orb
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

func GetNeighbors():
	ray.set_cast_to(ltopleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		topleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomright = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(ltoprightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		topright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().bottomleft = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		left = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().right = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	
	ray.set_cast_to(lbottomleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		bottomleft = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topright = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lbottomrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		bottomright = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().topleft = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		right = ray.get_collider()
		if(ray.get_collider().is_in_group("orb")):
			ray.get_collider().left = self
			ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	

func CheckMatch(matchingorbs, leftoverorbs): #accepts array of kinematic bodies2d
	#this function checks all neighbors to see if any of them are the same colour
	#matching neighbors will check their neighbors and so on until there are no more matches
	#returns true if their are more than three orbs touching with the same colour
	
	var match = false
	matchingorbs.push_front(self)
	if(topleft != null and topleft.is_in_group("orb")):
		if(topleft.colour == self.colour):
			if(!matchingorbs.has(topleft)):
				topleft.CheckMatch(matchingorbs, leftoverorbs)
		else:
			if(!leftoverorbs.has(topleft)):
				leftoverorbs.push_back(topleft)
	if(topright != null and topright.is_in_group("orb")):
			if(topright.colour == self.colour):
				if(!matchingorbs.has(topright)):
					topright.CheckMatch(matchingorbs, leftoverorbs)
			else:
				if(!leftoverorbs.has(topright)):
					leftoverorbs.push_back(topright)
	if(left != null and left.is_in_group("orb")):
		if(left.colour == self.colour):
			if(!matchingorbs.has(left)):
				left.CheckMatch(matchingorbs, leftoverorbs)
		else:
			if(!leftoverorbs.has(left)):
				leftoverorbs.push_back(left)
	if(right != null and right.is_in_group("orb")):
		if(right.colour == self.colour):
			if(!matchingorbs.has(right)):
				right.CheckMatch(matchingorbs, leftoverorbs)
		else:
			if(!leftoverorbs.has(right)):
				leftoverorbs.push_back(right)
	if(bottomleft != null and bottomleft.is_in_group("orb")):
		if(bottomleft.colour == self.colour):
			if(!matchingorbs.has(bottomleft)):
				bottomleft.CheckMatch(matchingorbs, leftoverorbs)
		else:
			if(!leftoverorbs.has(bottomleft)):
				leftoverorbs.push_back(bottomleft)
	if(bottomright != null and bottomright.is_in_group("orb")):
		if(bottomright.colour == self.colour):
			if(!matchingorbs.has(bottomright)):
				bottomright.CheckMatch(matchingorbs, leftoverorbs)
		else:
			if(!leftoverorbs.has(bottomright)):
				leftoverorbs.push_back(bottomright)
	if(matchingorbs.size() >= 3):
		match = true
	return match



#the topmost orbs will neighbor an area that is in the group "top"
func LookForTop(crossreforbs): 
	#this function takes an array or orbs that have already been checked and then checks to see if it has the top as itn neighbor
	#if its neighbor is not the top, that neighbor will then check if it neighbors the top and so on
	crossreforbs.push_back(self)
	if(topleft != null):
		print("topleft")
		if(!crossreforbs.has(topleft)):
			if(topleft.is_in_group("top") or (!topleft.is_in_group("top") and topleft.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on topleft")
				return true
	if(topright != null):
		print("topright")
		if(!crossreforbs.has(topright)):
			if(topright.is_in_group("top") or (!topright.is_in_group("top") and topright.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on topright")
				return true
	if(left != null):
		print("left")
		if(!crossreforbs.has(left)):
			if(left.is_in_group("top") or (!left.is_in_group("top") and left.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on left")
				return true
	if(right != null):
		print("right")
		if(!crossreforbs.has(right)):
			if(right.is_in_group("top") or (!right.is_in_group("top") and right.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on right")
				return true
	if(bottomleft != null):
		print("bottomleft")
		if(!crossreforbs.has(bottomleft)):
			if(bottomleft.is_in_group("top") or (!bottomleft.is_in_group("top") and bottomleft.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on bottomleft")
				return true
	if(bottomright != null):
		print("bottomright")
		if(!crossreforbs.has(bottomright)):
			if(bottomright.is_in_group("top") or (!bottomright.is_in_group("top") and bottomright.LookForTop(crossreforbs))):
				print(str(get_name()) + " found top on bottomright")
				return true
				
	falling = true
	print(str(get_name()) + " did not find top")
	return false


func ActivateAbility():
	pass

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
	return count