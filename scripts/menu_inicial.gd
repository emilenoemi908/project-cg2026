extends Node2D

@onready var nuvem1 = $Nuvem1
@onready var nuvem2 = $Nuvem2
@onready var nuvem3 = $Nuvem3
@onready var botao_soma = $BotaoSoma
@onready var botao_mult = $BotaoMultiplicacao
@onready var botao_meta = $BotaoMeta

var pos_nuvem1: Vector2
var pos_nuvem2: Vector2
var pos_nuvem3: Vector2
var tempo: float = 0.0

func _ready():
	pos_nuvem1 = nuvem1.position
	pos_nuvem2 = nuvem2.position
	pos_nuvem3 = nuvem3.position

	botao_soma.pressed.connect(func(): iniciar("soma_subtracao"))
	botao_mult.pressed.connect(func(): iniciar("multiplicacao"))
	botao_meta.pressed.connect(func(): iniciar("meta"))

func _process(delta):
	tempo += delta
	nuvem1.position.x = pos_nuvem1.x + sin(tempo * 0.1) * 40
	nuvem2.position.x = pos_nuvem2.x + sin(tempo * 0.08 + 1.0) * 50
	nuvem3.position.x = pos_nuvem3.x + sin(tempo * 0.12 + 2.0) * 35

func iniciar(modo_escolhido: String):
	GameManager.modo = modo_escolhido
	var erro = get_tree().change_scene_to_file("res://scenes/Jogo3D.tscn")
	print("Troca de cena: ", error_string(erro))
