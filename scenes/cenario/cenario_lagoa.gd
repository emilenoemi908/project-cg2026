extends Node2D

@onready var nuvem1 = $Nuvem1
@onready var nuvem2 = $Nuvem2
@onready var nuvem3 = $Nuvem3
@onready var agua = $agua

var pos_inicial_nuvem1: Vector2
var pos_inicial_nuvem2: Vector2
var pos_inicial_nuvem3: Vector2
var tempo: float = 0.0

func _ready():
	pos_inicial_nuvem1 = nuvem1.position
	pos_inicial_nuvem2 = nuvem2.position
	pos_inicial_nuvem3 = nuvem3.position

func _process(delta):
	tempo += delta

	nuvem1.position.x = pos_inicial_nuvem1.x + sin(tempo * 0.1) * 40
	nuvem2.position.x = pos_inicial_nuvem2.x + sin(tempo * 0.08 + 1.0) * 50
	nuvem3.position.x = pos_inicial_nuvem3.x + sin(tempo * 0.12 + 2.0) * 35

	var brilho = 0.9 + sin(tempo * 0.5) * 0.1
	agua.color = agua.color.lightened(0.0) * brilho
