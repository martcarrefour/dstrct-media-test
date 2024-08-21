extends Node2D

const ROUND = preload("res://round.tscn")

const MIN_HP = 15
const MAX_HP = 25
const MIN_INITIATIVE = 4
const MAX_INITIATIVE = 8
const TOTAL_COMBATANTS = 10
const PLAYER_COUNT = 4
const ENEMY_COUNT = 4
var player_combatants: Array[Combatant] = []
var enemy_combatants: Array[Combatant] = []

func init_round() -> void:
	var battle_round: Round = ROUND.instantiate()
	battle_round.enemy_combatants = enemy_combatants
	battle_round.player_combatants = player_combatants
	add_child(battle_round)

func _ready() -> void:
	init_combatants()
	init_round()


func init_combatants() -> void:
	var unique_combinations: Array = generate_unique_combinations()
	if unique_combinations.size() < TOTAL_COMBATANTS:
		print("Not enough unique combinations to create 10 combatants.")
		return

	player_combatants = create_combatants(unique_combinations.slice(0, PLAYER_COUNT), "Player")
	enemy_combatants = create_combatants(unique_combinations.slice(PLAYER_COUNT, PLAYER_COUNT + ENEMY_COUNT), "Enemy")


func generate_unique_combinations() -> Array:
	var combinations: Array = []


	for hp in range(MIN_HP, MAX_HP + 1):
		for initiative in range(MIN_INITIATIVE, MAX_INITIATIVE + 1):
			combinations.append({"hp": hp, "initiative": initiative})

	if combinations.size() < TOTAL_COMBATANTS:
		print("Not enough unique combinations to create the required number of combatants.")
		return []

	combinations.shuffle()
	return combinations.slice(0, TOTAL_COMBATANTS)

func create_combatants(combinations: Array, combatant_name: String) -> Array:
	var combatants: Array[Combatant] = []
	for i in combinations.size():
		var combatant = Combatant.new(combinations[i].hp, combinations[i].initiative, combatant_name + "_" + str(i + 1))
		combatants.append(combatant)
	return combatants
