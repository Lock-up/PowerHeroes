#http://www.techotopia.com/index.php/Drawing_Graphics_using_PowerShell_1.0_and_GDI%2B

#Set-ExecutionPolicy Unrestricted

# load forms (GUI)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing.Icon") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing.Graphics")
# Mediaplayer
Add-Type -AssemblyName PresentationCore
# Visual Styles
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

# STA Modus (Single Threading Apartment) - benötigt für OpenFileDialog
try {[threading.thread]::CurrentThread.SetApartmentState(0)}
catch { Write-Host "ERROR: [threading.thread]::CurrentThread.SetApartmentState(0)"}


$global:arrWindows = @{}
$global:windowOpen = $False;
$global:strCurrentWindow = "";

$global:arrSettings = @{}
$global:arrSettings["TOPMOST"] = $False;
$global:arrSettings["SIZE"] = 1;
$global:arrSettings["STARTUPSIZE"] = 1;
$global:arrSettings["VOLUMEMUSIC"] = 0.2;
$global:arrSettings["VOLUMEEFFECTS"] = 0.2;
$global:arrSettings["TILESIZE"] = 16;
$global:arrSettings["BUILDINGS_CIVIL"] = 7;
$global:arrSettings["BUILDINGS_SELECTED"] = -1;

$global:arrMap = @{}
$global:arrMap["AUTHOR"] = "The Author"
$global:arrMap["MAPNAME"] = "The Name"
$global:arrMap["WIDTH"] = 0
$global:arrMap["HEIGHT"] = 0
$global:arrMap["BUILDING_INDEX"] = 0
$global:arrMap["PLAYER_01X"] = -1
$global:arrMap["PLAYER_01Y"] = -1
$global:arrMap["PLAYER_02X"] = -1
$global:arrMap["PLAYER_02Y"] = -1
$global:arrMap["PLAYER_03X"] = -1
$global:arrMap["PLAYER_03Y"] = -1
$global:arrMap["PLAYER_04X"] = -1
$global:arrMap["PLAYER_04Y"] = -1
$global:arrMap["WORLD_L1"] = @{}
$global:arrMap["WORLD_L2"] = @{}
$global:arrMap["WORLD_L3"] = @{}
$global:arrMap["WORLD_LBLD"] = @{} # Buildings are referenced by ID, ID = -1 => no building, everything else = building in a building array. At first the building array should include player start positions.



# ideas for bld table
# ID, ID = index
# PosX
# PosY
# Owner
# HP
# Type
#####
$global:arrBuildings = @{}
$global:arrBuildings[0] = @{}
$global:arrBuildings[0].loc_x = 0
$global:arrBuildings[0].loc_y = 0
$global:arrBuildings[0].owner = 0
$global:arrBuildings[0].type = 0
$global:arrBuildings[0].hitpoints = 0

# functions für
# addBLDAt -> fill WORLD_LBLD, fill $global:arrBuildings, image
# DamageBLDAt -> update $global:arrBuildings
# GetBLDAt -> read WORLD_LBLD
# RemoveBLDAt -> update WORLD_LBLD, fill $global:arrBuildings, image


# colors:
# DARK: 128,0,128
# LIGHT: 255,0,255
# P1:
# 55, 104, 97
# 104, 136, 187
# P2:
# 55, 173, 64
# 63, 201, 79
# P3:
# 118, 43, 26
# 212, 51, 24
# P4:
# 165, 111, 23
# 247, 183, 40

$global:arrColors = @{}
$global:arrColors["CLR_BLACK"] = [System.Drawing.Color]::FromArgb(0, 0, 0);
$global:arrColors["CLR_MAGENTA"] = [System.Drawing.Color]::FromArgb(255, 0, 143)
$global:arrColors["CLR_GOLD_1"] = [System.Drawing.Color]::FromArgb(255, 255, 0)
$global:arrColors["CLR_GOLD_2"] = [System.Drawing.Color]::FromArgb(255, 219, 23)
$global:arrColors["CLR_GOLD_3"] = [System.Drawing.Color]::FromArgb(255, 191, 51)
$global:arrColors["CLR_BLUE_1"] = [System.Drawing.Color]::FromArgb(0, 211, 247)
$global:arrColors["CLR_BLUE_2"] = [System.Drawing.Color]::FromArgb(0, 123, 219)
$global:arrColors["CLR_BLUE_3"] = [System.Drawing.Color]::FromArgb(0, 55, 191)

$global:arrColors["CLR_PLAYER_DEF00"] = [System.Drawing.Color]::FromArgb(128,0,128)
$global:arrColors["CLR_PLAYER_DEF01"] = [System.Drawing.Color]::FromArgb(255,0,255)

$global:arrColors["CLR_PLAYER_00"] = [System.Drawing.Color]::FromArgb(144,144,144)
$global:arrColors["CLR_PLAYER_01"] = [System.Drawing.Color]::FromArgb(177,177,177)

$global:arrColors["CLR_PLAYER_10"] = [System.Drawing.Color]::FromArgb(55, 104, 97)
$global:arrColors["CLR_PLAYER_11"] = [System.Drawing.Color]::FromArgb(104, 136, 187)

$global:arrColors["CLR_PLAYER_20"] = [System.Drawing.Color]::FromArgb(55, 173, 64)
$global:arrColors["CLR_PLAYER_21"] = [System.Drawing.Color]::FromArgb(63, 201, 79)

$global:arrColors["CLR_PLAYER_30"] = [System.Drawing.Color]::FromArgb(118, 43, 26)
$global:arrColors["CLR_PLAYER_31"] = [System.Drawing.Color]::FromArgb(212, 51, 24)

$global:arrColors["CLR_PLAYER_40"] = [System.Drawing.Color]::FromArgb(165, 111, 23)
$global:arrColors["CLR_PLAYER_41"] = [System.Drawing.Color]::FromArgb(247, 183, 40)

$global:strGameState = "WAIT_INIT_CLICK"
$global:strMapFile = "";

$black          = [System.Drawing.Color]::FromArgb(0, 0, 0)
$transparent    = [System.Drawing.Color]::FromArgb(255, 0, 143)

$color_gold     = [System.Drawing.Color]::FromArgb(255, 255, 0)
$color_gold_1   = [System.Drawing.Color]::FromArgb(255, 219, 23)
$color_gold_2   = [System.Drawing.Color]::FromArgb(255, 191, 51)

$color_blue     = [System.Drawing.Color]::FromArgb(0, 211, 247)
$color_blue_1   = [System.Drawing.Color]::FromArgb(0, 123, 219)
$color_blue_2   = [System.Drawing.Color]::FromArgb(0, 55, 191)

$global:arrCreateMapOptions = @{}
$global:arrCreateMapOptions["WIDTH"] = 32;
$global:arrCreateMapOptions["HEIGHT"] = 32;
$global:arrCreateMapOptions["BASTEXTUREID"] = 0;
$global:arrCreateMapOptions["EDITOR_CHUNK_X"] = 0;
$global:arrCreateMapOptions["EDITOR_CHUNK_Y"] = 0;
$global:arrCreateMapOptions["EDIT_MODE"] = 0;
$global:arrCreateMapOptions["CLICK_MODE"] = 0;
$global:arrCreateMapOptions["IDX_LAYER01"] = 0;
$global:arrCreateMapOptions["IDX_LAYER02"] = 0;
$global:arrCreateMapOptions["IDX_LAYER03"] = 0;
$global:arrCreateMapOptions["SELECT_LAYER01"] = 0;
$global:arrCreateMapOptions["SELECT_LAYER02"] = 0;
$global:arrCreateMapOptions["SELECT_LAYER03"] = 0;
$global:arrCreateMapOptions["SELECT_PLAYER"] = 0;
$global:arrCreateMapOptions["LAST_CHANGED_TEX"] = 0;
$global:arrCreateMapOptions["LAST_MODE"] = 0;
$global:arrCreateMapOptions["LAST_CHANGED_X"] = 0;
$global:arrCreateMapOptions["LAST_CHANGED_Y"] = 0;
$global:arrCreateMapOptions["SELECTED_X"] = 0;
$global:arrCreateMapOptions["SELECTED_Y"] = 0;
$global:arrCreateMapOptions["SHOW_PREVIEW"] = $False;

# All textures shown in the editor at the first tab
$arrBaseTextureIDToKey = "GROUND_GREEN_01", "GROUND_GREEN_02", "GROUND_GREEN_03", "GROUND_GREEN_04", "GROUND_WATER_01", "GROUND_EMPTY_01"

# All textures shown in the editor at the 2nd tab
# 0 - 11 invalid
# 12 - 22 valid
# 23 - x invalid
$arrOverlayTextureIDToKey = "LAYER_EDGE_01", "LAYER_EDGE_02", "LAYER_EDGE_03", "LAYER_EDGE_04", "LAYER_EDGE_05", "LAYER_EDGE_06", "LAYER_EDGE_07", "LAYER_EDGE_08", "LAYER_EDGE_09", "LAYER_EDGE_11", "LAYER_EDGE_13", "LAYER_EDGE_15", `
"LAYER_PATH_01", "LAYER_PATH_02", "LAYER_PATH_03", "LAYER_PATH_04", "LAYER_PATH_05", "LAYER_PATH_06", "LAYER_PATH_07", "LAYER_PATH_08", "LAYER_PATH_09", "LAYER_PATH_10", "LAYER_PATH_11", `
"LAYER_RIVER_01", "LAYER_RIVER_02", "LAYER_RIVER_03", "LAYER_RIVER_04", "LAYER_RIVER_05", "LAYER_RIVER_06", "LAYER_RIVER_07", "LAYER_RIVER_08", "LAYER_RIVER_09", "LAYER_RIVER_10", "LAYER_RIVER_11", "LAYER_RIVER_12", "LAYER_RIVER_13", "LAYER_RIVER_14", "LAYER_RIVER_15", "LAYER_RIVER_16", "LAYER_RIVER_17", "LAYER_RIVER_18", "LAYER_RIVER_19"

# All textures shown in the editor at the 3rd tab
$arrObjectTextureIDToKey = "OBJ_BUSH_01", "OBJ_BUSH_02", "OBJ_BUSH_03", "OBJ_CHEST_01", "OBJ_MOUNTAIN_01", "OBJ_MOUNTAIN_02", "OBJ_MOUNTAIN_03", "OBJ_MOUNTAIN_04", "OBJ_STONES_01", "OBJ_STONES_02", "OBJ_STONES_03", "OBJ_STONES_04", "OBJ_STONES_05", "OBJ_TREE_01", "OBJ_TREE_02", "OBJ_TREE_03", "OBJ_TREE_04",`
 "OBJ_WHIRL_01", "OBJ_GOLD_01", "OBJ_HARBOR_01", "OBJ_POND_01", "OBJ_RUINS_01", "OBJ_RUINS_02", "OBJ_SHIP_01", "OBJ_SIGNPOST_01"

# All player icons
$arrPlayerIconsIDToKey = "PLAYER_00", "PLAYER_01", "PLAYER_02", "PLAYER_03", "PLAYER_04"

#region FILELOADING

$strPathIconGFX = ".\GFX\ICON\"
$global:arrIcons = @{}
$global:arrIcons["ICON_LAYER_01"]           = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_01.png'            ))));
$global:arrIcons["ICON_LAYER_02"]           = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_02.png'            ))));
$global:arrIcons["ICON_LAYER_03"]           = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_03.png'            ))));
$global:arrIcons["ICON_LAYER_DIRECTION"]    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_DIRECTION.png'     ))));
$global:arrIcons["ICON_LAYER_PLAYER"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_PLAYER.png'        ))));
$global:arrIcons["ICON_LAYER_SETTINGS"]     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_SETTINGS.png'      ))));
$global:arrIcons["ICON_ARROW_GOLD_LEFT"]    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_ARROW_GOLD_LEFT.png'     ))));
$global:arrIcons["ICON_ARROW_GOLD_RIGHT"]   = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_ARROW_GOLD_RIGHT.png'    ))));

$global:arrIcons["ICON_BUILDING_01"]           = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_BUILDING_01.png'            ))));
$global:arrIcons["ICON_BUILDING_02"]           = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_BUILDING_02.png'            ))));

$strPathTextureGFX = ".\GFX\WORLD\"
$global:arrTextures = @{}

#Ground Tiles
$global:arrTextures["GROUND_GREEN_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_01.png'  ))));
$global:arrTextures["GROUND_GREEN_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_02.png'  ))));
$global:arrTextures["GROUND_GREEN_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_03.png'  ))));
$global:arrTextures["GROUND_GREEN_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_04.png'  ))));
$global:arrTextures["GROUND_WATER_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_WATER_01.png'  ))));
$global:arrTextures["GROUND_EMPTY_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_EMPTY_01.png'  ))));

# Ground <> Water Tiles
$global:arrTextures["LAYER_EDGE_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_01.png' ))));
$global:arrTextures["LAYER_EDGE_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_02.png' ))));
$global:arrTextures["LAYER_EDGE_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_03.png' ))));
$global:arrTextures["LAYER_EDGE_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_04.png' ))));
$global:arrTextures["LAYER_EDGE_05"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_05.png' ))));
$global:arrTextures["LAYER_EDGE_06"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_06.png' ))));
$global:arrTextures["LAYER_EDGE_07"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_07.png' ))));
$global:arrTextures["LAYER_EDGE_08"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_08.png' ))));
$global:arrTextures["LAYER_EDGE_09"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_09.png' ))));
$global:arrTextures["LAYER_EDGE_11"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_11.png' ))));
$global:arrTextures["LAYER_EDGE_13"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_13.png' ))));
$global:arrTextures["LAYER_EDGE_15"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_EDGE_15.png' ))));

# Path Tiles
$global:arrTextures["LAYER_PATH_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_01.png' ))));
$global:arrTextures["LAYER_PATH_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_02.png' ))));
$global:arrTextures["LAYER_PATH_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_03.png' ))));
$global:arrTextures["LAYER_PATH_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_04.png' ))));
$global:arrTextures["LAYER_PATH_05"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_05.png' ))));
$global:arrTextures["LAYER_PATH_06"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_06.png' ))));
$global:arrTextures["LAYER_PATH_07"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_07.png' ))));
$global:arrTextures["LAYER_PATH_08"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_08.png' ))));
$global:arrTextures["LAYER_PATH_09"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_09.png' ))));
$global:arrTextures["LAYER_PATH_10"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_10.png' ))));
$global:arrTextures["LAYER_PATH_11"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_PATH_11.png' ))));

# River Tiles
$global:arrTextures["LAYER_RIVER_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_01.png' ))));
$global:arrTextures["LAYER_RIVER_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_02.png' ))));
$global:arrTextures["LAYER_RIVER_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_03.png' ))));
$global:arrTextures["LAYER_RIVER_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_04.png' ))));
$global:arrTextures["LAYER_RIVER_05"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_05.png' ))));
$global:arrTextures["LAYER_RIVER_06"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_06.png' ))));
$global:arrTextures["LAYER_RIVER_07"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_07.png' ))));
$global:arrTextures["LAYER_RIVER_08"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_08.png' ))));
$global:arrTextures["LAYER_RIVER_09"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_09.png' ))));
$global:arrTextures["LAYER_RIVER_10"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_10.png' ))));
$global:arrTextures["LAYER_RIVER_11"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_11.png' ))));
$global:arrTextures["LAYER_RIVER_12"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_12.png' ))));
$global:arrTextures["LAYER_RIVER_13"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_13.png' ))));
$global:arrTextures["LAYER_RIVER_14"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_14.png' ))));
$global:arrTextures["LAYER_RIVER_15"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_15.png' ))));
$global:arrTextures["LAYER_RIVER_16"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_16.png' ))));
$global:arrTextures["LAYER_RIVER_17"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_17.png' ))));
$global:arrTextures["LAYER_RIVER_18"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_18.png' ))));
$global:arrTextures["LAYER_RIVER_19"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'LAYER_RIVER_19.png' ))));

# Objects
$global:arrTextures["OBJ_BUSH_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_BUSH_01.png' ))));
$global:arrTextures["OBJ_BUSH_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_BUSH_02.png' ))));
$global:arrTextures["OBJ_BUSH_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_BUSH_03.png' ))));

$global:arrTextures["OBJ_MOUNTAIN_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_MOUNTAIN_01.png' ))));
$global:arrTextures["OBJ_MOUNTAIN_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_MOUNTAIN_02.png' ))));
$global:arrTextures["OBJ_MOUNTAIN_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_MOUNTAIN_03.png' ))));
$global:arrTextures["OBJ_MOUNTAIN_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_MOUNTAIN_04.png' ))));

$global:arrTextures["OBJ_STONES_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_STONES_01.png' ))));
$global:arrTextures["OBJ_STONES_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_STONES_02.png' ))));
$global:arrTextures["OBJ_STONES_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_STONES_03.png' ))));
$global:arrTextures["OBJ_STONES_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_STONES_04.png' ))));
$global:arrTextures["OBJ_STONES_05"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_STONES_05.png' ))));

$global:arrTextures["OBJ_TREE_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_TREE_01.png' ))));
$global:arrTextures["OBJ_TREE_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_TREE_02.png' ))));
$global:arrTextures["OBJ_TREE_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_TREE_03.png' ))));
$global:arrTextures["OBJ_TREE_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_TREE_04.png' ))));

$global:arrTextures["OBJ_WHIRL_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_WHIRL_01.png' ))));
$global:arrTextures["OBJ_WHIRL_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_WHIRL_02.png' ))));

$global:arrTextures["OBJ_CHEST_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_CHEST_01.png' ))));

$global:arrTextures["OBJ_GOLD_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_GOLD_01.png' ))));

$global:arrTextures["OBJ_HARBOR_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_HARBOR_01.png' ))));

$global:arrTextures["OBJ_POND_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_POND_01.png' ))));
$global:arrTextures["OBJ_POND_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_POND_02.png' ))));

$global:arrTextures["OBJ_RUINS_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_RUINS_01.png' ))));
$global:arrTextures["OBJ_RUINS_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_RUINS_02.png' ))));

$global:arrTextures["OBJ_SHIP_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_SHIP_01.png' ))));

$global:arrTextures["OBJ_SIGNPOST_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'OBJ_SIGNPOST_01.png' ))));

$global:arrTextures["PLAYER_00"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PLAYER_00.png' ))));
$global:arrTextures["PLAYER_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PLAYER_01.png' ))));
$global:arrTextures["PLAYER_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PLAYER_02.png' ))));
$global:arrTextures["PLAYER_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PLAYER_03.png' ))));
$global:arrTextures["PLAYER_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PLAYER_04.png' ))));

$strPathInterfaceGFX = ".\GFX\INTERFACE\"
$global:arrInterface = @{}
$global:arrInterface["CUR_SELECTEDTILE"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathInterfaceGFX + 'CUR_SELECTEDTILE.png'  ))));
$global:arrInterface["CUR_SELECTEDTILE"].MakeTransparent($transparent);

#Music
$strPathMusic = ".\SND\"
$file = Get-Item ($strPathMusic + "SONG_MEDIVAL.ogg")
$global:objMusic001 = New-Object System.Windows.Media.Mediaplayer
$global:objMusic001.Open([uri]($file.FullName))
$global:objMusic001.Volume = $global:arrSettings["VOLUMEMUSIC"];
$global:objMusic001.Add_MediaEnded({
$global:objMusic001.Position = New-TimeSpan -Hour 0 -Minute 0 -Seconds 0
$global:objMusic001.Play();
})

$strPathImageGFX = ".\GFX\IMAG\"
$global:objWorld = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));

$global:arrImages = @{}
$global:arrImages["SCREEN_BACK_MAP"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_MAP.png'  ))));

# textures etc.
$strPathToMenuGFX = ".\GFX\MENU\"
$tex_MENU_CORNER        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'MENU_CORNER.png'          ))));
$tex_MENU_SIDE_VERT     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'MENU_SIDE_VERT.png'       ))));
$tex_MENU_SIDE_HOR      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'MENU_SIDE_HOR.png'        ))));
#$tex_MENU_TEX_BACK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.    EX_BACK_GREEN_DARK.bmp'  ))));
$tex_MENU_TEX_BACK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_BACK_GREEN_NOISE.bmp'  ))));
$tex_MENU_GRAY_DARK     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_GRAY_DARK.bmp'        ))));
$tex_MENU_GRAY_LIGHT    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_GRAY_LIGHT.bmp'       ))));
$tex_MENU_RED_DARK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_RED_DARK.bmp'         ))));
$tex_MENU_RED_LIGHT     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_RED_LIGHT.bmp'        ))));
$tex_MENU_GREEN_DARK    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_GREEN_DARK.bmp'       ))));
$tex_MENU_GREEN_LIGHT   = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + 'TEX_GREEN_LIGHT.bmp'      ))));

$strPathToFontGFX = ".\GFX\FONT\"
$arrFont = @{}
$arrFont["!"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '1.bmp'  ))));
$arrFont[""""] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '2.bmp'  ))));
$arrFont["#"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '3.bmp'  ))));
$arrFont["`$"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '4.bmp'  ))));
$arrFont["%"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '5.bmp'  ))));
$arrFont["&"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '6.bmp'  ))));
$arrFont["'"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '7.bmp'  ))));
$arrFont["("] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '8.bmp'  ))));
$arrFont[")"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '9.bmp'  ))));
$arrFont["*"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '10.bmp'  ))));
$arrFont["+"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '11.bmp'  ))));
$arrFont[","] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '12.bmp'  ))));
$arrFont["-"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '13.bmp'  ))));
$arrFont["."] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '14.bmp'  ))));
$arrFont["/"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '15.bmp'  ))));
$arrFont["0"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '16.bmp'  ))));
$arrFont["1"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '17.bmp'  ))));
$arrFont["2"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '18.bmp'  ))));
$arrFont["3"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '19.bmp'  ))));
$arrFont["4"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '20.bmp'  ))));
$arrFont["5"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '21.bmp'  ))));
$arrFont["6"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '22.bmp'  ))));
$arrFont["7"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '23.bmp'  ))));
$arrFont["8"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '24.bmp'  ))));
$arrFont["9"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '25.bmp'  ))));
$arrFont[":"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '26.bmp'  ))));
$arrFont[";"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '27.bmp'  ))));
$arrFont["<"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '28.bmp'  ))));
$arrFont["="] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '29.bmp'  ))));
$arrFont[">"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '30.bmp'  ))));
$arrFont["?"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '31.bmp'  ))));
$arrFont["@"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '32.bmp'  ))));
$arrFont["A"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '33.bmp'  ))));
$arrFont["B"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '34.bmp'  ))));
$arrFont["C"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '35.bmp'  ))));
$arrFont["D"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '36.bmp'  ))));
$arrFont["E"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '37.bmp'  ))));
$arrFont["F"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '38.bmp'  ))));
$arrFont["G"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '39.bmp'  ))));
$arrFont["H"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '40.bmp'  ))));
$arrFont["I"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '41.bmp'  ))));
$arrFont["J"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '42.bmp'  ))));
$arrFont["K"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '43.bmp'  ))));
$arrFont["L"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '44.bmp'  ))));
$arrFont["M"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '45.bmp'  ))));
$arrFont["N"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '46.bmp'  ))));
$arrFont["O"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '47.bmp'  ))));
$arrFont["P"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '48.bmp'  ))));
$arrFont["Q"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '49.bmp'  ))));
$arrFont["R"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '50.bmp'  ))));
$arrFont["S"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '51.bmp'  ))));
$arrFont["T"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '52.bmp'  ))));
$arrFont["U"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '53.bmp'  ))));
$arrFont["V"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '54.bmp'  ))));
$arrFont["W"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '55.bmp'  ))));
$arrFont["X"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '56.bmp'  ))));
$arrFont["Y"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '57.bmp'  ))));
$arrFont["Z"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '58.bmp'  ))));
$arrFont["\"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '59.bmp'  ))));
$arrFont["^"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '60.bmp'  ))));
$arrFont["_"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '61.bmp'  ))));
$arrFont["©"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '58.bmp'  ))));
$arrFont["Ä"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '63.bmp'  ))));
$arrFont["Ö"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '64.bmp'  ))));
$arrFont["Ü"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '65.bmp'  ))));
$arrFont["ß"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '66.bmp'  ))));
$arrFont[" "] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '67.bmp'  ))));
$arrFont["["] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '68.bmp'  ))));
$arrFont["]"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '69.bmp'  ))));

function replaceColor($objImage, $colorSource, $colorTarget)
{
	 for($i = 0; $i -lt $objImage.Width; $i++)
    {
        for($j = 0; $j -lt $objImage.Height; $j++)
        {
            if($objImage.GetPixel($i, $j) -eq $colorSource)
            {

                $objImage.SetPixel($i, $j, $colorTarget)
            }
        }
    }
}

#HQ
#HOUSE_SMALL
#HOUSE_MEDIUM
#HOUSE_LARGE
#WELL
#FARM
#FIELD
#SAWMILL
#MINE
#BARRACKS
#STABLE
#ARCHERY_RANGE
#TOWER
$global:arrBuildingIDToKey = "HQ", "HUM_HOUSE_SMALL", "HUM_HOUSE_MEDIUM", "HUM_HOUSE_LARGE", "HUM_FARM", "HUM_FIELD", "HUM_WELL"

$rect_tile    = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
$strPathToBuildingGFX = ".\GFX\BUILDING\"
$global:arrBuilding = @{}
$arrBuilding["HQ"] = @{}
$arrBuilding["HQ"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_00.png'  ))));
$arrBuilding["HQ"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_01.png'  ))));
$arrBuilding["HQ"][2] = $arrBuilding["HQ"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HQ"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HQ"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HQ"][3] = $arrBuilding["HQ"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HQ"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HQ"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HQ"][4] = $arrBuilding["HQ"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HQ"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HQ"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HQ"][5] = $arrBuilding["HQ"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HQ"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HQ"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_HOUSE_SMALL"] = @{}
$arrBuilding["HUM_HOUSE_SMALL"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_SMALL_00.png'  ))));
$arrBuilding["HUM_HOUSE_SMALL"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_SMALL_01.png'  ))));
$arrBuilding["HUM_HOUSE_SMALL"][2] = $arrBuilding["HUM_HOUSE_SMALL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_HOUSE_SMALL"][3] = $arrBuilding["HUM_HOUSE_SMALL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_HOUSE_SMALL"][4] = $arrBuilding["HUM_HOUSE_SMALL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_HOUSE_SMALL"][5] = $arrBuilding["HUM_HOUSE_SMALL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_HOUSE_MEDIUM"] = @{}
$arrBuilding["HUM_HOUSE_MEDIUM"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_MEDIUM_00.png'  ))));
$arrBuilding["HUM_HOUSE_MEDIUM"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_MEDIUM_01.png'  ))));
$arrBuilding["HUM_HOUSE_MEDIUM"][2] = $arrBuilding["HUM_HOUSE_MEDIUM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_HOUSE_MEDIUM"][3] = $arrBuilding["HUM_HOUSE_MEDIUM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_HOUSE_MEDIUM"][4] = $arrBuilding["HUM_HOUSE_MEDIUM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_HOUSE_MEDIUM"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_HOUSE_MEDIUM"][5] = $arrBuilding["HUM_HOUSE_MEDIUM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_HOUSE_SMALL"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_HOUSE_LARGE"] = @{}
$arrBuilding["HUM_HOUSE_LARGE"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_LARGE_00.png'  ))));
$arrBuilding["HUM_HOUSE_LARGE"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HOUSE_LARGE_01.png'  ))));
$arrBuilding["HUM_HOUSE_LARGE"][2] = $arrBuilding["HUM_HOUSE_LARGE"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_HOUSE_LARGE"][3] = $arrBuilding["HUM_HOUSE_LARGE"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_HOUSE_LARGE"][4] = $arrBuilding["HUM_HOUSE_LARGE"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_HOUSE_LARGE"][5] = $arrBuilding["HUM_HOUSE_LARGE"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_HOUSE_LARGE"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_FARM"] = @{}
$arrBuilding["HUM_FARM"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_FARM_00.png'  ))));
$arrBuilding["HUM_FARM"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_FARM_01.png'  ))));
$arrBuilding["HUM_FARM"][2] = $arrBuilding["HUM_FARM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FARM"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_FARM"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_FARM"][3] = $arrBuilding["HUM_FARM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FARM"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_FARM"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_FARM"][4] = $arrBuilding["HUM_FARM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FARM"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_FARM"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_FARM"][5] = $arrBuilding["HUM_FARM"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FARM"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_FARM"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_FIELD"] = @{}
$arrBuilding["HUM_FIELD"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_FIELD_00.png'  ))));
$arrBuilding["HUM_FIELD"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_FIELD_01.png'  ))));
$arrBuilding["HUM_FIELD"][2] = $arrBuilding["HUM_FIELD"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FIELD"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_FIELD"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_FIELD"][3] = $arrBuilding["HUM_FIELD"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FIELD"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_FIELD"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_FIELD"][4] = $arrBuilding["HUM_FIELD"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FIELD"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_FIELD"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_FIELD"][5] = $arrBuilding["HUM_FIELD"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_FIELD"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_FIELD"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

$arrBuilding["HUM_WELL"] = @{}
$arrBuilding["HUM_WELL"][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_WELL_00.png'  ))));
$arrBuilding["HUM_WELL"][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_WELL_01.png'  ))));
$arrBuilding["HUM_WELL"][2] = $arrBuilding["HUM_WELL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_WELL"][2] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_10"]
replaceColor $arrBuilding["HUM_WELL"][2] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_11"]
$arrBuilding["HUM_WELL"][3] = $arrBuilding["HUM_WELL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_WELL"][3] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_20"]
replaceColor $arrBuilding["HUM_WELL"][3] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_21"]
$arrBuilding["HUM_WELL"][4] = $arrBuilding["HUM_WELL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_WELL"][4] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_30"]
replaceColor $arrBuilding["HUM_WELL"][4] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_31"]
$arrBuilding["HUM_WELL"][5] = $arrBuilding["HUM_WELL"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
replaceColor $arrBuilding["HUM_WELL"][5] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors["CLR_PLAYER_40"]
replaceColor $arrBuilding["HUM_WELL"][5] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors["CLR_PLAYER_41"]

#$arrBuilding["HQ"][10] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_10.png'  ))));
#$arrBuilding["HQ"][11] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_11.png'  ))));
#$arrBuilding["HQ"][20] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_10.png'  ))));
#$arrBuilding["HQ"][21] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_HQ_11.png'  ))));
#$arrBuilding[1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_02.png'  ))));
#$arrBuilding[2] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_03.png'  ))));
#$arrBuilding[3] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_04.png'  ))));
#$arrBuilding[4] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_05.png'  ))));
#$arrBuilding[5] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_06.png'  ))));
#$arrBuilding[6] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_07.png'  ))));
#$arrBuilding[7] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_08.png'  ))));
#$arrBuilding[8] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_09.png'  ))));
#$arrBuilding[9] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_10.png'  ))));
#$arrBuilding[10] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_11.png'  ))));
#$arrBuilding[11] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_12.png'  ))));
#$arrBuilding[12] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_13.png'  ))));
#$arrBuilding[13] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_14.png'  ))));
#$arrBuilding[14] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_15.png'  ))));
#$arrBuilding[15] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_16.png'  ))));
#$arrBuilding[16] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_17.png'  ))));
#$arrBuilding[17] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_18.png'  ))));
#$arrBuilding[18] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_19.png'  ))));
#$arrBuilding[19] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_20.png'  ))));
#$arrBuilding[20] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_21.png'  ))));
#$arrBuilding[21] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_22.png'  ))));
#$arrBuilding[22] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_23.png'  ))));
#$arrBuilding[23] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_24.png'  ))));
#$arrBuilding[24] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + 'HUM_BUILDING_25.png'  ))));
#endregion

$DrawingSizeX    = 480
$DrawingSizeY    = 270
$global:bitmap  = New-Object System.Drawing.Bitmap($DrawingSizeX, $DrawingSizeY);

# Create the form
$objForm = New-Object System.Windows.Forms.Form 
$objForm.minimumSize = New-Object System.Drawing.Size(($DrawingSizeX + 16), ($DrawingSizeY + 36)) 
$objForm.maximumSize = New-Object System.Drawing.Size(($DrawingSizeX + 16), ($DrawingSizeY + 36)) 
$objForm.MaximizeBox = $False;
$objForm.MinimizeBox = $False;
$objForm.Topmost = $global:arrSettings["TOPMOST"]; 
#https://i-msdn.sec.s-msft.com/dynimg/IC24340.jpeg

$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.SizeMode = 4
$pictureBox.Size = New-Object System.Drawing.Size($DrawingSizeX    , $DrawingSizeY)
$objForm.controls.add($pictureBox)
$objForm.AutoSize = $False
$pictureBox.Add_Click({onMouseClick "Picturebox"})
$objForm.Add_Shown({$objForm.Activate()})
$objForm.Add_Click({})
$pictureBox.Add_Paint({onRedraw $this $_})
$objForm.Add_KeyDown({onKeyPress $this $_})
#$objForm.Add_MouseMove({onMouseMove $this $_})
$pictureBox.Add_MouseMove({onMouseMove $this $_})
$objForm.Add_Click({onMouseClick "Form"})
$objForm.Text = "PowerHeroes - 0.1.1"
If (Test-Path ".\PowerHeroes.exe") { $objForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(".\PowerHeroes.exe")}
##
## onKeyPress
##
function onMouseMove($sender, $EventArgs)
{
    if($global:strGameState -ne "EDIT_MAP" -and $global:strGameState -ne "SINGLEPLAYER_INGAME")
    {
        return;
    }
    
    $relX = [System.Windows.Forms.Cursor]::Position.X - $objForm.Location.X - 8 # 8 = left border
    $relY = [System.Windows.Forms.Cursor]::Position.Y - $objForm.Location.Y - 30 # 30 = upper border
    
    $relX = $relX / [math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 ))
    $relY = $relY / [math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 ))
    
    if($EventArgs.Button -eq "Left" -and $relX -lt ($DrawingSizeX - 160))
    {
        #Write-Host "Mouse moves"
        handleClickEditor $relX $relY
    }
    $tile_x = [math]::floor($relX / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($relY / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]
    
    $global:arrCreateMapOptions["SELECTED_X"] = $tile_x;
    $global:arrCreateMapOptions["SELECTED_Y"] = $tile_y;
    
    $pictureBox.Refresh();
}

function MAP_changeTile($objImage, $iTileX, $iTileY)
{
    $offset_x = $iTileX * $global:arrSettings["TILESIZE"]
    $offset_y = $iTileY * $global:arrSettings["TILESIZE"]

    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $tmp_pixel = $objImage.GetPixel($i, $j)
        
            if($tmp_pixel -ne $transparent)
            {
                $global:objWorld.SetPixel(($offset_x + $i), ($offset_y + $j), $tmp_pixel);
            }
        }
    }
    
    $objForm.Refresh();
}

function MAP_createMapImage()
{
    Write-Host "Generating map..."
    
    $global:arrMap["WIDTH"] = $global:arrCreateMapOptions["WIDTH"]
    $global:arrMap["HEIGHT"] = $global:arrCreateMapOptions["HEIGHT"]
    #$global:arrMap["WORLD_L1"] = @{}
    #$global:arrMap["WORLD_L2"] = @{}
    #$global:arrMap["WORLD_L3"] = @{}

    $size_x = $global:arrMap["WIDTH"] + 4;
    $size_y = $global:arrMap["HEIGHT"] + 4;
    
    $global:objWorld = New-Object System.Drawing.Bitmap(($size_x * $global:arrSettings["TILESIZE"]), ($size_y * $global:arrSettings["TILESIZE"]));
    
    $runs = $size_x * $size_y
    $runs5 = [math]::floor($runs * 0.05)
    $runs = $runs5;
    
    #Write-Host "Reporting every $runs5 run!"

    $arrImage = New-Object 'object[,]' $global:arrSettings["TILESIZE"],$global:arrSettings["TILESIZE"]
    
    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $arrImage[$i,$j] = $global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]].getPixel($i, $j)
        }
    }
    
    $arrImageNothing = New-Object 'object[,]' $global:arrSettings["TILESIZE"],$global:arrSettings["TILESIZE"]
    
    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $arrImageNothing[$i,$j] = $global:arrTextures["GROUND_EMPTY_01"].getPixel($i, $j)
        }
    }
      
    #Write-Host "Textures loaded! Worldsize in chunks is: $size_x by $size_y"

    for($i = 0; $i -lt $size_x; $i++)
    {
        # $i - 2 because thats the left border
        if($i -ge 2 -and $i -lt ($size_x - 2))
        {
            Write-Host "Creating array for: $i"
            $global:arrMap["WORLD_L1"][($i - 2)] = @{}
            $global:arrMap["WORLD_L2"][($i - 2)] = @{}
            $global:arrMap["WORLD_L3"][($i - 2)] = @{}
        }

        for($j = 0; $j -lt $size_y; $j++)
        {
            #Write-Host "row: $i col: $j"
            # $i - 2 because thats the left border
            # same for y
            if($i -ge 2 -and $i -lt ($size_x - 2) -and $j -ge 2 -and $j -lt ($size_y - 2))
            {
                $global:arrMap["WORLD_L1"][($i - 2)][($j - 2)] = $global:arrCreateMapOptions["BASTEXTUREID"]
                $global:arrMap["WORLD_L2"][($i - 2)][($j - 2)] = -1
                $global:arrMap["WORLD_L3"][($i - 2)][($j - 2)] = -1
            }


            $offset_x = ([int]$global:arrSettings["TILESIZE"] * $i);
            $offset_y = ([int]$global:arrSettings["TILESIZE"] * $j);
            
            for($ix = 0; $ix -lt $global:arrSettings["TILESIZE"]; $ix ++)
            {
                for($iy = 0; $iy -lt $global:arrSettings["TILESIZE"]; $iy++)
                {
                    #Write-Host "Setting pixels ix $ix and iy $iy (Offset: $offset_x by $offset_y)"

                    #Borders
                    if($i -lt 2 -or $i -ge ($size_x - 2) -or $j -lt 2 -or $j -ge ($size_y - 2))
                    {
                        $global:objWorld.SetPixel(($offset_x + $ix), ($offset_y + $iy), ($arrImageNothing[$ix,$iy]));
                    }
                    else
                    {
                        $global:objWorld.SetPixel(($offset_x + $ix), ($offset_y + $iy), ($arrImage[$ix,$iy]));
                    }
                }
            }
            
            
            if(($i * $j) -gt $runs)
            {
                $percent = [math]::floor(($i * $j) / ($size_x * $size_y) * 100)
                Write-Host "$percent percent generated..."

                $runs += $runs5;
				[System.Windows.Forms.Application]::DoEvents() 
                $objForm.Refresh();
            }
        }
    }
    Write-Host "... done."
}

function getPlayerAtPosition($posX, $posY)
{
    if($posX -eq $global:arrMap["PLAYER_01X"] -and $posY -eq $global:arrMap["PLAYER_01Y"]) {return 1}
    if($posX -eq $global:arrMap["PLAYER_02X"] -and $posY -eq $global:arrMap["PLAYER_02Y"]) {return 2}
    if($posX -eq $global:arrMap["PLAYER_03X"] -and $posY -eq $global:arrMap["PLAYER_03Y"]) {return 3}
    if($posX -eq $global:arrMap["PLAYER_04X"] -and $posY -eq $global:arrMap["PLAYER_04Y"]) {return 4}
    return 0
}

function getPlayerCount()
{
    $playerCount = 0
    if($global:arrMap["PLAYER_01X"] -ne -1) {$playerCount += 1}
    if($global:arrMap["PLAYER_02X"] -ne -1) {$playerCount += 1}
    if($global:arrMap["PLAYER_03X"] -ne -1) {$playerCount += 1}
    if($global:arrMap["PLAYER_04X"] -ne -1) {$playerCount += 1}
    return $playerCount
}

function setPlayerPosition($posX, $posY, $playerID)
{
    $global:arrMap[("PLAYER_0" + $playerID + "X")] = $posX
    $global:arrMap[("PLAYER_0" + $playerID + "Y")] = $posY

    drawPlayerIndicatorAtPosition $posX $posY $playerID
}

function drawPlayerIndicatorAtPosition($posX, $posY, $playerID)
{
    MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][$posX][$posY]]]) ($posX + 2) ($posY + 2)
    
    if([int]$global:arrMap["WORLD_L2"][([int]$posX)][([int]$posY)] -ne -1)
    {
        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][$posX][$posY]]]) ($posX + 2) ($posY + 2)
    }
    # don't need layer 3, if there is something on layer 3 the player couldn't be added in the first place
    #MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L3"][$posX][$posY]]]) $posX $posY

    MAP_changeTile ($global:arrTextures[$arrPlayerIconsIDToKey[$playerID]]) ($posX + 2) ($posY + 2)
}

function removePlayerFromPosition($playerID)
{
    $strPlayerKey = "PLAYER_0" + $playerID


    $posX = [int]$global:arrMap[($strPlayerKey + "X")]
    $posY = [int]$global:arrMap[($strPlayerKey + "Y")]
    
    if([int]$global:arrMap[($strPlayerKey + "X")] -ne -1)
    {
        removePlayerIndicatorAtPosition $posX $posY $playerID
    }

    # reset position
    $global:arrMap[($strPlayerKey + "X")] = -1
    $global:arrMap[($strPlayerKey + "Y")] = -1
    
}

function removePlayerIndicatorAtPosition($posX, $posY, $playerID)
{
    Write-Host "removePlayerIndicatorAtPosition $posX, $posY, $playerID"

    MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][($posX)][($posY)]]]) ($posX + 2) ($posY + 2)
    
    if($global:arrMap["WORLD_L2"][([int]$posX)][([int]$posY)] -ne -1)
    {
        Write-Host "WORLD_L2 not 0"
        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][($posX)][($posY)]]]) ($posX + 2) ($posY + 2)
    }

}

function loadMapHeader($strPath)
{
    if($strName -eq "")
    {
        Write-Host "ERROR: loadMap - no path given!"
        return;
    }

    $global:arrMap = @{}
    $global:arrMap["AUTHOR"] = "The Author"
    $global:arrMap["MAPNAME"] = "The Name"
    $global:arrMap["WIDTH"] = 0
    $global:arrMap["HEIGHT"] = 0
    $global:arrMap["PLAYER_01X"] = -1
    $global:arrMap["PLAYER_01Y"] = -1
    $global:arrMap["PLAYER_02X"] = -1
    $global:arrMap["PLAYER_02Y"] = -1
    $global:arrMap["PLAYER_03X"] = -1
    $global:arrMap["PLAYER_03Y"] = -1
    $global:arrMap["PLAYER_04X"] = -1
    $global:arrMap["PLAYER_04Y"] = -1
    $global:arrMap["WORLD_L1"] = @{}
    $global:arrMap["WORLD_L2"] = @{}
    $global:arrMap["WORLD_L3"] = @{}
	$global:arrMap["WORLD_LBLD"] = @{}


    $arrMap_TMP = Get-Content $strPath
    $global:arrMap["AUTHOR"] =  ($arrMap_TMP[0].split("="))[1]
    $global:arrMap["MAPNAME"] = ($arrMap_TMP[1].split("="))[1]
    $global:arrMap["WIDTH"] =   ($arrMap_TMP[2].split("="))[1]
    $global:arrMap["HEIGHT"] =  ($arrMap_TMP[3].split("="))[1]

    $global:arrMap["PLAYER_01X"] = ($arrMap_TMP[4].split("="))[1]
    $global:arrMap["PLAYER_01Y"] = ($arrMap_TMP[5].split("="))[1]
    $global:arrMap["PLAYER_02X"] = ($arrMap_TMP[6].split("="))[1]
    $global:arrMap["PLAYER_02Y"] = ($arrMap_TMP[7].split("="))[1]
    $global:arrMap["PLAYER_03X"] = ($arrMap_TMP[8].split("="))[1]
    $global:arrMap["PLAYER_03Y"] = ($arrMap_TMP[9].split("="))[1]
    $global:arrMap["PLAYER_04X"] = ($arrMap_TMP[10].split("="))[1]
    $global:arrMap["PLAYER_04Y"] = ($arrMap_TMP[11].split("="))[1]
}

function loadMap($strPath)
{
    if($strName -eq "")
    {
        Write-Host "ERROR: loadMap - no path given!"
        return;
    }

    loadMapHeader $strPath

    $arrMap_TMP = Get-Content $strPath

    $global:arrCreateMapOptions["WIDTH"] = $global:arrMap["WIDTH"]
    $global:arrCreateMapOptions["HEIGHT"] = $global:arrMap["HEIGHT"]

    # create map image
    $size_x = [int]$global:arrMap["WIDTH"] + 4;
    $size_y = [int]$global:arrMap["HEIGHT"] + 4;

    $global:objWorld = New-Object System.Drawing.Bitmap(($size_x * $global:arrSettings["TILESIZE"]), ($size_y * $global:arrSettings["TILESIZE"]));

    for($i = 0; $i -lt [int]$global:arrMap["WIDTH"]; $i++)
    {
        $global:arrMap["WORLD_L1"][$i] = @{}
        $global:arrMap["WORLD_L2"][$i] = @{}
        $global:arrMap["WORLD_L3"][$i] = @{}
		$global:arrMap["WORLD_LBLD"][$i] = @{}
    }

	for($i = 0; $i -lt $global:arrMap["WIDTH"]; $i++)
	{
		for($j = 0; $j -lt $global:arrMap["HEIGHT"]; $j++)
		{
			$global:arrMap["WORLD_LBLD"][$i][$j] = -1
		}
	}

    $length = $arrMap_TMP.Length
    for($i = 12; $i -lt $arrMap_TMP.Length; $i++)
    {
        $strValues = ($arrMap_TMP[$i].split("="))[1]
        $arrValues = $strValues.split(",")
        #calc current tile
        $x = [math]::floor((([int]$i - 12) / [int]$global:arrMap["WIDTH"]))
        $y = ($i - 12) - $x * [int]$global:arrMap["WIDTH"]

        #but in map file its saved 15 -> 0 and not 0 -> 15
        $realx = [int]$global:arrMap["WIDTH"] - 1 - $x
        $realy = [int]$global:arrMap["HEIGHT"] - 1 - $y

        $global:arrMap["WORLD_L1"][[int]$realx][[int]$realy] = [int]$arrValues[0]
        $global:arrMap["WORLD_L2"][[int]$realx][[int]$realy] = [int]$arrValues[1]
        $global:arrMap["WORLD_L3"][[int]$realx][[int]$realy] = [int]$arrValues[2]

        MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[[int]$arrValues[0]]]) ($realx + 2) ($realy + 2) 

        if([int]$arrValues[1] -ne -1)
        {
            MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[[int]$arrValues[1]]]) ($realx + 2) ($realy + 2)
        }

        if([int]$arrValues[2] -ne -1)
        {
            MAP_changeTile ($global:arrTextures[$arrObjectTextureIDToKey[[int]$arrValues[2]]]) ($realx + 2) ($realy + 2)
        }

        $playerID = getPlayerAtPosition $realx $realy
        if($playerID -ne 0)
        {
            #MAP_changeTile ($global:arrTextures[$arrPlayerIconsIDToKey[$playerID]]) ($realx + 2) ($realy + 2)

			addBuildingAtPositionForPlayer ([int]($realx)) ([int]($realy)) 0 ([int]$playerID)

			#drawBuildingAt ($realx + 2) ($realy + 2) 0 $playerID

        }
    }

    # $i = y, $j = x, upper side
    for($i = 0; $i -lt 2; $i ++)
    {
        for($j = 0; $j -lt $size_x; $j++)
        {
            MAP_changeTile ($global:arrTextures["GROUND_EMPTY_01"]) $j $i
        }
    }

    # $i = y, $j = x, lower side
    for($i = ($size_y - 2) ; $i -lt $size_y; $i ++)
    {
        for($j = 0; $j -lt $size_x; $j++)
        {
            MAP_changeTile ($global:arrTextures["GROUND_EMPTY_01"]) $j $i
        }
    }

    ## $i = x, $j = y, left
    for($i = 0; $i -lt 2; $i ++)
    {
        for($j = 0; $j -lt $size_y; $j++)
        {
            MAP_changeTile ($global:arrTextures["GROUND_EMPTY_01"]) $i $j
        }
    }
    #
    ## $i = x, $j = y, lower side
    for($i = ($size_x - 2) ; $i -lt $size_x; $i ++)
    {
        for($j = 0; $j -lt $size_y; $j++)
        {
            MAP_changeTile ($global:arrTextures["GROUND_EMPTY_01"]) $i $j
        }
    }

    #$global:windowOpen = $False;
    

    Write-Host "Map has been loaded!"

    $objForm.Refresh();
}

function saveMap($strName)
{
    # Test Save Map
    if($strName -eq "")
    {
        $strFileName = ".\MAP\" + $global:arrMap["MAPNAME"] + ".smf"
    }
    else
    {
        $strFileName = ".\MAP\$strName" + ".smf"
    }
    
    If (Test-Path $strFileName){
        Remove-Item $strFileName
    }

    "AUTHOR=" + $global:arrMap["AUTHOR"] | Out-File -FilePath $strFileName -Append
    "MAPNAME=" + $global:arrMap["MAPNAME"] | Out-File -FilePath $strFileName -Append
    "WIDTH=" + $global:arrMap["WIDTH"] | Out-File -FilePath $strFileName -Append
    "HEIGHT=" + $global:arrMap["HEIGHT"] | Out-File -FilePath $strFileName -Append


    "PLAYER_01X=" + $global:arrMap["PLAYER_01X"] | Out-File -FilePath $strFileName -Append
    "PLAYER_01Y=" + $global:arrMap["PLAYER_01Y"] | Out-File -FilePath $strFileName -Append
    "PLAYER_02X=" + $global:arrMap["PLAYER_02X"] | Out-File -FilePath $strFileName -Append
    "PLAYER_02Y=" + $global:arrMap["PLAYER_02Y"] | Out-File -FilePath $strFileName -Append
    "PLAYER_03X=" + $global:arrMap["PLAYER_03X"] | Out-File -FilePath $strFileName -Append
    "PLAYER_03Y=" + $global:arrMap["PLAYER_03Y"] | Out-File -FilePath $strFileName -Append
    "PLAYER_04X=" + $global:arrMap["PLAYER_04X"] | Out-File -FilePath $strFileName -Append
    "PLAYER_04Y=" + $global:arrMap["PLAYER_04Y"] | Out-File -FilePath $strFileName -Append

    $keys_a = $global:arrMap["WORLD_L1"].Keys
    
    foreach($key in $keys_a)
    {
        $keys_b = $global:arrMap["WORLD_L1"][$key]

        foreach($key_out in $keys_a)
        {
            $strOutput = "";
            $strOutput = "" + $key + ":" + $key_out + "=" + $global:arrMap["WORLD_L1"][$key][$key_out] + "," + $global:arrMap["WORLD_L2"][$key][$key_out]+ "," + $global:arrMap["WORLD_L3"][$key][$key_out]
            $strOutput | Out-File -FilePath $strFileName -Append
        }
    }

    Write-Host "Map has been saved!"
}

function MAP_changeMapsizeBy($strSide, $iValue, $updateInfobutton)
{
    if(($global:arrCreateMapOptions[$strSide] + $iValue) -lt 16)
    {
        $global:arrCreateMapOptions[$strSide] = 16;
    }
    elseif(($global:arrCreateMapOptions[$strSide] + $iValue) -gt 128)
    {
        $global:arrCreateMapOptions[$strSide] = 128;
    }
    else
    {
        $global:arrCreateMapOptions[$strSide] += $iValue;
    }
    
    
    if($updateInfobutton)
    {
        if($strSide -eq "WIDTH")
        {
            $global:arrWindows["WND_CREATE_MAP"].btn.Remove("BTN_CREATEMAP_WIDTH")
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 ([string]($global:arrCreateMapOptions["WIDTH"])) 10 4 "Gold" $False
        }
        else
        {
            $global:arrWindows["WND_CREATE_MAP"].btn.Remove("BTN_CREATEMAP_HEIGHT")
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 ([string]($global:arrCreateMapOptions["HEIGHT"])) 10 4 "Gold" $False
        }
    }
}

function handleInput($key)
{
    $key = [string]$key
    
    switch($global:strGameState)
    {
        "INPUT_MAPAUTHOR"
        {
            $len_mapname = ([string]($global:arrMap["AUTHOR"])).Length
            
            if($key -eq "Back" -and $len_mapname -gt 0)
            {
                $global:arrMap["AUTHOR"] = ($global:arrMap["AUTHOR"]).Substring(0, ($len_mapname - 1))
                
                addColoredArea "WND_ESC_EDITOR" 12 92 136 20 $black
                addText $global:arrWindows["WND_ESC_EDITOR"].wnd $global:arrMap["AUTHOR"] 14 96 "Gold" $False
                $objForm.Refresh();
                return;
            }
            elseif($key -eq "Escape" -or $key -eq "Return")
            {
                $global:strGameState = "EDIT_MAP_ESCAPE"
                return;
            }
            elseif($key.Length -gt 1)
            {
                Write-Host "Character longer than 1 ($key)"
                return; 
            }
            elseif($len_mapname -lt 10)
            {
                $global:arrMap["AUTHOR"] = $global:arrMap["AUTHOR"] + $key
                
                addColoredArea "WND_ESC_EDITOR" 12 92 136 20 $black
                addText $global:arrWindows["WND_ESC_EDITOR"].wnd $global:arrMap["AUTHOR"] 14 96 "Gold" $False
                $objForm.Refresh();
            }
        }
        "INPUT_MAPNAME"
        {
            $len_mapname = ([string]($global:arrMap["MAPNAME"])).Length
            
            if($key -eq "Back" -and $len_mapname -gt 0)
            {
                $global:arrMap["MAPNAME"] = ($global:arrMap["MAPNAME"]).Substring(0, ($len_mapname - 1))
                
                addColoredArea "WND_ESC_EDITOR" 12 66 136 20 $black
                addText $global:arrWindows["WND_ESC_EDITOR"].wnd $global:arrMap["MAPNAME"] 14 70 "Gold" $False
                $objForm.Refresh();
                return;
            }
            elseif($key -eq "Escape" -or $key -eq "Return")
            {
                $global:strGameState = "EDIT_MAP_ESCAPE"
                return;
            }
            elseif($key.Length -gt 1)
            {
                Write-Host "Character longer than 1 ($key)"
                return; 
            }
            elseif($len_mapname -lt 10)
            {
                $global:arrMap["MAPNAME"] = $global:arrMap["MAPNAME"] + $key
                
                addColoredArea "WND_ESC_EDITOR" 12 66 136 20 $black
                addText $global:arrWindows["WND_ESC_EDITOR"].wnd $global:arrMap["MAPNAME"] 14 70 "Gold" $False
                $objForm.Refresh();
            }
        }
    }
}

function onKeyPress($sender, $EventArgs)
{
    $keyCode = $EventArgs.KeyCode
    
    if($global:strGameState -eq "INPUT_MAPNAME" -or $global:strGameState -eq "INPUT_MAPAUTHOR")
    {
        handleInput $keyCode
        return;
    }
    
    switch($keyCode)
    {   
        # handle zoom
        "Add"       
        {
            scaleGame $True
        }
        "Oemplus"
        {
            scaleGame $True
        }
        "Subtract"
        {
            scaleGame $False
        }
        "OemMinus"
        {
            scaleGame $False
        }
        "Escape"
        {
            #showWindow "WND_ESC_MAIN"
            if($global:strGameState -eq "EDIT_MAP")
            {
                showWindow "WND_ESC_EDITOR"
                $global:strGameState = "EDIT_MAP_ESCAPE"
                $objForm.Refresh();
            }
            elseif($global:strGameState -eq "EDIT_MAP_ESCAPE")
            {
                $global:strGameState = "EDIT_MAP"
                showWindow "WND_INTERFACE_EDITOR"
                $objForm.Refresh();
            }
        }
        "T"
        {
            Write-Host "Testfunction!"
            #$global:arrWindows["WND_ESC_MAIN"].btn.Remove("BTN_SINGLEPLAYER")
            #addButtonToWindow "WND_ESC_MAIN" "BTN_SINGLEPLAYER_KRAM" "Gray" 136 20 12 24 "Singlekram" 8 4 "Gold" $False
            
        }
        "P"
        {
            if($global:strGameState -eq "EDIT_MAP")
            {
                Write-Host "toggling tile preview"
                $global:arrCreateMapOptions["SHOW_PREVIEW"] = !$global:arrCreateMapOptions["SHOW_PREVIEW"]
            }
        }
        "Right"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -lt ($global:arrCreateMapOptions["WIDTH"] - 16) -and $global:strGameState -eq "EDIT_MAP")
            {
                Write-Host "Move right"
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] += 1;
                $objForm.Refresh();
            }
			if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -lt ($global:arrCreateMapOptions["WIDTH"] - 16) -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                Write-Host "Move right"
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] += 1;
                $objForm.Refresh();
            }
        }
        "Left"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -gt 0 -and $global:strGameState -eq "EDIT_MAP")
            {
                Write-Host "Move left"
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] -= 1;
                $objForm.Refresh();
            }

			if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -gt 0 -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                Write-Host "Move left"
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] -= 1;
                $objForm.Refresh();
            }
        }
        "Down"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -lt ($global:arrCreateMapOptions["HEIGHT"] - 13) -and $global:strGameState -eq "EDIT_MAP")
            {
                Write-Host "Move down"
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] += 1;
                $objForm.Refresh();
            }

			if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -lt ($global:arrCreateMapOptions["HEIGHT"] - 13) -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                Write-Host "Move down"
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] += 1;
                $objForm.Refresh();
            }
        }
        "Up"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -gt 0 -and $global:strGameState -eq "EDIT_MAP")
            {
                Write-Host "Move up"
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -= 1;
                $objForm.Refresh();
            }

			if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -gt 0 -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                Write-Host "Move up"
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -= 1;
                $objForm.Refresh();
            }
        }
        
        default     {Write-Host "Unhandled keypress, code '$keyCode'"}
    }
}

function onMouseClick($strNameSender)
{
    if($global:strGameState -eq "INPUT_MAPNAME" -or $global:strGameState -eq "INPUT_MAPAUTHOR")
    {
        return;
    }

    $relX = [System.Windows.Forms.Cursor]::Position.X - $objForm.Location.X - 8 # 8 = left border
    $relY = [System.Windows.Forms.Cursor]::Position.Y - $objForm.Location.Y - 30 # 30 = upper border
    
    $relX = $relX / [math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 ))
    $relY = $relY / [math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 ))
    
    switch($strNameSender)
    {
        "Picturebox"
        {
            handleClickPicturebox $relX $relY
        }
        default
        {
            Write-Host "unhandled click at $relX $relY"
        }
    }
}

function handleClickPicturebox($posX, $posY)
{
    if($global:strGameState -eq "WAIT_INIT_CLICK")
    {
        showWindow "WND_ESC_MAIN"
        $global:strGameState = "MAIN_MENU"
    }
    elseif($global:strGameState -eq "INPUT_MAPNAME" -or $global:strGameState -eq "INPUT_MAPAUTHOR")
    {
        return;
    }
    elseif($global:windowOpen)
    {
        handleClickWindow $posX $posY
    }
    else
    {
        Write-Host "unhandled click at $relX $relY (in handleClickPicturebox)"
    }
}
function handleClickGameworld ($posX, $posY)
{
	$tile_x = [math]::floor($posX / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($posY / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]

	Write-Host "handleClickGameworld: $tile_x $tile_y"
    
    if($tile_x -lt 2 -or $tile_y -lt 2 -or $tile_x -gt ($arrCreateMapOptions["WIDTH"] + 1) -or $tile_y -gt ($arrCreateMapOptions["HEIGHT"] + 1))
    {
        Write-Host "handleClickGameworld: But border tile"
        return;
    }

	$canBuild = checkIfBuildingPossible ([int]($tile_x - 2)) ([int]($tile_y - 2))

	if($canBuild -and $global:arrSettings["BUILDINGS_SELECTED"] -ge 0)
	{
		addBuildingAtPositionForPlayer ([int]($tile_x - 2)) ([int]($tile_y - 2)) $global:arrSettings["BUILDINGS_SELECTED"] 1
        $global:arrSettings["BUILDINGS_SELECTED"] = -1
	}

}

function addBuildingAtPositionForPlayer($posX, $posY, $building, $player)
{
	# (1) generate new building
	# (2) add building to lbld array (index)
	# (3) redraw

	Write-Host "addBuildingAtPositionForPlayer($posX, $posY, $building, $player)"

	#$global:arrBuildings[7] = @{}
	#$global:arrBuildings[7].loc_x = 0
	#$global:arrBuildings[7].loc_y = 0
	#$global:arrBuildings[7].owner = 0
	#$global:arrBuildings[7].type = 0
	#$global:arrBuildings[7].hitpoints = 0

	#
	# 1
	#
	$nextBuildingIndex = $global:arrMap["BUILDING_INDEX"] + 1
	$global:arrMap["BUILDING_INDEX"] += 1
	#$nextBuildingIndex = $global:arrBuildings.IndexOf([int]($global:arrBuildings[-1]))
	$last = $global:arrBuildings.Values
	#$nextBuildingIndex = ($global:arrBuildings.keys)
	Write-Host "next index is: $nextBuildingIndex"
	$global:arrBuildings[$nextBuildingIndex] = @{}
	$global:arrBuildings[$nextBuildingIndex].loc_x = $posX
	$global:arrBuildings[$nextBuildingIndex].loc_y = $posY
	$global:arrBuildings[$nextBuildingIndex].owner = $player
	$global:arrBuildings[$nextBuildingIndex].type = $building
	$global:arrBuildings[$nextBuildingIndex].hitpoints = 10

	#
	# 2
	#
	$global:arrMap["WORLD_LBLD"][$posX][$posY] = $nextBuildingIndex

	#
	# 3
	#
	drawBuildingAt $posX $posY $building $player

	#$global:arrBuildings = @{}
	#$global:arrBuildings[0] = @{}
	
}

function drawBuildingAt($posX, $posY, $bld, $player)
{
	Write-Host "drawBuildingAt($posX, $posY, $bld, $player)"
	$key = $arrBuildingIDToKey[$bld]
	Write-Host "Key for ID is: $key"

    MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][[int]$posX][[int]$posY]]]) ($posX + 2) ($posY + 2)

    if([int]$global:arrMap["WORLD_L2"][([int]$posX)][([int]$posY)] -ne -1)
    {
        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][$posX][$posY]]]) ($posX + 2) ($posY + 2)
    }
    # don't need layer 3, if there is something on layer 3 the player couldn't be added in the first place
    #MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L3"][$posX][$posY]]]) $posX $posY

    #MAP_changeTile ($global:arrTextures[$arrPlayerIconsIDToKey[$playerID]]) ($posX + 2) ($posY + 2)

	#$arrBuildingIDToKey = "HQ", "HUM_HOUSE_SMALL"
	#
	#$rect_tile    = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
	#$strPathToBuildingGFX = ".\GFX\BUILDING\"
	#$global:arrBuilding = @{}
	#$arrBuilding["HQ"]
	#$arrBuilding["HQ"][2] = $arrBuilding["HQ"][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

	MAP_changeTile $arrBuilding[$arrBuildingIDToKey[$bld]][($player + 1)] ($posX + 2) ($posY + 2)


	#MAP_changeTile $arrBuilding["HUM_HOUSE_SMALL"][0] ($posX + 2) ($posY + 2)
}

function checkIfBuildingPossible($posX, $posY)
{
	# first check if it's a valid position
    # LAYER 1 check

	Write-Host "checkIfBuildingPossible($posX, $posY)"

    if([int]$global:arrMap["WORLD_L1"][$posX][$posY] -ge 0 -and [int]$global:arrMap["WORLD_L1"][$posX][$posY] -lt 4)
    {
        # LAYER 2 check
        if([int]$global:arrMap["WORLD_L2"][$posX][$posY] -ge 12 -and [int]$global:arrMap["WORLD_L2"][$posX][$posY] -le 22 -or [int]$global:arrMap["WORLD_L2"][$posX][$posY] -eq -1)
        {
            if([int]$global:arrMap["WORLD_L3"][$posX][$posY] -eq -1)
            {
				if($global:arrMap["WORLD_LBLD"][$posX][$posY] -eq -1)
				{
					Write-Host "Valid buildingspot"
					return $True
				}
				else
				{
					Write-Host "Invalid BQ - LBLD"
				}
            }
			else
			{
				Write-Host "Invalid BQ - L3"
			}
        }
		else
		{
			Write-Host "Invalid BQ - L2"
		}
    }
	else
	{
		Write-Host "Invalid BQ - L1"
	}

	return $False
}

function handleClickEditor($posX, $posY)
{
    $tile_x = [math]::floor($posX / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($posY / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]
    
    #$global:arrCreateMapOptions["SELECTED_X"] = $tile_x;
    #$global:arrCreateMapOptions["SELECTED_Y"] = $tile_y;

    #Write-Host "click at tile $tile_x $tile_y"
    
    if($tile_x -lt 2 -or $tile_y -lt 2 -or $tile_x -gt ($arrCreateMapOptions["WIDTH"] + 1) -or $tile_y -gt ($arrCreateMapOptions["HEIGHT"] + 1))
    {
        Write-Host "But border tile"
        return;
    }
    
    if($global:arrCreateMapOptions["EDIT_MODE"] -eq 1 -and (($global:arrCreateMapOptions["LAST_CHANGED_X"] -ne $tile_x) -or ($global:arrCreateMapOptions["LAST_CHANGED_Y"] -ne $tile_y) -or ($global:arrCreateMapOptions["LAST_MODE"] -ne 1) -or ($global:arrCreateMapOptions["LAST_CHANGED_TEX"] -ne $global:arrCreateMapOptions["SELECT_LAYER01"])))
    {
        $playerAtPos = getPlayerAtPosition ([int]$tile_x - 2) ([int]$tile_y - 2)
        if($playerAtPos -ne 0) {return}

        MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) $tile_x $tile_y
        $global:arrCreateMapOptions["LAST_CHANGED_TEX"] = $global:arrCreateMapOptions["SELECT_LAYER01"];
        $global:arrCreateMapOptions["LAST_MODE"] = $global:arrCreateMapOptions["EDIT_MODE"];
        $global:arrCreateMapOptions["LAST_CHANGED_X"] = $tile_x;
        $global:arrCreateMapOptions["LAST_CHANGED_Y"] = $tile_y;

        #Write-Host "Mapposis: $tile_x $tile_y"

        $global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER01"]
        $global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] = -1
        $global:arrMap["WORLD_L3"][([int]$tile_x - 2)][([int]$tile_y - 2)] = -1

    }
    elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 2 -and (($global:arrCreateMapOptions["LAST_CHANGED_X"] -ne $tile_x) -or ($global:arrCreateMapOptions["LAST_CHANGED_Y"] -ne $tile_y) -or ($global:arrCreateMapOptions["LAST_MODE"] -ne 2) -or ($global:arrCreateMapOptions["LAST_CHANGED_TEX"] -ne $global:arrCreateMapOptions["SELECT_LAYER02"])))
    {
        $playerAtPos = getPlayerAtPosition ([int]$tile_x - 2) ([int]$tile_y - 2)
        if($playerAtPos -ne 0) {return}

        #MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) $tile_x $tile_y
        MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y

        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) $tile_x $tile_y
        $global:arrCreateMapOptions["LAST_CHANGED_TEX"] = $global:arrCreateMapOptions["SELECT_LAYER02"];
        $global:arrCreateMapOptions["LAST_MODE"] = $global:arrCreateMapOptions["EDIT_MODE"];
        $global:arrCreateMapOptions["LAST_CHANGED_X"] = $tile_x;
        $global:arrCreateMapOptions["LAST_CHANGED_Y"] = $tile_y;

        #Write-Host "Mapposis: $tile_x $tile_y"

        #$global:arrMap["WORLD_L1"][($tile_x - 2)][($tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER01"]
        #MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y
        $global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER02"]
        $global:arrMap["WORLD_L3"][([int]$tile_x - 2)][([int]$tile_y - 2)] = -1
    }
    elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 3 -and (($global:arrCreateMapOptions["LAST_CHANGED_X"] -ne $tile_x) -or ($global:arrCreateMapOptions["LAST_CHANGED_Y"] -ne $tile_y) -or ($global:arrCreateMapOptions["LAST_MODE"] -ne 3) -or ($global:arrCreateMapOptions["LAST_CHANGED_TEX"] -ne $global:arrCreateMapOptions["SELECT_LAYER03"])))
    {
        #MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) $tile_x $tile_y
        $playerAtPos = getPlayerAtPosition ([int]$tile_x - 2) ([int]$tile_y - 2)
        if($playerAtPos -ne 0) {return}

        MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y
        # we can have objects without overlay texture
        if([int]$global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] -ne -1)
        {
            MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y
        }

        MAP_changeTile ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]) $tile_x $tile_y
        $global:arrCreateMapOptions["LAST_CHANGED_TEX"] = $global:arrCreateMapOptions["SELECT_LAYER03"];
        $global:arrCreateMapOptions["LAST_MODE"] = $global:arrCreateMapOptions["EDIT_MODE"];
        $global:arrCreateMapOptions["LAST_CHANGED_X"] = $tile_x;
        $global:arrCreateMapOptions["LAST_CHANGED_Y"] = $tile_y;

        #Write-Host "Mapposis: $tile_x $tile_y"

        #$global:arrMap["WORLD_L1"][($tile_x - 2)][($tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER01"]
        #MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y
        $global:arrMap["WORLD_L3"][([int]$tile_x - 2)][([int]$tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER03"]
    }
    elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 5)
    {
        # first check if it's a valid position
        # LAYER 1 check
        if([int]$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)] -ge 0 -and [int]$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)] -lt 4)
        {
            # LAYER 2 check
            if([int]$global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] -ge 12 -and [int]$global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] -le 22 -or [int]$global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] -eq -1)
            {
                if([int]$global:arrMap["WORLD_L3"][([int]$tile_x - 2)][([int]$tile_y - 2)] -eq -1)
                {
                    $playerAtPos = getPlayerAtPosition ([int]$tile_x - 2) ([int]$tile_y - 2)
                    Write-Host "Player at position is: $playerAtPos"

                    if($playerAtPos -ne 0) 
                    {
                        removePlayerFromPosition $playerAtPos
                    }
                    
                    if($global:arrCreateMapOptions["SELECT_PLAYER"] -ne 0)
                    {
                        removePlayerFromPosition $global:arrCreateMapOptions["SELECT_PLAYER"]
                    }

                    if($global:arrCreateMapOptions["SELECT_PLAYER"] -ne 0)
                    {
                        setPlayerPosition ([int]$tile_x - 2) ([int]$tile_y - 2) $global:arrCreateMapOptions["SELECT_PLAYER"]

                    }
                }
            }
        }
    }
}

function handleClickWindow($posX, $posY)
{
    $relX = $posX -  $global:arrWindows[$global:strCurrentWindow].loc_x
    $relY = $posY -  $global:arrWindows[$global:strCurrentWindow].loc_y

    # relative to window click    
    if($global:strGameState -eq "EDIT_MAP" -and $posX -lt ($DrawingSizeX - 160))
    {
        Write-Host "Send click to editor"
        handleClickEditor $posX $posY
    }

	if($global:strGameState -eq "SINGLEPLAYER_INGAME" -and $posX -lt ($DrawingSizeX - 160))
    {
        Write-Host "Send click to gameworld"
        handleClickGameworld $posX $posY
    }
    
    if($global:windowOpen -and !$global:arrWindows[$global:strCurrentWindow].btn)
    {
        Write-Host "Active window but no buttons?"
        return;
    }
    
    if($posX -lt $global:arrWindows[$global:strCurrentWindow].loc_x -or $posX -gt ($global:arrWindows[$global:strCurrentWindow].loc_x + $global:arrWindows[$global:strCurrentWindow].wnd.Width))
    {
        return;
    }
    
    if($posY -lt $global:arrWindows[$global:strCurrentWindow].loc_y -or $posY -gt ($global:arrWindows[$global:strCurrentWindow].loc_y + $global:arrWindows[$global:strCurrentWindow].wnd.Height))
    {
        return;
    }
    
    $keys    = $global:arrWindows[$global:strCurrentWindow].btn.Keys
    
    Try
    {
        foreach($key in $keys)
        {
            if(!$global:arrWindows[$global:strCurrentWindow].btn)
            {
                return;
            }
            
            if(($global:arrWindows[$global:strCurrentWindow].btn[$key].loc_x -lt $relX) -and ($global:arrWindows[$global:strCurrentWindow].btn[$key].loc_x + $global:arrWindows[$global:strCurrentWindow].btn[$key].size_x -gt $relX))
            {
                if(($global:arrWindows[$global:strCurrentWindow].btn[$key].loc_y -lt $relY) -and ($global:arrWindows[$global:strCurrentWindow].btn[$key].loc_y + $global:arrWindows[$global:strCurrentWindow].btn[$key].size_y -gt $relY))
                {
                    handleButtonKlick $key ($relX - $global:arrWindows[$global:strCurrentWindow].btn[$key].loc_x) ($relY - $global:arrWindows[$global:strCurrentWindow].btn[$key].loc_y) $global:arrWindows[$global:strCurrentWindow].btn[$key].size_x $global:arrWindows[$global:strCurrentWindow].btn[$key].size_y
                }
            }
        }
    }
    Catch [system.exception]
    {
        Write-Host "Warning: Maybe a click has not properly been registered!"
    }
}

function handleButtonKlick($strButtonID, $iPosX, $iPosY, $iSizeX, $iSizeY)
{
    switch($strButtonID)
    {
        "BTN_QUIT"
        {
            showWindow "WND_QUIT_MAIN"
        }
        "BTN_QUIT_NO"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_CREDITS"
        {
            showWindow "WND_CREDITS"
        }
        "BTN_QUIT_YES"
        {
            $objForm.Close();
        }
        "BTN_OPTIONS"
        {
            showWindow "WND_GAME_OPTIONS"
        }
        "BTN_GAME_OPTIONS_BACK"
        {
            saveConfig
            showWindow "WND_ESC_MAIN"
        }
        "BTN_CREDITS_BACK"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_SINGLEPLAYER"
        {
            showWindow "WND_SINGLEPLAYER_SETUP"
        }
        "BTN_MULTIPLAYER"
        {
            showWindow "WND_ERROR_NOTIMPLEMENTED"
        }
        "BTN_SINGLEPLAYER_SETUP_START"
        {
			$global:arrMap["WIDTH"] = 0
            $global:arrMap["HEIGHT"] = 0

            #showWindow "WND_ERROR_NOTIMPLEMENTED"
			showWindow "WND_PLEASE_WAIT"
            loadMap $global:strMapFile
			
            showWindow "WND_SINGLEPLAYER_MENU"
            $global:strGameState = "SINGLEPLAYER_INGAME";
			$pictureBox.Refresh();
        }
        "BTN_ERROR_NOTIMPLEMENTED_BACK"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_EDITOR"
        {
            #Reset Variables
            #$global:arrCreateMapOptions = @{}
            #$global:arrCreateMapOptions["WIDTH"] = 32;
            #$global:arrCreateMapOptions["HEIGHT"] = 32;
            #$global:arrCreateMapOptions["BASTEXTUREID"] = 0;
            $global:arrCreateMapOptions["EDITOR_CHUNK_X"] = 0;
            $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] = 0;
        
            showWindow "WND_CREATE_MAP"
        }
        "BTN_CREATE_MAP_CANCEL"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_CREATEMAP_TEXTURE_PREV"
        {
            if($global:arrCreateMapOptions["BASTEXTUREID"] -ne 0)
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] -= 1;
            }
            else
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] = $arrBaseTextureIDToKey.Length - 1;
            }
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 210 74
            $pictureBox.Refresh();
        }
        "BTN_CREATEMAP_TEXTURE_NEXT"
        {
            if($global:arrCreateMapOptions["BASTEXTUREID"] -ne ($arrBaseTextureIDToKey.Length - 1))
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] += 1;
            }
            else
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] = 0;
            }
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 210 74
            $pictureBox.Refresh();
        }
        "BTN_CREATEMAP_WADD01"
        {
            MAP_changeMapsizeBy "WIDTH" 16 $True
        }
        "BTN_CREATEMAP_WADD02"
        {
            MAP_changeMapsizeBy "WIDTH" 2 $True
        }
        "BTN_CREATEMAP_WIDTH"
        {
        }
        "BTN_CREATEMAP_WSUB01"
        {
            MAP_changeMapsizeBy "WIDTH" -2 $True
        }
        "BTN_CREATEMAP_WSUB02"
        {
            MAP_changeMapsizeBy "WIDTH" -16 $True
        }
        "BTN_CREATEMAP_HADD01"
        {
            MAP_changeMapsizeBy "HEIGHT" 16 $True
        }
        "BTN_CREATEMAP_HADD02"
        {
            MAP_changeMapsizeBy "HEIGHT" 2 $True
        }
        "BTN_CREATEMAP_HEIGHT"
        {
        }
        "BTN_CREATEMAP_HSUB01"
        {
            MAP_changeMapsizeBy "HEIGHT" -2 $True
        }
        "BTN_CREATEMAP_HSUB02"
        {
            MAP_changeMapsizeBy "HEIGHT" -16 $True
        }
        "BTN_CREATE_MAP_CONTINUE"
        {
            # Creating map...
            showWindow "WND_PLEASE_WAIT"
            # reset map here
            $global:arrMap = @{}
            $global:arrMap["AUTHOR"] = "The Author"
            $global:arrMap["MAPNAME"] = "The Name"
            $global:arrMap["WIDTH"] = 0
            $global:arrMap["HEIGHT"] = 0
            $global:arrMap["PLAYER_01X"] = -1
            $global:arrMap["PLAYER_01Y"] = -1
            $global:arrMap["PLAYER_02X"] = -1
            $global:arrMap["PLAYER_02Y"] = -1
            $global:arrMap["PLAYER_03X"] = -1
            $global:arrMap["PLAYER_03Y"] = -1
            $global:arrMap["PLAYER_04X"] = -1
            $global:arrMap["PLAYER_04Y"] = -1
            $global:arrMap["WORLD_L1"] = @{}
            $global:arrMap["WORLD_L2"] = @{}
            $global:arrMap["WORLD_L3"] = @{}

            MAP_createMapImage
            #$global:windowOpen = $False;
            showWindow "WND_INTERFACE_EDITOR"
            $global:strGameState = "EDIT_MAP";
            
            #$global:objWorld.Save("world.png")
            
            $objForm.Refresh();
        }
        "BTN_CREATE_MAP_LOAD"
        {
            openMapFile
            if($global:strMapFile -ne "")
            {
                showWindow "WND_PLEASE_WAIT"
                loadMap $global:strMapFile
                showWindow "WND_INTERFACE_EDITOR"
                $global:strGameState = "EDIT_MAP";
            }
            else
            {
                Write-Host "No map selected"
            }
        }
        "BTN_SINGLEPLAYER_SETUP_MAP"
        {
            openMapFile
            if($global:strMapFile -ne "")
            {
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove("BTN_SINGLEPLAYER_SETUP_MAP")
                $filename = Split-Path $global:strMapFile -leaf
                addButtonToWindow "WND_SINGLEPLAYER_SETUP" "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 286 20 142 12 $filename 4 4 "Gold" $False

                # header load map
                loadMapHeader $global:strMapFile

                #addText $global:arrWindows[$strType].wnd "Players:" 12 46 "Gold" $False
                # Playercount
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 142 46 100 36
                [string]$playerCount = getPlayerCount
                addText $global:arrWindows["WND_SINGLEPLAYER_SETUP"].wnd $playerCount 142 46 "Gold" $False

                # Author
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 142 76 100 36
                addText $global:arrWindows["WND_SINGLEPLAYER_SETUP"].wnd $global:arrMap["AUTHOR"] 142 76 "Gold" $False

                # Size
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 142 106 100 36
                addText $global:arrWindows["WND_SINGLEPLAYER_SETUP"].wnd ($global:arrMap["WIDTH"] + " x " + $global:arrMap["HEIGHT"]) 142 106 "Gold" $False

                #$pictureBox.Refresh();
                $objForm.Refresh();
            }  
        }
        "BTN_SWITCH_TOPMOST"
        {
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_SWITCH_TOPMOST")
            $global:arrSettings["TOPMOST"] = !$global:arrSettings["TOPMOST"];
            $objForm.Topmost = $global:arrSettings["TOPMOST"];
            addSwitchButtonToWindow "WND_GAME_OPTIONS" "BTN_SWITCH_TOPMOST" $global:arrSettings["TOPMOST"] 60 20 240 12 $True $False
        }
        #"BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT"
        #{
        #    
        #    $newX = [math]::floor($iPosX / 20)
        #    $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove("BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT")
        #    addCountButtonToWindow "WND_SINGLEPLAYER_SETUP" "BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT" 20 20 142 42 5 ($newX + 1) $False
        #}
        "BTN_WND_GAME_OPTIONS_SCREENSIZE"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_SCREENSIZE")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_SCREENSIZE" 20 20 240 46 3 ($newX + 1) $False
            
            $global:arrSettings["STARTUPSIZE"] = ($newX + 1);
        }
        "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_VOLUMEMUSIC")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC" 20 20 240 80 5 ($newX + 1) $False
            
            Write-Host "Setting music volume..."
            $global:arrSettings["VOLUMEMUSIC"] = $newX * 0.05;
            $global:objMusic001.Volume = $global:arrSettings["VOLUMEMUSIC"];
        }
        "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS" 20 20 240 114 5 ($newX + 1) $False
            
            $global:arrSettings["VOLUMEEFFECTS"] = $newX * 0.05;
        }
        "BTN_EDITOR_QUIT"
        {
            showWindow "WND_QUIT_EDITOR"
            #$global:strGameState = "MAIN_MENU"
            #$global:strCurrentWindow = "WND_ESC_MAIN"
            #$objForm.Refresh();
        }
        "BTN_EDITOR_QUIT_YES"
        {
            $global:strGameState = "MAIN_MENU"
            $global:strCurrentWindow = "WND_ESC_MAIN"
            $objForm.Refresh();
        }
        "BTN_EDITOR_QUIT_NO"
        {
            showWindow "WND_ESC_EDITOR"
            $objForm.Refresh();
        }
        "BTN_EDITOR_SAVEIMAGE"
        {
            showWindow "WND_PLEASE_WAIT"
            $objForm.Refresh();
            try
            {
                $global:objWorld.Save(($PSScriptRoot + ".\MAP\" + ($global:arrMap["MAPNAME"]) + ".png"))
            }
            catch 
            {
                $ErrorMessage = $_.Exception.Message
                Write-Host "Error: $ErrorMessage"
            }
            Write-Host "Image has been saved!"
            showWindow "WND_ESC_EDITOR"
            $objForm.Refresh();
        }
        "BTN_EDITOR_SAVEMAP"
        {
            showWindow "WND_PLEASE_WAIT"
            saveMap ""
            showWindow "WND_ESC_EDITOR"
        }
        "BTN_IFE_EDIT_LAYER01"
        {
            if($global:arrCreateMapOptions["EDIT_MODE"] -eq 1)
            {
                return;
            }
        
            $global:arrCreateMapOptions["EDIT_MODE"] = 1;
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER03_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_PLAYER_SELECT")
            #$global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_PREV")
            #$global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_NEXT")
            
            buildButton "Gray" 20 20 10 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
            
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
            
            # next and prev disabled for now
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_PREV" "Gray" 40 20 16 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 23 202
            
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_NEXT" "Gray" 40 20 104 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 111 202
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_SELECT" "Transparent" 120 160 16 36 "" 8 4 "Gold" $False
            
            
            $max_tex_id = $arrBaseTextureIDToKey.Length
            for($i = 0; $i -lt 6; $i++)
            {
                for($j = 0; $j -lt 8; $j++)
                {
                    $tex_id = ($global:arrCreateMapOptions["IDX_LAYER01"] + ($i * 8) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  20 20 (16 + $i * 20) (36 + $j * 20) $False
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20)
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) (19 + $old_x * 20) (39 + $old_y * 20)
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYER01_SELECT"
        {
            $texID = [math]::floor($iPosX / 20) * 8 + [math]::floor($iPosY / 20)
            $max_tex_id = $arrBaseTextureIDToKey.Length
            $texID += $global:arrCreateMapOptions["IDX_LAYER01"];
            
            if($texID -lt $max_tex_id -and $texID -ne $global:arrCreateMapOptions["SELECT_LAYER01"])
            {
                # alte markierung übermalen
                $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] / 8)
                $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] - ($old_x * 8))
                buildButton "Gray"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $False
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) (18 + $old_x * 20) (38 + $old_y * 20)
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20)
                
                $global:arrCreateMapOptions["SELECT_LAYER01"] = $texID;
                $pictureBox.Refresh();
            }
            
            Write-Host "TextureID: $texID"
        }
        "BTN_IFE_EDIT_LAYER02"
        {
            if($global:arrCreateMapOptions["EDIT_MODE"] -eq 2)
            {
                return;
            }
        
            $global:arrCreateMapOptions["EDIT_MODE"] = 2;
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER03_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_PLAYER_SELECT")
            #$global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_PREV")
            #$global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_NEXT")
            
            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
            
            # next and prev disabled for now
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_NEXT" "Gray" 40 20 16 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 23 202
            #
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_PREV" "Gray" 40 20 104 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 111 202
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_SELECT" "Transparent" 120 160 16 36 "" 8 4 "Gold" $False
   
            $max_tex_id = $arrOverlayTextureIDToKey.Length
            for($i = 0; $i -lt 6; $i++)
            {
                for($j = 0; $j -lt 8; $j++)
                {
                    $tex_id = ($global:arrCreateMapOptions["IDX_LAYER02"] + ($i * 8) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  20 20 (16 + $i * 20) (36 + $j * 20) $False
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20)
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) (19 + $old_x * 20) (39 + $old_y * 20)
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYER02_SELECT"
        {
            $texID = [math]::floor($iPosX / 20) * 8 + [math]::floor($iPosY / 20)
            $max_tex_id = $arrOverlayTextureIDToKey.Length
            $texID += $global:arrCreateMapOptions["IDX_LAYER02"];
            
            if($texID -lt $max_tex_id -and $texID -ne $global:arrCreateMapOptions["SELECT_LAYER02"])
            {
                # alte markierung übermalen
                $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] / 8)
                $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] - ($old_x * 8))
                buildButton "Gray"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $False
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) (18 + $old_x * 20) (38 + $old_y * 20)
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20)
                
                $global:arrCreateMapOptions["SELECT_LAYER02"] = $texID;
                $pictureBox.Refresh();
            }
            Write-Host "TextureID(Layer2): $texID"
        }
        "BTN_IFE_EDIT_LAYER03"
        {
            if($global:arrCreateMapOptions["EDIT_MODE"] -eq 3)
            {
                return;
            }

            $global:arrCreateMapOptions["EDIT_MODE"] = 3;
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_PLAYER_SELECT")
            
            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER03_SELECT" "Transparent" 120 160 16 36 "" 8 4 "Gold" $False

            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220

            $max_tex_id = $arrObjectTextureIDToKey.Length
            for($i = 0; $i -lt 6; $i++)
            {
                for($j = 0; $j -lt 8; $j++)
                {
                    $tex_id = ($global:arrCreateMapOptions["IDX_LAYER03"] + ($i * 8) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  20 20 (16 + $i * 20) (36 + $j * 20) $False
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20)
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]) (19 + $old_x * 20) (39 + $old_y * 20)
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYER03_SELECT"
        {
            $texID = [math]::floor($iPosX / 20) * 8 + [math]::floor($iPosY / 20)
            $max_tex_id = $arrObjectTextureIDToKey.Length
            $texID += $global:arrCreateMapOptions["IDX_LAYER03"];
            
            if($texID -lt $max_tex_id -and $texID -ne $global:arrCreateMapOptions["SELECT_LAYER03"])
            {
                # alte markierung übermalen
                $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] / 8)
                $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] - ($old_x * 8))
                buildButton "Gray"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $False
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]) (18 + $old_x * 20) (38 + $old_y * 20)
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20)
                
                $global:arrCreateMapOptions["SELECT_LAYER03"] = $texID;
                $pictureBox.Refresh();
            }
            Write-Host "TextureID(Layer3): $texID"
        }
        "BTN_IFE_EDIT_DIRECTIONS"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 4;
            
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER03_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_PLAYER_SELECT")

            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
        
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_PLAYER"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 5;

            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER03_SELECT")
            
            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_PLAYER_SELECT" "Transparent" 20 100 16 36 "" 8 4 "Gold" $False

            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220


            $max_tex_id = $arrObjectTextureIDToKey.Length
            for($i = 0; $i -lt 5; $i++)
            {
                buildButton "Gray"  20 20 16 (36 + $i * 20) $False
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$i]]) 18 (38 + $i * 20)
            }
            
            buildButton "Red"  20 20 16 (36 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 19 (39 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"])


            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_PLAYER_SELECT"
        {
            $playerID = [math]::floor($iPosY / 20)

            # redraw old selection
            buildButton "Gray"  20 20 16 (36 + $global:arrCreateMapOptions["SELECT_PLAYER"] * 20) $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 18 (38 + $global:arrCreateMapOptions["SELECT_PLAYER"] * 20)

            $global:arrCreateMapOptions["SELECT_PLAYER"] = $playerID

            # redraw new selection
            buildButton "Red"  20 20 16 (36 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 19 (39 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"])

            Write-Host "Player with ID $playerID selected"

        }
        "BTN_IFE_EDIT_LAYERSETTINGS"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 6;

            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER03_SELECT")
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_PLAYER_SELECT")
            
            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            buildButton "Gray" 20 20 130 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
        
            $pictureBox.Refresh();
        }
        "BTN_BUILDINGS_01"
        {
            $global:arrCreateMapOptions["CLICK_MODE"] = 1;

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "Economy Buildings" -1 -1 "Gold" $False

            buildButton "Gray" 20 20 10 12 $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14

            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_BUILDING_01_SELECT" "Transparent" 120 160 10 58 "" 8 4 "Gold" $False

            $max_tex_id = $global:arrSettings["BUILDINGS_CIVIL"]
            for($i = 0; $i -lt 4; $i++)
            {
                for($j = 0; $j -lt 4; $j++)
                {
                    $tex_id = (($i * 4) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  20 20 (10 + $i * 20 + $i * 18) (58 + $j * 20 + $j * 12) $False
                        addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$tex_id]][0]) (11 + $i * 20 + $i * 18) (59 + $j * 20 + $j * 12)
                    }
                }
            }

        }
        "BTN_BUILDING_01_SELECT"
        {
            $texID = -1

            $ColID = [math]::floor($iPosX / 38)
            $RowID = [math]::floor($iPosY / 32)
            if($iPosX -gt ($ColID * 20 + $ColID * 18) -and $iPosX -lt (20 + $ColID * 20 + $ColID * 18))
            {
                if($iPosY -gt ($RowID * 20 + $RowID * 12) -and $iPosY -lt (20 + $RowID * 20 + $RowID * 12))
                {
                    $texID = $ColID * 4 + $RowID
                    Write-Host "valid spot"
                }
            }

            if($texID -eq -1 -or $texID -ge $global:arrSettings["BUILDINGS_CIVIL"])
            {
                return;
            }

            $global:arrSettings["BUILDINGS_SELECTED"] = $texID
            Write-Host "TextureID: $texID"
        }
        "BTN_BUILDINGS_02"
        {
            $global:arrCreateMapOptions["CLICK_MODE"] = 2;

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "Military Buildings" -1 -1 "Gold" $False

            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14

            buildButton "Gray" 20 20 34 12 $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14
        }
        "BTN_EDITMAPNAME"
        {
            $global:strGameState = "INPUT_MAPNAME"
        }
        "BTN_EDITMAPAUTHOR"
        {
            $global:strGameState = "INPUT_MAPAUTHOR"
        }
        default
        {
            Write-Host "Button $strButtonID was clicked but has no function?"
        }
    }
}

function showWindow($strType)
{
	Write-Host "Building window: $strType"
    switch($strType)
    {
        "WND_ESC_MAIN"
        {
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow "WND_ESC_MAIN" "BTN_SINGLEPLAYER" "Gray" 136 20 12 14 "Singleplayer" -1 -1 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_MULTIPLAYER" "Gray" 136 20 12 40 "Multiplayer" -1 -1 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_EDITOR" "Gray" 136 20 12 66 "Editor" -1 -1 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_OPTIONS" "Gray" 136 20 12 92 "Options" -1 -1 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_CREDITS" "Gray" 136 20 12 118 "Credits" -1 -1 "Gold" $False
            
            addButtonToWindow "WND_ESC_MAIN" "BTN_QUIT" "Red" 136 20 12 166 "Quit" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_MAIN"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Really quit?" 12 12 "Gold" $False
            addButtonToWindow "WND_QUIT_MAIN" "BTN_QUIT_YES" "Red" 60 20 12 56 "Yes" -1 -1 "Gold" $False
            addButtonToWindow "WND_QUIT_MAIN" "BTN_QUIT_NO" "Green" 60 20 88 56 "No" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_CREDITS"
        {
            Write-Host "Building window: $strType"
            buildWindow 310 200 (($DrawingSizeX - 310) / 2) (($DrawingSizeY - 200) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Written by:" 10 10 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Spikeone" 10 22 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Story by:" 10 40 "Gold" $False
            addText $global:arrWindows[$strType].wnd "-" 10 52 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Graphics by:" 10 70 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Andre Mari Coppola" 10 82 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Music By:" 10 100 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Ted" 10 112 "Gold" $False
            addButtonToWindow $strType "BTN_CREDITS_BACK" "Gray" 136 20 87 156 "Back" -1 -1 "Gold" $False
        }
        "WND_GAME_OPTIONS"
        {
            Write-Host "Building window: $strType"
            buildWindow 360 220 (($DrawingSizeX - 360) / 2) (($DrawingSizeY - 220) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Topmost:" 12 16 "Gold" $False
            addSwitchButtonToWindow $strType "BTN_SWITCH_TOPMOST" ($global:arrSettings["TOPMOST"]) 60 20 240 12 $True $False
            
            addText $global:arrWindows[$strType].wnd "Startup Screensize:" 12 50 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_SCREENSIZE" 20 20 240 46 3 ([int]$global:arrSettings["STARTUPSIZE"]) $False
            
            addText $global:arrWindows[$strType].wnd "Volume Music (0 = off):" 12 84 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC" 20 20 240 80 5 ($global:arrSettings["VOLUMEMUSIC"] / 0.05 + 1) $False
            
            addText $global:arrWindows[$strType].wnd "Volume Effects (0 = off):" 12 118 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS" 20 20 240 114 5 ($global:arrSettings["VOLUMEEFFECTS"] / 0.05 + 1) $False
            
            addButtonToWindow $strType "BTN_GAME_OPTIONS_BACK" "Gray" 136 20 112 176 "Back" 48 4 "Gold" $False
        }
        "WND_ERROR_NOTIMPLEMENTED"
        {
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Sorry! Not" 10 10 "Gold" $False
            addText $global:arrWindows[$strType].wnd "implemented..." 10 22 "Gold" $False
            addButtonToWindow $strType "BTN_ERROR_NOTIMPLEMENTED_BACK" "Gray" 136 20 12 56 "Back" 48 4 "Gold" $False
        }
        "WND_PLEASE_WAIT"
        {
            buildWindow 160 40 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 40) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Please wait!" 38 10 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Working..." 38 22 "Gold" $False
            $objForm.Refresh();
        }
        "WND_SINGLEPLAYER_SETUP"
        {
            buildWindow 440 230 (($DrawingSizeX - 440) / 2) (($DrawingSizeY - 230) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Map:" 12 16 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 286 20 142 12 "Open Map..." 4 4 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Players:" 12 46 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Author:" 12 76 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Size:" 12 106 "Gold" $False
            
            addButtonToWindow $strType "BTN_ERROR_NOTIMPLEMENTED_BACK" "Red" 136 20 12 198 "Back" 48 4 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_START" "Green" 136 20 292 198 "Start" 48 4 "Gold" $False
        }
        "WND_CREATE_MAP"
        {
            buildWindow 310 200 (($DrawingSizeX - 310) / 2) (($DrawingSizeY - 200) / 2) $strType
            
            $global:arrCreateMapOptions["WIDTH"] = 32;
            $global:arrCreateMapOptions["HEIGHT"] = 32;

            try {$global:arrWindows["WND_CREATE_MAP"].btn.Remove("BTN_CREATEMAP_WIDTH")} catch{}
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 ([string]($global:arrCreateMapOptions["WIDTH"])) 10 4 "Gold" $False

            try {$global:arrWindows["WND_CREATE_MAP"].btn.Remove("BTN_CREATEMAP_HEIGHT")} catch{}
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 ([string]($global:arrCreateMapOptions["HEIGHT"])) 10 4 "Gold" $False

            addText $global:arrWindows[$strType].wnd "Width:" 12 15 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD01" "Gray" 30 20 140 12 "+16" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD02" "Gray" 30 20 170 12 "+ 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 "32" 10 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB01" "Gray" 30 20 240 12 "- 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB02" "Gray" 30 20 270 12 "-16" 4 4 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Height:" 12 45 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD01" "Gray" 30 20 140 42 "+16" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD02" "Gray" 30 20 170 42 "+ 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 "32" 10 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB01" "Gray" 30 20 240 42 "- 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB02" "Gray" 30 20 270 42 "-16" 4 4 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Basetexture:" 12 75 "Gold" $False
            #addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_PREV" "Gray" 20 64 170 86 "<" 4 26 "Gold" $False
            #addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_NEXT" "Gray" 20 64 250 86 ">" 4 26 "Gold" $False

            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_PREV" "Gray" 30 20 170 72 "<" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_NEXT" "Gray" 30 20 240 72 ">" 4 4 "Gold" $False
            
            addImageToWindow $strType ($global:arrTextures[$arrBaseTextureIDToKey[0]]) 210 74
            
            addButtonToWindow $strType "BTN_CREATE_MAP_CANCEL" "Red" 88 20 12 166 "Cancel" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATE_MAP_LOAD" "Gray" 88 20 111 166 "Load..." 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATE_MAP_CONTINUE" "Green" 88 20 210 166 "Continue" 4 4 "Gold" $False
        }
        "WND_ESC_EDITOR"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow $strType "BTN_EDITOR_SAVEMAP" "Gray" 136 20 12 14 "Save map" 8 4 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR_SAVEIMAGE" "Gray" 136 20 12 40 "Save image" 12 4 "Gold" $False
            
            addColoredArea $strType 12 66 136 20 $black
            addText $global:arrWindows[$strType].wnd $global:arrMap["MAPNAME"] 14 70 "Gold" $False
            addButtonToWindow "WND_ESC_EDITOR" "BTN_EDITMAPNAME" "Transparent" 136 20 12 66 "" 8 4 "Gold" $False

            addColoredArea $strType 12 92 136 20 $black
            addText $global:arrWindows[$strType].wnd $global:arrMap["AUTHOR"] 14 96 "Gold" $False
            addButtonToWindow "WND_ESC_EDITOR" "BTN_EDITMAPAUTHOR" "Transparent" 136 20 12 92 "" 8 4 "Gold" $False

            addButtonToWindow $strType "BTN_EDITOR_QUIT" "Red" 136 20 12 166 "Quit" 48 4 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_EDITOR"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Really quit?" 12 12 "Gold" $False
            addButtonToWindow "WND_QUIT_EDITOR" "BTN_EDITOR_QUIT_YES" "Red" 60 20 12 56 "Yes" 8 4 "Gold" $False
            addButtonToWindow "WND_QUIT_EDITOR" "BTN_EDITOR_QUIT_NO" "Green" 60 20 88 56 "No" 8 4 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_INTERFACE_EDITOR"
        {
            buildWindow 160 270 ($DrawingSizeX - 160) 0 $strType
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01" "Gray" 20 20 10 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02" "Gray" 20 20 34 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER03" "Gray" 20 20 58 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_DIRECTIONS" "Gray" 20 20 82 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_PLAYER" "Gray" 20 20 106 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYERSETTINGS" "Gray" 20 20 130 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
        
            $pictureBox.Refresh();
        }

		"WND_SINGLEPLAYER_MENU"
        {

            buildWindow 160 270 ($DrawingSizeX - 160) 0 $strType
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_BUILDINGS_01" "Gray" 20 20 10 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_BUILDINGS_02" "Gray" 20 20 34 12 "" 8 4 "Gold" $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14
            
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "---" -1 -1 "Gold" $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14

            #addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_IFE_EDIT_LAYER03" "Gray" 20 20 58 12 "" 8 4 "Gold" $False
            #addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_LAYER_03"]) 60 14
        	#
            #addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_IFE_EDIT_DIRECTIONS" "Gray" 20 20 82 12 "" 8 4 "Gold" $False
            #addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14
        	#
            #addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_IFE_EDIT_PLAYER" "Gray" 20 20 106 12 "" 8 4 "Gold" $False
            #addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14
            #
            #addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_IFE_EDIT_LAYERSETTINGS" "Gray" 20 20 130 12 "" 8 4 "Gold" $False
            #addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14
            $pictureBox.Refresh();
        }
        default
        {
            Write-Host "Unknown window $strType"
        }
    }
}

function addCountButtonToWindow($strWindow, $strName, $iSizeX, $iSizeY, $iPosX, $iPosY, $iCount, $iActive, $doOutline)
{
    Write-Host "$strName $strBtnColor"
    if(!$global:arrWindows[$strWindow].btn)
    {
        Write-Host "No buttons"
        $global:arrWindows[$strWindow].btn = @{}
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    elseif(!$global:arrWindows[$strWindow].btn[$strName])
    {
        Write-Host "Buttons but new one"
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    else
    {
        Write-Host "Buttons"
        return;
    }
    
    $global:arrWindows[$strWindow].btn[$strName].size_x = ($iSizeX * $iCount);
    $global:arrWindows[$strWindow].btn[$strName].size_y = $iSizeY;
    $global:arrWindows[$strWindow].btn[$strName].loc_x  = $iPosX;
    $global:arrWindows[$strWindow].btn[$strName].loc_y  = $iPosY;
    
    # buttons bekommen keine eigene grafik, sie werden lediglich geführt für die klicks
    if($iSizeX -lt 0 -or $iSizeY -lt 0)
    {
        Write-Host "ERROR: addButtonToWindow Size less than 0"
        return;
    }
    
    if((($iSizeX * $iCount) + $iPosX) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Width) -or ($iSizeY + $iPosY) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Height))
    {
        Write-Host "ERROR: addButtonToWindow button larger than window"
        return;
    }
    
    if($iActive -gt $iCount -or $iActive -lt 0)
    {
        Write-Host "ERROR: Active index out of range (Active: $iActive Count: $iCount)"
        return;
    }
    
    for($i = 0; $i -lt $iCount; $i++)
    {
        if($i -eq ($iActive - 1))
        {
            buildButton "Gray" $iSizeX $iSizeY ($iPosX + $i * $iSizeX) $iPosY $True
        }
        else
        {
            buildButton "Gray" $iSizeX $iSizeY ($iPosX + $i * $iSizeX) $iPosY $False
        }
        addText $global:arrWindows[$strWindow].wnd ([string]$i) ($iPosX + 6 + $i * $iSizeX) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
    }
    
    $objForm.Refresh();
}

function addSwitchButtonToWindow($strWindow, $strName, $isActive, $iSizeX, $iSizeY, $iPosX, $iPosY, $showZeroOne, $doOutline)
{
    Write-Host "$strName $strBtnColor"
    if(!$global:arrWindows[$strWindow].btn)
    {
        Write-Host "No buttons"
        $global:arrWindows[$strWindow].btn = @{}
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    elseif(!$global:arrWindows[$strWindow].btn[$strName])
    {
        Write-Host "Buttons but new one"
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    else
    {
        Write-Host "Buttons"
        return;
    }
    
    $global:arrWindows[$strWindow].btn[$strName].size_x = $iSizeX;
    $global:arrWindows[$strWindow].btn[$strName].size_y = $iSizeY;
    $global:arrWindows[$strWindow].btn[$strName].loc_x  = $iPosX;
    $global:arrWindows[$strWindow].btn[$strName].loc_y  = $iPosY;
    
    # buttons bekommen keine eigene grafik, sie werden lediglich geführt für die klicks
    if($iSizeX -lt 0 -or $iSizeY -lt 0)
    {
        Write-Host "ERROR: addButtonToWindow Size less than 0"
        return;
    }
    
    if(($iSizeX + $iPosX) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Width) -or ($iSizeY + $iPosY) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Height))
    {
        Write-Host "ERROR: addButtonToWindow button larger than window"
        return;
    }
    
    if(!$isActive)
    {
        buildButton "Red" $iSizeX $iSizeY $iPosX $iPosY $False
        buildButton "Gray" ($iSizeX / 2 - 2) ($iSizeY - 4) ($iPosX + $iSizeX - ($iSizeX / 2)) ($iPosY + 2) $False
    }
    else
    {
        buildButton "Green" $iSizeX $iSizeY $iPosX $iPosY $False
        buildButton "Gray" ($iSizeX / 2 - 2) ($iSizeY - 4) ($iPosX + 2) ($iPosY + 2) $False
    }
    
    if($showZeroOne)
    {
        if(!$isActive)
        {
            addText $global:arrWindows[$global:strCurrentWindow].wnd "0" ($iPosX - 4 + $iSizeX / 4) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
        }
        else
        {
            addText $global:arrWindows[$global:strCurrentWindow].wnd "1" ($iPosX - 4 + 3 * $iSizeX / 4) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
        }
        
    }
    
    $objForm.Refresh();
}

function addImageToWindow($strWindow, $objImage, $iPosX, $iPosy)
{
    Write-Host "addImageToWindow: Adding image to window"
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($size_x_w -lt ($size_x_i + $iPosX))
    {
        Write-Host "addImageToWindow: Image outside of window (x)"
        Write-Host "$iPosX $iPosy"
        return;
    }
    
    if($size_y_w -lt ($size_y_i + $iPosy))
    {
        Write-Host "addImageToWindow: Image outside of window (y)"
        Write-Host "$iPosX $iPosy"
        return;
    }

    for($i = 0; $i -lt $size_x_i; $i++)
    {
        for($j = 0; $j -lt $size_y_i; $j++)
        {
            $tmp_pixel = $objImage.GetPixel($i, $j)
        
            if($tmp_pixel -ne $transparent)
            {
                $global:arrWindows[$strWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tmp_pixel);
            }

        }
    }
}

function addColoredArea($strWindow, $iPosX, $iPosy, $iSizeX, $iSizeY, $color)
{
    Write-Host "addImageToWindow: Adding image to window"
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($size_x_w -lt ($size_x_i + $iPosX))
    {
        Write-Host "addImageToWindow: Image outside of window (x)"
        Write-Host "$iPosX $iPosy"
        return;
    }
    
    for($i = $iPosX; $i -lt ($iPosX + $iSizeX); $i++)
    {
        for($j = $iPosy; $j -lt ($iPosY + $iSizeY); $j++)
        {
            $global:arrWindows[$strWindow].wnd.SetPixel($i, $j, $color);
        }
    }
}

function redrawWindowBack($strWindow, $iPosX, $iPosy, $iSizeX, $iSizeY)
{
    Write-Host "addImageToWindow: Adding image to window"
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($size_x_w -lt ($size_x_i + $iPosX))
    {
        Write-Host "addImageToWindow: Image outside of window (x)"
        Write-Host "$iPosX $iPosy"
        return;
    }
    
    if($size_y_w -lt ($size_y_i + $iPosy))
    {
        Write-Host "addImageToWindow: Image outside of window (y)"
        Write-Host "$iPosX $iPosy"
        return;
    }

    $arrBack = New-Object 'object[,]' $global:arrSettings["TILESIZE"],$global:arrSettings["TILESIZE"]
    
    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $arrBack[$i,$j] = $tex_MENU_TEX_BACK.getPixel($i, $j)
        }
    }
    
    for($i = $iPosX; $i -lt ($iPosX + $iSizeX); $i++)
    {
        for($j = $iPosy; $j -lt ($iPosY + $iSizeY); $j++)
        {
            $posx = $i - [math]::floor($i / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
            $posy = $j - [math]::floor($j / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
            
            $global:arrWindows[$strWindow].wnd.SetPixel($i, $j, ($arrBack[$posx,$posy]));
        }
    }
}

function buildButton($strBtnColor, $iSizeX, $iSizeY, $iPosX, $iPosY, $isPressed)
{
    # well, first of all just fill the button area

    $tmp_grd = [System.Drawing.Graphics]::FromImage($global:arrWindows[$global:strCurrentWindow].wnd);
    $tmp_grd.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $tmp_grd.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    
    for($i = 0; $i -lt ([math]::floor($iSizeX / $global:arrSettings["TILESIZE"]) + 1); $i++)
    {
        for($j = 0; $j -lt ([math]::floor($iSizeY / $global:arrSettings["TILESIZE"]) + 1); $j++)
        {
            if($i -eq ([math]::floor($iSizeX / $global:arrSettings["TILESIZE"])))
            {
                $off_size_x = 16 - ($iSizeX - ([math]::floor($iSizeX / $global:arrSettings["TILESIZE"])) * 16);
            }
            else
            {
                $off_size_x = 0;
            }
            
            if($j -eq ([math]::floor($iSizeY / $global:arrSettings["TILESIZE"])))
            {
                $off_size_y = 16 - ($iSizeY - ([math]::floor($iSizeY / $global:arrSettings["TILESIZE"])) * 16);
            }
            else
            {
                $off_size_y = 0;
            }
            
            $rect_src = New-Object System.Drawing.Rectangle(0, 0, (16 - $off_size_x), (16 - $off_size_y))
            $rect_dst = New-Object System.Drawing.Rectangle((($i * 16) + $iPosX), (($j * 16) + $iPosY), (16 - $off_size_x), (16 - $off_size_y))
            
            switch($strBtnColor)
            {
                "Red"
                {
                    $tmp_grd.DrawImage($tex_MENU_RED_DARK, $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
                "Green"
                {
                    $tmp_grd.DrawImage($tex_MENU_GREEN_DARK, $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
                default
                {
                    $tmp_grd.DrawImage($tex_MENU_GRAY_DARK, $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
            }
        }
    }
    
    # and special effects...
    # $i = y
    for($i = 0; $i -lt 2; $i++)
    {
        for($j = $i; $j -lt ($iSizeX); $j++)
        {   
            if(!$isPressed)
            {
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY + $i - 2), "Black");
            }
            else
            {
                $posx = $i - [math]::floor($i / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                $posy = $j - [math]::floor($j / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                
                switch($strBtnColor)
                {
                    "Red"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY + $i - 2), $tex_MENU_RED_LIGHT.GetPixel($posx, $posy));
                    }
                    "Green"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY + $i - 2), $tex_MENU_GREEN_LIGHT.GetPixel($posx, $posy));
                    }
                    default
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY + $i - 2), $tex_MENU_GRAY_LIGHT.GetPixel($posx, $posy));
                    }
                }
            }
        }
        
    }
    
    # $i = x
    for($i = ($iSizeX - 2); $i -lt $iSizeX; $i++)
    {
        for($j = (0 + $iSizeX - $i - 1); $j -lt $iSizeY; $j++)
        {   
            if(!$isPressed)
            {
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), "Black");
            }
            else
            {
                $posx = $i - [math]::floor($i / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                $posy = $j - [math]::floor($j / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                
                switch($strBtnColor)
                {
                    "Red"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_RED_LIGHT.GetPixel($posx, $posy));
                    }
                    "Green"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GREEN_LIGHT.GetPixel($posx, $posy));
                    }
                    default
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GRAY_LIGHT.GetPixel($posx, $posy));
                    }
                }
            }
        }
    }
    
    # and special effects...
    # $i = y
    for($i = 0; $i -lt 2; $i++)
    {
        for($j = $i; $j -lt ($iSizeX - $i); $j++)
        {   
            if($isPressed)
            {
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $i), "Black");
            }
            else
            {
                $posx = $i - [math]::floor($i / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                $posy = $j - [math]::floor($j / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                
                switch($strBtnColor)
                {
                    "Red"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $i), $tex_MENU_RED_LIGHT.GetPixel($posx, $posy));
                    }
                    "Green"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $i), $tex_MENU_GREEN_LIGHT.GetPixel($posx, $posy));
                    }
                    default
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $i), $tex_MENU_GRAY_LIGHT.GetPixel($posx, $posy));
                    }
                }
            }
        }
    }
    
    # $i = x
    for($i = 0; $i -lt 2; $i++)
    {
        for($j = 0; $j -lt ($iSizeY - $i); $j++)
        {   
            if($isPressed)
            {
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), "Black");
            }
            else
            {
                $posx = $i - [math]::floor($i / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                $posy = $j - [math]::floor($j / $global:arrSettings["TILESIZE"]) * $global:arrSettings["TILESIZE"];
                
                switch($strBtnColor)
                {
                    "Red"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_RED_LIGHT.GetPixel($posx, $posy));
                    }
                    "Green"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GREEN_LIGHT.GetPixel($posx, $posy));
                    }
                    default
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GRAY_LIGHT.GetPixel($posx, $posy));
                    }
                }
            }
            
        }
    }
}

function addButtonToWindow($strWindow, $strName, $strBtnColor, $iSizeX, $iSizeY, $iPosX, $iPosY, $strText, $iTextX, $iTextY, $strColor, $doOutline)
{
    Write-Host "$strName $strBtnColor"

    if(!$global:arrWindows[$strWindow].btn)
    {
        Write-Host "No buttons"
        $global:arrWindows[$strWindow].btn = @{}
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    elseif(!$global:arrWindows[$strWindow].btn[$strName])
    {
        Write-Host "Buttons but new one"
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    else
    {
        Write-Host "Buttons"
        return;
    }
    
    $global:arrWindows[$strWindow].btn[$strName].size_x = $iSizeX;
    $global:arrWindows[$strWindow].btn[$strName].size_y = $iSizeY;
    $global:arrWindows[$strWindow].btn[$strName].loc_x  = $iPosX;
    $global:arrWindows[$strWindow].btn[$strName].loc_y  = $iPosY;
    
    # buttons bekommen keine eigene grafik, sie werden lediglich geführt für die klicks
    if($iSizeX -lt 0 -or $iSizeY -lt 0)
    {
        Write-Host "ERROR: addButtonToWindow Size less than 0"
        return;
    }
    
    if(($iSizeX + $iPosX) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Width) -or ($iSizeY + $iPosY) -ge ($global:arrWindows[$global:strCurrentWindow].wnd.Height))
    {
        Write-Host "ERROR: addButtonToWindow button larger than window"
        return;
    }
    
    if(($strText.Length * 7) -ge $iSizeX)
    {
        $l = ($strText.Length * 7)
        Write-Host "ERROR: Button Text too long ($l > $iSizeX)"
    }
 
    if($strBtnColor -eq "Transparent")
    {
        return;
    }
    
    buildButton $strBtnColor $iSizeX $iSizeY $iPosX $iPosY $False

    if([int]$iTextX -lt 0)
    {
        $iTextX = [int](($iSizeX - ($strText.Length * 7)) / 2)
    }

    if([int]$iTextY -lt 0)
    {
        $iTextY = [int](($iSizeY - 7) / 2)
    }

    addText $global:arrWindows[$global:strCurrentWindow].wnd $strText ($iPosX + $iTextX) ($iPosY + $iTextY) $strColor $doOutline
    $objForm.Refresh();
}

function addText($objTarget, $strText, $iPosX, $iPosY, $strColor, $doOutline)
{
    if ($strText -eq "")
    {
        return;
    }

    $strText = $strText.ToUpper();
    #Write-Host "Adding text"
    $sizeX      = 0;
    for($i = 0; $i -lt ($strText.Length); $i++)
    {
        $tempChar = $strText.Substring($i, 1);
        if($arrFont[$tempChar])
        {
            $sizeX = $sizeX + $arrFont[$tempChar].Width;
        }
        else
        {
            $sizeX = $sizeX + $arrFont["?"].Width;
        }
    }
    $sizeY      = 9;
    $tmp_img    = New-Object System.Drawing.Bitmap($sizeX, $sizeY);
    
    #Write-Host "$strText $iPosX $iPosY"
    
    $offset_x = 0;
    
    for($i = 0; $i -lt ($strText.Length); $i++)
    {
        $tempChar = $strText.Substring($i, 1);
        
        if($arrFont[$tempChar])
        {
            # valid char
            for($j = 0; $j -lt ($arrFont[$tempChar].Width); $j++)
            {
                for($k = 0; $k -lt $sizeY; $k++)
                {
                    # mal sehen ob es hier noch das font gibt
                    if($j -lt $arrFont[$tempChar].Width -and $k -lt $arrFont[$tempChar].Height)
                    {
                        $tmp_img.SetPixel(($j + $offset_x), $k, $arrFont[$tempChar].GetPixel($j, $k))
                    }
                    else
                    {
                        $tmp_img.SetPixel(($j + $offset_x), $k, $transparent);
                    }
                }
            }
            
            $offset_x = $offset_x + $arrFont[$tempChar].Width;
        }
        else
        {
            # invalid char
            $tempChar = "?";
            for($j = 0; $j -lt ($arrFont[$tempChar].Width); $j++)
            {
                for($k = 0; $k -lt $sizeY; $k++)
                {
                    # mal sehen ob es hier noch das font gibt
                    if($j -lt $arrFont[$tempChar].Width -and $k -lt $arrFont[$tempChar].Height)
                    {
                        $tmp_img.SetPixel(($j + $offset_x), $k, $arrFont[$tempChar].GetPixel($j, $k))
                    }
                    else
                    {
                        $tmp_img.SetPixel(($j + $offset_x), $k, $transparent);
                    }
                }
            }
            
            $offset_x = $offset_x + $arrFont[$tempChar].Width;
        }
    }
    
    for($i = 0; $i -lt $sizeX; $i++)
    {
        for($j = 0; $j -lt $sizeY; $j++)
        {
            if($tmp_img.GetPixel($i, $j) -ne $transparent -and (($tmp_img.GetPixel($i, $j) -ne $black) -or ($doOutline -and $tmp_img.GetPixel($i, $j) -eq $black)))
            {
                switch($strColor)
                {
                    "Gold"
                    {
                        $pixel = $tmp_img.GetPixel($i, $j);
                        
                        if($pixel -eq $color_blue)
                        {
                            $objTarget.SetPixel(($i + $iPosX), ($j + $iPosY), $color_gold)
                        }
                        elseif($pixel -eq $color_blue_1)
                        {
                            $objTarget.SetPixel(($i + $iPosX), ($j + $iPosY), $color_gold_1)
                        }
                        elseif($pixel -eq $color_blue_2)
                        {
                            $objTarget.SetPixel(($i + $iPosX), ($j + $iPosY), $color_gold_1)
                        }
                        else
                        {
                            $objTarget.SetPixel(($i + $iPosX), ($j + $iPosY), $tmp_img.GetPixel($i, $j))
                        }
                    }
                    default
                    {
                        $objTarget.SetPixel(($i + $iPosX), ($j + $iPosY), $tmp_img.GetPixel($i, $j))
                    }
                }
            }
        }
    }
}

function buildWindow($iSizeX, $iSizeY, $iPosX, $iPosY, $strWindow)
{
    if($iSizeX % 2 -ne 0 -or $iSizeY % 2 -ne 0)
    {
        Write-Host "ERROR: buildWindow"
        return;
    }
    
    if($iPosX -lt 0 -or $iPosY -lt 0)
    {
        Write-Host "ERROR: buildWindow"
        return;
    }
    
    if($iSizeX -lt 0 -or $iSizeX -gt $DrawingSizeX)
    {
        Write-Host "ERROR: buildWindow"
        return;
    }
    
    if($iSizeY -lt 0 -or $iSizeY -gt $DrawingSizeY)
    {
        Write-Host "ERROR: buildWindow"
        return;
    }
    
    $global:windowOpen = $True;
    $global:strCurrentWindow = $strWindow;
    
    if(!$global:windowOpen)
    {
        Write-Host "Window is hidden now"
        $objForm.Refresh();
        return;
    }
    
    # check if graphic already exists
    # this has quite a big impact on peformance!
    if($global:arrWindows[$strWindow])
    {   
        $objForm.Refresh();
        return;
    }
    
    # create a rect
    $tmp_rec    = New-Object System.Drawing.Rectangle(0, 0, $iSizeX, $iSizeY)
    # cloning is faster than creating a new bitmap
    $tmp_wnd    = $global:bitmap.Clone($tmp_rec, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    
    # draw back
    $offset_x_l     = 1 + 6;
    $offset_x_r     = $iSizeX - 1 - 6;
    
    $offset_y_l     = 1 + 6;
    $offset_y_r     = $iSizeY - 1 - 6;
    
    $max_size_x     = $iSizeX - (2 * $offset_x_l)
    $max_size_y     = $iSizeY - (2 * $offset_y_l)
    
    $arrBack = New-Object 'object[,]' $global:arrSettings["TILESIZE"],$global:arrSettings["TILESIZE"]

    $tmp_grd = [System.Drawing.Graphics]::FromImage($tmp_wnd);
    $rect_src = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
    for($i = 0; $i -lt ([int]($max_size_x / $global:arrSettings["TILESIZE"]) + 1); $i++)
    {
        for($j = 0; $j -lt ([int]($max_size_y / $global:arrSettings["TILESIZE"]) + 1); $j++)
        {
            
            $rect_dst = New-Object System.Drawing.Rectangle(($i * 16), ($j * 16), 16, 16)

            $tmp_grd.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
            $tmp_grd.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        
            $tmp_grd.DrawImage($tex_MENU_TEX_BACK, $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
        }
    }
    
    # lets first create a outline
    for($i = 0; $i -lt $iSizeX; $i++)
    {
        $tmp_wnd.SetPixel($i, 0, "Black")
        $tmp_wnd.SetPixel($i, ($iSizeY - 1), "Black")
    }
    
    
    for($i = 0; $i -lt $iSizeY; $i++)
    {
        $tmp_wnd.SetPixel(0, $i, "Black")
        $tmp_wnd.SetPixel(($iSizeX - 1), $i, "Black")
    }
    
    # draw sides (vert)
    $offset_x       = 1 + 8;
    $offsetmax_x    = $iSizeX - 1 - 8;
    $offset_y       = $iSizey - 1 - 6;
    #$offsetmax_y    = 1 + 6;
    for($i = $offset_x; $i -lt $offsetmax_x; $i++)
    {
        for($j = 0; $j -lt 6; $j++)
        {
            $posx = $i - [math]::floor($i / 14) * 14;
            # top
            $tmp_wnd.SetPixel($i, ($j + 1), $tex_MENU_SIDE_VERT.GetPixel($posx, (5 - $j)));
            # bottom
            $tmp_wnd.SetPixel($i, ($j + $offset_y), $tex_MENU_SIDE_VERT.GetPixel($posx, $j));
        }
    }
    
    # draw sides (hor)
    $offset_x       = 1;
    $offset_y       = 1 + 6;
    $offsetmax_y    = $iSizeY - 1 - 6;
    #$offsetmax_y    = 1 + 6;
    for($i = 0; $i -lt 6; $i++)
    {
        for($j = $offset_y; $j -lt $offsetmax_y; $j++)
        {
            $posy = $j - [math]::floor($j / 14) * 14;
            # left
            $tmp_wnd.SetPixel(($i + $offset_x), $j, $tex_MENU_SIDE_HOR.GetPixel($i, $posy));
            # right
            $tmp_wnd.SetPixel(($iSizeX - $offset_x - $i - 1), $j, $tex_MENU_SIDE_HOR.GetPixel($i, $posy));
        }
    }
    
    # draw corners
    $offset_x = 1;
    $offset_y = 1;
    for($i = 0; $i -lt 8; $i++)
    {
        for($j = 0; $j -lt 8; $j++)
        {
            $tmp_wnd.SetPixel(($offset_x + $i), ($offset_y + $j), $tex_MENU_CORNER.GetPixel($i, $j));
        }
    }
    
    $offset_x = 1;
    $offset_y = $iSizeY - 1 - 8;
    for($i = 0; $i -lt 8; $i++)
    {
        for($j = 0; $j -lt 8; $j++)
        {
            $tmp_wnd.SetPixel(($offset_x + $i), ($offset_y + $j), $tex_MENU_CORNER.GetPixel($i, $j));
        }
    }
    
    $offset_x = $iSizeX - 1 - 8;
    $offset_y = 1;
    for($i = 0; $i -lt 8; $i++)
    {
        for($j = 0; $j -lt 8; $j++)
        {
            $tmp_wnd.SetPixel(($offset_x + $i), ($offset_y + $j), $tex_MENU_CORNER.GetPixel($i, $j));
        }
    }
    
    $offset_x = $iSizeX - 1 - 8;
    $offset_y = $iSizeY - 1 - 8;
    for($i = 0; $i -lt 8; $i++)
    {
        for($j = 0; $j -lt 8; $j++)
        {
            $tmp_wnd.SetPixel(($offset_x + $i), ($offset_y + $j), $tex_MENU_CORNER.GetPixel($i, $j));
        }
    }
    
    Write-Host "Adding arrays for window $strWindow"
    
    $global:arrWindows[$strWindow] = @{}
    #$global:arrWindows[$strWindow].btn = @{}
    $global:arrWindows[$strWindow].graphics = $tmp_grd;
    $global:arrWindows[$strWindow].wnd = $tmp_wnd;
    $global:arrWindows[$strWindow].loc_x = $iPosX;
    $global:arrWindows[$strWindow].loc_y = $iPosY;
    $objForm.Refresh();
}

function scaleGame($scaleUp)
{
    if($scaleUp)
    {
        if([int]$global:arrSettings["SIZE"] -lt 3)
        {
            $pictureBox.Scale(2.0);
            [int]$global:arrSettings["SIZE"]+=1;
            $size = [int]$global:arrSettings["SIZE"]
            $objForm.minimumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeY + 36)) 
            $objForm.maximumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeY + 36)) 
        }
    }
    else
    {
        if([int]$global:arrSettings["SIZE"] -gt 1)
        {
            $pictureBox.Scale(0.5);
            [int]$global:arrSettings["SIZE"]-=1;
            $objForm.minimumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeY + 36)) 
            $objForm.maximumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $DrawingSizeY + 36)) 
        }
    }
}

function onRedraw($Sender, $EventArgs)
{
    $EventArgs.Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $EventArgs.Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $rect = New-Object System.Drawing.Rectangle(0, 0, $pictureBox.Size.Width, $pictureBox.Size.Height)
    
    if($global:strGameState -eq "EDIT_MAP" -or $global:strGameState -eq "EDIT_MAP_ESCAPE" -or $global:strGameState -eq "INPUT_MAPNAME" -or $global:strGameState -eq "INPUT_MAPAUTHOR" -or $global:strGameState -eq "SINGLEPLAYER_INGAME")
    {
        # display empty back
        #$EventArgs.Graphics.DrawImage($global:arrImages["SCREEN_BACK_MAP"], $rect, 0, 0, $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
        #
        #$rect_map = New-Object System.Drawing.Rectangle(32, 32, ($pictureBox.Size.Width - 32), ($pictureBox.Size.Height - 32))
        #$EventArgs.Graphics.DrawImage($global:objWorld, $rect_map, 0, 0, $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
        
        #$global:arrCreateMapOptions["EDITOR_CHUNK_X"]
        $offset_x = $global:arrCreateMapOptions["EDITOR_CHUNK_X"] * $global:arrSettings["TILESIZE"];
        $offset_y = $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] * $global:arrSettings["TILESIZE"];
        
        $offset_curx = ($global:arrCreateMapOptions["SELECTED_X"] - $global:arrCreateMapOptions["EDITOR_CHUNK_X"]) * (([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrSettings["TILESIZE"]));
        $offset_cury = ($global:arrCreateMapOptions["SELECTED_Y"] - $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]) * (([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrSettings["TILESIZE"]));
        
        $EventArgs.Graphics.DrawImage($global:objWorld, $rect, ($offset_x), ($offset_y), $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
        
        $rect_cur = New-Object System.Drawing.Rectangle($offset_curx, $offset_cury, (([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrSettings["TILESIZE"])), (([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrSettings["TILESIZE"])))
        
        if($global:arrCreateMapOptions["SHOW_PREVIEW"])
        {
            if($global:arrCreateMapOptions["EDIT_MODE"] -eq 1)
            {
                $EventArgs.Graphics.DrawImage(($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]), $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
            }
            elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 2)
            {
                $EventArgs.Graphics.DrawImage(($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]), $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
            }
            elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 3)
            {
                $EventArgs.Graphics.DrawImage(($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]), $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
            }
        }
        else
        {
            $EventArgs.Graphics.DrawImage($global:arrInterface["CUR_SELECTEDTILE"], $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
        }
    }
    else
    {
        $EventArgs.Graphics.DrawImage($global:bitmap, $rect, 0, 0, $global:bitmap.Width, $global:bitmap.Height, [System.Drawing.GraphicsUnit]::Pixel)
    }
    
    #$EventArgs.Graphics.DrawImage($bitmap, $rect, 0, 0, $bitmap.Width, $bitmap.Height, [System.Drawing.GraphicsUnit]::Pixel)
    if($global:windowOpen)
    {
        # Position des rects anpassen, fenster soll sich gleichermaßen verschieben
        $rect_wnd = New-Object System.Drawing.Rectangle((([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].loc_x)), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].loc_y), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].wnd.Size.Width), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 )) * $global:arrWindows[$global:strCurrentWindow].wnd.Size.Height))
        #$rect_wnd = System.Drawing.Rectangle(0, 0, $global:arrWindows[$global:strCurrentWindow].wnd.Width, $global:arrWindows[$global:strCurrentWindow].wnd.Height)
        #Write-Host "$rect_wnd"
        # und das fenster korrekt skaliert darstellen
        # links und oben fehlen iwie 1 pixel... oder der wird nicht skaliert? es ist komisch
        
        #$tmpimg = [System.Drawing.Image]::FromHbitmap($global:arrWindows[$global:strCurrentWindow].graphics.Data)
        
        #[System.Drawing.Image]$tmpimg = [System.Drawing]::ConvertFrom($global:arrWindows[$global:strCurrentWindow].graphics.Data)
        
        $EventArgs.Graphics.DrawImage($global:arrWindows[$global:strCurrentWindow].wnd, $rect_wnd, 0, 0, $global:arrWindows[$global:strCurrentWindow].wnd.Width, $global:arrWindows[$global:strCurrentWindow].wnd.Height, [System.Drawing.GraphicsUnit]::Pixel)
        #$EventArgs.Graphics.DrawImage($tmpimg, $rect_wnd, 0, 0, $global:arrWindows[$global:strCurrentWindow].wnd.Width, $global:arrWindows[$global:strCurrentWindow].wnd.Height, [System.Drawing.GraphicsUnit]::Pixel)
        #$global:arrWindows[$strWindow].graphics

    }
    
    if($global:strGameState -eq "EDIT_MAP")
    {
    }

}   

function showSplash()
{
    $global:bitmap = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));
    $pictureBox.Refresh();
}

function addSpriteAt($bmp, $x, $y)
{
    Write-Host "adding sprite"
    
    $img_x = $bmp.Size.Width;
    $img_y = $bmp.Size.Height;

    for($i = 0; $i -lt $img_x; $i++)
    {
        for($j = 0; $j -lt $img_y; $j++)
        {
            $color = $bmp.GetPixel($i, $j)
            if($color -ne $transparent)
            {
                $global:bitmap.SetPixel(($x + $i), ($y + $j), $color)
            }
        }
    }
    
    $pictureBox.Refresh();
}

function initGame()
{
    Write-Host "Init game"
    loadConfig
    applyConfig
    $global:bitmap = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));
    $global:objMusic001.Play();
}

function loadConfig
{
    Write-Host "Loading Config..."

    $strFileName = ".\game.cfg"

    if (Test-Path $strFileName)
    {
        $arrConfigTMP = Get-Content $strFileName
    }
    else
    {
        return;
    }
    
    for($i = 0; $i -lt $arrConfigTMP.Length; $i++)
    {
        $arrConfigLine = $arrConfigTMP[$i].split("=")
        
        $valKey = $arrConfigLine[0]
        $valValue = $arrConfigLine[1]
        
        Write-Host "Key: $valKey Value: $valValue"
        
        if($valValue -eq "True")
        {
            $global:arrSettings[$valKey] = $True;
        }
        elseif($valValue -eq "False")
        {
            $global:arrSettings[$valKey] = $False;
        }
        else
        {
            $global:arrSettings[$valKey] = $valValue;
        }
    }
}

function saveConfig
{
    $strFileName = ".\game.cfg"
    
    Write-Host "Saving Config"
    
    If (Test-Path $strFileName){
        Remove-Item $strFileName
    }
    
    $keys    = $global:arrSettings.Keys
    
    foreach($key in $keys)
    {
        $strOutput = "";
        
        if($global:arrSettings[$key].GetType() -eq "bool")
        {
            if($global:arrSettings[$key])
            {
                $strOutput = $key + "=True"
            }
            else
            {
                $strOutput = $key + "=False"
            }
        }
        else
        {
            $strOutput = $key + "=" + $global:arrSettings[$key]
        }
        
        $strOutput | Out-File -FilePath $strFileName -Append
    }
}

function applyConfig
{
    $objForm.Topmost = $global:arrSettings["TOPMOST"];
    #[int]$global:arrSettings["SIZE"] = 1;
    
    if([int]$global:arrSettings["STARTUPSIZE"] -eq 2)
    {
        $pictureBox.Scale(2.0);
    }
    elseif([int]$global:arrSettings["STARTUPSIZE"] -eq 3)
    {
        $pictureBox.Scale(2.0);
        $pictureBox.Scale(2.0);
    }
    
    $objForm.minimumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["STARTUPSIZE"] -1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["STARTUPSIZE"] -1 )) * $DrawingSizeY + 36)) 
    $objForm.maximumSize = New-Object System.Drawing.Size(([math]::pow(2, ([int]$global:arrSettings["STARTUPSIZE"] -1 )) * $DrawingSizeX + 16), ([math]::pow(2, ([int]$global:arrSettings["STARTUPSIZE"] -1 )) * $DrawingSizeY + 36)) 
    
    $global:arrSettings["SIZE"] = [int]$global:arrSettings["STARTUPSIZE"];
    
    $global:objMusic001.Volume = $global:arrSettings["VOLUMEMUSIC"];
    #$global:arrSettings["VOLUMEMUSIC"] = 0.2;
    #$global:arrSettings["VOLUMEEFFECTS"] = 0.2;
}

Function openMapFile()
{   
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = ".\MAP"
    #"All files (*.*)| *.*"
    $OpenFileDialog.filter = "Maps (*.SMF, *.MMF)|*.smf;*.mmf|All files (*.*)| *.*"
    $OpenFileDialog.ShowHelp = $True
    $OpenFileDialog.Title = "Open map..."
    $OpenFileDialog.AddExtension = $True
    
    $Show = $OpenFileDialog.ShowDialog()
    If ($Show -eq "OK")
    {
        $global:strMapFile = $OpenFileDialog.FileName
    }
    Else 
    {
        $global:strMapFile = ""
    }
}

initGame
$objForm.Refresh();

###Window Settings###
#$objForm.Topmost = $True
[void] $objForm.ShowDialog()