extends CharacterBase # Kế thừa toàn bộ di chuyển/chém của cha

const SOLID_STEEL_AP_COST: float = 90.0
var is_solid_steel_active: bool = false

# Viết đè hàm nhận nút bấm của cha
func handle_skill_input() -> void:
	if Input.is_action_just_pressed("ui_accept"): # Phím Space
		if is_solid_steel_active: return
		if current_ap < SOLID_STEEL_AP_COST:
			show_message("Not enough AP!", Color.RED)
			return
			
		current_ap -= SOLID_STEEL_AP_COST
		activate_solid_steel()

func activate_solid_steel() -> void:
	is_solid_steel_active = true
	damage_reduction_factor = 0.5 # Thay đổi hệ số giảm dame của cha
	show_message("Solid Steel! Def+50%", Color.AQUA)
	
	var timer = get_tree().create_timer(8.0)
	timer.timeout.connect(_on_solid_steel_timeout)

func _on_solid_steel_timeout() -> void:
	damage_reduction_factor = 1.0
	is_solid_steel_active = false
	show_message("Solid Steel Ended", Color.WHITE)
