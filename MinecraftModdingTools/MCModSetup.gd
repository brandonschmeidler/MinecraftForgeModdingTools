extends Node

var modRootPath:String
var mainClassName:String
var domain:String
var namespace:String
var modId:String
var version:Dictionary
var displayName:String
var updateJSONURL:String
var displayURL:String
var logoFile:String
var credits:String
var authors:String
var description:String
var clientPID:int
var clientCheckTimer:Timer


const PATH_ASSETS:String = "src/main/resources/assets/{modId}"
const PATH_ASSETS_BLOCKSTATES:String = PATH_ASSETS + "/blockstates"
const PATH_ASSETS_LANG:String = PATH_ASSETS + "/lang"
const PATH_ASSETS_MODELS:String = PATH_ASSETS + "/models"
const PATH_BLOCK_MODELS:String = PATH_ASSETS_MODELS + "/block"
const PATH_ITEM_MODELS:String = PATH_ASSETS_MODELS + "/item"
const PATH_ASSETS_TEXTURES:String = PATH_ASSETS + "/textures"
const PATH_BLOCK_TEXTURES:String = PATH_ASSETS_TEXTURES + "/blocks"
const PATH_ITEM_TEXTURES:String = PATH_ASSETS_TEXTURES + "/items"

const PATH_DATA:String = "src/main/resources/data/{modId}"
const PATH_DATA_LOOT_TABLES:String = PATH_DATA + "/loot_tables"
const PATH_BLOCK_LOOT_TABLES:String = PATH_DATA_LOOT_TABLES + "/blocks"
const PATH_DATA_RECIPES:String = PATH_DATA + "/recipes"

func setup_directories(dir:Directory):
	dir.rename("src/main/java/com/example/examplemod/ExampleMod.java","src/main/java/com/example/examplemod/"+mainClassName+".java")
	dir.rename("src/main/java/com/example/examplemod","src/main/java/com/example/"+modId)
	dir.rename("src/main/java/com/example","src/main/java/com/"+namespace)
	dir.rename("src/main/java/com","src/main/java/"+domain)
	
	dir.make_dir_recursive(PATH_ASSETS.format({"modId": modId}))
	dir.make_dir(PATH_ASSETS_BLOCKSTATES.format({"modId": modId}))
	dir.make_dir(PATH_ASSETS_LANG.format({"modId": modId}))
	dir.make_dir(PATH_ASSETS_MODELS.format({"modId": modId}))
	dir.make_dir(PATH_ASSETS_TEXTURES.format({"modId": modId}))
	
	dir.make_dir_recursive(PATH_DATA.format({"modId": modId}))
	dir.make_dir(PATH_DATA_LOOT_TABLES.format({"modId": modId}))
	dir.make_dir(PATH_DATA_RECIPES.format({"modId": modId}))
	
	dir.make_dir(PATH_BLOCK_MODELS.format({"modId": modId}))
	dir.make_dir(PATH_BLOCK_TEXTURES.format({"modId": modId}))
	dir.make_dir(PATH_BLOCK_LOOT_TABLES.format({"modId": modId}))
	
	dir.make_dir(PATH_ITEM_MODELS.format({"modId": modId}))
	dir.make_dir(PATH_ITEM_TEXTURES.format({"modId": modId}))

func setup_main_class(dir:Directory):
	var file:File = File.new()
	var filepath = dir.get_current_dir() + "/src/main/java/"+domain+"/"+namespace+"/"+modId+"/"+mainClassName+".java"
	var err = file.open(filepath,File.READ)
	if (err == OK):
		var fileString:String = file.get_as_text()
		fileString = fileString.replace("com.example.examplemod",domain+"."+namespace+"."+modId)
		fileString = fileString.replace("examplemod",modId)
		fileString = fileString.replace("ExampleMod",mainClassName)
		file.close()
		dir.remove(filepath)
		file.open(filepath,File.WRITE)
		file.store_string(fileString)
		file.close()
	else:
		print("main class", err)

func setup_mod_toml(dir:Directory):
	var filepath = dir.get_current_dir() + "/src/main/resources/META-INF/mods.toml"
	dir.remove(filepath)
	
	var file:File = File.new()
	file.open(filepath,File.WRITE)
	file.store_line("modLoader=\"javafml\"\n")
	file.store_line("loaderVersion=\"[31,)\"\n")
	file.store_line("issueTrackerURL=\"http://my.issue.tracker/\"\n")
	file.store_line("[[mods]]\n")
	file.store_line("modId=\""+modId+"\"\n")
	file.store_line("version=\""+str(version.major)+"."+str(version.minor)+"."+str(version.patch)+"\"\n")
	file.store_line("displayName=\""+displayName+"\"\n")
	file.store_line("updateJSONURL=\""+updateJSONURL+"\"\n")
	file.store_line("displayURL=\""+displayURL+"\"\n")
	file.store_line("logoFile=\""+logoFile+"\"\n")
	file.store_line("credits=\""+credits+"\"\n")
	file.store_line("authors=\""+authors+"\"\n")
	file.store_line("description='''" + description + "'''\n")
	file.store_line("[[dependencies."+modId+"]]")
	file.store_line("modId=\"forge\"")
	file.store_line("mandatory=true")
	file.store_line("versionRange=\"[31,)\"")
	file.store_line("ordering=\"NONE\"")
	file.store_line("side=\"BOTH\"")
	file.store_line("[[dependencies."+modId+"]]")
	file.store_line("modId=\"minecraft\"")
	file.store_line("mandatory=true")
	file.store_line("versionRange=\"[1.15.2]\"")
	file.store_line("ordering=\"NONE\"")
	file.store_line("side=\"BOTH\"")
	file.close()

func setup_build_gradle(dir:Directory):
	var file:File = File.new()
	var filepath = dir.get_current_dir() + "/build.gradle"
	var err = file.open(filepath,File.READ)
	if (err == OK):
		var fileString:String = file.get_as_text()
		file.close()
		fileString = fileString.replace("version = '1.0'","version = '" + str(version.major) + "." + str(version.minor) + "." + str(version.patch) + "'")
		fileString = fileString.replace("group = 'com.yourname.modid'","group = '" + domain + "." + namespace + "." + modId + "'")
		fileString = fileString.replace("archivesBaseName = 'modid'", "archivesBaseName = '" + modId + "'")
		fileString = fileString.replace("version: '20190719-1.14.3'", "version: '20200320-1.15.1'")
		fileString = fileString.replace("examplemod", modId)
		
		dir.remove(filepath)
		file.open(filepath,File.WRITE)
		file.store_string(fileString)
		file.close()
	else:
		print("build.gradle", err)

func setup_mod_workspace():
	var dir:Directory = Directory.new()
	if (dir.open(modRootPath) == OK):
		OS.execute("tar", ["-xf", "forge-1.15.2-31.1.0-mdk.zip", "-C", modRootPath])
		setup_directories(dir)
		setup_main_class(dir)
		setup_mod_toml(dir)
		setup_build_gradle(dir)
		OS.execute("generate_mod",[dir.get_current_dir() + "/"])

func _init():
	OS.set_low_processor_usage_mode(true)
	modRootPath = ""
	mainClassName = "ExampleMod"
	domain = "mod"
	namespace = "example"
	modId = "examplemod"
	version = {}
	version.major = 0
	version.minor = 1
	version.patch = 0
	displayName = "Example Mod"
	updateJSONURL = "http://myurl.me/"
	displayURL = "http://myurl.me/"
	logoFile = "examplemod.png"
	credits = "Thanks to my great friend Hippyman!"
	authors = "Mr.ModderMan"
	description = "This is a description of the mod."
	
	clientPID = -1
	clientCheckTimer = Timer.new()
	clientCheckTimer.connect("timeout",self,"_on_client_check_timer_timeout")
	add_child(clientCheckTimer)

func _on_client_check_timer_timeout():
	var output = []
	OS.execute("is_client_running",[ clientPID ],true,output)
	print(output)

func _ready():
	$MarginContainer/VBoxContainer/modRootPath/LineEdit.text = modRootPath
	$MarginContainer/VBoxContainer/mainClassName/LineEdit.text = mainClassName
	$MarginContainer/VBoxContainer/domainNamespaceModid/domainLineEdit.text = domain
	$MarginContainer/VBoxContainer/domainNamespaceModid/namespaceLineEdit.text = namespace
	$MarginContainer/VBoxContainer/domainNamespaceModid/modIdLineEdit.text = modId
	$MarginContainer/VBoxContainer/displayName/LineEdit.text = displayName
	$MarginContainer/VBoxContainer/updateJSONURL/LineEdit.text = updateJSONURL
	$MarginContainer/VBoxContainer/displayURL/LineEdit.text = displayURL
	$MarginContainer/VBoxContainer/logoFile/LineEdit.text = logoFile
	$MarginContainer/VBoxContainer/credits/LineEdit.text = credits
	$MarginContainer/VBoxContainer/authors/LineEdit.text = authors
	$MarginContainer/VBoxContainer/description/TextEdit.text = description

func _on_FileDialog_dir_selected(dir):
	modRootPath = dir
	$MarginContainer/VBoxContainer/modRootPath/LineEdit.text = modRootPath

func _on_BrowseButton_pressed():
	$FileDialog.show_modal(true)

func _on_SetupButton_pressed():
	setup_mod_workspace()

func _on_RunButton_pressed():
	OS.execute("run_mod",[modRootPath + "/"])
	

func _on_modRootPath_LineEdit_text_changed(new_text):
	modRootPath = new_text

func _on_mainClassName_LineEdit_text_changed(new_text):
	mainClassName = new_text

func _on_domainLineEdit_text_changed(new_text):
	domain = new_text

func _on_namespaceLineEdit_text_changed(new_text):
	namespace = new_text

func _on_modIdLineEdit_text_changed(new_text):
	modId = new_text

func _on_displayName_LineEdit_text_changed(new_text):
	displayName = new_text

func _on_updateJSONURL_LineEdit_text_changed(new_text):
	updateJSONURL = new_text

func _on_displayURL_LineEdit_text_changed(new_text):
	displayURL = new_text

func _on_logoFile_LineEdit_text_changed(new_text):
	logoFile = new_text

func _on_credits_LineEdit_text_changed(new_text):
	credits = new_text

func _on_authors_LineEdit_text_changed(new_text):
	authors = new_text

func _on_description_TextEdit_text_changed():
	description = $MarginContainer/VBoxContainer/description/TextEdit.text
