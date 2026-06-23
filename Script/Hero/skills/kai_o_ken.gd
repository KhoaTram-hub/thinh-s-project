extends Node
class_name KaiokenComponent

const KAIOKEN_AP_COST: float = 30.0
var is_kaioken_active: bool = false
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent()

func _physics_process(_delta: float) -> void:
	if not player or not player.is_alive: return
	
	if Input.is_action_just_pressed("ui_accept"): # Phím Space
		if is_kaioken_active: return
		if player.current_ap < KAIOKEN_AP_COST:
			player.show_message("Not enough AP!", Color.RED)
			return
			
		player.current_ap -= KAIOKEN_AP_COST
		activate_kaioken()

func activate_kaioken() -> void:
	is_kaioken_active = true
	
	# Thay đổi trực tiếp các hệ số trên Player cha
	if "damage_output_factor" in player:
		player.damage_output_factor = 3.0 # Gây x3 sát thương
	player.damage_reduction_factor = 2.0   # Nhận x2 sát thương
	
	player.show_message("KAI-O-KEN x3!", Color.CRIMSON)
	
	var timer = get_tree().create_timer(15.0)
	timer.timeout.connect(_on_kaioken_timeout)

func _on_kaioken_timeout() -> void:
	if player:
		if "damage_output_factor" in player:
			player.damage_output_factor = 1.0
		player.damage_reduction_factor = 1.0
		player.show_message("Kai-O-Ken Ended", Color.WHITE)
	is_kaioken_active = false
