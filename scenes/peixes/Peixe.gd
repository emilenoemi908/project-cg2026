extends Area2D

var quantidade: int = 1
var peso: float = 0.5
var posicao_inicial: Vector2
var tempo: float = 0.0

func _ready():
	sortear_dados()
	area_entered.connect(_ao_ser_alcancado)
	posicao_inicial = position

func sortear_dados():
	quantidade = randi_range(1, 5)
	peso = float(randi_range(1, 5)) * 0.5

func _process(delta):
	tempo += delta
	position.x = posicao_inicial.x + sin(tempo * 1.5) * 15
	position.y = posicao_inicial.y + sin(tempo * 2.0) * 5

func _ao_ser_alcancado(area):
	if area.is_in_group("area_pesca"):
		GameManager.registrar_peixe(quantidade, peso)
		await reaparecer()


func reaparecer():
	visible = false
	monitoring = false
	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout

	sortear_dados()
	posicao_inicial = Vector2(randf_range(60, 1090), randf_range(420, 600))
	position = posicao_inicial
	tempo = 0.0

	visible = true
	monitoring = true
