extends Node

var current_score: int = 0
var highscore: int = 0

func add_score(amount: int) -> void:
	current_score += amount
	# If current score beats the highscore, update it instantly
	if current_score > highscore:
		highscore = current_score
	
	print("Score: ", current_score, " | Highscore: ", highscore)

func reset_score() -> void:
	current_score = 0
