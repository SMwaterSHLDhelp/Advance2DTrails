tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Advance2DTrail", "Line2D",preload("res://addons/Advance 2D Trails/TrailMaker.gd"), preload("res://addons/Advance 2D Trails/PokemonCrestIcon.png"))
	pass


func _exit_tree():
	remove_custom_type("Advance2DTrail")
	pass
