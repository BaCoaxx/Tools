#cs

#ce
#RequireAdmin
#NoTrayIcon

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include <Array.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include "GW_VaetApi.au3"


Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)

; ==== Constants ====
Global Enum $RANGE_ADJACENT=156, $RANGE_NEARBY=240, $RANGE_AREA=312, $RANGE_EARSHOT=1000, $RANGE_SPELLCAST = 1085, $RANGE_SPIRIT = 2500, $RANGE_COMPASS = 5000
Global Enum $RANGE_ADJACENT_2=156^2, $RANGE_NEARBY_2=240^2, $RANGE_AREA_2=312^2, $RANGE_EARSHOT_2=1000^2, $RANGE_SPELLCAST_2=1085^2, $RANGE_SPIRIT_2=2500^2, $RANGE_COMPASS_2=5000^2

; ================== CONFIGURATION ==================
; Edit the following two lines to count a particular item in the interface
Global Const $EventItemModelID = $model_id_cupcake
Global Const $EventItemName = "Cupcakes" ; just for the interface.
Global Const $NumberOfIdentKits = 2
Global Const $NumberOfSalvageKits = 8
; ================ END CONFIGURATION ================

Global Const $Version = "1.5"

#Region Global MatsPic´s And ModelID´Select
Global $PIC_MATS[26][2] = [["Fur Square", 941],["Bolt of Linen", 926],["Bolt of Damask", 927],["Bolt of Silk", 928],["Glob of Ectoplasm", 930],["Steel of Ignot", 949],["Deldrimor Steel Ingot", 950],["Monstrous Claws", 923],["Monstrous Eye", 931],["Monstrous Fangs", 932],["Rubies", 937],["Sapphires", 938],["Diamonds", 935],["Onyx Gemstones", 936],["Lumps of Charcoal", 922],["Obsidian Shard", 945],["Tempered Glass Vial", 939],["Leather Squares", 942],["Elonian Leather Square", 943],["Vial of Ink", 944],["Rolls of Parchment", 951],["Rolls of Vellum", 952],["Spiritwood Planks", 956],["Amber Chunk", 6532],["Jadeite Shard", 6533]]

#Region Guild Hall Globals
;~ Prophecies
Global $GH_ID_Warriors_Isle = 4
Global $GH_ID_Hunters_Isle = 5
Global $GH_ID_Wizards_Isle = 6
Global $GH_ID_Burning_Isle = 52
Global $GH_ID_Frozen_Isle = 176
Global $GH_ID_Nomads_Isle = 177
Global $GH_ID_Druids_Isle = 178
Global $GH_ID_Isle_Of_The_Dead = 179
;~ Factions
Global $GH_ID_Isle_Of_Weeping_Stone = 275
Global $GH_ID_Isle_Of_Jade = 276
Global $GH_ID_Imperial_Isle = 359
Global $GH_ID_Isle_Of_Meditation = 360
;~ Nightfall
Global $GH_ID_Uncharted_Isle = 529
Global $GH_ID_Isle_Of_Wurms = 530
Global $GH_ID_Corrupted_Isle = 537
Global $GH_ID_Isle_Of_Solitude = 538

Global $GH_Array[16] = [4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]

Global $WarriorsIsle = False
Global $HuntersIsle = False
Global $WizardsIsle = False
Global $BurningIsle = False
Global $FrozenIsle = False
Global $NomadsIsle = False
Global $DruidsIsle = False
Global $IsleOfTheDead = False
Global $IsleOfWeepingStone = False
Global $IsleOfJade = False
Global $ImperialIsle = False
Global $IsleOfMeditation = False
Global $UnchartedIsle = False
Global $IsleOfWurms = False
Global $CorruptedIsle = False
Global $IsleOfSolitude = False
#EndRegion Guild Hall Globals

; ==== Bot global variables ====
Global $IdKit = True
Global $SalvageKit = True
Global $StuffToSalvage = True
Global $iron_count_at_start = 0
Global $dust_count_at_start = 0
Global $iron_count = 0
Global $dust_count = 0
Global $glacial_stone_count = 0
Global $iron_count_old = 0
Global $dust_count_old = 0
Global $EventItemCount = 0
Global $RunCount = 0
Global $FailCount = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TimeTotal = 0 ; all times in seconds
Global $TimeRunAverage = 0 ; this and $TimeTotal is used to measure the avg time one Run takes
Global $TotalSeconds = 0 ; measures the overal time the bot is running
Global $HWND
Global $gPID = 0
Global $gCharSet = False
Global $RenderingEnabled = True
; === Timer ===
Global $ChatStuckTimer = TimerInit()
Global $tChannelingTimer
Global $tSfTimer
Global $tRunTimer
Global $tRenderTimer
Global $tResStuckTimer

; ==== Build ====
Global Const $SkillBarTemplate = "OwVUI2h5lPP8Id2BkAiAvpLBTAA"
; === Skills ===
Global Const $paradox = 1
Global Const $sf = 2
Global Const $shroud = 3
Global Const $wayofperf = 4
Global Const $hos = 5
Global Const $wastrel = 6
Global Const $echo = 7
Global Const $channeling = 8

;~ Dyes
Global Const $ITEM_ID_Dyes = 146
Global Const $ITEM_ExtraID_BlackDye = 10
Global Const $ITEM_ExtraID_WhiteDye = 12
Global $General_Items_Array[6] = [2989, 2991, 2992, 5899, 5900, 22751]
Global Const $ITEM_ID_Lockpicks = 22751
Global $Weapon_Mod_Array[25] = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15540, 15541, 15542, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 19122, 19123]
Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]
Global $All_Tomes_Array[20] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805, 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]
Global $All_Materials_Array[36] = [921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
Global $Common_Materials_Array[11] = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]
Global $Rare_Materials_Array[25] = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]
Global $Map_Piece_Array[4] = [24629, 24630, 24631, 24632]

#Region GUI
Global $MATID, $RAREMATSBUY = False, $mFoundChest = False, $mFoundMerch = False, $Bags = 4, $PICKUP_GOLDS = False
Global $SELECT_MAT = "Fur Square|Bolt of Linen|Bolt of Damask|Bolt of Silk|Glob of Ectoplasm|Steel of Ignot|Deldrimor Steel Ingot|Monstrous Claws|Monstrous Eye|Monstrous Fangs|Rubies|Sapphires|Diamonds|Onyx Gemstones|Lumps of Charcoal|Obsidian Shard|Tempered Glass Vial|Leather Squares|Elonian Leather Square|Vial of Ink|Rolls of Parchment|Rolls of Vellum|Spiritwood Planks|Amber Chunk|Jadeite Shard"
		
Global $SELECT_TOWN = " |Sifhalla"
Global $LONGEYE = False
Global $SIFHALLA = False

Global Const $mainGui 	  = GUICreate("vaettir v" & $Version, 525, 300, 192, 124)
							GUICtrlCreateTab(-1, 280, 525, 124)
							GUICtrlCreateTabItem("Main")
					        GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
							GUISetBkColor($COLOR_TEAL)
Global $CharInput
Global $CharInput = GUICtrlCreateCombo("", 8, 8, 217, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	                        GUICtrlSetData(-1, GetLoggedCharNames())
Global $SELECTMAT         = GUICtrlCreateCombo("Rare Mats", 265, 160, 225, 20, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
							GUICtrlCreateLabel("Rare Material Buy:", 325, 140, 125, 20)
							GUICtrlSetData($SELECTMAT, $SELECT_MAT)
                            GUICtrlSetOnEvent($SELECTMAT, "START_STOP")
GUICtrlCreateLabel("Runs:", 8, 35, 30, 17)
Global $RunsLabel =         GUICtrlCreateLabel($RunCount, 40, 35, 35, 17, $SS_RIGHT)
GUICtrlCreateLabel("Fails:", 105, 35, 35, 17)
Global $FailsLabel =        GUICtrlCreateLabel($FailCount, 142, 35, 35, 17, $SS_RIGHT)
GUICtrlCreateLabel($EventItemName, 142, 60, 70, 17)
Global $EventItemLabel = GUICtrlCreateLabel($EventItemCount, 200, 60, 30, 17, $SS_RIGHT)
	GUICtrlSetFont(-1, 8.5, $FW_SEMIBOLD)
GUICtrlCreateLabel("Avg time:", 8, 60, 50, 17)
Global $AverageTimeLabel =  GUICtrlCreateLabel("-", 60, 60, 50, 17, $SS_RIGHT)
GUICtrlCreateLabel("Total time:", 8, 85, 50, 17)
Global $TotalTimeLabel =    GUICtrlCreateLabel("-", 60, 85, 50, 17, $SS_RIGHT)	
GUICtrlCreateLabel("Iron:", 235, 250, 40, 17, $SS_RIGHT)
Global $IronLabel =         GUICtrlCreateLabel("-", 285, 250, 30, 17)
GUICtrlCreateLabel("Dust:",325, 250, 40, 17, $SS_RIGHT)
Global $DustLabel =         GUICtrlCreateLabel("-", 375, 250, 30, 17)
GUICtrlCreateLabel("Glacial:", 415, 250, 40, 17, $SS_RIGHT)
Global $GlacialStoneLabel = GUICtrlCreateLabel("-", 465, 250, 30, 17)
Global $RenderingBox    =   GUICtrlCreateCheckbox("Rendering?", 240,108,100,20)
						    GUICtrlSetState(-1, $gui_unchecked)
							GUICtrlSetState($RenderingBox, $GUI_DISABLE)
						    GUICtrlSetOnEvent(-1, "ToggleRendering")
Global $OnTopBox = 	        GUICtrlCreateCheckbox("Always On Top", 345, 108, 100, 20)
							GUICtrlSetOnEvent(-1, "ToggleOnTop")
Global  $cbx_mesmer_tome =  GUICtrlCreateCheckbox("Mesmer Tomes", 345,83,110,20)
Global $cbx_glacial =       GUICtrlCreateCheckbox("Keep Glacial Stones", 345, 58, 115, 17)
Global $cbx_map_set = GUICtrlCreateCheckbox("Pickup Mapsets", 345, 33, 105, 17)
Global $cbx_sell_golds = GUICtrlCreateCheckbox("Sell Golds", 345, 8, 105, 17)
						 GUICtrlSetOnEvent($cbx_sell_golds, "ToggleCheckBoxes")
Global $cbx_deposit_gold = GUICtrlCreateCheckbox("Deposit Gold", 340, 185, 95, 17)
Global $cbx_event_items = GUICtrlCreateCheckbox("Event Items", 240, 83, 95, 17)
Global $cbx_store_golds = GUICtrlCreateCheckbox("Store Unid Golds", 240, 8, 100, 17)
	GUICtrlSetOnEvent($cbx_store_golds, "ToggleCheckBoxes")
Global Const $cbx_salvage_box    = GUICtrlCreateCheckbox("Farm Materials", 240, 58, 100, 20)
Global Const $cbx_keep_mods  = GUICtrlCreateCheckbox("Keep Mods",240,33,100,20)
		GUICtrlSetOnEvent($cbx_keep_mods, "ToggleCheckBoxes")
Global Const $cbx_merch_gh = GUICtrlCreateCheckbox("Merch GH" , 300, 210, 75, 20)
		GUICtrlSetOnEvent($cbx_merch_gh, "ToggleCheckBoxes")
Global Const $cbx_merch_eotn = GUICtrlCreateCheckbox("Merch EotN" , 375, 210, 75, 20)
		GUICtrlSetOnEvent($cbx_merch_eotn, "ToggleCheckBoxes")
Global Const $Button      = GUICtrlCreateButton("Start", 8, 105, 105, 31)
						    GUICtrlSetOnEvent($Button, "GuiButtonHandler")
Global Const $SaveSettings      = GUICtrlCreateButton("Save Settings", 120, 105, 105, 31)
								  GUICtrlSetOnEvent(-1, "inisavebutton")
Global $StatusLabel = GUICtrlCreateEdit("", 8, 145, 217, 100, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))

GUICtrlCreateTabItem("Prof Mods")
GUICtrlCreateGroup("Weapon Type", 5, 5, 150, 240)
GUICtrlCreateGroup("Mod", 155, 5, 255, 240)



	Global Const $WeaponType_Axe = GUICtrlCreateCheckbox("Axe", 15, 20, 125, 20)
	Global Const $WeaponType_Bow = GUICtrlCreateCheckbox("Bow", 15, 45, 125, 20)
	Global Const $WeaponType_Hammer = GUICtrlCreateCheckbox("Hammer", 15, 70, 125, 20)
	Global Const $WeaponType_Wand = GUICtrlCreateCheckbox("Wand", 15, 95, 125, 20)
	Global Const $WeaponType_Sword = GUICtrlCreateCheckbox("Sword", 15, 120, 125, 20)
	Global Const $WeaponType_Dagger = GUICtrlCreateCheckbox("Dagger", 15, 145, 125, 20)
	Global Const $WeaponType_Scythe = GUICtrlCreateCheckbox("Scythe", 15, 170, 125, 20)
	Global Const $WeaponType_Spear = GUICtrlCreateCheckbox("Spear", 15, 195, 125, 20)
	Global Const $WeaponType_Staff = GUICtrlCreateCheckbox("Staff", 15, 220, 125, 20)
	
;Of the Profession Mods

	Global Const $ProfModStrength = GUICtrlCreateCheckbox("Of the Warrior", 160, 25, 110, 20)
	Global Const $ProfModExpertise = GUICtrlCreateCheckbox("Of the Ranger", 160, 65, 110, 20)
	Global Const $ProfModSoulReaping = GUICtrlCreateCheckbox("Of the Necromancer", 160, 105, 115, 20)
	Global Const $ProfModFastCasting = GUICtrlCreateCheckbox("Of the Mesmer", 160, 145, 110, 20)
	Global Const $ProfModEnergyStorage = GUICtrlCreateCheckbox("Of the Elementalist", 160, 185, 110, 20)
	Global Const $ProfModDivineFavor = GUICtrlCreateCheckbox("Of the Monk", 285, 25, 110, 20)
	Global Const $ProfModSpawningPower = GUICtrlCreateCheckbox("Of the Ritualist", 285, 65, 110, 20)
	Global Const $ProfModCritStrikes = GUICtrlCreateCheckbox("Of the Assassin", 285, 105, 110, 20)
	Global Const $ProfModLeadership = GUICtrlCreateCheckbox("Of the Paragon", 285, 145, 110, 20)
	Global Const $ProfModMysticism = GUICtrlCreateCheckbox("Of the Dervish", 285, 185, 110, 20)
	

GUICtrlCreateTabItem("Inscripts 1")

;Inscriptions

	Global Const $StrengthAndHonor  = GUICtrlCreateCheckbox("Strength and Honor", 5,50,125,20)
	Global Const $GuidedByFate  = GUICtrlCreateCheckbox("Guided by Fate", 5,75,125,20)
	Global Const $DanceWithDeath  = GUICtrlCreateCheckbox("Dance with Death", 5,100,125,20)
	Global Const $TothePain  = GUICtrlCreateCheckbox("To the Pain!", 5,125,125,20)
	Global Const $BrainOverBrains  = GUICtrlCreateCheckbox("Brawn over Brains", 5,150,125,20)
	Global Const $TooMuchInfo  = GUICtrlCreateCheckbox("Too Much Info", 5,175,125,20)
	Global Const $VengeanceIsMine  = GUICtrlCreateCheckbox("Vengeance is Mine", 5,200,125,20)
	Global Const $DontFearReaper  = GUICtrlCreateCheckbox("Don't Fear the Reaper", 135,50,125,20)
	Global Const $DontThinkTwice  = GUICtrlCreateCheckbox("Don't Think Twice", 135,75,125,20)
	Global Const $IHaveThePower  = GUICtrlCreateCheckbox("I have the power!", 135,100,125,20)
	Global Const $AptitudeNotAttitude  = GUICtrlCreateCheckbox("Aptitude not Attitude", 135,125,125,20)
	Global Const $SeizeTheDay  = GUICtrlCreateCheckbox("Seize the Day", 135,150,125,20)
	Global Const $HaleAndHearty  = GUICtrlCreateCheckbox("Hale and Hearty", 135,175,125,20)
	Global Const $HaveFaith  = GUICtrlCreateCheckbox("Have Faith", 135,200,125,20)
	Global Const $DontCallComeback  = GUICtrlCreateCheckbox("Don't call it a comeback!", 265,50,125,20)
	Global Const $IAmSorrow  = GUICtrlCreateCheckbox("I am Sorrow.", 265,75,125,20)
	Global Const $SerenityNow  = GUICtrlCreateCheckbox("Serenity Now", 265,100,125,20)
	Global Const $ForgetMeNot  = GUICtrlCreateCheckbox("Forget Me Not", 265,125,125,20)
	Global Const $LiveForToday  = GUICtrlCreateCheckbox("Live for Today", 265,150,125,20)
	Global Const $FaithIsMyShield  = GUICtrlCreateCheckbox("Faith is My Shield", 265,175,125,20)
	Global Const $IgnoranceBliss  = GUICtrlCreateCheckbox("Ignorance is Bliss", 265,200,125,20)
	Global Const $LifeIsPain  = GUICtrlCreateCheckbox("Life is Pain", 395,50,125,20)
	Global Const $ManForAllSeasons  = GUICtrlCreateCheckbox("Man for All Seasons", 395,75,125,20)
	Global Const $SurvivalOfFittest  = GUICtrlCreateCheckbox("Survival of the Fittest", 395,100,125,20)
	Global Const $MightMakesRight  = GUICtrlCreateCheckbox("Might Makes Right", 395,125,125,20)
	Global Const $KnowingIsHalfBattle  = GUICtrlCreateCheckbox("Knowing is Half the Battle", 395,150,125,20)
	Global Const $DownButNotOut  = GUICtrlCreateCheckbox("Down But Not Out", 395,175,125,20)
	Global Const $HailToTheKing  = GUICtrlCreateCheckbox("Hail to the King", 395,200,125,20)
	
GUICtrlCreateTabItem("Inscripts 2")

;Inscriptions Cont.

	Global Const $BeJustAndFearNot  = GUICtrlCreateCheckbox("Be Just and Fear Not", 5,50,150,20)
	Global Const $LuckOfTheDraw  = GUICtrlCreateCheckbox("Luck of the Draw", 5,75,150,20)
	Global Const $ShelteredByFaith  = GUICtrlCreateCheckbox("Sheltered by Faith", 5,100,150,20)
	Global Const $NothingToFear  = GUICtrlCreateCheckbox("Nothing to Fear", 5,125,150,20)
	Global Const $RunForYourLife  = GUICtrlCreateCheckbox("Run For Your Life!", 5,150,150,20)
	Global Const $MasterOfMyDomain  = GUICtrlCreateCheckbox("Master of My Domain!", 5,175,150,20)
	Global Const $BluntArmor  = GUICtrlCreateCheckbox("Not the Face!", 5,200,150,20)
	Global Const $ColdArmor  = GUICtrlCreateCheckbox("Leaf on the Wind", 5,225,150,20)
	Global Const $EarthArmor  = GUICtrlCreateCheckbox("Like a Rolling Stone", 175,50,150,20)
	Global Const $LightningArmor  = GUICtrlCreateCheckbox("Riders on the Storm", 175,75,150,20)
	Global Const $FireArmor  = GUICtrlCreateCheckbox("Sleep Now in the Fire", 175,100,150,20)
	Global Const $PiercingArmor  = GUICtrlCreateCheckbox("Through Thick and Thin", 175,125,150,20)
	Global Const $SlashingArmor  = GUICtrlCreateCheckbox("The Riddle of Steel", 175,150,150,20)
	Global Const $FearCutsDeeper  = GUICtrlCreateCheckbox("Fear Cuts Deeper", 175,175,150,20)
	Global Const $ICanSeeClearly  = GUICtrlCreateCheckbox("I Can See Clearly Now", 175,200,150,20)
	Global Const $SwiftAsTheWind  = GUICtrlCreateCheckbox("Swift as the Wind", 175,225,150,20)
	Global Const $StrengthOfBody  = GUICtrlCreateCheckbox("Strength of Body", 345,50,150,20)
	Global Const $CastOutTheUnclean  = GUICtrlCreateCheckbox("Cast Out the Unclean", 345,75,150,20)
	Global Const $PureOfHeart  = GUICtrlCreateCheckbox("Pure of Heart", 345,100,150,20)
	Global Const $SoundnessOfMind  = GUICtrlCreateCheckbox("Soundness of Mind", 345,125,125,20)
	Global Const $OnlyTheStrongSurvive  = GUICtrlCreateCheckbox("Only the Strong Survive", 345,150,150,20)
	Global Const $MeasureForMeasure  = GUICtrlCreateCheckbox("Measure for Measure", 345,175,150,20)
	Global Const $ShowMeTheMoney  = GUICtrlCreateCheckbox("Show me the money!", 345,200,150,20)
	Global Const $LetTheMemoryLiveAgain  = GUICtrlCreateCheckbox("Let the Memory Live Again", 345,225,150,20)
	
GUICtrlCreateTabItem("Shield/Wand/Offhand")
GUICtrlCreateGroup("Shield", 5, 5, 260, 250)
GUICtrlCreateGroup("Wand", 265, 5, 255, 125)
GUICtrlCreateGroup("Offhand", 265, 125, 255, 125)

;Shield Mods

	Global Const $30HPShield  = GUICtrlCreateCheckbox("+30 Health", 15,25,100,20)
	Global Const $45HPwEShield = GUICtrlCreateCheckbox("+45 w Enchanted", 15,75,124,20)
	Global Const $EnduranceShield  = GUICtrlCreateCheckbox("+45 w Stance", 15,125,100,20)
	Global Const $ValorShield  = GUICtrlCreateCheckbox("+60 w Hex", 15,175,100,20)
	Global Const $DemonShield  = GUICtrlCreateCheckbox("+10 vs Demons", 125,25,105,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $UndeadShield  = GUICtrlCreateCheckbox("+10 vs Undead", 125,75,105,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeletonShield  = GUICtrlCreateCheckbox("+10 vs Skeles", 125,125,105,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $CharrShield  = GUICtrlCreateCheckbox("+10 vs Charr", 125,175,105,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	
;Wand Mods

	Global Const $MemoryWand  = GUICtrlCreateCheckbox("20% HSR", 275,62,100,20)
	Global Const $QuickeningWand  = GUICtrlCreateCheckbox("+10 HSR", 390,62,100,20)

;Offhand Mods

	Global Const $30HPOffhand  = GUICtrlCreateCheckbox("+30 Health", 275,150,100,20)
	Global Const $AptitudeOffhand = GUICtrlCreateCheckbox("HCT 20%", 275,185,100,20)
	Global Const $45HPwEOffhand = GUICtrlCreateCheckbox("+45 w Enchanted", 275,220,100,20)
	Global Const $45HPwStanceOffhand = GUICtrlCreateCheckbox("+45 w Stance", 390,150,100,20)
	Global Const $60wHexOffhand  = GUICtrlCreateCheckbox("+60 w Hex", 390,185,100,20)
	Global Const $SwiftnessOffhand  = GUICtrlCreateCheckbox("10% HCT", 390,220,100,20)

;Staff Mods

GUICtrlCreateTabItem("Staff")

	Global Const $Defense  = GUICtrlCreateCheckbox("+5 Armor", 55,5,60,20)
	Global Const $WardingStaff  = GUICtrlCreateCheckbox("+7 Ele Armor", 55,30,100,20)
	Global Const $EnchantStaff  = GUICtrlCreateCheckbox("+20% Enchant", 55,55,100,20)
	Global Const $30HPStaff  = GUICtrlCreateCheckbox("+30 Health", 55,80,100,20)
	Global Const $InsightfulStaff  = GUICtrlCreateCheckbox("+5 Energy", 55,105,100,20)
	Global Const $AdeptStaff  = GUICtrlCreateCheckbox("20% HCT/Attr", 55,130,100,20)
	Global Const $SwiftStaff  = GUICtrlCreateCheckbox("10% HCT", 55,155,100,20)
	Global Const $DevotionStaff = GUICtrlCreateCheckbox("+45HP w Ench", 55,180,100,20)
	Global Const $EnduranceStaff	= GUICtrlCreateCheckbox("+45HP w Stance", 55,205,100,20)
	Global Const $ValorStaff = GUICtrlCreateCheckbox("+60 w Hex", 55,230,100,20)
	Global Const $ShelterStaff = GUICtrlCreateCheckbox("+7 Phys Armor", 55,255,100,20)
	Global Const $StaffMastery  = GUICtrlCreateCheckbox("+1 Attr/20%", 170,5,110,20)
	Global Const $DomMastery  = GUICtrlCreateCheckbox("+1 Dom/20%",170,30,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $InspMastery  = GUICtrlCreateCheckbox("+1 Inspiration/20%", 170,55,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $BloodMastery  = GUICtrlCreateCheckbox("+1 Blood/20%", 170,80,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DeathMastery  = GUICtrlCreateCheckbox("+1 Death/20%", 170,105,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SoulMastery = GUICtrlCreateCheckbox("+1 Soul/20%", 170,130,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $CurseMastery  = GUICtrlCreateCheckbox("+1 Curse/20%", 170,155,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $AirMastery  = GUICtrlCreateCheckbox("+1 Air/20%", 170,180,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $EarthMastery  = GUICtrlCreateCheckbox("+1 Earth/20%", 170,205,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $FireMastery  = GUICtrlCreateCheckbox("+1 Fire/20%", 170,230,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $WaterMastery = GUICtrlCreateCheckbox("+1 Water/20%", 285,5,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $HealMastery  = GUICtrlCreateCheckbox("+1 Heal/20%", 285,30,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SmiteMastery  = GUICtrlCreateCheckbox("+1 Smite/20%", 285,55,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $ProtMastery  = GUICtrlCreateCheckbox("+1 Prot/20%", 285,80,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DivineMastery  = GUICtrlCreateCheckbox("+1 Divine/20%", 285,105,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $CommMastery  = GUICtrlCreateCheckbox("+1 Comm/20%", 285,130,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $RestoMastery  = GUICtrlCreateCheckbox("+1 Resto/20%", 285,155,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $ChannMastery  = GUICtrlCreateCheckbox("+1 Chann/20%", 285,180,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SpawnMastery  = GUICtrlCreateCheckbox("+1 Spawn/20%", 285,205,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $IllMastery  = GUICtrlCreateCheckbox("+1 Illus/20%", 285,230,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $CharrStaff  = GUICtrlCreateCheckbox("20% vs Charr ", 400,5,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DemonStaff  = GUICtrlCreateCheckbox("20% vs Demon", 400,30,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DragonStaff  = GUICtrlCreateCheckbox("20% vs Dragon", 400,55,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DwarfStaff  = GUICtrlCreateCheckbox("20% vs Dwarf", 400,80,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $GiantStaff  = GUICtrlCreateCheckbox("20% vs Giant", 400,105,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $OgreStaff  = GUICtrlCreateCheckbox("20% vs Ogre", 400,130,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $PlantStaff  = GUICtrlCreateCheckbox("20% vs Plants", 400,155,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TrollStaff  = GUICtrlCreateCheckbox("20% vs Trolls", 400,180,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TenguStaff  = GUICtrlCreateCheckbox("20% vs Tengu", 400,205,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $UndeadStaff  = GUICtrlCreateCheckbox("20% vs Undead", 400,230,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeleStaff  = GUICtrlCreateCheckbox("20% vs Skele", 400,255,110,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	
	
GUICtrlCreateTabItem("Axe")

;Axe Mods

	Global Const $FuriousAxe 	= GUICtrlCreateCheckbox("+10% Adren Gain", 50,25,100,20)
	Global Const $ZealousAxe  	= GUICtrlCreateCheckbox("Zealous", 50,50,100,20)
	Global Const $VampiricAxe   = GUICtrlCreateCheckbox("Vampiric", 50,75,100,20)
	Global Const $EnchantAxe    = GUICtrlCreateCheckbox("+20% Enchant", 50,100,100,20)
	Global Const $30HPAxe       = GUICtrlCreateCheckbox("+30 Health", 50,125,100,20)
	Global Const $CrippAxe    = GUICtrlCreateCheckbox("33% Cripple", 50,150,100,20)
	Global Const $CruelAxe    = GUICtrlCreateCheckbox("33% Deep Wound", 50,175,105,20)
	Global Const $BarbedAxe    = GUICtrlCreateCheckbox("33% Bleed", 50,200,100,20)
	Global Const $HeavyAxe    = GUICtrlCreateCheckbox("33% Weak", 165,25,100,20)
	Global Const $PoisAxe    = GUICtrlCreateCheckbox("33% Poison", 165,50,100,20)
	Global Const $EbonAxe    = GUICtrlCreateCheckbox("Earth Dmg", 165,75,100,20)
	Global Const $FieryAxe    = GUICtrlCreateCheckbox("Fire Dmg", 165,100,100,20)
	Global Const $IcyAxe    = GUICtrlCreateCheckbox("Ice Dmg", 165,125,100,20)
	Global Const $ShockAxe    = GUICtrlCreateCheckbox("Lightning Dmg", 165,150,100,20)
	Global Const $SunderAxe    = GUICtrlCreateCheckbox("20% Armor Pen", 165,175,100,20)
	Global Const $DefenseAxe    = GUICtrlCreateCheckbox("+5 Armor", 165,200,100,20)
	Global Const $ShelterAxe    = GUICtrlCreateCheckbox("+7 Phys Armor", 280,25,100,20)
	Global Const $WardingAxe    = GUICtrlCreateCheckbox("+7 Ele Armor", 280,50,100,20)
	Global Const $AxeMaster    = GUICtrlCreateCheckbox("+1 Axe/20%", 280,75,100,20)
	Global Const $CharrAxe    = GUICtrlCreateCheckbox("20% vs Charr", 280,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DemonAxe    = GUICtrlCreateCheckbox("20% vs Demon", 280,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DragonAxe    = GUICtrlCreateCheckbox("20% vs Dragon", 280,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DwarfAxe    = GUICtrlCreateCheckbox("20% vs Dwarf ", 280,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $GiantAxe    = GUICtrlCreateCheckbox("20% vs Giant", 280,200,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $OgreAxe    = GUICtrlCreateCheckbox("20% vs Ogre", 390,25,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $PruningAxe    = GUICtrlCreateCheckbox("20% vs Plant", 390,50,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TenguAxe    = GUICtrlCreateCheckbox("20% vs Tengu", 390,75,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TrollAxe    = GUICtrlCreateCheckbox("20% vs Troll", 390,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DeathbaneAxe    = GUICtrlCreateCheckbox("20% vs Undead", 390,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeletonAxe    = GUICtrlCreateCheckbox("20% vs Skele", 390,150,105,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	

GUICtrlCreateTabItem("Sword")

;Sword Mods

	Global Const $AdrenGainSword  = GUICtrlCreateCheckbox("+10% Adren Gain", 50,25,100,20)
	Global Const $ZealousSword  = GUICtrlCreateCheckbox("Zealous", 50,50,100,20)
	Global Const $VampiricSword = GUICtrlCreateCheckbox("Vampiric", 50,75,100,20)
	Global Const $EnchantSword  = GUICtrlCreateCheckbox("+20% Enchant", 50,100,100,20)
	Global Const $30HPSword  = GUICtrlCreateCheckbox("+30 Health", 50,125,100,20)
	Global Const $BarbedSword  = GUICtrlCreateCheckbox("33% Bleed", 50,150,100,20)
	Global Const $CrippSword  = GUICtrlCreateCheckbox("33% Cripple", 50,175,100,20)
	Global Const $CruelSword  = GUICtrlCreateCheckbox("33% Deep Wound", 50,200,105,20)
	Global Const $PoisSword  = GUICtrlCreateCheckbox("33% Poison", 165,25,100,20)
	Global Const $EbonSword  = GUICtrlCreateCheckbox("Earth Dmg", 165,50,100,20)
	Global Const $FierySword  = GUICtrlCreateCheckbox("Fire Dmg", 165,75,100,20)
	Global Const $IcySword  = GUICtrlCreateCheckbox("Ice Dmg", 165,100,100,20)
	Global Const $ShockSword  = GUICtrlCreateCheckbox("Lightning Dmg", 165,125,100,20)
	Global Const $SunderSword  = GUICtrlCreateCheckbox("20% Armor Pen", 165,150,100,20)
	Global Const $DefenseSword  = GUICtrlCreateCheckbox("+5 Armor", 165,175,100,20)
	Global Const $ShelterSword  = GUICtrlCreateCheckbox("+7 Phys Armor", 280,25,100,20)
	Global Const $WardingSword  = GUICtrlCreateCheckbox("+7 Ele Armor", 280,50,100,20)
	Global Const $SwordMaster  = GUICtrlCreateCheckbox("+1 Sword/20%", 280,75,100,20)
	Global Const $CharrSword  = GUICtrlCreateCheckbox("20% vs Charr", 280,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DemonSword  = GUICtrlCreateCheckbox("20% vs Demon", 280,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DragonSword  = GUICtrlCreateCheckbox("20% vs Dragon", 280,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DwarfSword  = GUICtrlCreateCheckbox("20% vs Dwarf", 280,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $GiantSword  = GUICtrlCreateCheckbox("20% vs Giants", 390,25,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $OgreSword  = GUICtrlCreateCheckbox("20% vs Ogres", 390,50,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $PruningSword  = GUICtrlCreateCheckbox("20% vs Plants", 390,75,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TenguSword  = GUICtrlCreateCheckbox("20% vs Tengu", 390,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TrollSword  = GUICtrlCreateCheckbox("20% vs Trolls", 390,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $UndeadSword  = GUICtrlCreateCheckbox("20% vs Undead", 390,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeleSword  = GUICtrlCreateCheckbox("20% vs Skele", 390,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	
GUICtrlCreateTabItem("Spear")

;Spear Mods
	
	Global Const $BarbedSpear  = GUICtrlCreateCheckbox("33% Bleed", 65,40,100,20)
	Global Const $CrippSpear  = GUICtrlCreateCheckbox("33% Cripple", 65,65,100,20)
	Global Const $CruelSpear  = GUICtrlCreateCheckbox("33% Deep Wound", 65,90,105,20)
	Global Const $HeavySpear  = GUICtrlCreateCheckbox("33% Weakness", 65,115,100,20)
	Global Const $PoisSpear  = GUICtrlCreateCheckbox("33% Poison", 65,140,100,20)
	Global Const $SilencingSpear  = GUICtrlCreateCheckbox("33% Daze", 65,165,100,20)
	Global Const $EbonSpear  = GUICtrlCreateCheckbox("Earth Dmg", 65,190,100,20)
	Global Const $FierySpear  = GUICtrlCreateCheckbox("Fire Dmg", 200,40,100,20)
	Global Const $IcySpear  = GUICtrlCreateCheckbox("Ice Dmg", 200,65,100,20)
	Global Const $ShockingSpear  = GUICtrlCreateCheckbox("Lightning Dmg", 200,90,100,20)
	Global Const $SunderSpear  = GUICtrlCreateCheckbox("20% Armor Pen", 200,115,100,20)
	Global Const $VampiricSpear  = GUICtrlCreateCheckbox("Vampiric", 200,140,100,20)
	Global Const $DefenseSpear  = GUICtrlCreateCheckbox("+5 Armor", 200,165,100,20)
	Global Const $ShelterSpear  = GUICtrlCreateCheckbox("+7 Phys Armor", 200,190,100,20)
	Global Const $WardingSpear  = GUICtrlCreateCheckbox("+7 Ele Armor", 335,40,100,20)
	Global Const $30HPSpear  = GUICtrlCreateCheckbox("+30 HP", 335,65,100,20)
	Global Const $AdrenGainSpear  = GUICtrlCreateCheckbox("+10% Adren Gain", 335,90,100,20)
	Global Const $ZealousSpear  = GUICtrlCreateCheckbox("Zealous", 335,115,100,20)
	Global Const $EnchantSpear  = GUICtrlCreateCheckbox("+20% Enchant", 335,140,100,20)
	Global Const $SpearMaster  = GUICtrlCreateCheckbox("+1 Spear/20%", 335,165,1100,20)
	
GUICtrlCreateTabItem("Dag/Scythe")
GUICtrlCreateGroup("Daggers", 5, 5, 260, 250)
GUICtrlCreateGroup("Scythe", 265, 5, 255, 250)

;Dagger Mods
	
	Global Const $BarbedDag  = GUICtrlCreateCheckbox("33% Bleed", 15,25,100,20)
	Global Const $CrippDag  = GUICtrlCreateCheckbox("33% Crippling", 15,48,100,20)
	Global Const $CruelDag  = GUICtrlCreateCheckbox("33% Deep Wound", 15,71,100,20)
	Global Const $PoisDag  = GUICtrlCreateCheckbox("33% Poison", 15,94,100,20)
	Global Const $SilencingDag  = GUICtrlCreateCheckbox("33% Daze", 15,117,100,20)
	Global Const $EbonDag  = GUICtrlCreateCheckbox("Earth Dmg", 15,140,100,20)
	Global Const $FieryDag  = GUICtrlCreateCheckbox("Fire Dmg", 15,163,100,20)
	Global Const $IcyDag  = GUICtrlCreateCheckbox("Ice Dmg", 15,186,100,20)
	Global Const $ShockingDag	= GUICtrlCreateCheckbox("Lightning Dmg", 15,209,100,20)
	Global Const $FuriousDag  = GUICtrlCreateCheckbox("10% Adren Gain", 15,232,100,20)
	Global Const $SunderingDag  = GUICtrlCreateCheckbox("20% Armor Pen", 125,25,100,20)
	Global Const $DefenseDag  = GUICtrlCreateCheckbox("+5 Armor", 125,48,100,20)
	Global Const $ShelterDag  = GUICtrlCreateCheckbox("+7 Phys Armor", 125,71,100,20)
	Global Const $WardingDag  = GUICtrlCreateCheckbox("+7 Ele Armor", 125,94,100,20)
	Global Const $30HPDag  = GUICtrlCreateCheckbox("+30 HP", 125,117,100,20)
	Global Const $DaggerMaster  = GUICtrlCreateCheckbox("+1 Dagger/20%", 125,140,100,20)
	Global Const $VampiricDag = GUICtrlCreateCheckbox("Vampiric", 125,163,100,20)
	Global Const $EnchantDag  = GUICtrlCreateCheckbox("+20% Enchant", 125,186,100,20)
	Global Const $ZealousDag  = GUICtrlCreateCheckbox("Zealous", 125,209,100,20)
	
;Scythe Mods
	
	Global Const $BarbedScythe  = GUICtrlCreateCheckbox("33% Bleed", 275,25,100,20)
	Global Const $CrippScythe  = GUICtrlCreateCheckbox("33% Cripple", 275,48,100,20)
	Global Const $HeavyScythe  = GUICtrlCreateCheckbox("33% Weakness", 275,71,100,20)
	Global Const $PoisScythe  = GUICtrlCreateCheckbox("33% Poison", 275,94,100,20)
	Global Const $SilencingScythe  = GUICtrlCreateCheckbox("33% Daze", 275,117,100,20)
	Global Const $EbonScythe  = GUICtrlCreateCheckbox("Earth Damg", 275,140,100,20)
	Global Const $FieryScythe  = GUICtrlCreateCheckbox("Firee Dmg", 275,163,100,20)
	Global Const $IcyScythe  = GUICtrlCreateCheckbox("Ice Dmg", 275,186,100,20)
	Global Const $ShockingScythe  = GUICtrlCreateCheckbox("Lightning Dmg", 275,209,100,20)
	Global Const $FuriousScythe  = GUICtrlCreateCheckbox("10% Adren Gain", 275,232,100,20)
	Global Const $SunderingScythe  = GUICtrlCreateCheckbox("20% Armor Pen", 385,25,100,20)
	Global Const $VampiricScythe  = GUICtrlCreateCheckbox("Vampiric", 385,48,100,20)
	Global Const $ZealousScythe  = GUICtrlCreateCheckbox("Zealous", 385,71,100,20)
	Global Const $DefenseScythe  = GUICtrlCreateCheckbox("+5 Armor", 385,94,100,20)
	Global Const $ShelterScythe  = GUICtrlCreateCheckbox("+7 Phys Armor", 385,117,100,20)
	Global Const $WardingScythe  = GUICtrlCreateCheckbox("+7 Ele Armor", 385,140,100,20)
	Global Const $EnchantScythe = GUICtrlCreateCheckbox("20% Enchant", 385,163,100,20)
	Global Const $30HPScythe  = GUICtrlCreateCheckbox("+30 HP", 385,186,100,20)
	Global Const $ScytheMaster  = GUICtrlCreateCheckbox("+1 Scythe/20%", 385,209,100,20)
	
GUICtrlCreateTabItem("Hammer")

;Hammer Mods

	Global Const $CruelHammer  = GUICtrlCreateCheckbox("33% Deep Wound", 50,50,105,20)
	Global Const $HeavyHammer  = GUICtrlCreateCheckbox("33% Weakness", 50,75,100,20)
	Global Const $EbonHammer  = GUICtrlCreateCheckbox("Earth Dmg", 50,100,100,20)
	Global Const $FieryHammer  = GUICtrlCreateCheckbox("Fire Dmg", 50,125,100,20)
	Global Const $IcyHammer  = GUICtrlCreateCheckbox("Ice Dmg", 50,150,100,20)
	Global Const $ShockingHammer  = GUICtrlCreateCheckbox("Lightning Dmg", 50,175,100,20)
	Global Const $FuriousHammer  = GUICtrlCreateCheckbox("10% Adren Gain", 50,200,100,20)
	Global Const $SunderingHammer  = GUICtrlCreateCheckbox("20% Armor Pen", 165,50,100,20)
	Global Const $VampiricHammer  = GUICtrlCreateCheckbox("Vampiric", 165,75,100,20)
	Global Const $ZealousHammer  = GUICtrlCreateCheckbox("Zealous", 165,100,100,20)
	Global Const $DefenseHammer  = GUICtrlCreateCheckbox("+5 Armor", 165,125,100,20)
	Global Const $ShelterHammer  = GUICtrlCreateCheckbox("+7 Phys Armor", 165,150,100,20)
	Global Const $WardingHammer  = GUICtrlCreateCheckbox("+7 Ele Armor", 165,175,100,20)
	Global Const $EnchantHammer  = GUICtrlCreateCheckbox("20% Enchant", 165,200,100,20)
	Global Const $30HPHammer  = GUICtrlCreateCheckbox("+30 HP", 280,50,100,20)
	Global Const $HammerMaster  = GUICtrlCreateCheckbox("+1 Hammer/20%", 280,75,100,20)
	Global Const $CharrHammer  = GUICtrlCreateCheckbox("20% vs Charr", 280,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DemonHammer  = GUICtrlCreateCheckbox("20% vs Demons", 280,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DragonHammer  = GUICtrlCreateCheckbox("20% vs Dragons", 280,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DwarfHammer  = GUICtrlCreateCheckbox("20% vs Dwarf", 280,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $GiantHammer  = GUICtrlCreateCheckbox("20% vs Giants", 280,200,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $OgreHammer  = GUICtrlCreateCheckbox("20% vs Ogres", 390,50,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $PruningHammer  = GUICtrlCreateCheckbox("20% vs Plants", 390,75,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TenguHammer  = GUICtrlCreateCheckbox("20% vs Tengu", 390,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TrollHammer  = GUICtrlCreateCheckbox("20% vs Trolls", 390,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $UndeadHammer  = GUICtrlCreateCheckbox("20% vs Undead", 390,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeletonHammer  = GUICtrlCreateCheckbox("20% vs Skeles", 390,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	
GUICtrlCreateTabItem("Bow")

;Bow Mods

	Global Const $ZealousBow  = GUICtrlCreateCheckbox("Zealous", 50,50,100,20)
	Global Const $VampiricBow = GUICtrlCreateCheckbox("Vampiric", 50,75,100,20)
	Global Const $EnchantBow  = GUICtrlCreateCheckbox("+20% Enchant", 50,100,100,20)
	Global Const $BarbedBow	= GUICtrlCreateCheckbox("33% Bleed", 50,125,100,20)
	Global Const $CripplingBow  = GUICtrlCreateCheckbox("33% Cripple", 50,150,100,20)
	Global Const $PoisBow  = GUICtrlCreateCheckbox("33% Poison", 50,175,100,20)
	Global Const $SilencingBow  = GUICtrlCreateCheckbox("33% Daze", 50,200,100,20)
	Global Const $EbonBow  = GUICtrlCreateCheckbox("Earth Dmg", 165,50,100,20)
	Global Const $FireBow  = GUICtrlCreateCheckbox("Fire Dmg", 165,75,100,20)
	Global Const $IcyBow  = GUICtrlCreateCheckbox("Ice Dmg", 165,100,100,20)
	Global Const $ShockingBow  = GUICtrlCreateCheckbox("Lightning Dmg", 165,125,100,20)
	Global Const $SunderingBow  = GUICtrlCreateCheckbox("20% Armor Pen", 165,150,100,20)
	Global Const $DefenseBow  = GUICtrlCreateCheckbox("+5 Armor", 165,175,100,20)
	Global Const $ShelterBow  = GUICtrlCreateCheckbox("+7 Phys Armor", 165,200,100,20)
	Global Const $WardingBow  = GUICtrlCreateCheckbox("+7 Ele Armor", 280,50,100,20)
	Global Const $30HPBow  = GUICtrlCreateCheckbox("+30 HP", 280,75,100,20)
	Global Const $MarksmanMaster  = GUICtrlCreateCheckbox("+1 Marksman/20%", 280,100,105,20)
	Global Const $CharrBow  = GUICtrlCreateCheckbox("20% vs Charr", 280,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DemonBow  = GUICtrlCreateCheckbox("20% vs Demons", 280,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DragonBow  = GUICtrlCreateCheckbox("20% vs Dragons", 280,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $DwarfBow  = GUICtrlCreateCheckbox("20% vs Dwarf", 280,200,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $GiantBow  = GUICtrlCreateCheckbox("20% vs Giants", 390,50,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $OgreBow  = GUICtrlCreateCheckbox("20% vs Ogres", 390,75,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $PruningBow  = GUICtrlCreateCheckbox("20% vs Plants", 390,100,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TenguBow  = GUICtrlCreateCheckbox("20% vs Tengu", 390,125,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $TrollBow  = GUICtrlCreateCheckbox("20% vs Trolls", 390,150,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $UndeadBow  = GUICtrlCreateCheckbox("+20% vs Undead", 390,175,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	Global Const $SkeletonBow  = GUICtrlCreateCheckbox("+20% vs Skeles", 390,200,100,20)
				GUICtrlSetState(-1, $GUI_DISABLE)
	


GUISetState(@SW_SHOW)
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")

;~ Description: Handles the button presses
Func GuiButtonHandler()
	If $BotRunning Then
		Out("Will pause after this run.")
		GUICtrlSetState($Button, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Button, "Pause")
		$BotRunning = True
	Else
		Out("Initializing")
		Local $CharName = GUICtrlRead($CharInput)
		If $CharName=="" Then
			If Initialize(ProcessExists("gw.exe")) == False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName, True, True) == False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '"&$CharName&"'")
				Exit
			EndIf
		EndIf
		$HWND = GetWindowHandle()
		$CharName = GetCharname()
		GUICtrlSetData($CharInput, $CharName, $CharName)
		GUICtrlSetState($CharInput, $GUI_DISABLE)
		GUICtrlSetState($RenderingBox, $GUI_ENABLE)
		GUICtrlSetData($Button, "Pause")
		WinSetTitle($mainGui, "", "Vaettir Bot - " & $CharName)
		$BotRunning = True
		$BotInitialized = True
		SetMaxMemory()
	EndIf
EndFunc

If FileExists($sConfigFile) Then	;~ Loads GUI settings if custom settings have been saved
   iniload()
EndIf

SetCheckboxes()

Out("Waiting for Input.")
While Not $BotRunning
	Sleep(500)
	If ($CmdLine[0] <> 0) Then
		$BotRunning = True
	EndIf
WEnd

AdlibRegister("TimeUpdater", 5000)
SetupAtStart()

; ########## Main Loop ##########
While True
	If Not $BotRunning Then
		AdlibUnRegister("TimeUpdater")
		UpdateMatCount()
		GUICtrlSetState($Button, $GUI_ENABLE)
		GUICtrlSetData($Button, "Start")
		Out("Bot is paused.")
		While Not $BotRunning
			Sleep(500)
		WEnd
		AdlibRegister("TimeUpdater", 5000)
	EndIf
	;If IAmDisconnected() = True Then Return
	If IAmDisconnected() = True Then
		If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
			EnableRendering()
			WinSetState(GetWindowHandle(), "", @SW_SHOW)
			$RenderingEnabled = True
			Sleep(1000)
		EndIf
		
		RestartBot()
	EndIf
	Main()
WEnd

Func Main()

	If GetMapID() <> $map_id_jaga_moraine Then RunThere()
	
	Local $lSuccess = CombatLoop()
	If GetMapID() = $map_id_jaga_moraine Then UpdateStatistics($lSuccess)
EndFunc ;==>Main

Func SetCheckboxes()
	GUICtrlSetState($RenderingBox, $GUI_CHECKED) 
EndFunc ;==>SetCheckboxes

Func ToggleCheckBoxes()
    Local $keepModsState = GUICtrlRead($cbx_keep_mods)
    Local $sellGoldsState = GUICtrlRead($cbx_sell_golds)
    Local $storeGoldsState = GUICtrlRead($cbx_store_golds)
	Local $merchghstate = GUICtrlRead($cbx_merch_gh)
	Local $mercheotnstate = GUICtrlRead($cbx_merch_eotn)
	Local $salvagematsstate = GUICtrlRead($cbx_salvage_box)

    If $keepModsState = $GUI_CHECKED Then
        GUICtrlSetState($cbx_sell_golds, $GUI_DISABLE)
        GUICtrlSetState($cbx_store_golds, $GUI_DISABLE)
    ElseIf $sellGoldsState = $GUI_CHECKED  Then
		GUICtrlSetState($cbx_store_golds, $GUI_DISABLE)
        GUICtrlSetState($cbx_keep_mods, $GUI_DISABLE)
	ElseIf $storeGoldsState = $GUI_CHECKED  Then
		GUICtrlSetState($cbx_sell_golds, $GUI_DISABLE)
		GUICtrlSetState($cbx_keep_mods, $GUI_DISABLE)
    Else
        ; Re-enable checkboxes if none are checked
        GUICtrlSetState($cbx_keep_mods, $GUI_ENABLE)
        GUICtrlSetState($cbx_sell_golds, $GUI_ENABLE)
        GUICtrlSetState($cbx_store_golds, $GUI_ENABLE)
    EndIf
	
	If $merchghstate = $GUI_CHECKED Then
		GUICtrlSetState($cbx_merch_eotn, $GUI_DISABLE)
	ElseIf $mercheotnstate = $GUI_CHECKED Then
		GUICtrlSetState($cbx_merch_gh, $GUI_DISABLE)
	Else
		GUICtrlSetState($cbx_merch_gh, $GUI_ENABLE)
		GUICtrlSetState($cbx_merch_eotn, $GUI_ENABLE)
	EndIf
	
	;If $salvagematsstate = $GUI_CHECKED Then
		;GUICtrlSetState($SELECTMAT, $GUI_DISABLE)
	;Else 
		;GUICtrlSetState($SELECTMAT, $GUI_ENABLE)
	;EndIf
	
EndFunc

Func SetupAtStart()
	If ($CmdLine[0] <> 0) Then
		If SetAccountVariables($CmdLine[1]) Then
			LaunchGW()
		Else
			Out("Wrong Account Information.")
			Sleep(10000)
			Exit
		EndIf
	EndIf
	
	; If GetMapID() <> $map_id_longeyes_ledge Then
		; Out("Traveling to Longeyes.")
		; TravelTo($map_id_longeyes_ledge)
	; EndIf
	; Out("Loading skillbar.")
	;If GetInstanceType() = $instancetype_outpost Then LoadSkillTemplate($SkillBarTemplate)
	
	$iron_count_at_start = GetItemQuantity($model_id_iron_ingot)
	$dust_count_at_start = GetItemQuantity($model_id_dust)
	Out("IronStart: " & $iron_count_at_start)
	Out("DustStart: " & $dust_count_at_start)
EndFunc ;==>SetupAtStart

;~ Description: zones to longeyes if we're not there, and runs to Jaga Moraine
Func RunThere()
	Local $tOutpostTimer = Timerinit()

	If GetMapID() <> $map_id_longeyes_ledge Then
		Out("Traveling to Longeyes.")
		TravelTo($map_id_longeyes_ledge)
		WaitMapLoading()
	EndIf
	Out("In Longeyes")
	
	; === Rendering ===
	If $RenderingEnabled = True And GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
		$RenderingEnabled = False
		Sleep(1000)
	EndIf
	
	$tOutpostTimer = TimerInit()
	
	If CountFreeSlots() <= 5  Then
		If GuiCtrlRead($cbx_keep_mods) = $GUI_CHECKED And GuiCtrlRead($cbx_merch_gh) == $GUI_CHECKED Then
			Inventory()
		ElseIf GuiCtrlRead($cbx_keep_mods) = $GUI_CHECKED And GuiCtrlRead($cbx_merch_eotn) == $GUI_CHECKED Then
			InventoryEotN()
		ElseIf GuiCtrlRead($cbx_merch_eotn) == $GUI_CHECKED Then
			InventoryEotN()
		EndIf
		
	If CountFreeSlots() <= 5  Then
		If GuiCtrlRead($cbx_sell_golds) = $GUI_CHECKED And GuiCtrlRead($cbx_merch_gh) == $GUI_CHECKED Then
			Inventory2()
		ElseIf GuiCtrlRead($cbx_sell_golds) = $GUI_CHECKED And GuiCtrlRead($cbx_merch_eotn) == $GUI_CHECKED Then
			InventoryEotN2()
		ElseIf GuiCtrlRead($cbx_merch_eotn) == $GUI_CHECKED Then
			InventoryEotN2()
		EndIf
	EndIf

	If GUICtrlRead($cbx_store_golds) = $GUI_CHECKED Then
			StoreUNIDGolds()
		EndIf
	EndIf
	
	MaintainCitySpeed()
	
	If GUICtrlRead($cbx_salvage_box) = $GUI_CHECKED Then
		MoveTo(-23150, 14915)
		Local $lMerchant = GetNearestNPCToCoords(-23096, 15012)
		GoToNPC($lMerchant)
		PingSleep(1000)
		
		Out("Putting Mats into chest.")
		PutMatsIntoChest()
		Merch()
		PutMatsIntoChest()
		
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED Or GUICtrlRead($cbx_store_golds) = $GUI_CHECKED Or GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED Then
		
		CheckIDAndSalvageKits2()
		Else
		CheckIDAndSalvageKits()		
		EndIf
		
	EndIf

	UpdateMatCount()
	$iron_count_old = GetItemQuantityInventory($model_id_iron_ingot)
	$dust_count_old = GetItemQuantityInventory($model_id_dust)
	
	LeaveGroup()
	SwitchMode($hard_mode)
	SetTitleNorn()
	Sleep(GetPing()+2500)

	Out("Exiting Outpost.")
	MoveTo(-25745, 15900)	
	Move(-26550, 16250)
	
	If GetMapID() <> $map_id_jaga_moraine And TimerDiff($tOutpostTimer) > 300000 Then

    MoveTo(-25745, 15900)    
    Move(-26550, 16250)
	Sleep(2500)

	EndIf
	
	Sleep(5000)
	WaitMapLoading($map_id_bjora_marches)
	
	; === Rendering ===
	If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		$tRenderTimer = TimerInit()
		$RenderingEnabled = True
		Sleep(1000)
	EndIf
	
	If GetItemInInventory($model_id_cupcake) <> 0 Then UseItem(GetItemInInventory($model_id_cupcake))
	
	Local $lWayPoints[29][3] = [[1, 15003, -16598], [1, 12699, -14589], [1, 11628, -13867], [1, 10891, -12989], [1, 10517, -11229], _
								[1, 10209, -9973], [1, 9296, -8811], [1, 7815, -7967], [1, 6266, -6328], [1, 4940, -4655], _
								[1, 3867, -2397], [1, 2279, -1331], [1, 7, -1072], [1, -1752, -1209], [1, -3596, -1671], _
								[1, -5386, -1526], [1, -6904, -283], [1, -7711, 364], [1, -9537, 1265], [1, -11141, 857], _
								[1, -12730, 371], [1, -13379, 40], [1, -14925, 1099], [1, -16183, 2753], [1, -17803, 4439], _
								[1, -18852, 5290], [1, -19250, 5431], [1, -19968, 5564], [2, -20076, 5580]	]

	Out("Running to Jaga.")
	For $i = 0 To (UBound($lWayPoints) - 1)
		If ($lWayPoints[$i][0] = 1) Then
			If Not MoveRunning($lWayPoints[$i][1], $lWayPoints[$i][2]) Then ExitLoop
		ElseIf ($lWayPoints[$i][0] = 2) Then			
			Move($lWayPoints[$i][1], $lWayPoints[$i][2], 30)
			PingSleep(1000)
			WaitMapLoading($map_id_jaga_moraine)
		EndIf
	Next
	
	If GetMapID() = $map_id_jaga_moraine Then
		Return True
	Else
		Return False
	EndIf
EndFunc ;==>RunThere

; Description: This is pretty much all, take bounty, do left, do right, kill, rezone
Func CombatLoop()
	If GetMapID() <> $map_id_jaga_moraine Then Return False
	
	UpdateMatCount()
	
	Local $lSuccess = 0
	$tRunTimer = TimerInit()
	
	; === Rendering ===
	If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		$tRenderTimer = TimerInit()
		$RenderingEnabled = True
		Sleep(1000)
	EndIf
	
	If GetNornTitle() < 160000 Then
		Out("Taking Blessing.")
		GoNearestNPCToCoords(13318, -20826)
		Dialog(132)
		RndSleep(1000)
	EndIf	

	Local $lWayPointsLeft[13][2] =	[	[0, 0], [11375, -22761], [10925, -23466], [10917, -24311], [10280, -24620], _
										[9640, -23175], [7815, -23200], [7765, -22940], [8213, -22829], [8740, -22475], _
										[8880, -21384], [8684, -20833], [8982, -20576]	]
	
	Out("Moving to aggro left.")
	UseSkillEx($shroud)
	MoveToEx(12470, -22540)
	
	UseSkillEx($channeling)
	$tChannelingTimer = TimerInit()
	TargetNearestEnemy()
	
	For $i = 1 To (UBound($lWayPointsLeft) - 1)
		MoveAggroing($lWayPointsLeft[$i][0], $lWayPointsLeft[$i][1], 150, 150, $lWayPointsLeft[$i - 1][0], $lWayPointsLeft[$i - 1][1])
	Next

	Out("Waiting for left ball.")
	WaitForSettle(15000)

	If GetDistance() < 1000 And Not GetIsDead(-2) Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitForSettle(5000)
	WaitFor(2000)

	TargetNearestEnemy()
	
	Local $lWayPointsRight[15][2] =	[	[0, 0], [10196, -20124], [9976, -18338], [11316, -18056], [10392, -17512], _
										[10114, -16948], [10729, -16273], [10505, -14750], [10815, -14790], [11090, -15345], _
										[11670, -15457], [12604, -15320], [12450, -14800], [12725, -14850], [12476, -16157]	]

	Out("Moving to aggro right.")	
	For $i = 1 To (UBound($lWayPointsRight) - 1)
		MoveAggroing($lWayPointsRight[$i][0], $lWayPointsRight[$i][1], 150, 150, $lWayPointsRight[$i - 1][0], $lWayPointsRight[$i - 1][1])
	Next

	Out("Waiting for right ball.")
	TargetNearestEnemy()
	WaitForSettle(15000)

	If GetDistance() < 1000 And Not GetIsDead(-2) Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitForSettle(5000)
	WaitFor(2000)

	Out("Blocking enemies in spot.")
	MoveAggroing(13070, -16911, 30, 30)
	MoveAggroing(12938, -17081, 20, 20)
	WaitFor(500)
	MoveAggroing(12790, -17201, 10, 10)
	WaitFor(300)
	MoveAggroing(12747, -17220, 0, 10)
	WaitFor(300)
	MoveAggroing(12703, -17239, 0, 10)
	WaitFor(500)
	Move(12684, -17184, 0)
	PingSleep(500)

	Out("Killing.")
	Kill()

	PingSleep(1000)
	If GetNumberOfFoesInRangeOfAgent(-2, 1250) > 0 Then UseSF()

	Out("Looting.")
	PickUpLoot2()
	$StuffToSalvage = True
	$IdKit = True
	$SalvageKit = True
	
	; Travel to Outpost and deal with full inventory, functionality is in RunThere()
	If CountFreeSlots() <= 5 Then
		If GetMapID() <> $map_id_longeyes_ledge Then
			Out("Traveling to Longeyes for Inventory Management.")
			TravelTo($map_id_longeyes_ledge)
		EndIf
		
		; Analyze the contents of the inventory, to figure out if adjustments need to be made
		AnalyzeInventory()
		
		Return 0
	EndIf
	
	If CountFreeSlots() <= 5  Then
		If GuiCtrlRead($cbx_keep_mods) Or GuiCtrlRead($cbx_sell_golds) Then
			Inventory()
		EndIf
	EndIf
	
	If CountFreeSlots() <= 5  Then
		If GUICtrlRead($cbx_store_golds) = $GUI_CHECKED Then
			StoreUNIDGolds()
		EndIf
	EndIf
		
		
	If GetIsDead(-2) Then
		$FailCount += 1
		$lSuccess = 0
		GUICtrlSetData($FailsLabel, $FailCount)
	Else
		$RunCount += 1
		$lSuccess = 1
		GUICtrlSetData($RunsLabel, $RunCount)
	EndIf

	$tResStuckTimer = TimerInit()
	
	Out("Zoning.")
	MoveTo(12289, -17700) ;CHANGE THIS
	MoveZoning(15318, -20351)

	If GetIsDead(-2) Then Out("Waiting for res.")
	While GetIsDead(-2)		
		Sleep(1000)
		If IAmDisconnected() = True Then Return
	WEnd
	
	If GetMapID = $map_id_jaga_moraine And TimerDiff($tResStuckTimer) > 600000 then
	
	Out("Zoning.")
	MoveTo(12289, -17700) ;CHANGE THIS
	MoveZoning(15318, -20351)
	EndIf

	MoveTo(15318, -20351)
	Move(15865, -20531)
	WaitMapLoading($map_id_bjora_marches)

	; MoveTo(-19968, 5564, 25)
	Move(-20076,  5580, 30)
	WaitMapLoading($map_id_jaga_moraine)
	Return $lSuccess
EndFunc ;==>CombatLoop

Func MoveToEx($aX, $aY, $aRandom = 50)
	Local $lBlocked = 0
	Local $lMe
	Local $lMapLoading = GetInstanceType(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom, 1)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom, 1)

	Move($lDestX, $lDestY, 0)

	Do
		; === Rendering ===
		If $RenderingEnabled = True And TimerDiff($tRenderTimer) > 7000 Then
			If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
				DisableRendering()
				WinSetState(GetWindowHandle(), "", @SW_HIDE)
				ClearMemory()
				$RenderingEnabled = False
				Sleep(1000)
			EndIf
		EndIf
	
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetInstanceType()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') = 0 And DllStructGetData($lMe, 'MoveY') = 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move($lDestX, $lDestY, 0)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 30 Or $lBlocked > 14
EndFunc   ;==>MoveToEx

Func AnalyzeInventory()
	Local $lTmp, $lTotalCount = 0
	Out("******************************************************************************")
	$lTmp = GetItemQuantityInventory($model_id_superior_identification_kit)
	$lTotalCount += $lTmp
	Out("Superior ID: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_salvage_kit)
	$lTotalCount += $lTmp
	Out("Salvage Kit: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($EventItemModelID)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Event Item: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_iron_ingot)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Iron: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_dust)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Dust: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_granite_slab)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Granite: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_scale)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Scale: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_wood_plank)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	Out("Wood: " & $lTmp)
	
	$lTmp = GetItemQuantityInventory($model_id_bone)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	$lTmp = GetItemQuantityInventory($model_id_bolt_of_cloth)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	$lTmp = GetItemQuantityInventory($model_id_tanned_hide_square)
	$lTmp = Ceiling($lTmp / 250)
	$lTotalCount += $lTmp
	
	$lTotalCount += 3 ; 1xBlack, 1xLockpick
	Out("Total Count: " & $lTotalCount)
	Out("Free Slots: " & CountFreeSlots())
	Out("******************************************************************************")
EndFunc ;==>AnalyzeInventory

Func UpdateMatCount()
	Local $iron_count_new, $dust_count_new
	
	If GetInstanceType() = $instancetype_outpost Then
		$iron_count = GetItemQuantity($model_id_iron_ingot) - $iron_count_at_start
		$dust_count = GetItemQuantity($model_id_dust) - $dust_count_at_start
	ElseIf GetInstanceType() = $instancetype_explorable Then
		$iron_count_new = GetItemQuantityInventory($model_id_iron_ingot)
		$dust_count_new = GetItemQuantityInventory($model_id_dust)
				
		$iron_count = $iron_count + $iron_count_new - $iron_count_old
		$dust_count = $dust_count + $dust_count_new - $dust_count_old
				
		$iron_count_old = $iron_count_new
		$dust_count_old = $dust_count_new
	EndIf
	
	GUICtrlSetData($IronLabel, $iron_count)
	GUICtrlSetData($DustLabel, $dust_count)
EndFunc ;==>UpdateMatCount

Func CheckIDAndSalvageKits()	
	If GetGoldCharacter() < 5000 And GetInstanceType() = $instancetype_outpost Then
		WithdrawGold(5000)
		PingSleep(500)
	EndIf
	
	Out("Buying ID and Salvage Kits.")
	Local $lDeadlock = TimerInit()
	While GetItemQuantityInventory($model_id_superior_identification_kit) < $NumberOfIdentKits
		BuySuperiorIDKit2()
		If TimerDiff($lDeadlock) > 60000 Then
			Out("ABORTED buying ID Kits!!!")
			ExitLoop
		EndIf
	WEnd
	
	$lDeadlock = TimerInit()
	While GetItemQuantityInventory($model_id_salvage_kit) < $NumberOfSalvageKits
		BuySalvageKit2()
		If TimerDiff($lDeadlock) > 60000 Then
			Out("ABORTED buying Salvage Kits!!!")
			ExitLoop
		EndIf
	WEnd
	
	$IdKit = True
	$SalvageKit = True
EndFunc ;==>CheckIDAndSalvageKits

Func CheckIDAndSalvageKits2()	
	If GetGoldCharacter() < 5000 And GetInstanceType() = $instancetype_outpost Then
		WithdrawGold(5000)
		PingSleep(500)
	EndIf
	
	Out("Buying ID and Salvage Kits.")
	Local $lDeadlock = TimerInit()
	While GetItemQuantityInventory($model_id_superior_identification_kit) < 1
		BuySuperiorIDKit2()
		If TimerDiff($lDeadlock) > 60000 Then
			Out("ABORTED buying ID Kits!!!")
			ExitLoop
		EndIf
	WEnd
	
	$lDeadlock = TimerInit()
	While GetItemQuantityInventory($model_id_salvage_kit) < 4
		BuySalvageKit2()
		If TimerDiff($lDeadlock) > 60000 Then
			Out("ABORTED buying Salvage Kits!!!")
			ExitLoop
		EndIf
	WEnd
	
	$IdKit = True
	$SalvageKit = True
EndFunc ;==>CheckIDAndSalvageKits

; If Inventory is Full it will Travel to Longeyes and store all the stuff
Func StorePcons()
	If GUICtrlRead($cbx_salvage_box) = $GUI_CHECKED Then Return False
	
	If CountFreeSlots() <= 2 Then
		TravelTo($map_id_longeyes_ledge)
		PingSleep(1000)
		PutPconsIntoChest()
	EndIf

	If GetMapID() = $map_id_longeyes_ledge Then
		Return True
	Else
		Return False
	EndIf
EndFunc ;==>StorePcons

; Identifies and Salvages Items for Mats
; Travels to Longeyes if you're out of Ident/Salvage Kits
Func Merch()
	If GUICtrlRead($cbx_salvage_box) = $GUI_UNCHECKED Then Return False
	
	IdentBag(1)
	IdentBag(2)
	IdentBag(3)
	IdentBag(4)
	
	SalvageBag(1)
	SalvageBag(2)
	SalvageBag(3)
	SalvageBag(4)
	
	If GetMapID() = $map_id_longeyes_ledge Then
		Return True
	Else
		Return False
	EndIf
EndFunc ;==>Merch

Func Inventory()
	Local $charGold = GetGoldCharacter()
	Local $storageGold = GetGoldStorage()
	Local $depositGoldChecked = (GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED)
	Local $GuildHall = CheckGuildHall()
	
	Out("Travel to Guild Hall")
	TravelGH()
	
	WaitMapLoading()
	
	Sleep(GetPing()+2000)
	
	CheckGuildHall()

	Sleep(GetPing()+2000)

	;Chest()
	
	PutPconsIntoChest()
	
	
If $charGold > 85000 Then
	If $depositGoldChecked And $storageGold < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	Else
		Out("Buying Rare Materials")
		RareMaterialTrader()
	EndIf
EndIf
	
	

	;Out("Storing Stuff")
	;StoreItems()
	;StoreMaterials()

	Merchant()
	Sleep(GetPing()+2500)

	Out("Identifying")
	IdentBag(1)
	IdentBag(2)
	IdentBag(3)
	IdentBag(4)
	
	;StoreMods()
	;StoreWeapons()

	Out("Selling")
	Sell(1)
	Sell(2)
	Sell(3)
	Sell(4)
	
	StoreGoldsEx()
	
	Sleep(1500)


If GetGoldCharacter() > 85000 Then
	If $depositGoldChecked And GetGoldStorage() < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	Else
		Out("Buying Rare Materials")
		RareMaterialTrader()
	EndIf
EndIf

	Sleep(GetPing()+1000)

	LeaveGH()
	WaitMapLoading()
	Sleep(GetPing()+2500)
	Return
EndFunc

Func Inventory2()
	
	Local $charGold = GetGoldCharacter()
	Local $storageGold = GetGoldStorage()
	Local $depositGoldChecked = (GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED)
	Local $GuildHall = CheckGuildHall()
	
	Out("Travel to Guild Hall")
	TravelGH()
	
	WaitMapLoading()
	
	Sleep(GetPing()+2500)
	
	CheckGuildHall()
	
	Sleep(GetPing()+2500)

	;Chest()
	
	PutPconsIntoChest()
	
If $charGold > 85000 Then
	If $depositGoldChecked And $storageGold < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	Else
		Out("Buying Rare Materials")
		RareMaterialTrader()
	EndIf
EndIf

	;Out("Storing Stuff")
	;StoreItems()
	;StoreMaterials()

	Merchant()
	Sleep(2500)

	Out("Identifying")
	IdentBag(1)
	IdentBag(2)
	IdentBag(3)
	IdentBag(4)
	
	;StoreMods()
	;StoreWeapons()

	Out("Selling")
	Sell(1)
	Sell(2)
	Sell(3)
	Sell(4)


	Sleep(GetPing()+1000)

If GetGoldCharacter() > 85000 Then
	If $depositGoldChecked And GetGoldStorage() < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	Else
		Out("Buying Rare Materials")
		RareMaterialTrader()
	EndIf
EndIf

	LeaveGH()
	WaitMapLoading()
	Sleep(GetPing()+2500)
	Return
EndFunc


Func InventoryEotN()

	Local $charGold = GetGoldCharacter()
	Local $storageGold = GetGoldStorage()
	Local $depositGoldChecked = (GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED)

	Out("Travel to EotN")
	TravelTo($map_id_eye_of_the_north)
	
	WaitMapLoading()
	
	Sleep(GetPing()+2500)

	;Chest()
	
	PutPconsIntoChest()

If $charGold > 85000 Then
	If $depositGoldChecked And $storageGold < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	EndIf
EndIf

	;Out("Storing Stuff")
	;StoreItems()
	;StoreMaterials()
	
	Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy = GetNearestNPCToCoords(-2748, 1019)
	Until DllStructGetData($guy, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy)
	Sleep(250 + 3 * GetPing())
	
	Do
        MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(Random(500,750))
        GoNPC($guy)
        RndSleep(Random(250,500))
        Local $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(Random(1000,1500))
	
	Out("Identifying")
	IdentBag(1)
	IdentBag(2)
	IdentBag(3)
	IdentBag(4)
	
	;StoreMods()
	;StoreWeapons()

	Out("Selling")
	Sell(1)
	Sell(2)
	Sell(3)
	Sell(4)
	
	StoreGoldsEx()

	Sleep(GetPing()+1000)
	
	If GetGoldStorage() > 800000 And GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED Then
		Out("Buying Rare Materials")
		Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy2 = GetNearestNPCToCoords(-2079, 1046)
	Until DllStructGetData($guy2, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy2)
	Sleep(250 + 3 * GetPing())
	
	While GetGoldCharacter() > 20*1000
		TraderRequest($MATID)
		Sleep(1000 + 3 * GetPing())
		$TRADERPRICE = GETTRADERCOSTVALUE()
		TraderBuy()
	WEnd
	
	EndIf

	If GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED Then
		Out("Depositing Gold")
		DepositGold()
	ElseIf GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_UNCHECKED Then
		Out("Buying Rare Materials")
		Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy2 = GetNearestNPCToCoords(-2079, 1046)
	Until DllStructGetData($guy2, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy2)
	Sleep(250 + 3 * GetPing())
	
	While GetGoldCharacter() > 20*1000
		TraderRequest($MATID)
		Sleep(1000 + 3 * GetPing())
		$TRADERPRICE = GETTRADERCOSTVALUE()
		TraderBuy()
	WEnd
	
	EndIf

	TravelTo($map_id_longeyes_ledge)
	WaitMapLoading()
	Sleep(GetPing()+2500)
	Return
EndFunc

Func InventoryEotN2()
	Local $charGold = GetGoldCharacter()
	Local $storageGold = GetGoldStorage()
	Local $depositGoldChecked = (GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED)

	Out("Travel to EotN")
	TravelTo($map_id_eye_of_the_north)
	
	WaitMapLoading()
	
	Sleep(GetPing()+2500)

	;Chest()
	
	PutPconsIntoChest()

If $charGold > 85000 Then
	If $depositGoldChecked And $storageGold < 800000 Then
		Out("Depositing Gold")
		DepositGold()
	EndIf
EndIf
	;Out("Storing Stuff")
	;StoreItems()
	;StoreMaterials()
	
	Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy = GetNearestNPCToCoords(-2748, 1019)
	Until DllStructGetData($guy, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy)
	Sleep(250 + 3 * GetPing())
	
	Do
        MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(Random(500,750))
        GoNPC($guy)
        RndSleep(Random(250,500))
        Local $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(Random(1000,1500))
	
	Out("Identifying")
	IdentBag(1)
	IdentBag(2)
	IdentBag(3)
	IdentBag(4)
	
	;StoreMods()
	;StoreWeapons()

	Out("Selling")
	Sell(1)
	Sell(2)
	Sell(3)
	Sell(4)

	Sleep(GetPing()+1000)
	
	If GetGoldStorage() > 800000 And GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED Then
		Out("Buying Rare Materials")
		Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy2 = GetNearestNPCToCoords(-2079, 1046)
	Until DllStructGetData($guy2, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy2)
	Sleep(250 + 3 * GetPing())
	
	While GetGoldCharacter() > 20*1000
		TraderRequest($MATID)
		Sleep(1000 + 3 * GetPing())
		$TRADERPRICE = GETTRADERCOSTVALUE()
		TraderBuy()
	WEnd
	
	EndIf

	If GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_CHECKED Then
		Out("Depositing Gold")
		DepositGold()
	ElseIf GetGoldCharacter() > 85000 And GUICtrlRead($cbx_deposit_gold) == $GUI_UNCHECKED Then
		Out("Buying Rare Materials")
		Do
		Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
		Local $guy2 = GetNearestNPCToCoords(-2079, 1046)
	Until DllStructGetData($guy2, 'Id') <> 0
	Sleep(250 + 3 * GetPing())
	GoNPC($guy2)
	Sleep(250 + 3 * GetPing())
	
	While GetGoldCharacter() > 20*1000
		TraderRequest($MATID)
		Sleep(1000 + 3 * GetPing())
		$TRADERPRICE = GETTRADERCOSTVALUE()
		TraderBuy()
	WEnd
	
	EndIf

	TravelTo($map_id_longeyes_ledge)
	WaitMapLoading()
	Sleep(GetPing()+2500)
	Return
EndFunc


; Keeps all Golds
Func UNIDGolds($BAGINDEX, $NUMOFSLOTS)
	Out("Storing Golds")
	Local $aItem, $lItem, $m, $Q, $r, $lbag, $Slot, $Full, $NSlot
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$aItem = GetItemBySlot($lbag, $j)
			If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aItem, "ModelID")
			$r = GetRarity($lItem)
			If CanStoreGoldsEx($aItem) Then
				Do
					For $Bag = 8 To 12
						$Slot = FindEmptySlotEx($Bag)
						$Slot = @extended
						If $Slot <> 0 Then
							$Full = False
							$NSlot = $Slot
							ExitLoop 2
						Else
							$Full = True
						EndIf
						Sleep(400)
					Next
				Until $Full = True
				If $Full = False Then
					MoveItem($aItem, $Bag, $NSlot)
					Sleep(GetPing() + 500)
				EndIf
			EndIf
		Next
	Next
EndFunc ;~ UNID golds

Func CanStoreGoldsEx($aItem)
	Local $m = DllStructGetData($aItem, "ModelID")
	Local $r = GetRarity($aItem)
	Switch $r
		Case $Rarity_Gold
			If $m = 22280 Then
				Return False
			Else
				Return True
			EndIf
	EndSwitch
EndFunc   ;==>CanStoreGolds

Func StoreGoldsEx()
	Out("Storing Golds")
	Local $aItem, $lItem, $m, $Q, $r, $lbag, $Slot, $Full, $NSlot
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$aItem = GetItemBySlot($lbag, $j)
			If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aItem, "ModelID")
			$r = GetRarity($lItem)
			If CanStoreGoldsEx($aItem) Then
				Do
					For $Bag = 8 To 12
						$Slot = FindEmptySlotEx($Bag)
						$Slot = @extended
						If $Slot <> 0 Then
							$Full = False
							$NSlot = $Slot
							ExitLoop 2
						Else
							$Full = True
						EndIf
						Sleep(400)
					Next
				Until $Full = True
				If $Full = False Then
					MoveItem($aItem, $Bag, $NSlot)
					Sleep(GetPing() + 500)
				EndIf
			EndIf
		Next
	Next
EndFunc   ;==>StoreGolds

Func FindEmptySlotEx($BagIndex)
	Local $LItemINFO, $aSlot
	For $aSlot = 1 To DllStructGetData(GetBag($BagIndex), "Slots")
		Sleep(40)
		$LItemINFO = GetItemBySlot($BagIndex, $aSlot)
		If DllStructGetData($LItemINFO, "ID") = 0 Then
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot

; Puts all Pcons in your inventory into chest
Func PutPconsIntoChest()
	If GetInstanceType() <> $instancetype_outpost Then
		Out("You need to go to an Outpost.")
		Return False
	EndIf
	Out("Putting Pcons into chest.")

	Local $lItem, $lQuantity, $lModelID
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'slots')
			$lItem = GetItemBySlot($i, $j)
			If DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
			$lModelID = DllStructGetData($lItem, 'ModelID')
			$lQuantity = DllStructGetData($lItem, 'quantity')
			If IsEventItem($lModelID) And $lQuantity = 250 Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
		Next
	Next
EndFunc ;==>PutPconsIntoChest

; Func IsPcon($aModelID)
	
; EndFunc ;==>IsPcon

Func PutMatsIntoChest()
	If GetInstanceType() <> $instancetype_outpost Then
		Out("You need to go to an Outpost.")
		Return False
	EndIf

	Local $lItem, $lQuantity, $lModelID
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'slots')
			$lItem = GetItemBySlot($i, $j)
			If DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
			$lModelID = DllStructGetData($lItem, 'ModelID')
			$lQuantity = DllStructGetData($lItem, 'quantity')
			If ($lModelID = $model_id_iron_ingot And $lQuantity = 250) Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_dust And $lQuantity = 250) Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_bone And $lQuantity = 250) Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_Wood_Plank) Then
				SellItem($lItem, $lQuantity)
				PingSleep(500)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_scale And $lQuantity = 250) Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
			If $lModelID = $model_id_tanned_hide_square Then
				SellItem($lItem, $lQuantity)
				PingSleep(500)
				ContinueLoop
			EndIf
			If $lModelID = $model_id_bolt_of_cloth Then
				SellItem($lItem, $lQuantity)
				PingSleep(500)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_granite_slab And $lQuantity = 250) Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
			If ($lModelID = $model_id_glacial_stone And $lQuantity = 250) And GUICtrlRead($cbx_glacial) = $GUI_CHECKED Then
				MoveItemToChest($lItem)
				ContinueLoop
			EndIf
		Next
	Next
EndFunc ;==>PutMatsIntoChest

Func StoreUNIDGolds()

	Out("Travel to Guild Hall")
	TravelGH()
	WaitForMapLoading()
	
	PutPconsIntoChest()
	
	UNIDGolds(1, 20)
	UNIDGolds(2, 5)
	UNIDGolds(3, 10)
	UNIDGolds(4, 10)
	
	LeaveGH()
	WaitMapLoading()
	Return
EndFunc ;~ UNID Golds

Func SalvageOneThing()
    If $StuffToSalvage = False Or $SalvageKit = False Then Return
    If IAmDisconnected() = True Then Return
    If GetIsDead(-2) Then Return

    Local $lItem, $lModelID, $lType, $lRarity
    Local $lGlacialStone = 0, $lWhiteWeapon = 0, $lGoldWeapon = 0, $lBlueWeapon = 0, $lPurpleWeapon = 0
    Local $lIdKit = 0, $lSalvageKit = 0

     For $i = 1 To 4
        Local $bag = GetBag($i)
        If @error Or $bag = 0 Then ContinueLoop
		
        For $j = 1 To DllStructGetData(GetBag($i), 'slots')
            If IAmDisconnected() = True Then Return
            
            $lItem = GetItemBySlot($i, $j)
            If @error Or DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
            
            $lModelID = DllStructGetData($lItem, 'ModelID')
            $lType = DllStructGetData($lItem, 'Type')
            $lRarity = GetRarity($lItem)

            If WantToSalvageForMats($lType) = True Then
                Switch $lRarity
                    Case $rarity_white
                        $lWhiteWeapon = $lItem
                    Case $rarity_blue
                        $lBlueWeapon = $lItem
                    Case $rarity_purple
                        $lPurpleWeapon = $lItem
                    Case $rarity_gold
                        $lGoldWeapon = $lItem
                EndSwitch
                ContinueLoop
            EndIf

            Switch $lModelID
                Case $model_id_glacial_stone
                    $lGlacialStone = $lItem
                Case $model_id_salvage_kit
                    $lSalvageKit = $lItem
                Case $model_id_superior_identification_kit
                    $lIdKit = $lItem
            EndSwitch
        Next
    Next

    If $lSalvageKit = 0 Then
        $SalvageKit = False
        Return
    EndIf

    If $lIdKit = 0 Then
        $IdKit = False
        If $lWhiteWeapon = 0 And $lGlacialStone = 0 And $lBlueWeapon = 0 And $lPurpleWeapon = 0 And $lGoldWeapon = 0 Then
            $StuffToSalvage = False
            Return
        EndIf
    EndIf    

    If $lGoldWeapon <> 0 Then
        IdentifyItem2($lGoldWeapon)
        PingSleep(100)
        StartSalvage2($lGoldWeapon)
		PingSleep(1000)
		ControlSend(GetWindowHandle(), "", "", "{Enter}")
        PingSleep(1000)
    ElseIf $lPurpleWeapon <> 0 Then
        IdentifyItem2($lPurpleWeapon)
        PingSleep(100)
        StartSalvage2($lPurpleWeapon)
		PingSleep(1000)
		ControlSend(GetWindowHandle(), "", "", "{Enter}")
        PingSleep(1000)
    ElseIf $lBlueWeapon <> 0 Then
        IdentifyItem2($lBlueWeapon)
        PingSleep(100)
        StartSalvage2($lBlueWeapon)
        PingSleep(1000)
    ElseIf $lWhiteWeapon <> 0 Then
        StartSalvage2($lWhiteWeapon)
        PingSleep(1000)
    ElseIf $lGlacialStone <> 0 And GUICtrlRead($cbx_glacial) = $GUI_UNCHECKED Then
        StartSalvage2($lGlacialStone)
        PingSleep(1000)
    EndIf
EndFunc ;===> SalvageOneThing

Func SalvageOneThing2()
    If $StuffToSalvage = False Or $SalvageKit = False Then Return
    If IAmDisconnected() = True Then Return
    If GetIsDead(-2) Then Return

    Local $lItem, $lModelID, $lType, $lRarity
    Local $lGlacialStone = 0, $lWhiteWeapon = 0, $lBlueWeapon = 0, $lPurpleWeapon = 0
    Local $lIdKit = 0, $lSalvageKit = 0

    For $i = 1 To 4
        Local $bag = GetBag($i)
        If @error Or $bag = 0 Then ContinueLoop
		
        For $j = 1 To DllStructGetData(GetBag($i), 'slots')
            If IAmDisconnected() = True Then Return
            
            $lItem = GetItemBySlot($i, $j)
            If @error Or DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
            
            $lModelID = DllStructGetData($lItem, 'ModelID')
            $lType = DllStructGetData($lItem, 'Type')
            $lRarity = GetRarity($lItem)

            If WantToSalvageForMats($lType) = True Then
                If $lRarity = $rarity_gold Then ContinueLoop ; Skip gold weapons
                Switch $lRarity
                    Case $rarity_white
                        $lWhiteWeapon = $lItem
                    Case $rarity_blue
                        $lBlueWeapon = $lItem
                    Case $rarity_purple
                        $lPurpleWeapon = $lItem
                EndSwitch
                ContinueLoop
            EndIf

            Switch $lModelID
                Case $model_id_glacial_stone
                    $lGlacialStone = $lItem
                Case $model_id_salvage_kit
                    $lSalvageKit = $lItem
                Case $model_id_superior_identification_kit
                    $lIdKit = $lItem
            EndSwitch
        Next
    Next

    If $lSalvageKit = 0 Then
        $SalvageKit = False
        Return
    EndIf

    If $lIdKit = 0 Then
        $IdKit = False
        If $lWhiteWeapon = 0 And $lGlacialStone = 0 And $lBlueWeapon = 0 And $lPurpleWeapon = 0 Then
            $StuffToSalvage = False
            Return
        EndIf
    EndIf    

    If $lPurpleWeapon <> 0 Then
        IdentifyItem2($lPurpleWeapon)
        PingSleep(100)
        StartSalvage2($lPurpleWeapon)
		PingSleep(1000)
		ControlSend(GetWindowHandle(), "", "", "{Enter}")
        PingSleep(1000)
    ElseIf $lBlueWeapon <> 0 Then
        IdentifyItem2($lBlueWeapon)
        PingSleep(100)
        StartSalvage2($lBlueWeapon)
        PingSleep(1000)
    ElseIf $lWhiteWeapon <> 0 Then
        StartSalvage2($lWhiteWeapon)
        PingSleep(1000)
    ElseIf $lGlacialStone <> 0 And GUICtrlRead($cbx_glacial) = $GUI_UNCHECKED Then
        StartSalvage2($lGlacialStone)
        PingSleep(1000)
    EndIf
EndFunc ;===> SalvageOneThing2



Func SalvageBag($bagIndex)
    ; Check if salvage kits are available and ensure we're not in the wrong map instance
    If (FindSuperiorIDKit() = 0 Or FindSalvageKit2() = 0) And GetInstanceType() = $instancetype_explorable Then Return False

    Local $lBag = GetBag($bagIndex)
    Local $lItem, $lRarity, $lType
    Local $cbx_keep_modsState = GUICtrlRead($cbx_keep_mods) ; Read the state of the StoreGolds checkbox

    For $i = 1 To DllStructGetData($lBag, 'slots')
        $lItem = GetItemBySlot($bagIndex, $i)
        If DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
        $lRarity = GetRarity($lItem)
        $lType = DllStructGetData($lItem, 'Type')

        ; Skip gold items if StoreGolds checkbox is checked
        If $cbx_keep_modsState = $GUI_CHECKED And $lRarity = $rarity_gold Then ContinueLoop

        ; Ensure we have salvage kits; buy if necessary in an outpost
        If FindSalvageKit2() = 0 Then
            If GetInstanceType() = $instancetype_outpost Then
                If GetGoldCharacter() < 500 AND GetGoldStorage() > 499 Then
                    WithdrawGold(500)
                    RndSleep(500)
                EndIf
                BuySalvageKit2()
            Else
                Return False
            EndIf
        EndIf

        ; Check if the item is worth salvaging
        If WantToSalvageForMats($lType) Then
            StartSalvage2($lItem)
            PingSleep(2500)

            ; Handle confirmation dialog for high-rarity items
            If $lRarity = $rarity_gold Or $lRarity = $rarity_purple Then
                ControlSend(GetWindowHandle(), "", "", "{Enter}")
                PingSleep(1500)
            EndIf
        EndIf
    Next
EndFunc ; ==>SalvageBag

Func IdentBag($bagIndex, $aWhites = False, $aGolds = True)
	Local $lItem
	Local $lBag = GetBag($bagIndex)
	For $i = 1 To DllStructGetData($lBag, 'slots')
		$lItem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
		If GetRarity($lItem) = $rarity_white And $aWhites = False Then ContinueLoop
		If GetRarity($lItem) = $rarity_gold And $aGolds = False Then ContinueLoop
		If GetIsIDed($lItem) Then ContinueLoop
		If FindSuperiorIDKit() = 0 Then
			If GetInstanceType() = $instancetype_outpost Then
				If GetGoldCharacter() < 1000 AND GetGoldStorage() > 1000 Then
					WithdrawGold(1000)
					RndSleep(500)
				EndIf			
				BuySuperiorIDKit2()
			Else
				Return False
			EndIf
		EndIf
		IdentifyItem2($lItem)
		PingSleep(50)
	Next
EndFunc ;==>IdentBag

Func IdentifyAll($aWhites = False, $aGolds = True)
	Local $lItem

	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'slots')
			$lItem = GetItemBySlot($i, $j)
			If DllStructGetData($lItem, 'ID') = 0 Then ContinueLoop
			If GetRarity($lItem) = $rarity_white And $aWhites = False Then ContinueLoop
			If GetRarity($lItem) = $rarity_gold And $aGolds = False Then ContinueLoop
			If GetIsIDed($lItem) Then ContinueLoop
			If FindSuperiorIDKit() = 0 Then
				$IdKit = False
				Return
			EndIf
			IdentifyItem2($lItem)
			PingSleep(50)
		Next
	Next
EndFunc ;==>IdentifyAll

;~ Description: use whatever skills you need to keep yourself alive.
Func StayAlive()
	Local $lMe = GetAgentByID(-2)
	Local $lEnergy = GetEnergy($lMe)
	Local $lHp = DllStructGetData($lMe, 'HP')

	UseSF()

	If IsRecharged($shroud) And $lHp < 0.6 Then UseSkillEx($shroud)

	UseSF()

	If IsRecharged($wayofperf) And $lHp < 0.55 Then UseSkillEx($wayofperf)
	
	UseSF()

	If IsRecharged($channeling) Then
		If (GetEffectTimeDuration($skill_id_channeling) - TimerDiff($tChannelingTimer)) < 3000 Then
			UseSkillEx($channeling)
			$tChannelingTimer = TimerInit()
		EndIf
	EndIf

	UseSF()
EndFunc ;==>StayAlive

;~ Description: Uses sf if there's anything close and if its recharged
Func UseSF()
	If IsRecharged($sf) Then
		UseSkillEx($paradox)
		UseSkillEx($sf)
		$tSfTimer = TimerInit()
	EndIf
EndFunc ;==>UseSF

;~ Description: Move to destX, destY, while staying alive vs vaettirs
Func MoveAggroing($lDestX, $lDestY, $lRandom = 150, $aRandom = 150, $aHosX = 0, $aHosY = 0)
	If IAmDisconnected() = True Then Return
	If GetIsDead(-2) Then Return False

	Local $lMe, $lHosTarget
	Local $lBlocked = 0
	Local $lHosCount = 0, $lAggressiveHos = 0
	Local $lAngle = 0
	Local $lDeadlock = TimerInit()
	Local $lTimeout = 3*60*1000
	Local $lMoveTimer = TimerInit() ; we dont wanna spam Move to often
	Local $bKeepMods = GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED
	Local $bSellGolds = GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED
	Local $bStoreGolds = GUICtrlRead($cbx_store_golds) = $GUI_CHECKED

	Move($lDestX, $lDestY, $lRandom)
	
	If $bKeepMods Or $bSellGolds Or $bStoreGolds Then
		SalvageOneThing2()
	Else
		SalvageOneThing()
	EndIf
	
	Sleep(250)
	
	Do
		PingSleep(250)
		$lMe = GetAgentByID(-2)

		If IAmDisconnected() = True Then Return
		If GetIsDead($lMe) Then Return False

		StayAlive()
		
		If Not GetIsMoving($lMe) Then
			; suicide if you didn't reach your Coords in 3 minutes
			If $lHosCount > 6 Or TimerDiff($lDeadlock) > $lTimeout Then
				Do	; suicide
					PingSleep(500)
					If IAmDisconnected() = True Then Return
				Until GetIsDead(-2)
				Return False
			EndIf
			
			; use HoS on yourself if you didn't reach your Coords during 1 minute
			If TimerDiff($lDeadlock) > 60000 Then UseSkillEx($hos, -2)

			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			ElseIf $lBlocked < 10 Then
				If IsRecharged($hos) And $lAggressiveHos = 0 Then
					If $aHosX = 0 And $aHosY = 0 Then
						; Out("Aggressive HOS on Nearest.")
						UseSkillEx($hos, -1)
					Else
						$lHosTarget = GetHosTarget($aHosX, $aHosY)
						If IsDllStruct($lHosTarget) = 0 Then
							; Out("Aggressive HOS on Nearest2.")
							UseSkillEx($hos, -1)
						Else
							; Out("Aggressive HOS on GOOD TARGET.")
							ChangeTarget($lHosTarget)
							UseSkillEx($hos, $lHosTarget)
						EndIf
					EndIf
					$lAggressiveHos = 1
					$lBlocked = 0
				Else
					; Out("MOVE ANGLE")
					$lAngle += 40
					Move((DllStructGetData($lMe, 'X') + 300*sin($lAngle)), (DllStructGetData($lMe, 'Y') + 300*cos($lAngle)))
					PingSleep(500)
				EndIf
			ElseIf IsRecharged($hos) Then
				If $lHosCount < 2 Then
					If $aHosX = 0 And $aHosY = 0 Then
						UseSkillEx($hos, -1)
					Else
						$lHosTarget = GetHosTarget($aHosX, $aHosY)
						If IsDllStruct($lHosTarget) = 0 Then
							UseSkillEx($hos, -1)
						Else
							ChangeTarget($lHosTarget)
							UseSkillEx($hos, $lHosTarget)
						EndIf
					EndIf
				Else
					UseSkillEx($hos, -2)
				EndIf
				$lBlocked = 0
				$lHosCount += 1
			Else
				If TimerDiff($lMoveTimer) > 1500 then
					Move($lDestX, $lDestY, $lRandom)
					$lMoveTimer = TimerInit()
				EndIf
			EndIf
		Else
			If $lBlocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then	; use a timer to avoid spamming /stuck
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
				$lHosCount = 0
			EndIf

			If GetDistance() > 900 Then ; target is far, we probably got stuck.
				If TimerDiff($ChatStuckTimer) > 3000 Then ; dont spam
					;Out("GOT STUCK, but game didnt notice!")
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
					PingSleep(50)
					If GetDistance() > 900 Then ; we werent stuck, but target broke aggro. select a new one.
						TargetNearestEnemy()
					EndIf
				EndIf
			EndIf
		EndIf
	Until ComputeDistance(XLocation($lMe), YLocation($lMe), $lDestX, $lDestY) < $aRandom*1.5
	Return True
EndFunc ;==>MoveAggroing

Func MoveZoning($lDestX, $lDestY, $lRandom = 150, $aRandom = 150, $aHosX = 0, $aHosY = 0)
	If IAmDisconnected() Then Return
	If GetIsDead(-2) Then Return False

	Local $lMe, $lHosTarget, $lHp
	Local $lBlocked = 0, $lHosCount = 0, $lAngle = 0
	Local $lDeadlockTimer = TimerInit()
	Local $lLastMoveAttempt = TimerInit()
	Local $lChatStuckTimer = TimerInit()
	Local $lTimeout = 2 * 60 * 1000
	Local $bKeepMods = GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED
	Local $bSellGolds = GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED
	Local $bStoreGolds = GUICtrlRead($cbx_store_golds) = $GUI_CHECKED

	If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		Sleep(500)
	EndIf
	
	Move($lDestX, $lDestY, $lRandom)
	
	If $bKeepMods Or $bSellGolds Or $bStoreGolds Then
		SalvageOneThing2()
	Else
		SalvageOneThing()
	EndIf
	
	Sleep(250)
	
	Do
		PingSleep(250)
		$lMe = GetAgentByID(-2)
		$lHp = DllStructGetData($lMe, 'HP')

		If IAmDisconnected() Then Return
		If GetIsDead($lMe) Then Return False

		; Stay alive if enemies are nearby
		If GetNumberOfFoesInRangeOfAgent($lMe, 1250) > 0 Then
			UseSF()
			If GetEffectTimeDuration($skill_id_shroud_of_distress) <= 0 And $lHp < 0.5 Then UseSkillEx($shroud)
		EndIf

		If Not GetIsMoving($lMe) Then
			If TimerDiff($lDeadlockTimer) > $lTimeout Then
				Do
					PingSleep(500)
				Until GetIsDead(-2)
				Return False
			EndIf

			If TimerDiff($lLastMoveAttempt) > 60000 Then
				UseSkillEx($hos, -2)
				$lLastMoveAttempt = TimerInit()
			EndIf

			$lBlocked += 1
			Switch $lBlocked
				Case 1 To 4
					Move($lDestX, $lDestY, $lRandom)
				Case 5 To 9
					$lAngle += Random(30, 50, 1)
					Move(DllStructGetData($lMe, 'X') + 300 * Sin($lAngle), DllStructGetData($lMe, 'Y') + 300 * Cos($lAngle))
				Case Else
					If IsRecharged($hos) Then
						If $lHosCount < 2 Then
							If $aHosX == 0 And $aHosY == 0 Then
								UseSkillEx($hos, -1)
							Else
								$lHosTarget = GetHosTarget($aHosX, $aHosY)
								If IsDllStruct($lHosTarget) == 0 Then
									UseSkillEx($hos, -1)
								Else
									ChangeTarget($lHosTarget)
									UseSkillEx($hos, $lHosTarget)
								EndIf
							EndIf
						Else
							UseSkillEx($hos, -2)
						EndIf
						$lBlocked = 0
						$lHosCount += 1
					EndIf
			EndSwitch
		Else
			If $lBlocked > 0 Then
				If TimerDiff($lChatStuckTimer) > 3000 Then
					SendChat("stuck", "/")
					$lChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
				$lHosCount = 0
			EndIf

			If GetDistance() > 1100 Then
				If TimerDiff($lChatStuckTimer) > 3000 Then
					SendChat("stuck", "/")
					$lChatStuckTimer = TimerInit()
					PingSleep(50)
					If GetDistance() > 1100 Then
						TargetNearestEnemy()
					EndIf
				EndIf
			EndIf
		EndIf
	Until ComputeDistance(XLocation($lMe), YLocation($lMe), $lDestX, $lDestY) < $aRandom * 1.5
	Return True
EndFunc




;~ Description: Move to destX, destY. This is to be used in the run from across Bjora
Func MoveRunning($lDestX, $lDestY)
	If IAmDisconnected() = True Then Return
	If GetIsDead(-2) Then Return False

	Local $lMe, $lHp, $lEnergy
	Local $lTgt, $lDistance
	Local $lBlocked = 0
	Local $bKeepMods = GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED
	Local $bSellGolds = GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED
	Local $bStoreGolds = GUICtrlRead($cbx_store_golds) = $GUI_CHECKED

	Move($lDestX, $lDestY)
	
	If $bKeepMods Or $bSellGolds Or $bStoreGolds Then
		SalvageOneThing2()
	Else
		SalvageOneThing()
	EndIf
	
	Sleep(250)	
	
	Do
		; === Rendering ===
		If $RenderingEnabled = True And TimerDiff($tRenderTimer) > 7000 Then
			If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
				DisableRendering()
				WinSetState(GetWindowHandle(), "", @SW_HIDE)
				ClearMemory()
				$RenderingEnabled = False
				Sleep(1000)
			EndIf
		EndIf
	
		RndSleep(500)

		TargetNearestEnemy()
		$lMe = GetAgentByID(-2)
		$lHp = DllStructGetData($lMe, 'HP')
		$lEnergy = GetEnergy($lMe)
		
		$lTgt = GetAgentByID(-1)
		$lDistance = GetDistance($lMe, $lTgt)
	
		If IAmDisconnected() == True Then Return
		If GetIsDead($lMe) Then Return False

		If $lDistance < 1300 And $lEnergy > 20 And IsRecharged($paradox) And IsRecharged($sf) Then
			UseSkillEx($paradox)
			UseSkillEx($sf)
		EndIf

		If $lHp < 0.9 And $lEnergy > 10 And IsRecharged($shroud) Then UseSkillEx($shroud)

		If $lHp < 0.5 And $lDistance < 500 And $lEnergy > 5 And IsRecharged($hos) Then UseSkillEx($hos, -1)

		If Not GetIsMoving($lMe) Then
			$lBlocked += 1
			Move($lDestX, $lDestY)
		EndIf

	Until ComputeDistance(XLocation($lMe), YLocation($lMe), $lDestX, $lDestY) < 250
	Return True
EndFunc ;==>MoveRunning

;~ Description: Waits until all foes are in range or Timeout
Func WaitForSettle($aTimeout = 15000)
	Local $lAgentArray
	Local $lAdjCount = 0
	Local $lSpellCastCount = 0
	Local $lMe, $lDistance
	Local $lTimer = TimerInit()
	Local $bKeepMods = GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED
	Local $bSellGolds = GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED
	Local $bStoreGolds = GUICtrlRead($cbx_store_golds) = $GUI_CHECKED
	
	While TimerDiff($lTimer) < $aTimeout
		PingSleep(500)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return
		If IAmDisconnected() == True Then Return
		StayAlive()
	
	If $bKeepMods Or $bSellGolds Or $bStoreGolds Then
		SalvageOneThing2()
	Else
		SalvageOneThing()
	EndIf

		Sleep(250)
		
		$lAgentArray = GetAgentArray(0xDB)		
		$lAdjCount = 0
		$lSpellCastCount = 0
		For $i = 1 To $lAgentArray[0]
			$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
			If $lDistance < $RANGE_SPELLCAST_2 Then
				$lSpellCastCount += 1
			EndIf
			If $lDistance < $RANGE_NEARBY_2 Then
				$lAdjCount += 1
			EndIf
		Next
		If $lSpellCastCount = $lAdjCount Then Return True
	WEnd
EndFunc ;==>WaitForSettle

;~ Description: Wait and stay alive at the same time (like Sleep(..), but without the letting yourself die part)
Func WaitFor($lMs)
	If IAmDisconnected() == True Then Return
	If GetIsDead(-2) Then Return
	
	Local $lTimer = TimerInit()
	Do
		PingSleep(250)
		If IAmDisconnected() == True Then Return
		If GetIsDead(-2) Then Return
		StayAlive()
	Until TimerDiff($lTimer) > $lMs
EndFunc ;==>WaitFor

;~ Description: BOOOOOOOOOOOOOOOOOM
Func Kill()
	If IAmDisconnected() == True Then Return
	If GetIsDead(-2) Then Return

	Local $lAgentArray
	Local $lDeadlock = TimerInit()

	TargetNearestEnemy()
	Sleep(100)
	Local $lTargetID = GetCurrentTargetID()

	While GetAgentExists($lTargetID) And DllStructGetData(GetAgentByID($lTargetID), "HP") > 0
		PingSleep(250)
		If IAmDisconnected() == True Then Return
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive()

		; Use echo if possible
		If (GetEffectTimeDuration($skill_id_shadow_form) - TimerDiff($tSfTimer)) > 5000 And GetSkillbarSkillID($echo) == $skill_id_arcane_echo Then
			If IsRecharged($wastrel) And IsRecharged($echo) Then
				UseSkillEx($echo)
				UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
				$lAgentArray = GetAgentArray(0xDB)
			EndIf
		EndIf

		UseSF()

		; Use wastrel if possible
		If IsRecharged($wastrel) Then
			UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
			$lAgentArray = GetAgentArray(0xDB)
		EndIf

		UseSF()

		; Use echoed wastrel if possible
		If IsRecharged($echo) And GetSkillbarSkillID($echo) == $skill_id_wastrels_demise Then
			UseSkillEx($echo, GetGoodTarget($lAgentArray))
		EndIf

		; Check if target has ran away
		If GetDistance(-2, $lTargetID) > $RANGE_EARSHOT Then
			TargetNearestEnemy()
			PingSleep(100)
			If GetAgentExists(-1) And DllStructGetData(GetAgentByID(-1), "HP") > 0 And GetDistance(-2, -1) < $RANGE_AREA Then
				$lTargetID = GetCurrentTargetID()
			Else
				ExitLoop
			EndIf
		EndIf

		If TimerDiff($lDeadlock) > 60 * 1000 Then ExitLoop
	WEnd
EndFunc ;==>Kill

; Returns a good target for watrels
; Takes the agent array as returned by GetAgentArray(..)
Func GetGoodTarget(Const ByRef $lAgentArray)
	Local $lMe = GetAgentByID(-2)
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		If GetDistance($lMe, $lAgentArray[$i]) > $RANGE_NEARBY Then ContinueLoop
		If GetHasHex($lAgentArray[$i]) Then ContinueLoop
		If Not GetIsEnchanted($lAgentArray[$i]) Then ContinueLoop
		Return DllStructGetData($lAgentArray[$i], "ID")
	Next
EndFunc ;==>GetGoodTarget

Func GetHosTarget(Const $aX, Const $aY)
	Local $lNearestAgent = 0, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0xDB)

	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop

		$lDistance = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance And GetDistance($lAgentArray[$i], -2) < 500 Then
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc ; ==>GetHosTarget

Func GoNearestNPCToCoords($x, $y)
	Local $guy, $Me
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(500)
		Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
		RndSleep(500)
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
EndFunc ;==>GoNearestNPCToCoords

;~ Description: standard pickup function, only modified to increment a custom counter when taking stuff with a particular ModelID
Func PickUpLoot2()
	Local $lAgent
	Local $lItem
	Local $lDeadlock
	For $i = 1 To GetMaxAgents()
		If IAmDisconnected() = True Then Return
		If GetIsDead(-2) Then Return
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'Type') <> 0x400 Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickup($lItem) And CountFreeSlots() > 0 Then
			PickUpItem($lItem)
			$lDeadlock = TimerInit()
			While GetAgentExists($i)
				Sleep(100)
				If IAmDisconnected() = True Then Return
				If GetIsDead(-2) Then Return
				If TimerDiff($lDeadlock) > 10000 Then ExitLoop
			WEnd
		EndIf
	Next
EndFunc ;==>PickUpLoot2

; Checks if should pick up the given item. Returns True or False
Func CanPickUp($aItem)
	Local $LRARITY = GetRarity($aitem)
	Local $aModelID = DllStructGetData(($aItem), 'ModelID')
	Local $lExtraID = DllStructGetData($aItem, 'ExtraID')
	If $aModelID = 2511 And GetGoldCharacter() < 99000 Then Return True
	If $aModelID = $model_id_mesmer_tome And GUICtrlRead($cbx_mesmer_tome) = $GUI_CHECKED Then Return True
	If IsBlackDye($aModelID, $lExtraID) Then Return True 
	If $aModelID = $model_id_lockpick Then Return True
	If $aModelID = $model_id_glacial_stone Then
		$glacial_stone_count += 1
		GUICtrlSetData($GlacialStoneLabel, $glacial_stone_count)
		Return True
	EndIf
	If $aModelID = $EventItemModelID Then
		$EventItemCount += 1
		GUICtrlSetData($EventItemLabel, $EventItemCount)
		Return True
	EndIf
	; ==== Pcons ====
	If IsEventItem($aModelID) And GUICtrlRead($cbx_event_items) = $GUI_CHECKED Then Return True
	
	;If $aModelID = $model_id_cupcake Or $aModelID = $model_id_golden_egg Or $aModelID = $model_id_chocolate_bunny Then Return True
	
	; === Map Set ===
	If IsMapPiece($aModelID) And GUICtrlRead($cbx_map_set) = $GUI_CHECKED Then Return True
	
	If GUICtrlRead($cbx_store_golds) = $GUI_CHECKED Or GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED  And $LRARITY = $Rarity_Gold Then Return True
	
	If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And $LRARITY = $Rarity_Gold Then Return True
	
	If GUICtrlRead($cbx_sell_golds) = $GUI_CHECKED And $LRARITY = $RARITY_Gold Then Return True
	
	If GUICtrlRead($cbx_salvage_box) = $GUI_CHECKED Then 
		Local $lType = DllStructGetData($aItem, 'Type')
		;If WantToSalvageForMats($lType) Then Return True
		Return WantToSalvageForMats($lType)
	EndIf

	Return False
EndFunc ;==>CanPickUp

Func IsMapPiece($aModelID)
	Switch $aModelID
		Case $model_id_top_left_map_piece, $model_id_top_right_map_piece
			Return True
		Case $model_id_bottom_left_map_piece, $model_id_bottom_right_map_piece
			Return True
	EndSwitch
	Return False
EndFunc

Func Sell($BAGINDEX)
	Local $AITEM
	Local $BAG = GETBAG($BAGINDEX)
	Local $NUMOFSLOTS = DllStructGetData($BAG, "slots")
	For $I = 1 To $NUMOFSLOTS
		Out("Selling item: " & $BAGINDEX & ", " & $I)
		$AITEM = GETITEMBYSLOT($BAGINDEX, $I)
		If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
		If CANSELL($AITEM) Then
			If GetGoldCharacter() >= 85000 And GetGoldStorage() < 800000 Then 
				DepositGold()
			EndIf
		SELLITEM($AITEM)
		EndIf
		Sleep(GetPing()+250)
	Next
EndFunc

Func CanSell($aItem)

	Local $lType = DllStructGetData($aItem, 'Type')

	Local $LMODELID = DllStructGetData($aItem, "ModelID")

	Local $LRARITY = GetRarity($aitem)
	Local $Requirement = GetItemReq($aItem)

    Local $IsCaster = IsPerfectCaster($aItem)
    Local $IsStaff  = IsPerfectStaff($aItem)
    Local $IsShield = IsPerfectShield($aItem)
    Local $IsRune   = IsRareRune($aItem)
    Local $Type     = DllStructGetData($aItem, "Type")
	Local $StoreGolds = GUICtrlRead($cbx_store_golds)
	Local $SellGolds = GUICtrlRead($cbx_sell_golds)

    Local $NiceMod  = IsNiceMod($aItem)
	;Staff Mod Checks
	
	If $lModelID == $model_id_glacial_stone And GUICtrlRead($cbx_glacial) == $GUI_CHECKED Then 
			Return False
		ElseIf $lModelID == $model_id_glacial_stone And GUICtrlRead($cbx_glacial) == $GUI_UNCHECKED Then 
			Return True
	EndIf

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($Defense) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($WardingStaff) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($EnchantStaff) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($30HPStaff) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($InsightfulStaff) == $GUI_CHECKED And IsNiceMod5E($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($AdeptStaff) == $GUI_CHECKED And IsNiceModHCT20($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($SwiftStaff) == $GUI_CHECKED And IsNiceModHCT10($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DevotionStaff) == $GUI_CHECKED And IsNiceMod45HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($EnduranceStaff) == $GUI_CHECKED And IsNiceMod45HPStance($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($ValorStaff) == $GUI_CHECKED And IsNiceMod60HPHex($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($ShelterStaff) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($IllMastery) == $GUI_CHECKED And IsNiceModIllMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DomMastery) == $GUI_CHECKED And IsNiceModDomMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($InspMastery) == $GUI_CHECKED And IsNiceModInspMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($BloodMastery) == $GUI_CHECKED And IsNiceModBloodMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DeathMastery) == $GUI_CHECKED And IsNiceModDeathMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($SoulMastery) == $GUI_CHECKED And IsNiceModSoulMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($CurseMastery) == $GUI_CHECKED And IsNiceModCurseMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($AirMastery) == $GUI_CHECKED And IsNiceModAirMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($EarthMastery) == $GUI_CHECKED And IsNiceModEarthMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($FireMastery) == $GUI_CHECKED And IsNiceModFireMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($WaterMastery) == $GUI_CHECKED And IsNiceModWaterMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($HealMastery) == $GUI_CHECKED And IsNiceModHealMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($SmiteMastery) == $GUI_CHECKED And IsNiceModSmiteMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($ProtMastery) == $GUI_CHECKED And IsNiceModProtMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DivineMastery) == $GUI_CHECKED And IsNiceModDivineMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($CommMastery) == $GUI_CHECKED And IsNiceModCommMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($RestoMastery) == $GUI_CHECKED And IsNiceModRestoMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($ChannMastery) == $GUI_CHECKED And IsNiceModChannMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($SpawnMastery) == $GUI_CHECKED And IsNiceModSpawnMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($CharrStaff) == $GUI_CHECKED And IsNiceModCharrSlaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DemonStaff) == $GUI_CHECKED And IsNiceModDemonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DragonStaff) == $GUI_CHECKED And IsNiceModDragonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($DwarfStaff) == $GUI_CHECKED And IsNiceModDwarfslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($GiantStaff) == $GUI_CHECKED And IsNiceModGiantslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($OgreStaff) == $GUI_CHECKED And IsNiceModOgreslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($PlantStaff) == $GUI_CHECKED And IsNiceModPruning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($TrollStaff) == $GUI_CHECKED And IsNiceModTrollslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($TenguStaff) == $GUI_CHECKED And IsNiceModTenguslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($UndeadStaff) == $GUI_CHECKED And IsNiceModUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($SkeleStaff) == $GUI_CHECKED And IsNiceModSkeletonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_staff And GuiCtrlRead($StaffMastery) == $GUI_CHECKED And IsNiceModStaffMastery($aItem) Then
                        Return False
					EndIf
			
	;Axe Mod Checks
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($FuriousAxe) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($ZealousAxe) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($VampiricAxe) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($EnchantAxe) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($30HPAxe) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($CrippAxe) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($BarbedAxe) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($HeavyAxe) == $GUI_CHECKED And IsNiceModHeavy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($PoisAxe) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($EbonAxe) == $GUI_CHECKED And IsNiceModEarth($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($FieryAxe) == $GUI_CHECKED And IsNiceModFire($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($IcyAxe) == $GUI_CHECKED And IsNiceModCold($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($ShockAxe) == $GUI_CHECKED And IsNiceModLightning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($SunderAxe) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($DefenseAxe) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($ShelterAxe) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($WardingAxe) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($AxeMaster) == $GUI_CHECKED And IsNiceModAxeMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($CharrAxe) == $GUI_CHECKED And IsNiceModCharrSlaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($DemonAxe) == $GUI_CHECKED And IsNiceModDemonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($DragonAxe) == $GUI_CHECKED And IsNiceModDragonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($DwarfAxe) == $GUI_CHECKED And IsNiceModDwarfslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($GiantAxe) == $GUI_CHECKED And IsNiceModGiantslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($OgreAxe) == $GUI_CHECKED And IsNiceModOgreslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($PruningAxe) == $GUI_CHECKED And IsNiceModPruning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($TenguAxe) == $GUI_CHECKED And IsNiceModTenguslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($TrollAxe) == $GUI_CHECKED And IsNiceModTrollslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($DeathbaneAxe) == $GUI_CHECKED And IsNiceModUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_axe And GuiCtrlRead($SkeletonAxe) == $GUI_CHECKED And IsNiceModSkeletonslaying($aItem) Then
                        Return False
					EndIf
						
;Sword Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($AdrenGainSword) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($ZealousSword) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($VampiricSword) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($EnchantSword) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($30HPSword) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($BarbedSword) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($CrippSword) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword And GuiCtrlRead($CruelSword) == $GUI_CHECKED And IsNiceModCruel($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($PoisSword) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($EbonSword) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($FierySword) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($IcySword) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ShockSword) == $GUI_CHECKED And IsNiceModShock($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($SunderSword) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($DefenseSword) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ShelterSword) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($WardingSword) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($SwordMaster) == $GUI_CHECKED And IsNiceModSwordMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($CharrSword) == $GUI_CHECKED And IsNiceModCharrSlaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($DemonSword) == $GUI_CHECKED And IsNiceModDemonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($DragonSword) == $GUI_CHECKED And IsNiceModDragonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($DwarfSword) == $GUI_CHECKED And IsNiceModDwarfslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($GiantSword) == $GUI_CHECKED And IsNiceModGiantslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($OgreSword) == $GUI_CHECKED And IsNiceModOgreslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($PruningSword) == $GUI_CHECKED And IsNiceModPruning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($TenguSword) == $GUI_CHECKED And IsNiceModTenguslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($TrollSword) == $GUI_CHECKED And IsNiceModTrollslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($UndeadSword) == $GUI_CHECKED And IsNiceModUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($SkeleSword) == $GUI_CHECKED And IsNiceModSkeletonslaying($aItem) Then
                        Return False
					EndIf

;Spear Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($BarbedSpear) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($CrippSpear) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($CruelSpear) == $GUI_CHECKED And IsNiceModCruel($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($HeavySpear) == $GUI_CHECKED And IsNiceModHeavy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($PoisSpear) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($SilencingSpear) == $GUI_CHECKED And IsNiceModSilencing($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($EbonSpear) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($FierySpear) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($IcySpear) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ShockingSpear) == $GUI_CHECKED And IsNiceModShock($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($SunderSpear) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($VampiricSpear) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($DefenseSpear) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ShelterSpear) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($WardingSpear) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($30HPSpear) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If  GuiCtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($AdrenGainSpear) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ZealousSpear) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($EnchantSpear) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($SpearMaster) == $GUI_CHECKED And IsNiceModSpearMastery($aItem) Then
                        Return False
					EndIf

;Dagger Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($BarbedDag) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($CrippDag) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($CruelDag) == $GUI_CHECKED And IsNiceModCruel($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($PoisDag) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If  GuiCtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($SilencingDag) == $GUI_CHECKED And IsNiceModSilencing($aItem) Then
                        Return False
					EndIf
				If GuiCtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($EbonDag) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($FieryDag) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($IcyDag) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($FuriousDag) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($SunderingDag) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($DefenseDag) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ShelterDag) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($WardingDag) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($30HPDag) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($DaggerMaster) == $GUI_CHECKED And IsNiceModDagMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($VampiricDag) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($EnchantDag) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ZealousDag) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ShockingDag) == $GUI_CHECKED And IsNiceModLightning($aItem) Then
                        Return False
					EndIf

;Scythe Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($BarbedScythe) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($CrippScythe) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($HeavyScythe) == $GUI_CHECKED And IsNiceModHeavy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($PoisScythe) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($SilencingScythe) == $GUI_CHECKED And IsNiceModSilencing($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($FieryScythe) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($IcyScythe) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ShockingScythe) == $GUI_CHECKED And IsNiceModShock($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($FuriousScythe) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($SunderingScythe) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($VampiricScythe) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If  GuiCtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ZealousScythe) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If  GuiCtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($DefenseScythe) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ShelterScythe) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($WardingScythe) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($EnchantScythe) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($30HPScythe) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ScytheMaster) == $GUI_CHECKED And IsNiceModScytheMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($EbonScythe) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf

;Hammer Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($CruelHammer) == $GUI_CHECKED And IsNiceModCruel($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($HeavyHammer) == $GUI_CHECKED And IsNiceModHeavy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($EbonHammer) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($FieryHammer) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($IcyHammer) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ShockingHammer) == $GUI_CHECKED And IsNiceModShock($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($FuriousHammer) == $GUI_CHECKED And IsNiceModAdren($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($SunderingHammer) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($VampiricHammer) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ZealousHammer) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($DefenseHammer) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ShelterHammer) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($WardingHammer) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($EnchantHammer) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($30HPHammer) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($HammerMaster) == $GUI_CHECKED And IsNiceModHamMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($CharrHammer) == $GUI_CHECKED And IsNiceModCharrSlaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($DemonHammer) == $GUI_CHECKED And IsNiceModDemonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($DragonHammer) == $GUI_CHECKED And IsNiceModDragonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($DwarfHammer) == $GUI_CHECKED And IsNiceModDwarfslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($GiantHammer) == $GUI_CHECKED And IsNiceModGiantslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($OgreHammer) == $GUI_CHECKED And IsNiceModOgreslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($PruningHammer) == $GUI_CHECKED And IsNiceModPruning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($TenguHammer) == $GUI_CHECKED And IsNiceModTenguslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($TrollHammer) == $GUI_CHECKED And IsNiceModTrollslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($UndeadHammer) == $GUI_CHECKED And IsNiceModUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($SkeletonHammer) == $GUI_CHECKED And IsNiceModSkeletonslaying($aItem) Then
						Return False
					EndIf
						
;Bow Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ZealousBow) == $GUI_CHECKED And IsNiceModZeal($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($VampiricBow) == $GUI_CHECKED And IsNiceModVamp($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($EnchantBow) == $GUI_CHECKED And IsNiceModEnch($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($BarbedBow) == $GUI_CHECKED And IsNiceModBarbed($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($CripplingBow) == $GUI_CHECKED And IsNiceModCrippling($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($PoisBow) == $GUI_CHECKED And IsNiceModPoisonous($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($SilencingBow) == $GUI_CHECKED And IsNiceModSilencing($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($EbonBow) == $GUI_CHECKED And IsNiceModEbon($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($FireBow) == $GUI_CHECKED And IsNiceModFiery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($IcyBow) == $GUI_CHECKED And IsNiceModIcy($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ShockingBow) == $GUI_CHECKED And IsNiceModShock($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($SunderingBow) == $GUI_CHECKED And IsNiceModSundering($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($DefenseBow) == $GUI_CHECKED And IsNiceModDef($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ShelterBow) == $GUI_CHECKED And IsNiceModShelter($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($WardingBow) == $GUI_CHECKED And IsNiceModWard($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($30HPBow) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($MarksmanMaster) == $GUI_CHECKED And IsNiceModBowMastery($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($CharrBow) == $GUI_CHECKED And IsNiceModCharrSlaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($DemonBow) == $GUI_CHECKED And IsNiceModDemonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($DragonBow) == $GUI_CHECKED And IsNiceModDragonslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($DwarfBow) == $GUI_CHECKED And IsNiceModDwarfslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($GiantBow) == $GUI_CHECKED And IsNiceModGiantslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($OgreBow) == $GUI_CHECKED And IsNiceModOgreslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($PruningBow) == $GUI_CHECKED And IsNiceModPruning($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($TenguBow) == $GUI_CHECKED And IsNiceModTenguslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($TrollBow) == $GUI_CHECKED And IsNiceModTrollslaying($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($UndeadBow) == $GUI_CHECKED And IsNiceModUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($SkeletonBow) == $GUI_CHECKED And IsNiceModSkeletonslaying($aItem) Then
                        Return False
					EndIf
						
;Shield Mod Checks

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($30HPShield) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($45HPwEShield) == $GUI_CHECKED And IsNiceMod45HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($EnduranceShield) == $GUI_CHECKED And IsNiceMod45HPStance($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($ValorShield) == $GUI_CHECKED And IsNiceMod60HPHex($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($DemonShield) == $GUI_CHECKED And IsNiceModARDemons($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($UndeadShield) == $GUI_CHECKED And IsNiceModARUndead($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($SkeletonShield) == $GUI_CHECKED And IsNiceModARSkele($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_shield  And GuiCtrlRead($CharrShield) == $GUI_CHECKED And IsNiceModARCharr($aItem) Then
                        Return False
					EndIf
						
;Wand Mod Checks
 
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($MemoryWand) == $GUI_CHECKED And IsNiceModHSR20($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($QuickeningWand) == $GUI_CHECKED And IsNiceModHSR10($aItem) Then
                        Return False
					EndIf
				
;Offhand Mod Checks
				

				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($30HPOffhand) == $GUI_CHECKED And IsNiceMod30HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($AptitudeOffhand) == $GUI_CHECKED And IsNiceModHCT20($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($45HPwEOffhand) == $GUI_CHECKED And IsNiceMod45HP($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($45HPwStanceOffhand) == $GUI_CHECKED And IsNiceMod45HPStance($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($60wHexOffhand) == $GUI_CHECKED And IsNiceMod60HPHex($aItem) Then
                        Return False
					EndIf
				If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And $lType = $item_type_offhand  And GuiCtrlRead($SwiftnessOffhand) == $GUI_CHECKED And IsNiceModHCT10($aItem) Then
                        Return False
					EndIf

	;Inscripts Checks

		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($StrengthAndHonor) = $GUI_CHECKED And IsNiceModSaH($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($GuidedByFate) = $GUI_CHECKED And IsNiceModGbF($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($DanceWithDeath) = $GUI_CHECKED And IsNiceModDwD($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($TothePain) = $GUI_CHECKED And IsNiceModTtP($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($BrainOverBrains) = $GUI_CHECKED And IsNiceModBoB($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($TooMuchInfo) = $GUI_CHECKED And IsNiceModTMI($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($VengeanceIsMine) = $GUI_CHECKED And IsNiceModVIM($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($DontThinkTwice) = $GUI_CHECKED And IsNiceModHCT10($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($IHaveThePower) = $GUI_CHECKED And IsNiceMod5E($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($AptitudeNotAttitude) = $GUI_CHECKED And IsNiceModANA($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SeizeTheDay) = $GUI_CHECKED And IsNiceModSTD($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($HaleAndHearty) = $GUI_CHECKED And IsNiceMod5EAbove50($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($HaveFaith) = $GUI_CHECKED And IsNiceMod5E($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($DontCallComeback) = $GUI_CHECKED And IsNiceModHaveE7Below50($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($IAmSorrow) = $GUI_CHECKED And IsNiceModHave7EHex($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SerenityNow) = $GUI_CHECKED And IsNiceModHSR10($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ForgetMeNot) = $GUI_CHECKED And IsNiceModFMN($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($LiveForToday) = $GUI_CHECKED And IsNiceModLFT($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($FaithIsMyShield) = $GUI_CHECKED And IsNiceModFIMS($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($IgnoranceBliss) = $GUI_CHECKED And IsNiceModIIB($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($LifeIsPain) = $GUI_CHECKED And IsNiceModLIP($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ManForAllSeasons) = $GUI_CHECKED And IsNiceModMFAS($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SurvivalOfFittest) = $GUI_CHECKED And IsNiceModSOTF($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($MightMakesRight) = $GUI_CHECKED And IsNiceModMMR($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($KnowingIsHalfBattle) = $GUI_CHECKED And IsNiceModKIHTB($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($DownButNotOut) = $GUI_CHECKED And IsNiceModDBNO($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($HailToTheKing) = $GUI_CHECKED And IsNiceModHTTK($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($BeJustAndFearNot) = $GUI_CHECKED And IsNiceModBJAFN($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($LuckOfTheDraw) = $GUI_CHECKED And IsNiceModLOTD($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ShelteredByFaith) = $GUI_CHECKED And IsNiceModSBF($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($NothingToFear) = $GUI_CHECKED And IsNiceModNTF($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($RunForYourLife) = $GUI_CHECKED And IsNiceModRFYL($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($MasterOfMyDomain) = $GUI_CHECKED And IsNiceModMOMD($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($BluntArmor) = $GUI_CHECKED And IsNiceModBlunt($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ColdArmor) = $GUI_CHECKED And IsNiceModCold($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($EarthArmor) = $GUI_CHECKED And IsNiceModEarth($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($LightningArmor) = $GUI_CHECKED And IsNiceModLightning($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($FireArmor) = $GUI_CHECKED And IsNiceModFire($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($PiercingArmor) = $GUI_CHECKED And IsNiceModPierce($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SlashingArmor) = $GUI_CHECKED And IsNiceModSlashing($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($FearCutsDeeper) = $GUI_CHECKED And IsNiceModFCD($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ICanSeeClearly) = $GUI_CHECKED And IsNiceModBlind($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SwiftAsTheWind) = $GUI_CHECKED And IsNiceModCrip($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($StrengthOfBody) = $GUI_CHECKED And IsNiceModSOB($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($CastOutTheUnclean) = $GUI_CHECKED And IsNiceModCOTU($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($PureOfHeart) = $GUI_CHECKED And IsNiceModPoison($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($SoundnessOfMind) = $GUI_CHECKED And IsNiceModDaze($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($OnlyTheStrongSurvive) = $GUI_CHECKED And IsNiceModWeak($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($MeasureForMeasure) = $GUI_CHECKED And IsNiceModM4M($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($ShowMeTheMoney) = $GUI_CHECKED And IsNiceModSMTM($aItem) Then
			Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) = $GUI_CHECKED And GUICtrlRead($LetTheMemoryLiveAgain) = $GUI_CHECKED And IsNiceModHSR10($aItem) Then
			Return False
		EndIf
		
;Proffession Mod Checks

;Strength

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModStrength) == $GUI_CHECKED And IsNiceModStrength($aItem) Then
           Return False
		EndIf
		
		
;Expertise

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModExpertise) == $GUI_CHECKED And IsNiceModExpertise($aItem) Then
           Return False
		EndIf

;Soul Reaping

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModSoulReaping) == $GUI_CHECKED And IsNiceModSoulReaping($aItem) Then
           Return False
		EndIf
		
;Fast Casting

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModFastCasting) == $GUI_CHECKED And IsNiceModFastCasting($aItem) Then
           Return False
		EndIf
		
;Energy Storage

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModEnergyStorage) == $GUI_CHECKED And IsNiceModEnergyStorage($aItem) Then
           Return False
		EndIf
		
;Divine Favor

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModDivineFavor) == $GUI_CHECKED And IsNiceModDivineFavor($aItem) Then
           Return False
		EndIf
		
;Spawning power

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModSpawningPower) == $GUI_CHECKED And IsNiceModSpawningPower($aItem) Then
           Return False
		EndIf
		
;Crit Strikes

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModCritStrikes) == $GUI_CHECKED And IsNiceModCritStrikes($aItem) Then
           Return False
		EndIf
		
;Leadership

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe) == $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModLeadership) == $GUI_CHECKED And IsNiceModLeadership($aItem) Then
           Return False
		EndIf
		
;Mysticism

		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Axe) == $GUI_CHECKED And $lType = $item_type_axe  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Bow) == $GUI_CHECKED And $lType = $item_type_bow  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Hammer) == $GUI_CHECKED And $lType = $item_type_hammer  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Wand) == $GUI_CHECKED And $lType = $item_type_wand  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Sword) == $GUI_CHECKED And $lType = $item_type_sword  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Dagger) == $GUI_CHECKED And $lType = $item_type_dagger  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Scythe)== $GUI_CHECKED And $lType = $item_type_scythe  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Spear) == $GUI_CHECKED And $lType = $item_type_spear  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf
		If GUICtrlRead($cbx_keep_mods) == $GUI_CHECKED And GUICtrlRead($WeaponType_Staff) == $GUI_CHECKED And $lType = $item_type_staff  And GuiCtrlRead($ProfModMysticism) == $GUI_CHECKED And IsNiceModMysticism($aItem) Then
           Return False
		EndIf

		

    ; Switch $IsShield
    ;     Case True
    ;         Return False ; Is perfect shield
    ; EndSwitch

    ; Switch $Type
    ;     Case 12 ; Offhands
    ;         If $IsCaster = True Then
    ;             Return False ; Is perfect offhand
    ;         Else
    ;             Return True
    ;         EndIf
    ;     Case 22 ; Wands
    ;         If $IsCaster = True Then
    ;             Return False ; Is perfect wand
    ;         Else
    ;             Return True
    ;         EndIf
    ;     Case 26 ; Staves
    ;         If $IsStaff = True Then
    ;             Return False ; Is perfect Staff
    ;         Else
    ;             Return True
    ;         EndIf
    ; EndSwitch

	If CheckArrayTomes($LMODELID) Then Return False
	If CheckArrayMaterials($LMODELID) Then Return False
	If CheckArrayRareMaterials($LMODELID) Then Return False
	If CheckArrayWeaponMods($LMODELID) Then Return False
	If CheckArrayGeneralItems($LMODELID) Then Return False
	If CheckArrayPscon($LMODELID) Then Return False
	If CheckArrayMapPieces($LMODELID) Then Return False

    Switch $IsRune
    Case True
        Return False
    EndSwitch
	
	Switch $LMODELID
		 Case $MODEL_ID_Greater_Etched_Sword, $MODEL_ID_Etched_Sword, $MODEL_ID_Lesser_Etched_Sword
			 Return True
		Case $ITEM_ID_Dyes
			Switch DllStructGetData($aItem, "ExtraID")
				Case $ITEM_ExtraID_BlackDye, $ITEM_ExtraID_WhiteDye
					Return False
				Case Else
					Return True
			EndSwitch
	EndSwitch

	If IsEotN20thAnniversaryWeapon($aItem) And $Requirement = 9 Then Return False
	If IsAnyCampaign20thAnniversaryWeapon($aItem) And $Requirement = 9 Then Return False

	Switch $LRARITY
		Case $RARITY_Gold
			Switch GUICtrlRead($cbx_store_golds)
				Case $GUI_CHECKED
					Return False
			EndSwitch
			Switch GUICtrlRead($cbx_sell_golds)
				Case $GUI_CHECKED
					Return True
			EndSwitch
		Case $RARITY_Purple
			Return True
		Case $RARITY_Blue, $RARITY_White
			Return False
	EndSwitch

	If CheckArrayTomes($LMODELID) Then Return False
	If CheckArrayMaterials($LMODELID) Then Return False
	If CheckArrayRareMaterials($LMODELID) Then Return False
	If CheckArrayWeaponMods($LMODELID) Then Return False
	If CheckArrayGeneralItems($LMODELID) Then Return False
	If CheckArrayPscon($LMODELID) Then Return False
	If CheckArrayMapPieces($LMODELID) Then Return False

	Return True
EndFunc   ;==>CanSell

Func WantToSalvageForMats($aType)
	Local $aItem
	Local $TyriaAnniversary = IsTyria20thAnniversaryWeapon($aItem)
	Local $CanthaAnniversary = IsCantha20thAnniversaryWeapon($aItem)
	Local $ElonaAnniversary = IsElona20thAnniversaryWeapon($aItem)
	Local $EotNAnniversary = IsEotN20thAnniversaryWeapon($aItem)
	Local $AnyCampaignAnniversary = IsAnyCampaign20thAnniversaryWeapon($aItem)


	If $aType = $item_type_axe Then Return True			; Axe
	If $aType = $item_type_bow Then Return True			; Bow
	If $aType = $item_type_offhand Then Return True		; Offhand
	If $aType = $item_type_hammer Then Return True		; Hammer
	If $aType = $item_type_wand Then Return True		; Wand
	If $aType = $item_type_shield Then Return True		; Shield
	If $aType = $item_type_staff Then Return True		; Staff
	If $aType = $item_type_sword Then Return True		; Sword
	If $aType = $item_type_dagger Then Return True		; Daggers
	If $aType = $item_type_scythe Then Return True		; Scythe
	If $aType = $item_type_spear Then Return True		; Spear
	;If $TyriaAnniversary Then Return False
	;If $CanthaAnniversary Then Return False
	;If $ElonaAnniversary Then Return False
	;If $EotNAnniversary Then Return False
	;If $AnyCampaignAnniversary Then Return False
	Return False
EndFunc ;==>WantToSalvageForMats

Func UpdateStatistics($aSuccess)
	Local $lRunTime = Round(TimerDiff($tRunTimer)/1000) ; divide to turn ms into seconds
	Out("Last Run: " & GetTimeString($lRunTime))
	
	If $aSuccess = 1 Then
		$TimeTotal += $lRunTime
		$TimeRunAverage = Round($TimeTotal/$RunCount)
		GUICtrlSetData($AverageTimeLabel, GetTimeString($TimeRunAverage))
	EndIf
EndFunc ;==> UpdateStatistics

; Converts an Input in Seconds to a HH:MM:SS format
Func GetTimeString($aSeconds)
	Local $tmpMinutes = Floor($aSeconds/60) ; total amount of minutes
	Local $lHours = Floor($tmpMinutes/60) ; amount of hours, result
	Local $lSeconds = $aSeconds - $tmpMinutes*60 ; seconds in the current minute, result
	Local $lMinutes = $tmpMinutes - $lHours*60 ; minutes in the current hour, result
	Local $lTimeString = ""
	
	If $lHours < 10 Then
		If $lMinutes < 10 Then
			If $lSeconds < 10 Then
				$lTimeString = '0' & $lHours & ':0' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = '0' & $lHours & ':0' & $lMinutes & ':' & $lSeconds
			EndIf
		ElseIf $lMinutes >= 10 Then
			If $lSeconds < 10 Then
				$lTimeString = '0' & $lHours & ':' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = '0' & $lHours & ':' & $lMinutes & ':' & $lSeconds
			EndIf
		EndIf
	ElseIf $lHours >= 10 Then
		If $lMinutes < 10 Then
			If $lSeconds < 10 Then
				$lTimeString = $lHours & ':0' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = $lHours & ':0' & $lMinutes & ':' & $lSeconds
			EndIf
		ElseIf $lMinutes >= 10 Then
			If $lSeconds < 10 Then
				$lTimeString = $lHours & ':' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = $lHours & ':' & $lMinutes & ':' & $lSeconds
			EndIf
		EndIf
	EndIf
	Return $lTimeString
EndFunc ;==> GetTimeString

Func TimeUpdater()
	$TotalSeconds += 5
	GUICtrlSetData($TotalTimeLabel, GetTimeString($TotalSeconds))
EndFunc

;~ Description: Print to console with timestamp
Func Out($msg)
	GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

;~ Description: guess what?
Func _exit()
	If GUICtrlRead($RenderingBox) = $GUI_CHECKED Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		Sleep(500)
	EndIf
	Exit
EndFunc

Func ToggleOnTop()
   If BitAND(GUICtrlRead($OnTopBox), $GUI_CHECKED) Then
	  WinSetOnTop($mainGui, "", 1)
   Else
	  WinSetOnTop($mainGui, "", 0)
   EndIf
EndFunc ;==>Toggles GUI always on top

#CS
Func ToggleRendering()
   If GUICtrlRead($RenderingBox) = $GUI_UNCHECKED Then
	  EnableRendering()
	  WinSetState(GetWindowHandle(), "", @SW_SHOW)
	  $RenderingEnabled = True
   Else
	  DisableRendering()
	  WinSetState(GetWindowHandle(), "", @SW_HIDE)
	  ClearMemory()
	  $RenderingEnabled = False
   EndIf
   Return True
EndFunc
#CE

Func EndRunningGW()
	Local $list = ProcessList("gw.exe")
    For $i = 1 to $list[0][0]
		$pid = $list[$i][1]
		Local $hProc = DllCall("kernel32.dll", "int", "OpenProcess", "int", 0x0410, "int", False, "int", $pid)
		If $hProc[0] Then
			Local $stHMod = DllStructCreate("int hMod")
			Local $stCB = DllStructCreate("dword cbNeeded")
			Local $resEnum = DllCall("psapi.dll", "int", "EnumProcessModules", "int", $hProc[0], "ptr", DllStructGetPtr($stHMod), "dword", DllStructGetSize($stHMod), "ptr", DllStructGetPtr($stCB, 1))
			If $resEnum[0] Then
				Local $resPath = DllCall("psapi.dll", "int", "GetModuleFileNameEx", "int", $hProc[0], "int", DllStructGetData($stHMod, 1), "str", "", "dword", 32768)
				   If ('"' & $resPath[3] & '"') = $GWEXE Then
					  Out("Ending running gw.exe")
					  ProcessClose($pid)
				   EndIf
				EndIf
			$stHMod = 0
			$stCB = 0
			DllCall("kernel32.dll", 'int', 'CloseHandle', 'int', $hProc[0])
		EndIf
    Next
	Sleep(5000)
EndFunc ;==>EndRunningGW

Func LaunchGW()
	Local $Run = $MultiLaunchEXE & " " & $GWEXE & ' -password ' & $Password & ' -character "' & $Character & '"'
	Out($Run)
	$gPID = Run($Run)
	GUICtrlSetData($CharInput, $CmdLine[1], $CmdLine[1])
	Sleep(30000)
	Out("Initializing!")
	Initialize($Character, True)
	Sleep(1000)
	$HWND = GetWindowHandle()
	;Sleep(1000)
	GUICtrlSetState($CharInput, $GUI_DISABLE)
	ControlSend($HWND, "", "", "{Enter}")
	Sleep(4000)
	ControlSend($HWND, "", "", "{Enter}")
	Sleep(2000)
	ControlSend($HWND, "", "", "{Enter}")
	Sleep(2000)
	; ControlSend($HWND, "", "", "{Enter}")
	; Sleep(2000)
	Local $charname = GetCharname()
	GUICtrlSetData($CharInput, $charname, $charname)
	GUICtrlSetData($Button, "Pause")
	GUICtrlSetState($RenderingBox, $GUI_ENABLE)
	WinSetTitle($mainGui, "", "Vaettir Bot - " & $charname)
	WinMove($mainGui, "", $xPos, $yPos)
	Sleep(1000)
	WinMove($HWND, "", $gwX, $gwY, $gwWidth, $gwHeight)
	Sleep(1000)
	$BotRunning = True
	$BotInitialized = True
	SetMaxMemory()
EndFunc ;==>LaunchGW

Func IAmDisconnected()
	If GetInstanceType() <> 2 And GetAgentExists(-2) Then
		Return False
	Else
		Return True
	EndIf
EndFunc ;==>IAmDisconnected

Func RestartBot()
	ProcessClose($gPID)
	Sleep(2000)
	EndRunningGW()
	
	If $gCharSet = True Then
		Local $Run = $AUTOITEXE & " " & '"' & $SCRIPTAU3 & '"' & " " & '"' & $Character & '"'
		Run($Run)
		Sleep(1000)
	EndIf
	Exit
EndFunc

Func SetAccountVariables($aCharacterName)
	For $i=0 To Ubound($Accounts)-1
		If $Accounts[$i][1] == $aCharactername Then
			$Email = $Accounts[$i][0]
			$Character = $Accounts[$i][1]
			$Password = $Accounts[$i][2]
			$GWEXE = $Accounts[$i][3]
			$xPos = $Accounts[$i][4]
			$yPos = $Accounts[$i][5]
			$gwX = $Accounts[$i][6]
			$gwY = $Accounts[$i][7]
			$gwWidth = $Accounts[$i][8]
			$gwHeight = $Accounts[$i][9]
			$gCharSet = True
			Out("Setting character: " & $Accounts[$i][1])
			Return True
		EndIf
	Next

	$gCharSet = False
	Out("Character not found in VaettirAccounts.au3.")
	Out("If the Game crashes the Bot can't do an automatic Restart.")
	Return False
	; Out("Character not found in vaettir.au3, cannot proceed")
	; Sleep(60000)
	; Exit
EndFunc ;==>SetAccountVariables


Func CheckGold()
	Local $GCHARACTER = GetGoldCharacter()
	Local $GSTORAGE = GetGoldStorage()
	Local $GDIFFERENCE = ($GSTORAGE - $GCHARACTER)
	If $GCHARACTER <= 1000 Then
		Switch $GSTORAGE
			Case 100000 To 1000000
				WithdrawGold(100000 - $GCHARACTER)
				Sleep(500 + 3 * GetPing())
			Case 1 To 99999
				WithdrawGold($GDIFFERENCE)
				Sleep(500 + 3 * GetPing())
			Case 0
				Out("Out of cash, beginning farm")
				Return False
		EndSwitch
	EndIf
	Return True
EndFunc   ;==>CHECKGOLD

#Region Checking Guild Hall
;~ Checks to see which Guild Hall you are in and the spawn point
Func CheckGuildHall()
	If GetMapID() == $GH_ID_Warriors_Isle Then
		$WarriorsIsle = True
		Out("Warrior's Isle")
	EndIf
	If GetMapID() == $GH_ID_Hunters_Isle Then
		$HuntersIsle = True
		Out("Hunter's Isle")
	EndIf
	If GetMapID() == $GH_ID_Wizards_Isle Then
		$WizardsIsle = True
		Out("Wizard's Isle")
	EndIf
	If GetMapID() == $GH_ID_Burning_Isle Then
		$BurningIsle = True
		Out("Burning Isle")
	EndIf
	If GetMapID() == $GH_ID_Frozen_Isle Then
		$FrozenIsle = True
		Out("Frozen Isle")
	EndIf
	If GetMapID() == $GH_ID_Nomads_Isle Then
		$NomadsIsle = True
		Out("Nomad's Isle")
	EndIf
	If GetMapID() == $GH_ID_Druids_Isle Then
		$DruidsIsle = True
		Out("Druid's Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_The_Dead Then
		$IsleOfTheDead = True
		Out("Isle of the Dead")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Weeping_Stone Then
		$IsleOfWeepingStone = True
		Out("Isle of Weeping Stone")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Jade Then
		$IsleOfJade = True
		Out("Isle of Jade")
	EndIf
	If GetMapID() == $GH_ID_Imperial_Isle Then
		$ImperialIsle = True
		Out("Imperial Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Meditation Then
		$IsleOfMeditation = True
		Out("Isle of Meditation")
	EndIf
	If GetMapID() == $GH_ID_Uncharted_Isle Then
		$UnchartedIsle = True
		Out("Uncharted Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Wurms Then
		$IsleOfWurms = True
		Out("Isle of Wurms")
		If $IsleOfWurms = True Then
			CheckIsleOfWurms()
		EndIf
	EndIf
	If GetMapID() == $GH_ID_Corrupted_Isle Then
		$CorruptedIsle = True
		Out("Corrupted Isle")
		If $CorruptedIsle = True Then
			CheckCorruptedIsle()
		EndIf
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Solitude Then
		$IsleOfSolitude = True
		Out("Isle of Solitude")
	EndIf
EndFunc ;~ Check Guild halls

;~ If there is a missing Guild Hall from the below listing, it is because there is only 1 spawn point in that Guild Hall
Func CheckIsleOfWurms()
	If CheckArea(8682, 2265) Then
		OUT("Start Point 1")
		If Waypoint1() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(6697, 3631) Then
		OUT("Start Point 2")
		If Waypoint2() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(6716, 2929) Then
		OUT("Start Point 3")
		If Waypoint3() Then
			Return True
		Else
			Return False
		EndIf
	Else
		OUT("Where the fuck am I?")
		Return False
	EndIf
EndFunc

Func CheckCorruptedIsle()
	If CheckArea(-4830, 5985) Then
		OUT("Start Point 1")
		If Waypoint4() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(-3778, 6214) Then
		OUT("Start Point 2")
		If Waypoint5() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(-5209, 4468) Then
		OUT("Start Point 3")
		If Waypoint6() Then
			Return True
		Else
			Return False
		EndIf
	Else
		OUT("Where the fuck am I?")
		Return False
	EndIf
EndFunc

Func Waypoint1()
	MoveTo(8263, 2971)
EndFunc

Func Waypoint2()
	MoveTo(7086, 2983)
	MoveTo(8263, 2971)
EndFunc

Func Waypoint3()
	MoveTo(8263, 2971)
EndFunc

Func Waypoint4()
	MoveTo(-4830, 5985)
EndFunc

Func Waypoint5()
	MoveTo(-3778, 6214)
EndFunc

Func Waypoint6()
	MoveTo(-4352, 5232)
EndFunc

Func Chest()
	Dim $Waypoints_by_XunlaiChest[16][3] = [ _
			[$BurningIsle, -5285, -2545], _
			[$DruidsIsle, -1792, 5444], _
			[$FrozenIsle, -115, 3775], _
			[$HuntersIsle, 4855, 7527], _
			[$IsleOfTheDead, -4562, -1525], _
			[$NomadsIsle, 4630, 4580], _
			[$WarriorsIsle, 4224, 7006], _
			[$WizardsIsle, 4858, 9446], _
			[$ImperialIsle, 2184, 13125], _
			[$IsleOfJade, 8614, 2660], _
			[$IsleOfMeditation, -726, 7630], _
			[$IsleOfWeepingStone, -1573, 7303], _
			[$CorruptedIsle, -4868, 5998], _
			[$IsleOfSolitude, 4478, 3055], _
			[$IsleOfWurms, 8586, 3603], _
			[$UnchartedIsle, 4522, -4451]]
	For $i = 0 To (UBound($Waypoints_by_XunlaiChest) - 1)
		If ($Waypoints_by_XunlaiChest[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_XunlaiChest[$i][1], $Waypoints_by_XunlaiChest[$i][2], Random(60, 80, 2))
			Until CheckAreaRange($Waypoints_by_XunlaiChest[$i][1], $Waypoints_by_XunlaiChest[$i][2], 1250)
		EndIf
	Next
	Local $aChestName = "Xunlai Chest"
	Local $lChest = GetAgentByName($aChestName)
	If IsDllStruct($lChest)Then
		Out("Going to " & $aChestName)
		GoToNPC($lChest)
		RndSleep(Random(3000, 4200))
	EndIf
EndFunc ;~ Xunlai Chest

Func Merchant()
	Dim $Waypoints_by_Merchant[29][3] = [ _
			[$BurningIsle, -4439, -2088], _
			[$BurningIsle, -4772, -362], _
			[$BurningIsle, -3637, 1088], _
			[$BurningIsle, -2506, 988], _
			[$DruidsIsle, -2037, 2964], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, -299, 79], _
			[$HuntersIsle, 5156, 7789], _
			[$HuntersIsle, 4416, 5656], _
			[$IsleOfTheDead, -4066, -1203], _
			[$NomadsIsle, 5129, 4748], _
			[$WarriorsIsle, 4159, 8540], _
			[$WarriorsIsle, 5575, 9054], _
			[$WizardsIsle, 4288, 8263], _
			[$WizardsIsle, 3583, 9040], _
			[$ImperialIsle, 1415, 12448], _
			[$ImperialIsle, 1746, 11516], _
			[$IsleOfJade, 8825, 3384], _
			[$IsleOfJade, 10142, 3116], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$CorruptedIsle, -4670, 5630], _
			[$IsleOfSolitude, 2970, 1532], _
			[$IsleOfWurms, 8284, 3578], _
			[$UnchartedIsle, 1503, -2830]]
	For $i = 0 To (UBound($Waypoints_by_Merchant) - 1)
		If ($Waypoints_by_Merchant[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_Merchant[$i][1], $Waypoints_by_Merchant[$i][2], Random(60, 80, 2))
			Until CheckAreaRange($Waypoints_by_Merchant[$i][1], $Waypoints_by_Merchant[$i][2], 1250)
		EndIf
	Next
	
	Out("Going to Merchant")

	Do
        Sleep(250 + 3 * GetPing())
		Local $Me = GetAgentByID(-2)
        Local $guy = GetNearestNPCToCoords(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
    Until DllStructGetData($guy, 'Id') <> 0
    ChangeTarget($guy)
    Sleep(250 + 3 * GetPing())
    GoNPC($guy)
    Sleep(250 + 3 * GetPing())
    Do
        MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(Random(500,750))
        GoNPC($guy)
        RndSleep(Random(250,500))
        Local $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(Random(1000,1500))

EndFunc ;~ Merchant

Func RareMaterialTrader()
LOCAL $TRADERPRICE

	Dim $Waypoints_by_RareMatTrader[36][3] = [ _
			[$BurningIsle, -3793, 1069], _
			[$BurningIsle, -2798, -74], _
			[$DruidsIsle, -989, 4493], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, -385, 3254], _
			[$FrozenIsle, -983, 3195], _
			[$HuntersIsle, 3267, 6557], _
			[$IsleOfTheDead, -3415, -1658], _
			[$NomadsIsle, 1930, 4129], _
			[$NomadsIsle, 462, 4094], _
			[$WarriorsIsle, 4108, 8404], _
			[$WarriorsIsle, 3403, 6583], _
			[$WarriorsIsle, 3415, 5617], _
			[$WizardsIsle, 3610, 9619], _
			[$ImperialIsle, 759, 11465], _
			[$IsleOfJade, 8919, 3459], _
			[$IsleOfJade, 6789, 2781], _
			[$IsleOfJade, 6566, 2248], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, 422, 8769], _
			[$IsleOfMeditation, 549, 9531], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -2431, 7946], _
			[$IsleOfWeepingStone, -1618, 8797], _
			[$CorruptedIsle, -4424, 5645], _
			[$CorruptedIsle, -4443, 4679], _
			[$IsleOfSolitude, 3172, 3728], _
			[$IsleOfSolitude, 3221, 4789], _
			[$IsleOfSolitude, 3745, 4542], _
			[$IsleOfWurms, 8353, 2995], _
			[$IsleOfWurms, 6708, 3093], _
			[$UnchartedIsle, 2530, -2403]]
	For $i = 0 To (UBound($Waypoints_by_RareMatTrader) - 1)
		If ($Waypoints_by_RareMatTrader[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_RareMatTrader[$i][1], $Waypoints_by_RareMatTrader[$i][2], Random(60, 80, 2))
			Until CheckAreaRange($Waypoints_by_RareMatTrader[$i][1], $Waypoints_by_RareMatTrader[$i][2], 1250)
		EndIf
	Next

	Out("Going to Rare Material Trader")
	Do
        RndSleep(Random(250,500))
		Local $Me = GetAgentByID(-2)
        Local $guy = GetNearestNPCToCoords(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
    Until DllStructGetData($guy, 'Id') <> 0
    ChangeTarget($guy)
    RndSleep(Random(250,500))
    GoNPC($guy)
    RndSleep(Random(250,500))
    Do
        MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(Random(500,750))
        GoNPC($guy)
        RndSleep(Random(250,500))
        Local $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(Random(1000,1500))



	While GetGoldCharacter() > 20*1000
		Out("Buying Rare Materials")
		TraderRequest($MATID)
		Sleep(1000 + 3 * GetPing())
		$TRADERPRICE = GETTRADERCOSTVALUE()
		TraderBuy()
	WEnd
EndFunc   ;~ Rare Material trader
#EndRegion Checking Guild Hall

Func MatSwitcher()
	$RAREMATSBUY = False
	Out("$RareMatsBuy" & $RAREMATSBUY)
	For $i = 0 To UBound($PIC_MATS) - 1
		If (GUICtrlRead($SELECTMAT, "") == $PIC_MATS[$i][0]) Then
			$MATID = $PIC_MATS[$i][1]
			$RAREMATSBUY = True
			Out("$RareMatsBuy" & $RAREMATSBUY)
			Out("You Select - " & $PIC_MATS[$i][0])
			Out("Mat Model ID == " & "" & $MATID)
		EndIf
	Next
EndFunc   ;==>MATSWITCHER

Func START_STOP()
	Switch (@GUI_CtrlId)
		Case $SELECTMAT
			MatSwitcher()
	EndSwitch
EndFunc   ;==>START_STOP

Func WaitForMapLoading()
    Local $iCurrentMap

    Do
        Sleep(250) ; Small delay to prevent excessive polling
        $iCurrentMap = GetMapID() ; Fetches the current map ID
    Until _ArraySearch($GH_Array, $iCurrentMap) <> -1

    Return $iCurrentMap
EndFunc

Func GetMapID_Log()
    Local $mapID = GetMapID() ; Retrieve the current Map ID
    
    If @error Then
        Out("Error retrieving Map ID.")
        Return -1 ; Indicate an error
    EndIf
    
    Out("Current Map ID: " & $mapID)
    Return $mapID
EndFunc

Func GenericRandomPath($aPosX, $aPosY, $aRandom = 50, $STOPSMIN = 1, $STOPSMAX = 5, $NUMBEROFSTOPS = -1)
	If $NUMBEROFSTOPS = -1 Then $NUMBEROFSTOPS = Random($STOPSMIN, $STOPSMAX, 1)
	Local $lAgent = GetAgentByID(-2)
	Local $MYPOSX = DllStructGetData($lAgent, "X")
	Local $MYPOSY = DllStructGetData($lAgent, "Y")
	Local $DISTANCE = ComputeDistance($MYPOSX, $MYPOSY, $aPosX, $aPosY)
	If $NUMBEROFSTOPS = 0 Or $DISTANCE < 200 Then
		MoveTo($aPosX, $aPosY, $aRandom)
	Else
		Local $M = Random(0, 1)
		Local $N = $NUMBEROFSTOPS - $M
		Local $STEPX = (($M * $aPosX) + ($N * $MYPOSX)) / ($M + $N)
		Local $STEPY = (($M * $aPosY) + ($N * $MYPOSY)) / ($M + $N)
		MoveTo($STEPX, $STEPY, $aRandom)
		GenericRandomPath($aPosX, $aPosY, $aRandom, $STOPSMIN, $STOPSMAX, $NUMBEROFSTOPS - 1)
	EndIf
EndFunc   ;==>GENERICRANDOMPATH

#Region Arrays
Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc

Func CheckArrayGeneralItems($lModelID)
	For $p = 0 To (UBound($General_Items_Array) -1)
		If ($lModelID == $General_Items_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayWeaponMods($lModelID)
	For $p = 0 To (UBound($Weapon_Mod_Array) -1)
		If ($lModelID == $Weapon_Mod_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayTomes($lModelID)
	For $p = 0 To (UBound($All_Tomes_Array) -1)
		If ($lModelID == $All_Tomes_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayMaterials($lModelID)
	For $p = 0 To (UBound($All_Materials_Array) -1)
		If ($lModelID == $All_Materials_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayRareMaterials($lModelID)
	For $p = 0 To (UBound($Rare_Materials_Array) -1)
		If ($lModelID == $Rare_Materials_Array[$p]) Then Return True
	Next
EndFunc


Func CheckArrayMapPieces($lModelID)
	For $p = 0 To (UBound($Map_Piece_Array) -1)
		If ($lModelID == $Map_Piece_Array[$p]) Then Return True
	Next
EndFunc
#EndRegion Arrays