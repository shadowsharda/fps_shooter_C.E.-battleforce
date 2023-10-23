extends KinematicBody

#var shoot:bool=false
#var shoot_stop:bool
signal fire
signal dont_shoot

# Declare member variables here. Examples:
# var a = 2
var new_target
var suspicious_target
const angular_speed:float= PI/4
var direction:int=0
#var check:bool

#var rotatating:bool

var left:int=1

const speed:int=50
var health:int
const max_health:int=100
var move_to_target:bool
var _distancetotal:float
var _distance:float
var stand:bool=false

# Called when the node enters the scene tree for the first time. # Replace with function body.
onready var eyes_spatial:Spatial=$eyes_Spatial
onready var eyes_spatial_raycast:RayCast=$eyes_Spatial/eyes_spatial_RayCast
onready var raycast:RayCast=$RayCast
onready var alert_timer_180:Timer=$alert_timer
onready var check_wall_raycast:RayCast=$check_wall_raycast
onready var degree_rotate_360:Timer=$degree_rotate360
onready var degree_rotate_90:Timer=$degree_rotate90
enum {idle, alert,extra_idle,shooting,scan_and_shoot}
var opponent_commando_state_machine=extra_idle
onready var bullet_dectector_area:CollisionShape=$Player_Area_detector/CollisionShape
onready var left_area_collision_shape:CollisionShape=$left_Area/CollisionShape
onready var right_area_collision_shape:CollisionShape=$right_Area2/CollisionShape


func take_damage(amount:int)->void:
	health = health-amount
	#emit_signal("health_changed",health)
	#heath_label.set_text(str(health))
	health= int(clamp(health,0,max_health))
	if health==0:
		explode()
func explode()->void:
	queue_free()
func _ready():
	$degree_rotate90.set_paused(true)
	health=max_health
	eyes_spatial.set_as_toplevel(true)
	degree_rotate_360.set_paused(true)

func _on_Timer_timeout():
	direction=0
	#check=true
	$Timer.stop()

func _on_Timer2_timeout():
	direction=0
	print("rotated 360")
	$Player_Area_detector/CollisionShape.set_deferred("disabled",false)
	print("area_enabled")
	raycast.enabled=false
	check_wall_raycast.enabled=true
	left=1
	#rotatating=true
	#check=true
	alert_timer_180.stop()

#func check_left_raycast()->void:
	#if raycast_left.is_colliding():
		#var collider=raycast_left.get_collider()
		#if collider.is_in_group("Player"):
			#left=-1
			#print(left)
	#if target==null:
		#left=1
		#print(left)
	

func check_collision_raycast()->void:
	var collider
	var check:bool
	check=raycast.is_colliding()
	if check==false:
		
		emit_signal("dont_shoot")
	#if direction==1:
		#raycast_left.enabled=true
	#if direction==0:
		#raycast_left.enabled=false

	
	if check==true:
		#rotatating=false
		collider = raycast.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player"):
			
			degree_rotate_360.set_paused(true)
			#enables this area for better aim
			left_area_collision_shape.set_deferred("disabled",false)
			right_area_collision_shape.set_deferred("disabled",false)
			
			#$player_detector/CollisionShape.disabled=false
			direction=0
			#shoot=true
			emit_signal("fire")
			
			#left_attack=false
			#print("left_attack_off")
			#speed=0
			#print("player_detected")
		else:
			
			emit_signal("dont_shoot")
			#if !collider.is_in_group("Player"):
			direction=1
	if collider==null:
		emit_signal("dont_shoot")
		direction=1
		
			#speed=50
			#$bullet_dectector/CollisionShape.disabled=true
		
	#if raycast.is_colliding()==false:
		#direction=1
		#speed=20
		#$Timer.start()
	##direction=1
		#rotatating=true
		#alert_timer_180.start()\
func check_if_player_behind_wall(wall_check_raycast_intake:RayCast)->void:
	var collider
	var check
	check=wall_check_raycast_intake.is_colliding()
	if check==false:
		pass
	if check==true:
		#rotatating=false
		collider = wall_check_raycast_intake.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player")==true:
			#not_behind_wall=true

			print("player_detected")
		else:
			pass

	if collider==null:
		pass
		#emit_signal("dont_shoot")

func _on_ground_check_body_entered(body):
	#print_debug(body.name)
	if body.is_in_group("Player"):
		print("body entered player")
		eyes_spatial_raycast.set_deferred("enabled",false)
		opponent_commando_state_machine=scan_and_shoot
	direction=1
	#$left_Area/CollisionShape.set_deferred("disabled")
	#rotatating=true
	$Timer.start()

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	eyes_spatial.translation.x=translation.x
	eyes_spatial.translation.y=translation.y
	eyes_spatial.translation.z=translation.z
	if eyes_spatial_raycast.enabled==true:
		eyes_spatial_raycast_check_collsion_fuction()
	match opponent_commando_state_machine:
		idle:
			#print_debug("opponent guard idle state")
			move_to_target=false
			raycast.enabled=false
			#direction should not be set to zero from here
			left_area_collision_shape.set_deferred("disabled",true)
			right_area_collision_shape.set_deferred("disabled",true)
			eyes_spatial.rotation=Vector3(0,0,0)
			eyes_spatial_raycast.set_deferred("enabled",false)
		extra_idle:
			move_to_target=false
			stand=false
			eyes_spatial_raycast.set_deferred("enabled",false)
			eyes_spatial.rotation=Vector3(0,0,0)
		alert:
			stand=false
			eyes_spatial_raycast.set_deferred("enabled",true)
			eyes_spatial.look_at(suspicious_target.global_transform.origin,Vector3.UP)
		shooting:
			raycast.enabled=true
			direction=1
			move_to_target=true
			stand=false
			new_target=suspicious_target
			eyes_spatial.look_at(suspicious_target.global_transform.origin,Vector3.UP)
		scan_and_shoot:
			eyes_spatial_raycast.set_deferred("enabled",false)
			#print_debug("opponent commando state is scan and shoot")
			raycast.enabled=true
			direction=1
			new_target=null
			move_to_target=false
			stand=true
			

	if check_wall_raycast.enabled==true:
		check_wall_raycast_function(delta)


	if raycast.enabled==true:
		check_collision_raycast()
	#if raycast_left.enabled==true:
		#check_left_raycast()
	if new_target==null:
	#var direction:int=1
		var velocity:Vector3
		var move:Vector3
		rotation.y = rotation.y+(angular_speed*direction*delta*left)
		velocity= Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y)
		#velocity.y=velocity.y-2.0
	#rotation=Vector3(1,1,1)
		
		if stand==true:
			print_debug("stand is true")
			velocity=Vector3(0.0,0.0,0.0)
			move=velocity*speed*delta*left
		else:
			velocity= Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y)
			move=velocity*speed*delta*left
			#velocity=move_and_slide(velocity,Vector3.UP)
			#rotation.y = rotation.y+(angular_speed*direction*delta*left)
		
		move.y=move.y-10.0
		move=move_and_slide(move,Vector3.UP)
	if move_to_target==true && new_target:
		#rotation.y=lerp(rotation.y,0,0.1)
		#rot=(target.transform.origin-transform.origin).normalized()
		#rotation_degrees=rotation_degrees.linear_interpolate(rot,0.3*delta)
		#rotation_degrees.y=rot.y
		#rotation_degrees.x=rot.x
		#rotation_degrees.z=rot.z
		#velocity= Vector3(0,1,0).rotated(Vector3(0,1,0),rot.y)
		#var move1=rot*speed*delta
		#move1=move_and_slide(move1,Vector3.UP)
		
		#rotation_degrees=(global_transform.basis.linear_interpolate(target.global_transform.basis,0.1)).g
		#look_at(target.global_transform.origin,Vector3.UP)
			#var target_direction:Vector2=((target.global_transform.origin-global_transform.origin).normalized()).angle()
			#var current_direction:Vector3= Vector3(1,0,0)
			#rotation_degrees=current_direction.linear_interpolate(target_direction,turret_speed*delta).angle()
			#direction=lerp_angle(rotation.y,target.rotation.y,0.3)
			#rotation_degrees=ro
	#check_left_raycast()
	#check_right_raycast()
		#var velocity:Vector3
		
		var direction1:Vector3
		var move:Vector3
		#var ads:float=0.3
		
		#velocity= Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y)
		direction1=(new_target.global_transform.origin-self.global_transform.origin).normalized()
		#angle=deg2rad(direction1.y)
		#rotate(Vector3(0,1,0),direction1.y*delta)
		
		rotation.y = rotation.y+(angular_speed*direction*delta*left)
		#rotation.y=lerp(rotation.y,angle,angular_speed*delta)
		#velocity= Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y)
		move=direction1*speed*delta
		move.y=move.y-10.0
		move=move_and_slide(move,Vector3.UP)

		

	
func check_wall_raycast_function(delta)->void:
	#var distance:float=0
	#var speed1:int=50
	#total_distance=total_distance+distance
	if check_wall_raycast.is_colliding():
		$degree_rotate90.set_paused(false)
		#distancetotal=0
		#check_wall_raycast.enabled=false
	if !check_wall_raycast.is_colliding():
		_distance=speed*delta
		#print("not_colliding")
		_distancetotal=_distancetotal+_distance
		print(str(_distancetotal))
		if _distancetotal>1000.0:
			print(str(_distancetotal))
			$degree_rotate90.set_paused(false)
			direction=1

#func _on_player_detector_body_entered(body):
	#if body.is_in_group("Player"):
		#direction=0
		#target=body
	#print(body.name +"'entered")

#func _on_right_player_detector2_body_entered(body):
	 # Replace with function body.
	#if body.is_in_group("Player"):
		#direction=-1
#func _on_Player_Area_detector_area_entered(area):
	#if area.is_in_group("player_area"):
		#target=area
		#raycast.enabled=true
func _on_Player_Area_detector_body_entered(body):
	 # Replace with function body.
	if body.is_in_group("Player"):
		#target=body
		raycast.enabled=true
		$Player_Area_detector/CollisionShape.set_deferred("disabled",true)
		print("area_disabled")
		direction=1
		alert_timer_180.start()
		


#func _on_Player_Area_detector_body_exited(body):
	#if body.is_in_group("Player"):
		#target=null
		#print("player_away")
	 # Replace with function body.
		#raycast.enabled=false
		#raycast_left.enabled=false
		#direction=1
		#alert_timer_180.start()

#aiming assistance

func _on_left_Area_area_entered(area):
	if area.is_in_group("player_standing")||area.is_in_group("player_crouching"):
		left=-1
		print("detected")

#aiming assistance

func _on_left_Area_area_exited(area):
	# Replace with function body.
	if area.is_in_group("player_standing")||area.is_in_group("player_crouching"):
		left=-1
		print("detected_exit")

#aiming assistance
func _on_right_Area2_area_entered(area):
	 # Replace with function body.
	if area.is_in_group("player_standing")||area.is_in_group("player_crouching"):
		left=1
		print("detected_left")

#aiming assistance

func _on_right_Area2_area_exited(area):
	 # Replace with function body.
	if area.is_in_group("player_standing")||area.is_in_group("player_crouching"):
		left=1
		print("detected_right")


#aiming assistance
func _on_degree_rotate90_timeout():
	check_wall_raycast.enabled=false
	direction=0
	_distancetotal=0
	#check_wall_raycast.enabled=true
	
	$degree_rotate90.set_paused(true)


func _on_bullet_dectector_area_entered(area):
	if area.is_in_group("bullet"):
		#direction=1
		#raycast.enabled=true
		opponent_commando_state_machine=scan_and_shoot
		bullet_dectector_area.set_deferred("disabled",true)
		degree_rotate_360.set_paused(false)

func _on_degree_rotate360_timeout():
	opponent_commando_state_machine=idle
	#raycast.enabled=false
	direction=0
	
	bullet_dectector_area.set_deferred("disabled",false)
	degree_rotate_360.set_paused(true)


func _on_Player_Area_detector_area_entered(area):
	if area.is_in_group("player_standing"):
		opponent_commando_state_machine=alert
		suspicious_target=area
		#raycast.enabled=true
		#line commented to debug
		#$Player_Area_detector/CollisionShape.set_deferred("disabled",true)
		print("area_disabled")
		#direction=1
		#alert_timer_180.start()
	if area.is_in_group("player_crouching"):
		opponent_commando_state_machine=alert
		suspicious_target=area
		#wall_check_raycast_enable_function()
		
func eyes_spatial_raycast_check_collsion_fuction()->void:
	var collider:Spatial
	var check:bool
	check=eyes_spatial_raycast.is_colliding()
	if check==false:
		opponent_commando_state_machine=idle
		
	if check==true:
		#rotatating=false
		collider = eyes_spatial_raycast.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player"):
			
			#print_debug("state must switch to shooting")
			
			opponent_commando_state_machine=shooting

			
			
		else:
			opponent_commando_state_machine=idle

	if collider==null:
		pass
		#emit_signal("dont_shoot")




