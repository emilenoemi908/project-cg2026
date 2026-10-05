extends CanvasLayer

@onready var label_pontuacao = $LabelPontuacao

func _ready():
	atualizar()
	GameManager.desafio_pronto.connect(atualizar)

func atualizar():
	label_pontuacao.text = "Acertos: %d" % GameManager.acertos
