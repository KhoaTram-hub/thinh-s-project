extends CharacterBase # Kế thừa toàn bộ di chuyển/chém của cha

const SPEEDFORCE_AP_COST: float = 30.0
var is_speedforce_active: bool = false

# Viết đè hàm nhận nút bấm của cha
func handle_skill_input() -> void:
	if Input.is_action_just_pressed("ui_accept"): # Phím Space
		if is_speedforce_active: return
		if current_ap < SPEEDFORCE_AP_COST:
			show_message("Not enough AP!", Color.RED) # Gọi được hàm của cha luôn!
			return
			
		current_ap -= SPEEDFORCE_AP_COST
		activate_speedforce()

func activate_speedforce() -> void:
	is_speedforce_active = true
	speed = BASE_SPEED * 3 # Thay đổi biến speed của cha
	show_message("Speedforce Actived!", Color.YELLOW)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_on_speedforce_timeout)

func _on_speedforce_timeout() -> void:
	speed = BASE_SPEED
	is_speedforce_active = false
	show_message("Speedforce Ended", Color.WHITE)
