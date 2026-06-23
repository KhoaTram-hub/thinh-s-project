extends Node
class_name VampirismComponent

const VAMPIRISM_AP_COST: float = 25.0
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent()

func _physics_process(_delta: float) -> void:
	if not player or not player.is_alive: return
	
	# Giữ nguyên phím Space (ui_accept) theo ý bạn
	if Input.is_action_just_pressed("ui_accept"):
		if player.current_ap < VAMPIRISM_AP_COST:
			player.show_message("Not enough AP!", Color.RED)
			return
			
		# Bổ sung logic trừ AP và gọi hàm xử lý hút máu ở đây:
		player.current_ap -= VAMPIRISM_AP_COST
		
		var lost_health = 500 - player.health # Giả định 500 là máu tối đa
		if lost_health <= 0:
			player.show_message("Health is full!", Color.ORANGE)
			return
			
		activate_vampirism(lost_health)

func activate_vampirism(lost_amount: float) -> void:
	var heal_amount = int(lost_amount * 0.2)
	player.health = min(player.health + heal_amount, 500)
	var message_text = "+" + str(heal_amount) + " HP (Now: " + str(player.health) + "/500)"
	player.show_message(message_text, Color.GREEN)
	
	print("Heal +", heal_amount, " HP")
	print("Current HP ", player.health, "/500")
	
	player.show_message("Vampirism! +" + str(heal_amount) + " HP", Color.GREEN)
