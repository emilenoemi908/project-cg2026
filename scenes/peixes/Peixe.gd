extends Area2D

var quantidade: int = 1
var peso: float = 0.5
var posicao_inicial: Vector2
var tempo: float = 0.0

func _ready():
	quantidade = randi_range(1, 5)
	peso = snappedf(randf_range(0.3, 2.0), 0.1)
	area_entered.connect(_ao_ser_alcancado)
	posicao_inicial = position


func _process(delta):
	tempo += delta
	position.x = posicao_inicial.x + sin(tempo * 1.5) * 15
	position.y = posicao_inicial.y + sin(tempo * 2.0) * 5

func _ao_ser_alcancado(area):
	if area.is_in_group("area_pesca"):
		GameManager.registrar_peixe(quantidade, peso)
		queue_free()
