extends Node2D

const ROUND = preload("res://scenes/round/round.tscn")

const MIN_HP = 15
const MAX_HP = 25
const MIN_INITIATIVE = 4
const MAX_INITIATIVE = 8
const TOTAL_COMBATANTS = 10
const PLAYER_COUNT = 4
const ENEMY_COUNT = 4

var player_combatants: Array[Combatant] = []
var enemy_combatants: Array[Combatant] = []

func _ready() -> void:
	init_combatants()
	init_round()

func init_round() -> void:
	var battle_round: Round = ROUND.instantiate()
	battle_round.enemy_combatants = enemy_combatants
	battle_round.player_combatants = player_combatants
	add_child(battle_round)

func init_combatants() -> void:
	var combatant_combinations = generate_unique_combinations()

	if combatant_combinations.size() < TOTAL_COMBATANTS:
		print("Not enough unique combinations to create 10 combatants.")
		return

	var player_combinations = combatant_combinations.slice(0, PLAYER_COUNT)
	var enemy_combinations = combatant_combinations.slice(PLAYER_COUNT, PLAYER_COUNT + ENEMY_COUNT)

	player_combatants = create_combatants(player_combinations, "Player")
	enemy_combatants = create_combatants(enemy_combinations, "Enemy")

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

func create_combatants(combinations: Array, prefix: String) -> Array:
	var combatants: Array[Combatant] = []
	
	for i in range(combinations.size()):
		var hp = combinations[i]["hp"]
		var initiative = combinations[i]["initiative"]
		var combatant_name = prefix + "_" + str(i + 1)
		
		var combatant = Combatant.new(hp, initiative, combatant_name)
		combatants.append(combatant)
	
	return combatants
