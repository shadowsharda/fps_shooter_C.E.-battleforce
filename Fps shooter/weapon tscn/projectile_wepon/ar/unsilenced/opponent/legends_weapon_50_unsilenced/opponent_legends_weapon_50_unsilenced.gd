
extends Spatial
class_name basic_opponent_weapons_script

const carpanter_unsilenced_bullet=preload("res://bullets/lmg_bullets/unsilenced_lmg_bullets/carpanter150_unsilenced_bullet/carpanter150_unsilenced_bullet.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var firerate_timer:Timer=$fire_rate_interval_Timer
onready var Postion_barrel:Position3D=$MeshInstance/barrel_Position3D


# Called when the node enters the scene tree for the first time.
func _ready():
	firerate_timer.set_paused(true)
	firerate_timer.autostart=true
	firerate_timer.connect("timeout",self,"_on_firerate_Timer_timeout")
 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_opponent_lmg_guy_fire():
		firerate_timer.set_paused(false)
		print("shooting")

func _on_firerate_Timer_timeout():
	var b=carpanter_unsilenced_bullet.instance()
	b.rotation_degrees=Postion_barrel.global_transform.basis.get_euler()
	#current_ammo=current_ammo-1
	#head.rotation.x =head.rotation.x+deg2rad(0.125)
	Postion_barrel.add_child(b)


func _on_opponent_lmg_guy_dont_shoot():
	firerate_timer.set_paused(true) 


func _on_opponent_commando_shooting():
	firerate_timer.set_paused(false)
	print("shooting")

func _on_fire_rate_timer_timeout() -> void:

	print_debug("timer")
	var b=carpanter_unsilenced_bullet.instance()
	b.rotation_degrees=Postion_barrel.global_transform.basis.get_euler()
	#current_ammo=current_ammo-1
	#head.rotation.x =head.rotation.x+deg2rad(0.125)
	Postion_barrel.add_child(b)
