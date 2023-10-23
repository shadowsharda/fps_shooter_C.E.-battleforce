extends Spatial
var look_sen:float=0.6
var required_rotation_angle:float=rotation_degrees.y
var required_rotation_in_redian:float

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target
enum {
	idle,
	alert,
	shooting
	patrol,
	reload,
	crouch
	
}

var state:=idle
onready var eyes_spatial:Spatial=$eyes
onready var opponent_body=$body
onready var raycast1:RayCast=$body/raycast_collection/RayCast1
onready var animation_player:AnimationPlayer=$"body/human (13th copy)/AnimationPlayer"
# Called when the node enters the scene tree for the first time.
#func _ready():
	#remove_child(eyes_spatial)
func _on_sight_range_body_exited(_body):
	pass # Replace with function body.


func _on_sight_range_body_entered(_body:PhysicsBody):
	pass # Replace with function body.
func _on_sight_range_area_entered(area:Area):
	if area.is_in_group("player_standing"):
		state=alert
		target=area

func raycast_check_for_collision()->void:
	if raycast1.is_colliding()==true:
		state=alert
	if raycast1.is_colliding()==false:
		state=idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if raycast1.enabled==true:
		raycast_check_for_collision()
	match state:
		idle:
			animation_player.play("idle_loop")
		alert:
			animation_player.play("run_loop")
			eyes_spatial.look_at(target.global_transform.origin,Vector3.UP)
			#rotate_y(deg2rad(eyes_spatial.rotation.y*-2))
			required_rotation_angle=eyes_spatial.rotation.y
			required_rotation_in_redian=deg2rad(required_rotation_angle)
			opponent_body.rotation.y=lerp_angle(opponent_body.rotation.y,required_rotation_angle,delta*look_sen)
		reload:
			animation_player.play("crouch")
			








func _on_sight_range_area_exited(_area):
	pass # Replace with function body.
