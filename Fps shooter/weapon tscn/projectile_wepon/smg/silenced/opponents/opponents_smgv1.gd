extends Spatial

const smgv1_bullet=preload("res://bullets/smg/tmp_smg/smgv1_bullet.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var firerate_timer:Timer=$firerate_timer
onready var Postion_barrel:Spatial=$Position3D


# Called when the node enters the scene tree for the first ti # Replace with function body.
func _ready():
	firerate_timer.set_paused(true)
	#rotation.y =rotation.y+ deg2rad(90)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_firerate_timer_timeout():
		var b=smgv1_bullet.instance()
		b.rotation_degrees=Postion_barrel.global_transform.basis.get_euler()
		#current_ammo=current_ammo-1
		#head.rotation.x =head.rotation.x+deg2rad(0.125)
		Postion_barrel.add_child(b)


func _on_opponent_guard_fire():
	
	firerate_timer.set_paused(false)
	#print("shooting")


func _on_opponent_guard_dont_shoot():
	#use this function to start timer from process function
	#autostart must be true
	#to take effect
	firerate_timer.set_paused(true)
	#print("'not_shooting")
