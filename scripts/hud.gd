extends CanvasLayer

@onready var score_label: Label = $ScoreLabel


func update_hud(
	depth: int,
	banked_money: int,
	carried_money: int,
	gun_health: int,
	gun_type: String
) -> void:
	score_label.text = "Depth: %dm  Money: $%d  Carrying: $%d  HP: %d  Gun: %s" % [
		depth,
		banked_money,
		carried_money,
		gun_health,
		gun_type
	]
