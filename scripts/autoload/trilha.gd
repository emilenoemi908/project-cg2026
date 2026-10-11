extends Node
# Música e volume geral do jogo.
# É um autoload: continua ativo ao trocar de cena (menu -> jogo), então a música não reinicia.

signal mudou

const PASTA := "res://assets/sons/"
const VOLUME_MUSICA_DB := -8.0

var volume := 1.0  # 0.0 a 1.0 (volume geral)
var mudo := false

var _player: AudioStreamPlayer
var _atual := ""


func _ready():
	_player = AudioStreamPlayer.new()
	_player.volume_db = VOLUME_MUSICA_DB
	add_child(_player)
	_aplicar()


func _carregar(nome: String) -> AudioStream:
	for ext in ["ogg", "mp3", "wav"]:
		var caminho := "%s%s.%s" % [PASTA, nome, ext]
		if ResourceLoader.exists(caminho):
			return load(caminho)
	return null


# Toca a música "nome". Se ela não existir, usa "alternativa".
# Se a mesma música já estiver tocando, não reinicia.
func tocar_musica(nome: String, alternativa: String = ""):
	var escolhida := nome
	var fluxo := _carregar(nome)
	if fluxo == null and alternativa != "":
		escolhida = alternativa
		fluxo = _carregar(alternativa)
	if fluxo == null:
		return
	if escolhida == _atual and _player.playing:
		return
	if "loop" in fluxo:
		fluxo.loop = true
	_atual = escolhida
	_player.stream = fluxo
	_player.play()


func definir_volume(v: float):
	volume = clampf(v, 0.0, 1.0)
	if volume > 0.001:
		mudo = false
	_aplicar()


func alternar_mudo():
	if volume <= 0.001:
		volume = 0.7
		mudo = false
	else:
		mudo = not mudo
	_aplicar()


# Controla o canal Master: vale para música, ambiente e todos os efeitos.
func _aplicar():
	var canal := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(canal, mudo or volume <= 0.001)
	AudioServer.set_bus_volume_db(canal, linear_to_db(maxf(volume, 0.001)))
	mudou.emit()
