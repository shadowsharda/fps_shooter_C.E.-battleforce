extends Area
enum {
	idle,
	alert,
	shooting
	patrol,
	reload,
	crouch
	
}
signal shooting
var state:=idle
var target=null

# Declare member variables here. Examples:
const speed:int = 2
const angular_speed:float= PI/2
const max_health:int=100
var health:int
var direction:int=0
var left:int=0
var walking:bool=false
var player_detected:bool=false
#aiming related variables
var required_rotation_angle:float=rotation_degrees.y
var required_rotation_in_redian:float
export var look_sen:float=3.0
#rotatating=false
#rotatating=fals
var left_and_right_decider_raycast_right_raycast_colliding_bool_value:bool=false
var left_and_right_decider_raycast_left_raycast_colliding_bool_value:bool=false
# var player_movement_detector:Area=$"opponent_commando/player_movemnent detector"
onready var floor_check_raycast:RayCast=$RayCast
onready var degree_rotate_ninty_timer:Timer=$rotate_Timer_90
onready var eyes_spatial:Spatial=$eyes_spatial
onready var eyes_spatial_raycast:RayCast=$eyes_spatial/eyes_spatial_RayCast2
onready var opponent_commando:KinematicBody=$opponent_commando
onready var left_and_right_decider_raycast_left_raycast=$left_and_right_decider_raycast/left_raycast
onready var left_and_right_decider_raycast_right_raycast=$left_and_right_decider_raycast/right_raycast
#boiler_plate_function_not called_anywhere in the game
func check_walls(wall_check_raycast_intake:RayCast)->void:
	var collider
	var check:bool
	check=wall_check_raycast_intake.is_colliding()
	if check==false:
		pass
	if check==true:
		#rotatating=false
		collider = wall_check_raycast_intake.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player")==true:
			pass
		else:
			pass

	if collider==null:
		pass
		#emit_signal("dont_shoot"
func floor_defining_function(move_intake:float=10.0)->float:

	var check_collision:bool
	var collider
	check_collision=floor_check_raycast.is_colliding()
	if check_collision==true:
		collider=floor_check_raycast.get_collider()
		if collider.name=="CSGCombiner"||collider.is_in_group("floor"):
			move_intake=0.0
	if check_collision==false:
		move_intake=10.0
	return move_intake
func opponent_detecting_function():
	print_debug("PLAYER_DETECTING_FUNCTION CALLED")
	var collider
	var check:bool
	check=eyes_spatial_raycast.is_colliding()
	if check==false:
		state=idle
	if check==true:
		#rotatating=false
		collider = eyes_spatial_raycast.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("player_standing")||collider.is_in_group("player_crouching")||collider.name=="newplayer"||collider.is_in_group("Player"):
			print_debug("PLAYER_DETECTED")
			target=collider
			player_detected=true
			
		else:
			state=idle

	if collider==null:
		pass
# Called when the node enters the scene tree for the first time.
func _ready():
	health=max_health
	set_physics_process(true)
	floor_check_raycast.enabled=true
# warning-ignore:return_value_discarded
	degree_rotate_ninty_timer.connect("timeout",self,"degree_rotate_ninty_timer_timeout")
	left_and_right_decider_raycast_left_raycast.enabled=true
	left_and_right_decider_raycast_right_raycast.enabled=true
func take_damage(amount:int)->void:
	health = health-amount
	#emit_signal("health_changed",health)
	#heath_label.set_text(str(health))
	health= int(clamp(health,0,max_health))
	if health==0:
		explode()
func explode()->void:
	queue_free()

func function_left_and_right_decider_raycast_left_raycast()->void:

	var check:bool
	check=left_and_right_decider_raycast_left_raycast.is_colliding()
	if check==false:
		left_and_right_decider_raycast_right_raycast_colliding_bool_value=false
	if check==true:
		left_and_right_decider_raycast_right_raycast_colliding_bool_value=true
		#rotatating=false
func function_left_and_right_decider_raycast_right_raycast()->void:

	var check:bool
	check=left_and_right_decider_raycast_right_raycast.is_colliding()
	if check==false:
		left_and_right_decider_raycast_left_raycast_colliding_bool_value=false
	if check==true:
		left_and_right_decider_raycast_left_raycast_colliding_bool_value=true
		#rotatating=false

func commando_sensors_active(Body:PhysicsBody)->void:
	print(Body.name)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if left_and_right_decider_raycast_left_raycast.enabled==true:
		function_left_and_right_decider_raycast_left_raycast()
	if left_and_right_decider_raycast_right_raycast.enabled==true:
		function_left_and_right_decider_raycast_right_raycast()
	if eyes_spatial_raycast.enabled==true:
		opponent_detecting_function()
	if player_detected==true:
		state=shooting
		eyes_spatial_raycast.set_deferred("enabled",false)
		print("player_detected")
	if walking==true:
		set_physics_process(true)
	#player movement code
		var velocity:Vector3
		var move:Vector3

		rotation.y = rotation.y+(angular_speed*direction*delta)
		velocity= Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y)

		#velocity.y=velocity.y-2.0
	#rotation=Vector3(1,1,1)
		move=velocity*speed*delta
		#move.y=move.y-10.0
		#move=move_and_slide(move,Vector3.UP)
		if floor_check_raycast.enabled==true:
			move.y=floor_defining_function(move.y)
		translation.x=translation.x+move.x
		translation.z=translation.z+move.z
		translation.y=translation.y-(move.y*delta)
		#player movement code end
	else:
		var move:float=0.0
		if floor_check_raycast.enabled==true:
			move=floor_defining_function(move)
			translation.y=translation.y-(move*delta)
	
	match state:
		idle:
			printraw("idle_state")
			#applying gravity
			var falling_gravity:float
			falling_gravity=floor_defining_function(falling_gravity)
			translation.y=translation.y-(falling_gravity*delta)
			#reseting_aim
			opponent_commando.rotation.y=lerp_angle(opponent_commando.rotation.y,0,delta*look_sen)
		alert:
			print("state_is_alrert")
			eyes_spatial_raycast.set_deferred("enabled",true)
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			

			#rotate_y(deg2rad(eyes_spatial.rotation.y*-2))

		shooting:
			walking=false
			print_debug("state_is_shooting")
			emit_signal("shooting")
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			required_rotation_angle=eyes_spatial.rotation.y
			required_rotation_in_redian=deg2rad(required_rotation_angle)
			opponent_commando.rotation.y=lerp_angle(opponent_commando.rotation.y,required_rotation_angle,delta*look_sen)

func _on_player_movemnent_detector_body_entered(body: Node) -> void:
	print(body.name)



func _on_wall_check_area_body_entered(body: Node) -> void:
	if body.is_in_group("world")==true||body.name=="CSGCombiner"==true:
		print("body entered")

		if left_and_right_decider_raycast_left_raycast_colliding_bool_value==true:
			print_debug("dir =1")
			
			direction=1
			left=1
			print(direction)
			degree_rotate_ninty_timer.start()
		if left_and_right_decider_raycast_right_raycast_colliding_bool_value==true:
			print_debug("dir=-1")
			print(direction)
			direction=-1
			left=-1
			print(direction)
			degree_rotate_ninty_timer.start()
		if left_and_right_decider_raycast_left_raycast_colliding_bool_value==false&&left_and_right_decider_raycast_right_raycast_colliding_bool_value==false:
			direction=1
			degree_rotate_ninty_timer.start()
		if left_and_right_decider_raycast_left_raycast_colliding_bool_value==true&&left_and_right_decider_raycast_right_raycast_colliding_bool_value==true:
			direction=2
			degree_rotate_ninty_timer.start()
		
		#degree_rotate_ninty_timer.start()
func degree_rotate_ninty_timer_timeout()->void:
	print("timer_function_connected")
	left=0
	direction=0


func _on_player_movemnent_detector_area_entered(area:Area)->void:
	if area.is_in_group("unsilenced_bullet_area"):
		walking=true
		if state==shooting:
			walking=false
		set_physics_process(true)
	if area.is_in_group("player_standing"):
		print_debug("player_standing_detected")
		walking=false
		state=alert
		target=area
func _on_field_of_view_Area_area_entered(_area: Area) -> void:
	pass # Replace with function body.


func _on_player_movemnent_detector_area_exited(area: Area) -> void:
	if area.is_in_group("player_standing"):
		print_debug("player_exit")
		state=idle
		


func _on_Area_area_entered(area: Area) -> void:
	if area.is_in_group("bullet"):
		take_damage(area.current_damage)
