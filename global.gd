extends Node
#tp06C94c9Q80yZtcqE7bX3WfYvH522az3rc35Os3
#PlanetWaves
var player
var nStructures
var nPlanetBase
var nDebug2droot
const RESOLUTION=Vector2(256,256)
var fPlanetRadius=1
var fEnergy=20#1000000
var colors={
	'blue':Color('#003049'),
	'red':Color('#D62828'),
	'orange':Color('#F77F00'),
	'yellow':Color('#FCBF49'),
	'white':Color('#EAE2B7'),
	'green':Color('#84B082'),
	'pink':Color('#E8AEB7')
}
var bTowerQueued=false
var nCamera
const tower=preload("res://scenes/tower.tscn")
const sfxMusic=preload("res://scenes/sfxMusic.tscn")
const sfxNewStructure=preload("res://scenes/sfxNewStructure.tscn")
var iPlanetLife=10#20
var bTutorialDone=false
var nUnlockPanel
var iNumberOfKills=0
var iCurrentNumberOfKills=0
var iScore=0
var nWhiteRect
var bGameOver=false
var scoreId=''
var nCtnStructures
var apiKey=''
signal oneKill
signal threeKills
signal fiveKills
signal sevenKills
signal photoPlaced
signal clearActors
signal gameOver
func resetGame():
	self.iNumberOfKills=0
	self.iCurrentNumberOfKills=0
	self.iPlanetLife=10
	self.fEnergy=20
	self.iScore=0
	self.bGameOver=false
	self.bTowerQueued=false
#	self.bTutorialDone=true
	get_tree().reload_current_scene()
func _ready():
	var f=File.new()
	f.open('res://.env',File.READ)
	self.apiKey=f.get_line()
	f.close()
	
	SilentWolf.configure({
	"api_key": self.apiKey,
	"game_id": "PlanetWaves",
	"game_version": "1.0.0",
	"log_level": 1
	})
	
#	SilentWolf.configure_scores({
#		"open_scene_on_close": "res://scenes/MainPage.tscn"
#	})

	
	if OS.is_debug_build():
		self.fEnergy+=1000
	add_child(sfxMusic.instance())
	set_process(true)
func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed('ui_debug'):
		self.iPlanetLife-=20
		#self.fEnergy-=1000
		self.iScore=10000
	if Input.is_action_just_pressed("ui_mute") and not self.bGameOver:
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Master'),!AudioServer.is_bus_mute(AudioServer.get_bus_index('Master')))
		pass
	if not bGameOver and self.iPlanetLife<=0:
		bGameOver=true
		emit_signal('gameOver')
	if iNumberOfKills!=iCurrentNumberOfKills:
		iCurrentNumberOfKills=iNumberOfKills
		if iNumberOfKills==5:emit_signal("oneKill")
		elif iNumberOfKills==10:emit_signal("threeKills")
		elif iNumberOfKills==25:emit_signal("fiveKills")
		elif iNumberOfKills==25:
			self.bTutorialDone=true
			emit_signal("sevenKills")
	if Input.is_action_just_pressed('ui_number') and not bGameOver and not self.bTowerQueued:
		var iType=-1
		var iPrice=0
		if Input.is_action_just_pressed("ui_1"):
			iType=0
			iPrice=20
		elif Input.is_action_just_pressed("ui_2"):
			iType=1
			iPrice=50
		elif Input.is_action_just_pressed("ui_3"):
			if bTutorialDone or (iNumberOfKills>=5):
				iType=4
				iPrice=50
		elif Input.is_action_just_pressed("ui_4"):
			if bTutorialDone or (iNumberOfKills>=10):
				iType=2
				iPrice=75
		elif Input.is_action_just_pressed("ui_5"):
			if bTutorialDone or (iNumberOfKills>=25):
				iType=3
				iPrice=100
		if iType!=-1:
			if self.fEnergy>=iPrice:
				self.fEnergy-=iPrice
				self.bTowerQueued=true
				var i=tower.instance()
				i.type=iType
				global.nStructures.add_child(i)
				self.nDebug2droot.add_child(sfxNewStructure.instance())
