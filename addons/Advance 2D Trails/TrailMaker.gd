
"""
Author: Jason Robinson
License: MIT
Version: 1.0
Note: Underdevelopment
[Need Support]
Email: jasonrobinson65@gmail.com
Discord: https://discord.gg/YQjuQWe2pZ
"""
extends Line2D

#User inputs
export(String, "Draw", "None") var drawing_type :String = "Draw"
export var behind_parent :bool = true
export var randomize_type :bool = false
export var randomize_effect :bool = false
export(int, 0, 1000) var maximum_points :int = 10
export(String, "Ribbon", "Closing Ribbon", "Spark", "Spark Closest", "", "Direction Point", 'Unlocked Direction Point') var Type = "Ribbon"
var types :Array = ["Ribbon", "Closing Ribbon", "Spark", "Spark Closest", "Direction Point", "Unlocked Direction Point"]
export(String, "None", "Width Bounce", "Rainbow", "Fading") var Effect = "None"
var effects :Array = ["None", "Width Bounce", "Rainbow", "Fading", "Wave"]
export var target_group :String = "null" 
export(float, 0.001, 999) var type_intensity :float = 1.0
export(float, 0.001, 999) var effect_intensity :float = 1.0
export(float, 0.001, 999) var effect_speed :float = 1.0
#Managed
var object_focus = get_parent()

#Closing Ribbon
var R_life_time :float = 0 
#Direction Point
var previous_point :Vector2
var DP_check :float = 0

#Var's for Width bounce
var default_width :float
var max_target_width :float
var W_bounce :int
var W_frame :float
#Rainbow
var R_bounce :int #+ -
var R_frame :float
var R_color_range :float = 1.0
#Fading
var F_bounce :int 
var F_frame :float
var F_alpha_range :float = 1.0
#Rotation
var R_angle : float = 0

func _ready():
	print(points)
	self.clear_points()
	randomize()
	object_focus = get_parent()
	self.show_behind_parent = behind_parent
	if randomize_type:
		Type = shuffle(types)
	if randomize_effect:
		Effect = shuffle(effects)
	
	#Spark Settup
	#Direction Point
	if Type == "Direction Point" or Type == "Unlocked Direction Point":
		self.add_point(object_focus.position, 0)
		self.add_point(object_focus.position, 1)
	#Width Bounce Related
	default_width = self.width
	max_target_width = default_width + effect_intensity
	W_frame = -1
	
	#Rainbow Setup
	R_frame = -1
	#Flash Setup
	F_frame = -1
	
func _physics_process(delta):
	match drawing_type:
		"None":
			self.clear_points()
			return
	object_focus = get_parent()
	self.global_position = Vector2.ZERO
	self.global_rotation = 0
	match Type:
		"Ribbon":
			if self.points.size() > 1:
				if !self.get_point_position(1).distance_to(object_focus.position) < type_intensity:
					self.add_point(object_focus.position, 0)
			else:
				self.add_point(object_focus.position, 0)
			if self.points.size() > maximum_points:
				self.remove_point(self.points.size() - 1)
		"Closing Ribbon":
			if !self.points.has(object_focus.position):
				self.add_point(object_focus.position, 0)
			else:
				self.remove_point(self.points.size() - 1)
			if self.points.size() > maximum_points:
				self.remove_point(self.points.size() - 1)
		"Spark":
			self.clear_points()
			self.add_point(object_focus.position, 0)
			var targets = get_tree().get_nodes_in_group(target_group)
			targets.sort()
			for n in targets.size():
				if targets[n].position.distance_to(object_focus.position) < type_intensity and self.points.size() < maximum_points:
					self.add_point(targets[n].position, 0)
		"Spark Closest":
			self.clear_points()
			var targets = get_tree().get_nodes_in_group(target_group)
			self.add_point(object_focus.position, 0)
			for n in targets.size():
				for j in targets.size() - 1:
					if targets[j].position.distance_to(object_focus.position) > targets[j + 1].position.distance_to(object_focus.position):
						var temp_array = targets[j]
						targets[j] = targets[j + 1]
						targets[j + 1] = temp_array
			for p in targets.size():
				if targets[p].position.distance_to(object_focus.position) < type_intensity and self.points.size() < maximum_points:
					self.add_point(targets[p].position, 0)
		"Direction Point":
			DP_check += delta 
			if DP_check >= .0000000001:
				if previous_point != object_focus.position:
					var target_point = previous_point - object_focus.position
					target_point = target_point.normalized()
					self.set_point_position(0, object_focus.position)
					self.set_point_position(1 , (-target_point * type_intensity + object_focus.position))
				DP_check = -0
			if DP_check <= 0.00000000001:
				previous_point = object_focus.position
		"Unlocked Direction Point":
			DP_check += delta 
			if DP_check >= .0000000001:
				if previous_point != object_focus.position:
					var target_point = previous_point - object_focus.position
					self.set_point_position(0, object_focus.position)
					self.set_point_position(1 , (-target_point * type_intensity + object_focus.position))
				DP_check = -0
			if DP_check <= 0.00000000001:
				previous_point = object_focus.position
	match Effect:
		"Width Bounce":
			if W_frame >= max_target_width:
				W_bounce = -1
			if W_frame <= 1:
				W_bounce = 1
			W_frame = clamp(W_frame, 1, max_target_width)
			W_frame += (delta * effect_speed) * W_bounce
			self.width = W_frame
		"Rainbow":
			if R_frame >= abs(R_color_range):
				R_bounce = -1
			if R_frame <= 0:
				R_bounce = 1
			R_frame = clamp(R_frame, 0, R_color_range)
			effect_intensity = clamp(effect_intensity, 0, 1)
			R_frame += (delta * effect_speed) * R_bounce
			var rainbow = Color.from_hsv(R_frame, 1, 1, effect_intensity)
			self.default_color = rainbow
		"Fading":
			if F_frame >= abs(F_alpha_range):
				F_bounce = -1
			if F_frame <= 0:
				F_bounce = 1
			F_frame = clamp(F_frame, 0, F_alpha_range)
			F_frame += (delta * effect_speed) * F_bounce
			self.modulate.a = F_frame
		
func shuffle(list):
	list.shuffle()
	return list.front()
