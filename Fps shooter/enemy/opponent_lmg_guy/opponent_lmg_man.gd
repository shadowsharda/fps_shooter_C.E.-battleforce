extends KinematicBody
var health:int
const max_health:int=100

var target:Spatial
var not_behind_wall:bool=false
var move_to_target_bool:bool=false
signal fire
signal dont_shoot
onready var alert_timer:Timer=$alert_timer
onready var sound_detection_collision_shape:CollisionShape=$sound_detection_area/CollisionShape
onready var cooldown_timer:Timer=$cooldown_timer
onready var bullet_detector_collisionshape:CollisionShape=$bullet_detector/bullet_detector
#variable will get current world nodetor_CollisionShape
#var space_state
export var speed:int=50
var look_sen:float=2.0
var movevel:Vector3=Vector3(0,0,0)
const angular_speed:float=PI/4
#const bullet= preload("res://bullets/lmgV1_bullet/lmgV1.tscn")

#value equals to 1 will rotate left value equal to -1 will rotate right value equal to 0 will stop rotation
var rotation_left_and_right_handeler:int=0
var unsilenced_bullet_detectedorheard:bool=false
enum {idle, alert,extra_idle,shooting}
var state_machine=extra_idle
onready var eyes_spatial:Spatial=$eyes_Spatial
onready var eyes_spatial_raycast:RayCast=$eyes_Spatial/RayCast
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
	health=max_health
	eyes_spatial.set_as_toplevel(true)
	alert_timer.set_autostart(true)
	alert_timer.set_paused(true)	
	

func _on_Area_body_entered(body):
	
	if body.is_in_group("Player"):
		target=body
		
		state_machine=alert
		print(body.name +"entered")
		#$Area/CollisionShape.set_deferred("disabled",true)
		bullet_detector_collisionshape.set_deferred("disabled",true)
		sound_detection_collision_shape.set_deferred("disabled",true)
		unsilenced_bullet_detectedorheard=false
		#$fire_Timer.start()
		#set_color_red()
func eyes_spatial_raycast_check_collsion_fuction()->void:
	var collider
	var check:bool
	check=eyes_spatial_raycast.is_colliding()
	if check==false:
		state_machine=idle
		
	if check==true:
		#rotatating=false
		collider = eyes_spatial_raycast.get_collider()
	if collider:
		#print(collider.name)
		
		if collider.is_in_group("Player"):
			not_behind_wall=true
			move_to_target_bool=true
			print("player_detected")
			target=collider
			if self.global_translation.distance_to(target.global_translation)<10:
				move_to_target_bool=false
		else:
			state_machine=idle

	if collider==null:
		pass
		#emit_signal("dont_shoot")


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		print(body.name+"exited")
		
		state_machine=idle
		not_behind_wall=false
		emit_signal("dont_shoot")
		sound_detection_collision_shape.set_deferred("disabled",false)
		bullet_detector_collisionshape.set_deferred("disabled",false)
		alert_timer.set_paused(false)
		target=null
		#wall_check_raycast_disable_function()


#func set_color_red()->void:
	#$body.get_surface_material(0).set_albedo(Color(1,0,0))
#func set_color_green()->void:
	#$body.get_surface_material(0).set_albedo(Color(0,1,0))
func _physics_process(delta):
	eyes_spatial.translation.x=translation.x
	eyes_spatial.translation.y=translation.y
	eyes_spatial.translation.z=translation.z
	
	
	if target&&not_behind_wall==true:
		state_machine=shooting
		emit_signal("fire")
		#alert_timer.stop()
		#print("target_found")
		
		if move_to_target_bool==true:
			move_to_target(delta)
			
			
		#set_color_red()
	else:
		stand(delta)
		#scan_rotation_on_y_axis(delta,rotation_left_and_right_handeler)
	if unsilenced_bullet_detectedorheard==true:
		#rotation_left_and_right_handeler=-1
		scan_rotation_on_y_axis(delta)
	match state_machine:
		extra_idle:
			eyes_spatial_raycast.set_deferred("enabled",false)
			eyes_spatial.rotation=Vector3(0,0,0)
		shooting:
			eyes_spatial_raycast.set_deferred("enabled",true)
			#eyes_spatial.rotation=Vector3(0.0,0.0,0.0)
			bullet_detector_collisionshape.set_deferred("disabled",true)
			sound_detection_collision_shape.set_deferred("disabled",true)
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			movevel=(target.global_transform.origin-self.global_transform.origin).normalized()
			self.rotation.y=lerp_angle(rotation.y,atan2(-movevel.x,-movevel.z),delta*look_sen)
		idle:
			eyes_spatial_raycast.set_deferred("enabled",false)
			eyes_spatial.rotation=Vector3(0,0,0)
			self.rotation.y=lerp_angle(rotation.y,0,delta*angular_speed)
			
		alert:
			eyes_spatial_raycast.set_deferred("enabled",true)
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)


		#print("wall_check+-1")
	if eyes_spatial_raycast.enabled==true:
		eyes_spatial_raycast_check_collsion_fuction()
		








		#print("'''''''''fu2")

func move_to_target(delta)->void:
	var velocity:Vector3
	var direction:Vector3=(target.transform.origin-transform.origin).normalized()
	velocity=direction*speed*delta
	velocity.y=velocity.y-200.0
	velocity=move_and_slide(velocity,Vector3(0,1,0))

func stand(_delta)->void:
	var velocity:Vector3
	#velocity=speed*delta
	velocity.y=velocity.y-200.0
	velocity=move_and_slide(velocity,Vector3(0,1,0))
func scan_rotation_on_y_axis(delta,direction:int=-1)->void:
	#var direction:int=-1
	rotation.y = rotation.y+(angular_speed*direction*delta)





func _on_sound_detection_area_area_entered(area): # Replace with function body.
	if area.is_in_group("unsilenced_bullet_area"):
		sound_detection_collision_shape.set_deferred("disabled",true)
		unsilenced_bullet_detectedorheard=true
		alert_timer.set_paused(false)
		rotation_left_and_right_handeler=-1
		


func _on_alert_timer_timeout():
	print("alert_timer_timeout")
	#sound_detection_collision_shape.set_deferred("disabled",false)
	
	unsilenced_bullet_detectedorheard=false
	alert_timer.set_paused(true)
	cooldown_timer.start()

func _on_bullet_detector_area_entered(area):
	# Replace with function body.
	if area.is_in_group("bullet"):
		bullet_detector_collisionshape.set_deferred("disabled",true)
		#$bullet_detector/bullet_detector_CollisionShape.set_deferred("disabled",true)
		sound_detection_collision_shape.set_deferred("disabled",true)
		unsilenced_bullet_detectedorheard=true
		alert_timer.start()


func _on_cooldown_timer_timeout():
	print("cooldown_complete")
	sound_detection_collision_shape.set_deferred("disabled",false)
	bullet_detector_collisionshape.set_deferred("disabled",false)
	#$bullet_detector/bullet_detector_CollisionShape.set_deferred("disabled",false)
	cooldown_timer.stop()
	




func _on_player_hitting_check_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		move_to_target_bool=false
