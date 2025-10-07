extends Node3D

const HAND_SIZE = 3
const HAND_Y_POS = 0.12
const CARD_SPACING = 0.04
const CARD_DEPTH = 0.03
const CURVE_STRENGTH = 0.0

@onready var player_deck = $player_deck

var hand: Array = []
var card_selected: int = 0

func _ready() -> void:
	player_deck.draw_card()

func _physics_process(delta: float) -> void:
	if hand.is_empty():
		player_deck.draw_card()
	select_card()
	use_card()

func add_card_to_hand(card: Node3D) -> void:
	hand.append(card)
	update_card_positions()

func update_card_positions() -> void:
	var mid = (hand.size() - 1) / 2.0

	for i in range(hand.size()):
		var card = hand[i]
		var y_pos = HAND_Y_POS
		var depth = CARD_DEPTH
		if card.hovered:
			y_pos = HAND_Y_POS + 0.02
			depth = CARD_DEPTH + 0.02
		var offset_x = (i - mid) * CARD_SPACING
		var pos = Vector3(offset_x, y_pos, depth)
		var rot_y = offset_x * CURVE_STRENGTH
		animate_card_to_position(card, pos, Vector3(-10, rot_y, 0))

func animate_card_to_position(card: Node3D, new_pos: Vector3, new_rot: Vector3) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, 0.2)
	tween.tween_property(card, "rotation_degrees", new_rot, 0.2)

func select_card():
	if not hand.is_empty():
		if Input.is_action_just_pressed("select_right") and card_selected < hand.size() - 1:
			card_selected += 1
			hand[card_selected - 1].hovered = false
		if Input.is_action_just_pressed("select_left") and card_selected > 0:
			card_selected -= 1
			hand[card_selected + 1].hovered = false
		if card_selected > hand.size() - 1 or card_selected < 0:
			card_selected -= 1
		hand[card_selected].hovered = true
		update_card_positions()

func use_card():
	if Input.is_action_just_pressed("activate"):
		hand[card_selected].hovered = false
		hand[card_selected].free()
		hand.remove_at(card_selected)
