extends Spatial
#editable variables

#time between bullets
export var turret_fire_rate_interval:float=0.5
#do not edit if you do not know what you are doing 
# it is recommended to be edited by code
var target:Spatial=null

#signals
signal shoooting_bullets
signal not_shooting_bullets
#signal activate_turret
#state machines variable and enum
enum {
	idle,
	alert,
	shooting,
}

var state:=idle



#onready vars
onready var eyes_raycast:RayCast=$eyes_spatial/RayCast
onready var eyes_spatial:Spatial=$eyes_spatial
onready var turret:KinematicBody=$bunker_guy_Body
#onready var fire_rate_interval_timer:Timer=$fire_rate_Timer
#onready var bullet_spawn_position:Marker2D=$turret_body/bullet_spawn_Marker2D
#generic raycast function for reference .
#no effect on turret code
# please try not to delete.
func check_walls(wall_check_raycast_intake:RayCast2D)->void:
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

func eyes_raycast_collision_check()->void:
	var collider
	var check:bool
	check=eyes_raycast.is_colliding()
	if check==false:
		pass
	if check==true:
		state=shooting
		collider = eyes_raycast.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player")==true:
			state=shooting
		else:
			state=alert

	if collider==null:
		pass
		#emit_signal("dont_shoot"

func _ready() -> void:
	eyes_raycast.enabled=false
	#fire_rate_interval_timer.wait_time=turret_fire_rate_interval
	
	#fire_rate_interval_timer.autostart=true
	#fire_rate_interval_timer.set_paused(true)
	

func _physics_process(delta: float) -> void:
	#if target != null:
		#state=alert
	if eyes_raycast.enabled==true:
		eyes_raycast_collision_check()
	
	match state:
		idle:
			eyes_raycast.enabled=false
			eyes_spatial.rotation.x=0
			eyes_spatial.rotation.y=0
			eyes_spatial.rotation.z=0
			eyes_raycast.rotation.x=0
			eyes_raycast.rotation.y=0
			eyes_raycast.rotation.z=0
			target=null
			emit_signal("not_shooting_bullets")
			
			#fire_rate_interval_timer.set_paused(true)
		alert:
			eyes_raycast.enabled=true
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			emit_signal("not_shooting_bullets")
			#fire_rate_interval_timer.set_paused(true)
		shooting:
			#print_debug("turret state is shooting")
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			turret.rotation.y = lerp_angle(  turret.rotation.y , eyes_spatial.rotation.y , 0.8*delta)
			#fire_rate_interval_timer.set_paused(false)
			emit_signal("shoooting_bullets")
			
			


	


func _on_field_of_view_body_entered(body) -> void:
	if body.is_in_group("Player"):
		print_debug("body entered player bunker guy")
		target=body
		state=alert


func _on_field_of_view_body_exited(body) -> void:
	if body.is_in_group("Player"):
		state=idle
		
		




