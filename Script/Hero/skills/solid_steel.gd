extends Node
class_name SolidSteelComponent

const SOLID_STEEL_AP_COST: float = 90.0
var is_solid_steel_active: bool = false
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent()

func _physics_process(_delta: float) -> void:
	if not player or not player.is_alive: return
	
	if Input.is_action_just_pressed("ui_accept"): # Phím Tab
		if is_solid_steel_active: return
		if player.current_ap < SOLID_STEEL_AP_COST:
			player.show_message("Not enough AP!", Color.RED)
			return
			
		player.current_ap -= SOLID_STEEL_AP_COST
		activate_solid_steel()

func activate_solid_steel() -> void:
	is_solid_steel_active = true
	player.damage_reduction_factor = 0.5 # Giảm 50% sát thương nhận vào
	player.show_message("Solid Steel! Def+50%", Color.AQUA)
	
	var timer = get_tree().create_timer(7.0)
	timer.timeout.connect(_on_solid_steel_timeout)
	
	print("Activate Solid Steel!!")

func _on_solid_steel_timeout() -> void:
	if player:
		player.damage_reduction_factor = 1.0
		player.show_message("Solid Steel Ended", Color.WHITE)
	is_solid_steel_active = false
