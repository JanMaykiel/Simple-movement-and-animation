extends Node3D

@onready var player_hand = $".."

var card_scene = preload("res://scenes/card.tscn")
var card_database = preload("res://scripts/card_database.gd")
var player_deck = ["Sample", "AttackSpeed", "AttackSpeed", "MoveSpeed", "MoveSpeed", "AttackSpeed", "MoveSpeed"]

func _ready() -> void:
	player_deck.shuffle()

func draw_card():
	if not player_deck.is_empty():
		for i in range(player_hand.HAND_SIZE):
			var card_drawn_name = player_deck[0]
			player_deck.erase(card_drawn_name)
			var new_card = card_scene.instantiate()
			var card_image_path = str("res://assets/Card/" + card_drawn_name + ".png")
			new_card.get_node("CardImage").texture = load(card_image_path)
			var new_card_effect_path = card_database.CARDS[card_drawn_name][1]
			if new_card_effect_path:
				new_card.card_effect = load(new_card_effect_path).new()
			new_card.name = "Card"
			player_hand.add_child(new_card)
			player_hand.add_card_to_hand(new_card)
			if player_deck.is_empty():
				return
