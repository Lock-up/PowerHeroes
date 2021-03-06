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

$global:VersionInfo = @{}
# major
$global:VersionInfo[0] = "0"
# minor
$global:VersionInfo[1] = "3"
# patch
$global:VersionInfo[2] = "0"
# build
$global:VersionInfo[3] = "20190307"

$global:arrWindows = @{}
$global:windowOpen = $False;
$global:strCurrentWindow = "";

$global:arrSettings = @{}
$global:arrSettings["TOPMOST"] = $False;
$global:arrSettings["SIZE"] = 1;
$global:arrSettings["STARTUPSIZE"] = 1;
$global:arrSettings["VOLUMEMUSIC"] = 0.1;
$global:arrSettings["VOLUMEEFFECTS"] = 0.1;
$global:arrSettings["TILESIZE"] = 16;
$global:arrSettings["BUILDINGS_MIN"] = 1
$global:arrSettings["BUILDINGS_CIVILS"] = 8;
$global:arrSettings["BUILDINGS_MILITARY"] = 4;
$global:arrSettings["BUILDINGS_SELECTED"] = -1;
$global:arrSettings["PLAYER_FACE"] = 0;

$global:arrSettingsInternal = @{}
$global:arrSettingsInternal["SONG_CURRENT"] = 0;
$global:arrSettingsInternal["SONGS"] = 0;
$global:arrSettingsInternal["HOOVER_X"] = -1;
$global:arrSettingsInternal["HOOVER_Y"] = -1;
$global:arrSettingsInternal["HOOVER_CANBUILD"] = $False;
$global:arrSettingsInternal["PLAYER_FACE_MAX"] = 23;
$global:arrSettingsInternal["PLAYER_MAX"] = 4;
$global:arrSettingsInternal["PLAYERTYPE_MAX"] = 5;

$global:arrMap = @{}
function initMapArray()
{
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
    # L stands for layer
    $global:arrMap["WORLD_L1"] = @{}
    $global:arrMap["WORLD_L2"] = @{}
    $global:arrMap["WORLD_L3"] = @{}
    $global:arrMap["WORLD_LBLD"] = @{} # Buildings are referenced by ID, ID = -1 => no building, everything else = building in a building array. At first the building array should include player start positions.
    $global:arrMap["WORLD_LUNIT"] = @{} # same as buildings
}

initMapArray



#region PLAYER_INFO

$global:arrPlayerInfo = @{}
$global:arrPlayerInfo.currentPlayer = -1
$global:arrPlayerInfo.currentSelection = -1
# playername (0)
# gold_income (1)
# wood_income (2)
# food_income (3)
# production (4)
# playertype (index) (5)
# gold_amount (6)
# wood_amount (7)
# food_amount (8)

#endregion

#region PLAYERTYPES
$global:arrPlayertypeIndexString = @{}
$global:arrPlayertypeIndexString[0] = "Closed"
$global:arrPlayertypeIndexString[1] = "Dummy"
$global:arrPlayertypeIndexString[2] = "AI"
$global:arrPlayertypeIndexString[3] = "Local"
$global:arrPlayertypeIndexString[4] = "Network"
#endregion

#region COLORS
$global:arrColors = @{}
$global:arrColors["CLR_BLACK"] = [System.Drawing.Color]::FromArgb(0, 0, 0);
$global:arrColors["CLR_MAGENTA"] = [System.Drawing.Color]::FromArgb(255, 0, 143)
$global:arrColors["CLR_TRANSPARENT"] = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
$global:arrColors["CLR_GOLD_1"] = [System.Drawing.Color]::FromArgb(255, 255, 0)
$global:arrColors["CLR_GOLD_2"] = [System.Drawing.Color]::FromArgb(255, 219, 23)
$global:arrColors["CLR_GOLD_3"] = [System.Drawing.Color]::FromArgb(255, 191, 51)
$global:arrColors["CLR_BLUE_1"] = [System.Drawing.Color]::FromArgb(0, 211, 247)
$global:arrColors["CLR_BLUE_2"] = [System.Drawing.Color]::FromArgb(0, 123, 219)
$global:arrColors["CLR_BLUE_3"] = [System.Drawing.Color]::FromArgb(0, 55, 191)
$global:arrColors["CLR_RED"] = [System.Drawing.Color]::FromArgb(111, 27, 15)
$global:arrColors["CLR_GRAY"] = [System.Drawing.Color]::FromArgb(83, 87, 95)
$global:arrColors["CLR_GREEN"] = [System.Drawing.Color]::FromArgb(32, 170, 73)

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

$global:arrColors["CLR_BAD"] = [System.Drawing.Color]::FromArgb(237, 28, 36)
$global:arrColors["CLR_OKAY"] = [System.Drawing.Color]::FromArgb(235, 160, 5)
$global:arrColors["CLR_GOOD"] = [System.Drawing.Color]::FromArgb(0, 145, 0)
$global:arrColors["CLR_BUILDING"] = [System.Drawing.Color]::FromArgb(63, 72, 204)

$global:arrColors["CLR_BUILDING"] = [System.Drawing.Color]::FromArgb(63, 72, 204)

#endregion

$global:strGameState = "WAIT_INIT_CLICK"
$global:strMapFile = "";

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



#region FUNCTIONS_LOAD_GRAPHICS
function loadGraphicsByName($objTargetArray, $strPath, $strFilter, $makeTransparent)
{
    foreach($file in (Get-ChildItem -Path $strPath $strFilter))
    {
        $arrSplit = $file.Name.split(".")

        $objTargetArray[$arrSplit[0]] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPath + $file.Name))));

        if($makeTransparent)
        {
            $objTargetArray[$arrSplit[0]].MakeTransparent($global:arrColors["CLR_MAGENTA"]);
        }
    }
}

function nameToId($strPrefix, $iID)
{
    if(([int]($iID)) -gt 9)
    {
        return ($strPrefix + ([string]($iID)))
    }
    else
    {
        return ($strPrefix + '0' + ([string]($iID)))
    }
}
#endregion

#region \GFX\ICON
$strPathIconGFX = ".\GFX\ICON\"
$global:arrIcons = @{}

loadGraphicsByName $global:arrIcons $strPathIconGFX "ICON_*" $True

#endregion

#region \GFX\WORLD\
# All textures shown in the editor at the first tab
$arrBaseTextureIDToKey = "GROUND_GREEN_01", "GROUND_GREEN_02", "GROUND_GREEN_03", "GROUND_GREEN_04", "GROUND_WATER_01", "GROUND_EMPTY_01"

# All textures shown in the editor at the 2nd tab
# 0 - 11 invalid
# 12 - 22 valid
# 23 - x invalid
$arrOverlayTextureIDToKey = "LAYER_EDGE_01", "LAYER_EDGE_02", "LAYER_EDGE_03", "LAYER_EDGE_04", "LAYER_EDGE_05", "LAYER_EDGE_06", "LAYER_EDGE_07", "LAYER_EDGE_08", "LAYER_EDGE_09", "LAYER_EDGE_10", "LAYER_EDGE_11", "LAYER_EDGE_12", `
"LAYER_PATH_01", "LAYER_PATH_02", "LAYER_PATH_03", "LAYER_PATH_04", "LAYER_PATH_05", "LAYER_PATH_06", "LAYER_PATH_07", "LAYER_PATH_08", "LAYER_PATH_09", "LAYER_PATH_10", "LAYER_PATH_11", `
"LAYER_RIVER_01", "LAYER_RIVER_02", "LAYER_RIVER_03", "LAYER_RIVER_04", "LAYER_RIVER_05", "LAYER_RIVER_06", "LAYER_RIVER_07", "LAYER_RIVER_08", "LAYER_RIVER_09", "LAYER_RIVER_10", "LAYER_RIVER_11", "LAYER_RIVER_12", "LAYER_RIVER_13", "LAYER_RIVER_14", "LAYER_RIVER_15", "LAYER_RIVER_16", "LAYER_RIVER_17", "LAYER_RIVER_18", "LAYER_RIVER_19"

# All textures shown in the editor at the 3rd tab
$arrObjectTextureIDToKey = "OBJ_BUSH_01", "OBJ_BUSH_02", "OBJ_BUSH_03", "OBJ_CHEST_01", "OBJ_MOUNTAIN_01", "OBJ_MOUNTAIN_02", "OBJ_MOUNTAIN_03", "OBJ_MOUNTAIN_04", "OBJ_STONES_01", "OBJ_STONES_02", "OBJ_STONES_03", "OBJ_STONES_04", "OBJ_STONES_05", "OBJ_TREE_01", "OBJ_TREE_02", "OBJ_TREE_03", "OBJ_TREE_04",`
 "OBJ_WHIRL_01", "OBJ_GOLD_01", "OBJ_HARBOR_01", "OBJ_POND_01", "OBJ_RUINS_01", "OBJ_RUINS_02", "OBJ_SHIP_01", "OBJ_SIGNPOST_01"

# All player icons
$arrPlayerIconsIDToKey = "PLAYER_00", "PLAYER_01", "PLAYER_02", "PLAYER_03", "PLAYER_04"

$strPathTextureGFX = ".\GFX\WORLD\"
$global:arrTextures = @{}

loadGraphicsByName $global:arrTextures $strPathIconGFX "FACE_*" $False

loadGraphicsByName $global:arrTextures $strPathTextureGFX "GROUND_*" $False

loadGraphicsByName $global:arrTextures $strPathTextureGFX "LAYER_EDGE_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "LAYER_PATH_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "LAYER_RIVER_*" $True

loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_BUSH_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_MOUNTAIN_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_STONES_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_TREE_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_WHIRL_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_CHEST_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_GOLD_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_HARBOR_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_POND_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_RUINS_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_SHIP_*" $True
loadGraphicsByName $global:arrTextures $strPathTextureGFX "OBJ_SIGNPOST_*" $True

loadGraphicsByName $global:arrTextures $strPathTextureGFX "PLAYER_*" $True

#endregion

#region \GFX\INTERFACE\
$strPathInterfaceGFX = ".\GFX\INTERFACE\"
$global:arrInterface = @{}

loadGraphicsByName $global:arrInterface $strPathInterfaceGFX "SELECTION_TILE_*" $True

loadGraphicsByName $global:arrInterface $strPathInterfaceGFX "MENU_*" $True
loadGraphicsByName $global:arrInterface $strPathInterfaceGFX "TEX_*" $True

#endregion

#region FUNCTIONS_LOAD_SOUNDS
function playSFX($strName, $strType)
{
    if ($global:arrSFX[$strName]) 
    {
        $global:arrSFX[$strName].Position = New-TimeSpan -Hour 0 -Minute 0 -Seconds 0;
        if($strType -eq "MUSIC")
        {
            $global:arrSFX[$strName].Volume = $global:arrSettings["VOLUMEMUSIC"];
        }
        else
        {
            $global:arrSFX[$strName].Volume = $global:arrSettings["VOLUMEEFFECTS"];
        }

        $global:arrSFX[$strName].Play();
    }
    else
    {
        Write-Host "Cant play $strName"
    }
}

function playSongs()
{
    $strFileName = nameToId "SNG_" ([int]$global:arrSettingsInternal["SONG_CURRENT"])

    $global:arrSFX[$strFileName].Stop()

    [int]$global:arrSettingsInternal["SONG_CURRENT"] += 1
    
    if([int]$global:arrSettingsInternal["SONG_CURRENT"] -gt [int]$global:arrSettingsInternal["SONGS"])
    {
        [int]$global:arrSettingsInternal["SONG_CURRENT"] = 1
        $strFileName = "SNG_01"
    }
    else
    {
        $strFileName = nameToId "SNG_" ([int]$global:arrSettingsInternal["SONG_CURRENT"])
    }

    playSFX $strFileName "MUSIC"
}

function loadSoundByName($objTargetArray, $strPath, $strFilter)
{
    foreach($file in (Get-ChildItem -Path $strPath $strFilter))
    {
        $arrSplit = $file.Name.split(".")

        $objTargetArray[$arrSplit[0]] = New-Object System.Windows.Media.Mediaplayer
        $objTargetArray[$arrSplit[0]].Open([uri]($file.FullName))
        $objTargetArray[$arrSplit[0]].Volume = $global:arrSettings["VOLUMEEFFECTS"];
    }
}

function loadSongs($strPrefix)
{
    $iID = 1

    $strFileName = $strPrefix + "01"

    while([System.IO.File]::Exists($strPathMusic + $strFileName + ".ogg"))
    {
        $global:arrSettingsInternal["SONGS"] = [int]$iID
        # one song exists, should start with that
        [int]$global:arrSettingsInternal["SONG_CURRENT"] = 1

        $file = Get-Item ($strPathMusic + $strFileName + ".ogg")
        $global:arrSFX[$strFileName] = New-Object System.Windows.Media.Mediaplayer
        $global:arrSFX[$strFileName].Open([uri]($file.FullName))
        $global:arrSFX[$strFileName].Volume = $global:arrSettings["VOLUMEMUSIC"];
        $global:arrSFX[$strFileName].Add_MediaEnded({playSongs})

        $iID += 1

        $strFileName = nameToId $strPrefix $iID
    }
}

#endregion

#region \SND\
$strPathMusic = ".\SND\"
$global:arrSFX = @{}

loadSoundByName $global:arrSFX $strPathMusic "SND_*"
loadSoundByName $global:arrSFX $strPathMusic "SFX_*"

loadSongs "SNG_"
#endregion

#region \GFX\IMG\
$strPathImageGFX = ".\GFX\IMAGE\"
$global:objWorld = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));

$global:arrImages = @{}
$global:arrImages["SCREEN_BACK_MAP"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_MAP.png'  ))));
#endregion

#region \GFX\FONT\
$strPathToFontGFX = ".\GFX\FONT\"
$arrFont = @{}
$fontString = "! # %&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\^_©ÄÖÜß []|"

for($i = 1; $i -le $fontString.Length; $i++)
{
    if($i -eq 2)
    {
        $arrFont[""""] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + $i + '.png'  ))));
    }
    elseif($i -eq 4)
    {
        $arrFont["`$"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + $i + '.png'  ))));
    }
    else
    {
        $arrFont[$fontString.Substring(($i - 1), 1)] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + $i + '.png'  ))));
    }
}

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
#endregion

#region \GFX\BUILDING\
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

$global:arrBuildingIDToKey = "HUM_HQ", "HUM_HOUSE_SMALL", "HUM_HOUSE_MEDIUM", "HUM_HOUSE_LARGE", "HUM_FARM", "HUM_FIELD", "HUM_WELL", "HUM_MINE", "HUM_SAWMILL", "HUM_BARRACKS", "HUM_ARCHERRANGE", "HUM_STABLE", "HUM_TOWER"

$rect_tile    = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
$strPathToBuildingGFX = ".\GFX\BUILDING\"
$global:arrBuilding = @{}

for($i = 0; $i -lt $global:arrBuildingIDToKey.Length; $i++)
{
    $arrBuilding[$global:arrBuildingIDToKey[$i]] = @{}

    # load player 0
    $arrBuilding[$global:arrBuildingIDToKey[$i]][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + ($global:arrBuildingIDToKey[$i] + '_00.png')  ))));
    $arrBuilding[$global:arrBuildingIDToKey[$i]][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + ($global:arrBuildingIDToKey[$i] + '_01.png')  ))));

    for($j = 1; $j-le $global:arrSettingsInternal["PLAYER_MAX"]; $j++)
    {
        $arrBuilding[$global:arrBuildingIDToKey[$i]][($j * 2)] = $arrBuilding[$global:arrBuildingIDToKey[$i]][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        replaceColor $arrBuilding[$global:arrBuildingIDToKey[$i]][($j * 2)] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors[("CLR_PLAYER_" + $j + "0")]
        replaceColor $arrBuilding[$global:arrBuildingIDToKey[$i]][($j * 2)] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors[("CLR_PLAYER_" + $j + "1")]
        
        $arrBuilding[$global:arrBuildingIDToKey[$i]][(($j * 2) + 1)] = $arrBuilding[$global:arrBuildingIDToKey[$i]][1].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        replaceColor $arrBuilding[$global:arrBuildingIDToKey[$i]][(($j * 2) + 1)] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors[("CLR_PLAYER_" + $j + "0")]
        replaceColor $arrBuilding[$global:arrBuildingIDToKey[$i]][(($j * 2) + 1)] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors[("CLR_PLAYER_" + $j + "1")]
    }
}

#endregion

#region UNITS
$strPathToUnitGFX = ".\GFX\UNIT\"
$global:arrUnitGFX = @{}

$global:arrUnitIDToKey = "HUM_ARMY_0", "HUM_ARMY_1", "HUM_ARMY_2", "HUM_ARMY_3", "HUM_ARMY_4", "HUM_ARMY_5", "HUM_ARMY_6", "HUM_ARMY_7", "HUM_ARMY_8", "HUM_ARMY_9"

for($i = 0; $i -lt $global:arrUnitIDToKey.Length; $i++)
{
    $arrUnitGFX[$global:arrUnitIDToKey[$i]] = @{}

    # load player 0
    $arrUnitGFX[$global:arrUnitIDToKey[$i]][0] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + ($global:arrBuildingIDToKey[$i] + '_00.png')  ))));
    $arrUnitGFX[$global:arrUnitIDToKey[$i]][1] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToBuildingGFX + ($global:arrBuildingIDToKey[$i] + '_01.png')  ))));

    for($j = 1; $j-le $global:arrSettingsInternal["PLAYER_MAX"]; $j++)
    {
        $arrUnitGFX[$global:arrUnitIDToKey[$i]][($j * 2)] = $arrUnitGFX[$global:arrUnitIDToKey[$i]][0].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        replaceColor $arrUnitGFX[$global:arrUnitIDToKey[$i]][($j * 2)] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors[("CLR_PLAYER_" + $j + "0")]
        replaceColor $arrUnitGFX[$global:arrUnitIDToKey[$i]][($j * 2)] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors[("CLR_PLAYER_" + $j + "1")]
        
        $arrUnitGFX[$global:arrUnitIDToKey[$i]][(($j * 2) + 1)] = $arrUnitGFX[$global:arrUnitIDToKey[$i]][1].Clone($rect_tile, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        replaceColor $arrUnitGFX[$global:arrUnitIDToKey[$i]][(($j * 2) + 1)] $global:arrColors["CLR_PLAYER_DEF00"] $global:arrColors[("CLR_PLAYER_" + $j + "0")]
        replaceColor $arrUnitGFX[$global:arrUnitIDToKey[$i]][(($j * 2) + 1)] $global:arrColors["CLR_PLAYER_DEF01"] $global:arrColors[("CLR_PLAYER_" + $j + "1")]
    }
}
#endregion

#region BUILDING_INFO
$arrBuilding["HUM_HQ"].name = "Headquarter"
$arrBuilding["HUM_HOUSE_SMALL"].name = "House small"
$arrBuilding["HUM_HOUSE_MEDIUM"].name = "House medium"
$arrBuilding["HUM_HOUSE_LARGE"].name = "House large"
$arrBuilding["HUM_FARM"].name = "Farm"
$arrBuilding["HUM_FIELD"].name = "Field"
$arrBuilding["HUM_WELL"].name = "Well"
$arrBuilding["HUM_MINE"].name = "Mine"
$arrBuilding["HUM_SAWMILL"].name = "Sawmill"
$arrBuilding["HUM_BARRACKS"].name = "Barracks"
$arrBuilding["HUM_ARCHERRANGE"].name = "Archer range"
$arrBuilding["HUM_STABLE"].name = "Stable"
$arrBuilding["HUM_TOWER"].name = "Tower"

$arrBuilding["HUM_HQ"].gold_cost = 100
$arrBuilding["HUM_HOUSE_SMALL"].gold_cost = 10
$arrBuilding["HUM_HOUSE_MEDIUM"].gold_cost = 19
$arrBuilding["HUM_HOUSE_LARGE"].gold_cost = 28
$arrBuilding["HUM_FARM"].gold_cost = 15
$arrBuilding["HUM_FIELD"].gold_cost = 5
$arrBuilding["HUM_WELL"].gold_cost = 15
$arrBuilding["HUM_MINE"].gold_cost = 10
$arrBuilding["HUM_SAWMILL"].gold_cost = 10
$arrBuilding["HUM_BARRACKS"].gold_cost = 20
$arrBuilding["HUM_ARCHERRANGE"].gold_cost = 40
$arrBuilding["HUM_STABLE"].gold_cost = 60
$arrBuilding["HUM_TOWER"].gold_cost = 80

$arrBuilding["HUM_HQ"].wood_cost = 100
$arrBuilding["HUM_HOUSE_SMALL"].wood_cost = 20
$arrBuilding["HUM_HOUSE_MEDIUM"].wood_cost = 38
$arrBuilding["HUM_HOUSE_LARGE"].wood_cost = 56
$arrBuilding["HUM_FARM"].wood_cost = 40
$arrBuilding["HUM_FIELD"].wood_cost = 15
$arrBuilding["HUM_WELL"].wood_cost = 25
$arrBuilding["HUM_MINE"].wood_cost = 30
$arrBuilding["HUM_SAWMILL"].wood_cost = 20
$arrBuilding["HUM_BARRACKS"].wood_cost = 40
$arrBuilding["HUM_ARCHERRANGE"].wood_cost = 70
$arrBuilding["HUM_STABLE"].wood_cost = 100
$arrBuilding["HUM_TOWER"].wood_cost = 120

$arrBuilding["HUM_HQ"].hitpoints = 1000
$arrBuilding["HUM_HOUSE_SMALL"].hitpoints = 150
$arrBuilding["HUM_HOUSE_MEDIUM"].hitpoints = 250
$arrBuilding["HUM_HOUSE_LARGE"].hitpoints = 400
$arrBuilding["HUM_FARM"].hitpoints = 100
$arrBuilding["HUM_FIELD"].hitpoints = 50
$arrBuilding["HUM_WELL"].hitpoints = 100
$arrBuilding["HUM_MINE"].hitpoints = 300
$arrBuilding["HUM_SAWMILL"].hitpoints = 250
$arrBuilding["HUM_BARRACKS"].hitpoints = 400
$arrBuilding["HUM_ARCHERRANGE"].hitpoints = 500
$arrBuilding["HUM_STABLE"].hitpoints = 600
$arrBuilding["HUM_TOWER"].hitpoints = 750

$arrBuilding["HUM_HQ"].buildspeed = 0.05
$arrBuilding["HUM_HOUSE_SMALL"].buildspeed = 0.5
$arrBuilding["HUM_HOUSE_MEDIUM"].buildspeed = 0.25
$arrBuilding["HUM_HOUSE_LARGE"].buildspeed = 0.125
$arrBuilding["HUM_FARM"].buildspeed = 0.3
$arrBuilding["HUM_FIELD"].buildspeed = 0.5
$arrBuilding["HUM_WELL"].buildspeed = 0.25
$arrBuilding["HUM_MINE"].buildspeed = 0.2
$arrBuilding["HUM_SAWMILL"].buildspeed = 0.25
$arrBuilding["HUM_BARRACKS"].buildspeed = 0.25
$arrBuilding["HUM_ARCHERRANGE"].buildspeed = 0.2
$arrBuilding["HUM_STABLE"].buildspeed = 0.15
$arrBuilding["HUM_TOWER"].buildspeed = 0.1

# 0 = none
# 1 = gold
# 2 = wood
# 3 = food
# 4 = production
# > 4 = all

# gold_income
# wood_income
# food_income
# production
$arrBuilding["HUM_HQ"].productionType = 5
$arrBuilding["HUM_HOUSE_SMALL"].productionType = 4
$arrBuilding["HUM_HOUSE_MEDIUM"].productionType = 4
$arrBuilding["HUM_HOUSE_LARGE"].productionType = 4
$arrBuilding["HUM_FARM"].productionType = 3
$arrBuilding["HUM_FIELD"].productionType = 3
$arrBuilding["HUM_WELL"].productionType = 0
$arrBuilding["HUM_MINE"].productionType = 1
$arrBuilding["HUM_SAWMILL"].productionType = 2
$arrBuilding["HUM_BARRACKS"].productionType = 0
$arrBuilding["HUM_ARCHERRANGE"].productionType = 0
$arrBuilding["HUM_STABLE"].productionType = 0
$arrBuilding["HUM_TOWER"].productionType = 0

$arrBuilding["HUM_HQ"].productionAmount = 5
$arrBuilding["HUM_HOUSE_SMALL"].productionAmount = 1
$arrBuilding["HUM_HOUSE_MEDIUM"].productionAmount = 3
$arrBuilding["HUM_HOUSE_LARGE"].productionAmount = 6
$arrBuilding["HUM_FARM"].productionAmount = 1
$arrBuilding["HUM_FIELD"].productionAmount = 2
$arrBuilding["HUM_WELL"].productionAmount = 0
$arrBuilding["HUM_MINE"].productionAmount = 3
$arrBuilding["HUM_SAWMILL"].productionAmount = 2
$arrBuilding["HUM_BARRACKS"].productionAmount = 0
$arrBuilding["HUM_ARCHERRANGE"].productionAmount = 0
$arrBuilding["HUM_STABLE"].productionAmount = 0
$arrBuilding["HUM_TOWER"].productionAmount = 0

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
$objForm.Text = ("PowerHeroes v" + $global:VersionInfo[0] + "." + $global:VersionInfo[1] + "." + $global:VersionInfo[2] + " - " + $global:VersionInfo[3])
If (Test-Path ".\PowerHeroes.exe") { $objForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(".\PowerHeroes.exe")}

try
{
# used for changing the cursor
Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern IntPtr LoadCursorFromFile(String lpFileName);
"@ -Namespace "MyWin32" -Name "LoadCursor"

$objForm.Cursor = [MyWin32.LoadCursor]::LoadCursorFromFile(".\GFX\INTERFACE\CURSOR_SHINY.cur")
} catch { Write-Host "Can't change cursor!"}

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
    # TODO: Copy rect

    $offset_x = $iTileX * $global:arrSettings["TILESIZE"]
    $offset_y = $iTileY * $global:arrSettings["TILESIZE"]

    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $tmp_pixel = $objImage.GetPixel($i, $j)
        
            if($tmp_pixel -ne $global:arrColors["CLR_MAGENTA"] -and $tmp_pixel -ne $global:arrColors["CLR_TRANSPARENT"])
            {
                $global:objWorld.SetPixel(($offset_x + $i), ($offset_y + $j), $tmp_pixel);
            }
        }
    }

    $objForm.Refresh();
}

function MAP_addBuildingBar($bldIndex)
{
    $offset_x = ($global:arrBuildings[$bldIndex][0] + 2) * $global:arrSettings["TILESIZE"]
    $offset_y = ($global:arrBuildings[$bldIndex][1] + 2) * $global:arrSettings["TILESIZE"]

    #calc percent
    $percent = ($global:arrBuildings[$bldIndex][6] / $arrBuilding[$global:arrBuildingIDToKey[$global:arrBuildings[$bldIndex][3]]].hitpoints)

    if(([int]($global:arrBuildings[$bldIndex][4])) -eq 0)
    {
        $percent = $global:arrBuildings[$bldIndex][5]
    }

    if($percent -lt 0)
    {
        return;
    }
    elseif($percent -gt 1)
    {
        $percent = ($percent / 100)
    }

    # TODO: use rect
    for($i = 2; $i -lt 14; $i++)
    {
        for($j = 2; $j -lt 5; $j++)
        {
            $global:objWorld.SetPixel(($offset_x + $i), ($offset_y + $j), $global:arrColors["CLR_BLACK"]);
        }
    }

    $lengthBar = [math]::floor($percent * 10)
    
    # Make sure, that at least one pixel is colored
    if($lengthBar -eq 0)
    {
        $lengthBar = 1;
    }

    $clrBar = getColorForPercent  $percent 

    for($i = 3; $i -lt (3 + $lengthBar); $i++)
    {
        $global:objWorld.SetPixel(($offset_x + $i), ($offset_y + 3), $clrBar);
    }

    $objForm.Refresh();
}

function getColorForPercent($fPercent)
{
    $clrBar = $global:arrColors["CLR_BAD"]

    if($fPercent -gt 0.66)
    {
        $clrBar = $global:arrColors["CLR_GOOD"]
    }
    elseif($fPercent -gt 0.33)
    {
        $clrBar = $global:arrColors["CLR_OKAY"]
    }
    
    return $clrBar
}

function MAP_createMapImage()
{
    $global:arrMap["WIDTH"] = $global:arrCreateMapOptions["WIDTH"]
    $global:arrMap["HEIGHT"] = $global:arrCreateMapOptions["HEIGHT"]

    $size_x = $global:arrMap["WIDTH"] + 4;
    $size_y = $global:arrMap["HEIGHT"] + 4;
    
    $global:objWorld = New-Object System.Drawing.Bitmap(($size_x * $global:arrSettings["TILESIZE"]), ($size_y * $global:arrSettings["TILESIZE"]));
    
    $runs = $size_x * $size_y
    $runs5 = [math]::floor($runs * 0.05)
    $runs = $runs5;

    # TODO: Copy Rect
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
      
    for($i = 0; $i -lt $size_x; $i++)
    {
        # $i - 2 because thats the left border
        if($i -ge 2 -and $i -lt ($size_x - 2))
        {
            $global:arrMap["WORLD_L1"][($i - 2)] = @{}
            $global:arrMap["WORLD_L2"][($i - 2)] = @{}
            $global:arrMap["WORLD_L3"][($i - 2)] = @{}
        }

        for($j = 0; $j -lt $size_y; $j++)
        {
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
}

function isLastPlayer($iPlayerID)
{
    if($iPlayerID -eq $global:arrSettingsInternal["PLAYER_MAX"]) {return $True}

    for($i = ($iPlayerID + 1); $i -le $global:arrSettingsInternal["PLAYER_MAX"]; $i++)
    {
        if((isActivePlayer $i)) {return $False}
    }

    return $True
}

function getNextActivePlayer($iCurrentPlayerID)
{
    for($i = ($iCurrentPlayerID + 1); $i -le $global:arrSettingsInternal["PLAYER_MAX"]; $i++)
    {
        if((isActivePlayer $i)) {return $i}
    }

    Write-Host "getNextActivePlayer($iCurrentPlayerID) - player was last player!"

    return $iCurrentPlayerID
}

function isActivePlayer($iPlayerID)
{
    return ($global:arrPlayerInfo[$iPlayerID][5] -gt 0 -and $global:arrPlayerInfo[$iPlayerID][5] -lt 5)
}

function getFirstActivePlayer()
{
    for($i = 1; $i -le $global:arrSettingsInternal["PLAYER_MAX"]; $i++)
    {
        if($global:arrPlayerInfo[$i][5] -ge 1 -and $global:arrPlayerInfo[$i][5] -le 4)
        {
            return $i
        }
    }

    return -1;
}

function getFirstHumanPlayer()
{
    for($i = 1; $i -le $global:arrSettingsInternal["PLAYER_MAX"]; $i++)
    {
        if($global:arrPlayerInfo[$i][5] -eq 3 -or $global:arrPlayerInfo[$i][5] -eq 4)
        {
            return $i
        }
    }

    return -1;
}

function gameHasPlayerType($type)
{
    for($i = 1; $i -le 4; $i++)
    {
        if($global:arrPlayerInfo[$i][5] -eq $type)
        {
            return $True
        }
    }

    return $False;
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
    MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][($posX)][($posY)]]]) ($posX + 2) ($posY + 2)
    
    if($global:arrMap["WORLD_L2"][([int]$posX)][([int]$posY)] -ne -1)
    {
        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][($posX)][($posY)]]]) ($posX + 2) ($posY + 2)
    }

}

function loadMapHeader($strPath)
{
    if($strPath -eq "")
    {
        return;
    }

    initMapArray

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
    }

    generateMapPreview
}

function generateMapPreview()
{
    $stepX = 1 / ([int]$global:arrMap["WIDTH"] / 16)
    $stepY = 1 / ([int]$global:arrMap["HEIGHT"] / 16)

    Write-Host "Step x / y: $stepX / $stepY"

    $currentStepX = 1
    $currentStepY = 1

    # create a rect
    $tmp_rec    = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
    # cloning is faster than creating a new bitmap
    $tmp_wnd    = $global:bitmap.Clone($tmp_rec, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    $tmp_grd = [System.Drawing.Graphics]::FromImage($tmp_wnd);
    $tmp_grd.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $tmp_grd.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

    $pixelIDx = 0
    $pixelIDy = 0
    for($i = 0; $i -lt $global:arrMap["WIDTH"]; $i++)
    {
        $pixelIDy = 0
        if($currentStepX -ge 1)
        {
            $currentStepX = $currentStepX -1

            for($j = 0; $j -lt $global:arrMap["HEIGHT"]; $j++)
            {
                if($currentStepY -ge 1)
                {
                    $currentStepY = $currentStepY -1
                    switch ($global:arrMap["WORLD_L1"][$i][$j])
                    {
                        4 
                        {
                            $tmp_wnd.SetPixel($pixelIDx, $pixelIDy, [System.Drawing.Color]::FromArgb(96, 117, 187))
                        }
                        5
                        {
                            $tmp_wnd.SetPixel($pixelIDx, $pixelIDy, [System.Drawing.Color]::FromArgb(0, 0, 0))
                        }
                        default
                        {
                            $tmp_wnd.SetPixel($pixelIDx, $pixelIDy, [System.Drawing.Color]::FromArgb(121, 215, 72))
                        }
                    }
                    $pixelIDy = $pixelIDy + 1
                }
                $currentStepY = $currentStepY + $stepY
            }
            $pixelIDx = $pixelIDx + 1
        }
        $currentStepX = $currentStepX + $stepX
    }

    for($i = 0; $i -lt 4; $i++)
    {
        if([int]$global:arrMap[("PLAYER_0" + ($i + 1) + "X")] -ne -1 -and [int]$global:arrMap[("PLAYER_0" + ($i + 1) + "Y")] -ne -1)
        {
            $playerX = [math]::floor([int]$global:arrMap[("PLAYER_0" + ($i + 1) + "X")] * (16 / [int]$global:arrMap["WIDTH"]))
            $playerY = [math]::floor([int]$global:arrMap[("PLAYER_0" + ($i + 1) + "Y")] * (16 / [int]$global:arrMap["HEIGHT"]))
            $tmp_wnd.SetPixel($playerX, $playerY, [System.Drawing.Color]::FromArgb(255, 0, 0))
        }
    }
   
    $global:arrMap.preview_graphics = $tmp_grd
    $global:arrMap.preview_wnd = $tmp_wnd
}

function loadMap($strPath)
{
    if($strPath -eq "")
    {
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

    for ($i = 0; $i -lt $global:arrMap["HEIGHT"]; $i++)
    {
        for($j = 0; $j -lt $global:arrMap["WIDTH"]; $j++)
        {
            MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][$i][$j]]]) ($i + 2) ($j + 2) 

            if([int]($global:arrMap["WORLD_L2"][$i][$j]) -ne -1)
            {
                MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][$i][$j]]]) ($i + 2) ($j + 2) 
            }

            if([int]($global:arrMap["WORLD_L3"][$i][$j]) -ne -1)
            {
                MAP_changeTile ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrMap["WORLD_L3"][$i][$j]]]) ($i + 2) ($j + 2) 
            }

            $playerID = getPlayerAtPosition $i $j
            if($playerID -ne 0 -and (isActivePlayer $playerID))
            {
                addBuildingAtPositionForPlayer $i $j 0 ([int]$playerID) $True
            }
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


    for($i = 1; $i -le $global:arrSettingsInternal["PLAYER_MAX"]; $i++)
    {
        ("PLAYER_0" + $i + "X=") + $global:arrMap["PLAYER_01X"] | Out-File -FilePath $strFileName -Append
        ("PLAYER_0" + $i + "Y=") + $global:arrMap["PLAYER_01Y"] | Out-File -FilePath $strFileName -Append
    }

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
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 ([string]($global:arrCreateMapOptions["WIDTH"])) -1 -1 "Gold" $False
        }
        else
        {
            $global:arrWindows["WND_CREATE_MAP"].btn.Remove("BTN_CREATEMAP_HEIGHT")
            addButtonToWindow "WND_CREATE_MAP" "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 ([string]($global:arrCreateMapOptions["HEIGHT"])) -1 -1 "Gold" $False
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
                
                addColoredArea "WND_ESC_EDITOR" 12 92 136 20 ($global:arrColors["CLR_BLACK"])
                addText "WND_ESC_EDITOR" $global:arrMap["AUTHOR"] 14 96 "Gold" $False
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
                
                addColoredArea "WND_ESC_EDITOR" 12 92 136 20 ($global:arrColors["CLR_BLACK"])
                addText "WND_ESC_EDITOR" $global:arrMap["AUTHOR"] 14 96 "Gold" $False
                $objForm.Refresh();
            }
        }
        "INPUT_MAPNAME"
        {
            $len_mapname = ([string]($global:arrMap["MAPNAME"])).Length
            
            if($key -eq "Back" -and $len_mapname -gt 0)
            {
                $global:arrMap["MAPNAME"] = ($global:arrMap["MAPNAME"]).Substring(0, ($len_mapname - 1))
                
                addColoredArea "WND_ESC_EDITOR" 12 66 136 20 ($global:arrColors["CLR_BLACK"])
                addText "WND_ESC_EDITOR" $global:arrMap["MAPNAME"] 14 70 "Gold" $False
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
                
                addColoredArea "WND_ESC_EDITOR" 12 66 136 20 ($global:arrColors["CLR_BLACK"])
                addText "WND_ESC_EDITOR" $global:arrMap["MAPNAME"] 14 70 "Gold" $False
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

            if($global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                showWindow "WND_ESC_SINGLEPLAYER"
                $global:strGameState = "SINGLEPLAYER_ESCAPE"
                $objForm.Refresh();
            }
            elseif($global:strGameState -eq "SINGLEPLAYER_ESCAPE")
            {
                $global:strGameState = "SINGLEPLAYER_INGAME"
                showWindow "WND_SINGLEPLAYER_MENU"
                $objForm.Refresh();
            }
        }
        "T"
        {
            for($i = 1; $i -lt 5; $i++)
            {
                Write-Host "Name      : " $global:arrPlayerInfo[$i][0]
                Write-Host "Goldincome: " $global:arrPlayerInfo[$i][1]
                Write-Host "Woodincome: " $global:arrPlayerInfo[$i][2]
                Write-Host "Foodincome: " $global:arrPlayerInfo[$i][3]
                Write-Host "Producion : " $global:arrPlayerInfo[$i][4]
                Write-Host "Gold      : " $global:arrPlayerInfo[$i][6]
                Write-Host "Wood      : " $global:arrPlayerInfo[$i][7]
                Write-Host "Food      : " $global:arrPlayerInfo[$i][8]
            }
        }
        "P"
        {
            if($global:strGameState -eq "EDIT_MAP")
            {
                $global:arrCreateMapOptions["SHOW_PREVIEW"] = !$global:arrCreateMapOptions["SHOW_PREVIEW"]
            }
        }
        "Right"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -lt ($global:arrCreateMapOptions["WIDTH"] - 16) -and $global:strGameState -eq "EDIT_MAP")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] += 1;
                $objForm.Refresh();
            }
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -lt ($global:arrCreateMapOptions["WIDTH"] - 16) -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] += 1;
                $objForm.Refresh();
            }
        }
        "Left"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -gt 0 -and $global:strGameState -eq "EDIT_MAP")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] -= 1;
                $objForm.Refresh();
            }

            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -gt 0 -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_X"] -= 1;
                $objForm.Refresh();
            }
        }
        "Down"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -lt ($global:arrCreateMapOptions["HEIGHT"] - 13) -and $global:strGameState -eq "EDIT_MAP")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] += 1;
                $objForm.Refresh();
            }

            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -lt ($global:arrCreateMapOptions["HEIGHT"] - 13) -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] += 1;
                $objForm.Refresh();
            }
        }
        "Up"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -gt 0 -and $global:strGameState -eq "EDIT_MAP")
            {
                $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -= 1;
                $objForm.Refresh();
            }

            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -gt 0 -and $global:strGameState -eq "SINGLEPLAYER_INGAME")
            {
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

function openTileInfoIfNeeded($posX, $posY)
{
    $objID = ([int]($global:arrMap["WORLD_L3"][$posX][$posY]))

    Write-Host "WorldL3 = $objId"

    $bldID = ([int]($global:arrMap["WORLD_LBLD"][$posX][$posY]))

    $global:arrPlayerInfo.currentSelection = $bldID

    if($bldID -eq -1 -and $objID -eq -1)
    {
        return
    }

    showWindow "WND_TILEINFO"
    $global:strGameState = "SINGLEPLAYER_TILEINFO"
    
    $global:arrWindows["WND_TILEINFO"].btn.Remove("BTN_TILEINFO_BURN_BUILDING")
    redrawWindowBack "WND_TILEINFO" 12 210 20 20 

    if($bldID -ne -1)
    {
        $owner = $global:arrBuildings[$bldID][2]
        $type = $global:arrBuildings[$bldID][3]
        $name = $arrBuilding[$global:arrBuildingIDToKey[$type]].name

        $hp_max = $arrBuilding[$global:arrBuildingIDToKey[$type]].hitpoints
        $hp_act = $global:arrBuildings[$bldID][6]

        $state = $global:arrBuildings[$bldID][4]
        $percent = ($global:arrBuildings[$bldID][5] * 100)

        $clrBar = getColorForPercent $global:arrBuildings[$bldID][5]

        if(([int]($state)) -eq 0)
        {
            $strStateText = ([string]($percent)) + " %"
            $clrBar = $global:arrColors["CLR_BUILDING"]
            addBarToWindow "WND_TILEINFO" 136 20 12 52 $strStateText $global:arrBuildings[$bldID][5] $clrBar
        }
        else
        {
            redrawWindowBack "WND_TILEINFO" 12 52 136 20 
        }

        $global:arrWindows["WND_TILEINFO"].btn.Remove("BTN_TILEINFO_DUMMY_01")
        addButtonToWindow "WND_TILEINFO" "BTN_TILEINFO_DUMMY_01" "Gray" 136 20 12 12 ($name) -1 -1 "Gold" $False

        $percent_HP = ($hp_act / $hp_max)
        $clr_HP = getColorForPercent $percent_HP

        addBarToWindow "WND_TILEINFO" 136 20 12 32 (([string]($hp_act)) + "/" + ([string]($hp_max))) $percent_HP $clr_HP

        redrawWindowBack "WND_TILEINFO" 48 80 64 64
        addImageToWindow "WND_TILEINFO" $arrBuilding[$global:arrBuildingIDToKey[$type]][0] 48 80 4

        if($owner -eq $global:arrPlayerInfo.currentPlayer)
        {
            addButtonToWindow "WND_TILEINFO" "BTN_TILEINFO_BURN_BUILDING" "Red" 20 20 12 210 "" -1 -1 "Gold" $False
            addImageToWindow "WND_TILEINFO" ($global:arrIcons["ICON_BOMB"]) 14 212 1
        }

        playSFX ("SND_" + $global:arrBuildingIDToKey[$type])
    }
    else
    {
        $global:arrWindows["WND_TILEINFO"].btn.Remove("BTN_TILEINFO_DUMMY_01")
        addButtonToWindow "WND_TILEINFO" "BTN_TILEINFO_DUMMY_01" "Gray" 136 20 12 12 "Object" -1 -1 "Gold" $False

        redrawWindowBack "WND_TILEINFO" 12 32 136 20
        redrawWindowBack "WND_TILEINFO" 12 52 136 20

        redrawWindowBack "WND_TILEINFO" 48 80 64 64
        addImageToWindow "WND_TILEINFO" $global:arrTextures[$arrObjectTextureIDToKey[$objID]] 48 80 4

        playSFX "SND_OBJ_GENERIC"
    }

   $pictureBox.Refresh();
}

function handleClickGameworld($posX, $posY)
{
    $tile_x = [math]::floor($posX / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($posY / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]


    if($tile_x -lt 2 -or $tile_y -lt 2 -or $tile_x -gt ([int]($arrCreateMapOptions["WIDTH"]) + 1) -or $tile_y -gt ([int]($arrCreateMapOptions["HEIGHT"]) + 1))
    {
        Write-Host "handleClickGameworld: But border tile"
        return;
    }

    if($global:strGameState -eq "SINGLEPLAYER_TILEINFO")
    {
        Write-Host "Tileinfo gamestate... returning!"
        return;
    }

    if(([int]($global:arrSettings["BUILDINGS_SELECTED"])) -eq -1)
    {
        Write-Host "lets check tile info..."
        openTileinfoIfNeeded ([int]($tile_x - 2)) ([int]($tile_y - 2))
    }
    else
    {
        $canBuild = checkIfBuildingPossible ([int]($global:arrSettings["BUILDINGS_SELECTED"])) ([int]($tile_x - 2)) ([int]($tile_y - 2)) ($global:arrPlayerInfo.currentPlayer)

        if($canBuild -and ([int]($global:arrSettings["BUILDINGS_SELECTED"])) -ge 0)
        {
            addBuildingAtPositionForPlayer ([int]($tile_x - 2)) ([int]($tile_y - 2)) $global:arrSettings["BUILDINGS_SELECTED"] ($global:arrPlayerInfo.currentPlayer) $False

            if(([int]($global:arrSettings["BUILDINGS_SELECTED"])) -gt 0)
            {
                if($global:arrCreateMapOptions["CLICK_MODE"] -eq 1)
                {
                    $prevColID = [math]::floor(($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) / 3)
                    $prevRowID = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) - 3 *  $prevColID

                    buildButton "Gray"  20 20 (10 + $prevColID * 20 + $prevColID * 18) (58 + $prevRowID * 20 + $prevRowID * 6) $False
                    addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$global:arrSettings["BUILDINGS_SELECTED"]]][0]) (11 + $prevColID * 20 + $prevColID * 18) (59 + $prevRowID * 20 + $prevRowID * 6) 1
                }
                else
                {
                    $prevColID = [math]::floor(($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"] - $global:arrSettings["BUILDINGS_CIVILS"]) / 3)
                    $prevRowID = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"] - $global:arrSettings["BUILDINGS_CIVILS"]) - 3 *  $prevColID

                    buildButton "Gray"  20 20 (10 + $prevColID * 20 + $prevColID * 18) (58 + $prevRowID * 20 + $prevRowID * 6) $False
                    addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$global:arrSettings["BUILDINGS_SELECTED"]]][0]) (11 + $prevColID * 20 + $prevColID * 18) (59 + $prevRowID * 20 + $prevRowID * 6) 1
                }
            }

            $global:arrSettings["BUILDINGS_SELECTED"] = -1

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 "" -1 -1 "Gold" $False

            redrawWindowBack "WND_SINGLEPLAYER_MENU" 30 162 120 62
        }
    }

}

function addBuildingAtPositionForPlayer($posX, $posY, $building, $player, $instant)
{
    Write-Host "addBuildingAtPositionForPlayer($posX, $posY, $building, $player, $instant)"

    # Still need to check if valid
    if($posX -lt 0 -or $posX -gt $global:arrMap["WIDTH"])
    {
        Write-Host "addBuildingAtPositionForPlayer - ERROR out of world ($posX)"
        return;
    }
    
    if($posY -lt 0 -or $posY -gt $global:arrMap["HEIGHT"])
    {
        Write-Host "addBuildingAtPositionForPlayer - ERROR out of world ($posY)"
        return;
    }
    
    if($building -lt 0 -or $building -gt $global:arrBuildingIDToKey.Length)
    {
        Write-Host "addBuildingAtPositionForPlayer - ERROR invalid building id ($building)"
        return;
    }
    
    if($player -lt 0 -or $player -gt $global:arrSettings["PLAYER_MAX"])
    {
        Write-Host "addBuildingAtPositionForPlayer - ERROR invalid player id ($player)"
        return;
    }

    # (1) generate new building
    # (2) add building to lbld array (index)
    # (3) redraw
    # (4) updatePlayerStats

    Write-Host "addBuildingAtPositionForPlayer($posX, $posY, $building, $player)"

    #
    # 1
    #

    # $global:arrBuildings
    # 0 = loc_x
    # 1 = loc_y
    # 2 = owner
    # 3 = bldID ($global:arrBuilding array)
    # 4 = state (0 building, 1 finished maybe 2 burning later)
    # 5 = % state (0 = nothing, 1 = done)
    # 6 = current hitpoints

    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]] = @{}
    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][0] = $posX #locx
    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][1] = $posY #loc_y
    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][2] = $player #owner
    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][3] = $building #building ID
    if($instant)
    {
        $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][4] = 1 #state (0 building, 1 finished maybe 2 burning later)
        $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][5] = 1 #percentage of building state (0 = nothing, 1 = done)
    }
    else
    {
        $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][4] = 0 #state (0 building, 1 finished maybe 2 burning later)
        $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][5] = 0 #percentage of building state (0 = nothing, 1 = done)
        playSFX "SND_HUM_BUILDING"
    }
    
    $global:arrBuildings[$global:arrMap["BUILDING_INDEX"]][6] = $arrBuilding[$global:arrBuildingIDToKey[$building]].hitpoints

    #
    # 2
    #
    $global:arrMap["WORLD_LBLD"][$posX][$posY] = $global:arrMap["BUILDING_INDEX"]

    # 
    # 2.5
    #
    $global:arrMap["BUILDING_INDEX"] = $global:arrMap["BUILDING_INDEX"] + 1

    #
    # 3 + 4 (for instant)
    #
    if($instant)
    {
        Write-Host "Adding new instant building"
        drawBuildingAt $posX $posY $building $player 0
        finishBuilding $player $building 1
    }
    else
    {
        Write-Host "adding new non instant building"
        drawBuildingAt $posX $posY $building $player 1
    }

    #
    # 5 update playerstats
    #
    updatePlayerStat $player 6 (-1 * ($arrBuilding[$global:arrBuildingIDToKey[$building]].gold_cost))
    updatePlayerStat $player 7 (-1 * ($arrBuilding[$global:arrBuildingIDToKey[$building]].wood_cost))
}

function destroySelectedBuilding()
{
    if($global:arrPlayerInfo.currentSelection -eq -1) {return}

    # $global:arrBuildings
    # 0 = loc_x
    # 1 = loc_y
    # 2 = owner
    # 3 = bldID ($global:arrBuilding array)
    # 4 = state (0 building, 1 finished maybe 2 burning later)
    # 5 = % state (0 = nothing, 1 = done)
    # 6 = current hitpoints
    $posX = $global:arrBuildings[$global:arrPlayerInfo.currentSelection][0]
    $posY = $global:arrBuildings[$global:arrPlayerInfo.currentSelection][1]
    $player = $global:arrBuildings[$global:arrPlayerInfo.currentSelection][2]
    $bldID = $global:arrBuildings[$global:arrPlayerInfo.currentSelection][3]

    # 1 update playerStat
    finishBuilding $player $bldID -1

    # 2 update world
    $global:arrMap["WORLD_LBLD"][$posX][$posY] = -1
    drawLayer1And2 $posX $posY

    # 3 update building array
    $global:arrBuildings.Remove($global:arrPlayerInfo.currentSelection)
}

function finishBuilding($player, $building, [int]$factor)
{
    Write-Host "finishBuilding($player, $building, $factor)"
    # There is at least one production type
    if($arrBuilding[$global:arrBuildingIDToKey[$building]].productionType -ne 0)
    {
        # only one type
        if($arrBuilding[$global:arrBuildingIDToKey[$building]].productionType -lt 5)
        {
            updatePlayerStat $player ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionType) ($factor * ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionAmount))
        }
        else
        {
            updatePlayerStat $player 1 ($factor * ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionAmount))
            updatePlayerStat $player 2 ($factor * ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionAmount))
            updatePlayerStat $player 3 ($factor * ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionAmount))
            updatePlayerStat $player 4 ($factor * ($arrBuilding[$global:arrBuildingIDToKey[$building]].productionAmount))
        }
    }
}

function updatePlayerStat($player, $index, $amount)
{
    Write-Host "updatePlayerStat($player, $index, $amount)"

    $global:arrPlayerInfo[([int]($player))][([int]($index))] += $amount
}

function drawLayer1And2($posX, $posY)
{
    MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][[int]$posX][[int]$posY]]]) ($posX + 2) ($posY + 2)

    if([int]$global:arrMap["WORLD_L2"][([int]$posX)][([int]$posY)] -ne -1)
    {
        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrMap["WORLD_L2"][$posX][$posY]]]) ($posX + 2) ($posY + 2)
    }
}

function drawBuildingAt($posX, $posY, $bld, $player, $offset)
{
    Write-Host "drawBuildingAt($posX, $posY, $bld, $player)"

    drawLayer1And2 $posX $posY

    MAP_changeTile $arrBuilding[$arrBuildingIDToKey[$bld]][($player * 2 + $offset)] ($posX + 2) ($posY + 2)

    $bldIndex = $global:arrMap["WORLD_LBLD"][$posX][$posY]

    MAP_addBuildingBar $bldIndex 
}

function checkIfPlayerHasWares($iPlayerID, $iBuildingID)
{
    Write-Host "checkIfPlayerHasWares($iPlayerID, $iBuildingID)"

    $hasWares = $True

    Write-Host "Cost Gold: " $arrBuilding[$global:arrBuildingIDToKey[$iBuildingID]].gold_cost "/" $global:arrPlayerInfo[$iPlayerID][6]
    Write-Host "Wood Gold: " $arrBuilding[$global:arrBuildingIDToKey[$iBuildingID]].wood_cost "/" $global:arrPlayerInfo[$iPlayerID][7]

    if($arrBuilding[$global:arrBuildingIDToKey[$iBuildingID]].gold_cost -gt $global:arrPlayerInfo[$iPlayerID][6]) {$hasWares = $False}
    if($arrBuilding[$global:arrBuildingIDToKey[$iBuildingID]].wood_cost -gt $global:arrPlayerInfo[$iPlayerID][7]) {$hasWares = $False}

    return $hasWares
}

function checkIfBuildingPossible($iBuildingID, $posX, $posY, $iPlayerID)
{
    ## firstfirst check if player has wares
    $canBuild = checkIfPlayerHasWares $iPlayerID $iBuildingID

    if(!$canBuild) {return $canBuild}

    # first check if it's a valid position
    # LAYER 1 check

    Write-Host "checkIfBuildingPossible($iBuildingID, $posX, $posY, $iPlayerID)"

    if($posX -ge $arrCreateMapOptions["WIDTH"] -or $posY -ge $arrCreateMapOptions["HEIGHT"])
    {
        return $False;
    }

    if($posY -lt 0 -or $posY -lt 0)
    {
        return $False
    }

    $canBuild = $False

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
                    $canBuild = $True
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

    # The building quality is not enough - so return and skip the next check
    if(!$canBuild){return $canBuild}

    $canBuild = checkBuildingPrerequisites $iBuildingID $posX $posY $iPlayerID

    return $canBuild
}

function checkBuildingPrerequisites($iBuildingID, $iPosX, $iPosY, $iPlayerID)
{
    Write-Host "checkBuildingPrerequisites($iBuildingID, $iPosX, $iPosY, $iPlayerID)"

    # TODO: Use hasHQOrTower

    switch($iBuildingID)
    {
        0 # HUM_HQ
        {
            # no prereq for HQs
            return $True
        }
        1 # HUM_HOUSE_SMALL
        {
            # close to HQ?
            $canBuild = hasBuildingInRange 2 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to Well?
            $canBuild = hasBuildingInRange 2 6 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        2 # HUM_HOUSE_MEDIUM
        {
            # close to HQ?
            $canBuild = hasBuildingInRange 1 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to Well?
            $canBuild = hasBuildingInRange 1 6 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        3 # HUM_HOUSE_LARGE
        {
            # next to HQ?
            $canBuild = hasBuildingInRange 0 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # next to Well?
            $canBuild = hasBuildingInRange 0 6 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        4 # HUM_FARM
        {
            # close to HQ?
            $canBuild = hasBuildingInRange 3 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to tower?
            $canBuild = hasBuildingInRange 3 12 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        5 # HUM_FIELD
        {
            # close to farm?
            $canBuild = hasBuildingInRange 1 4 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        6 # HUM_WELL
        {
            # close to HQ?
            $canBuild = hasBuildingInRange 3 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to Tower?
            $canBuild = hasBuildingInRange 3 12 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        7 # HUM_MINE
        {
            $hasGold = hasObjectInRange 0 18 $iPosX $iPosY

            if(!$hasGold) {return $False}

            # close to HQ?
            $canBuild = hasBuildingInRange 3 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to Tower?
            $canBuild = hasBuildingInRange 3 12 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        8 # HUM_SAWMILL
        {
            $hasWood = hasObjectInRange 0 13 $iPosX $iPosY

            if(!$hasWood) {$hasWood = hasObjectInRange 0 14 $iPosX $iPosY}
            if(!$hasWood) {$hasWood = hasObjectInRange 0 15 $iPosX $iPosY}
            if(!$hasWood) {$hasWood = hasObjectInRange 0 16 $iPosX $iPosY}

            Write-Host $hasWood

            if(!$hasWood) {return $False}

            # close to HQ?
            $canBuild = hasBuildingInRange 3 0 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            # close to Tower?
            $canBuild = hasBuildingInRange 3 12 $iPosX $iPosY $iPlayerID

            if($canBuild){return $True}

            return $False
        }
        9
        {
            return hasHQTower 3 $iPosX $iPosY $iPlayerID
        }
        10
        {
            return hasHQTower 3 $iPosX $iPosY $iPlayerID
        }
        11
        {
            return hasHQTower 3 $iPosX $iPosY $iPlayerID
        }
        12
        {
            return hasHQTower 4 $iPosX $iPosY $iPlayerID
        }

        default{return $True}
    }
}

function hasHQTower($iRange, $iPosX, $iPosY, $iPlayerID)
{
    # close to HQ?
    $canBuild = hasBuildingInRange $iRange 0 $iPosX $iPosY $iPlayerID

    if($canBuild){return $True}

    # close to tower?
    $canBuild = hasBuildingInRange $iRange 12 $iPosX $iPosY $iPlayerID

    if($canBuild){return $True}

    return $False
}

function hasObjectInRange($iMode, $iObjectID, $iPosX, $iPosY)
{
    if($iMode -eq 0)
    {
        ## left
        if($iPosX -gt 0)
        {
            $iObjID = ([int]($global:arrMap["WORLD_L3"][($iPosX - 1)][$iPosY]))
            Write-Host "Left: $iObjID"
            if($iObjID -ne -1)
            {
                if($iObjID -eq $iObjectID) {return $True}
            }
        }
        
        #top 
        if($iPosY -gt 0)
        {
            $iObjID = ([int]($global:arrMap["WORLD_L3"][$iPosX][($iPosY - 1)]))
            Write-Host "top: $iObjID"
            if($iObjID -ne -1)
            {
                if($iObjID -eq $iObjectID) {return $True}
            }
        }
        
        #right
        if($iPosX -lt [int]$global:arrCreateMapOptions["WIDTH"])
        {
            $iObjID = ([int]($global:arrMap["WORLD_L3"][$iPosX + 1][($iPosY)]))
            Write-Host "right: $iObjID"
            if($iObjID -ne -1)
            {
                if($iObjID -eq $iObjectID) {return $True}
            }
            
        }
        
        #bot 
        if($iPosY -lt [int]$global:arrCreateMapOptions["HEIGHT"])
        {
            $iObjID = ([int]($global:arrMap["WORLD_L3"][$iPosX][($iPosY + 1)]))
            Write-Host "bot: $iObjID"
            if($iObjID -ne -1)
            {
                if($iObjID -eq $iObjectID) {return $True}
            }
        }

        return $False
    }
    elseif($iMode -gt 0 -and $iMode -le 5)
    {
        # each column
        for($i = ($iPosX - $iMode); $i -le ($iPosX + $iMode); $i++)
        {
            if($i -lt 0) {continue}
            if($i -ge [int]$global:arrCreateMapOptions["WIDTH"]) {continue}

            for($j = ($iPosY - $iMode);$j -le ($iPosY + $iMode); $j++)
            {
                if($j -lt 0) {continue}
                if($j -ge [int]$global:arrCreateMapOptions["HEIGHT"]) {continue}

                $iObjID = ([int]($global:arrMap["WORLD_L3"][$i][$j]))
                if($iObjID -ne -1)
                {
                    if($iObjID -eq $iBldID) {return $True}
                }

                Write-Host "Not at: $i $j"
            }
        }
        return $False
    }

    return $False
}

function hasBuildingInRange($iMode, $iBldID, $iPosX, $iPosY, $iPlayerID)
{
    Write-Host "hasBuildingInRange($iMode, $iBldID, $iPosX, $iPosY, $iPlayerID)"
    # 0 = cross
    #    ?
    #   ?B?
    #    ?
    # 1 = around
    #   ???
    #   ?B?
    #   ???
    # 2 = around 2
    #  ?????
    #  ?????
    #  ??B??
    #  ?????
    #  ?????
    #  etc

    if($iMode -eq 0)
    {
        $bldID = ([int]($global:arrMap["WORLD_LBLD"][$iPosX][$iPosY]))

            ## left
            if($iPosX -gt 0)
            {
                $bldID = ([int]($global:arrMap["WORLD_LBLD"][($iPosX - 1)][$iPosY]))
                if($bldID -ne -1)
                {
                    $iOwner = $global:arrBuildings[$bldID][2]
                    $type = $global:arrBuildings[$bldID][3]
                    $state = $global:arrBuildings[$bldID][4]
                    if($type -eq $iBldID -and $state -eq 1 -and $iOwner -eq $iPlayerID) {return $True}
                }
            }
            
            #top 
            if($iPosY -gt 0)
            {
                $bldID = ([int]($global:arrMap["WORLD_LBLD"][$iPosX][($iPosY - 1)]))
                if($bldID -ne -1)
                {
                    $iOwner = $global:arrBuildings[$bldID][2]
                    $type = $global:arrBuildings[$bldID][3]
                    $state = $global:arrBuildings[$bldID][4]
                    if($type -eq $iBldID -and $state -eq 1 -and $iOwner -eq $iPlayerID) {return $True}
                }
            }
            
            #right
            if($iPosX -lt [int]$global:arrCreateMapOptions["WIDTH"])
            {
                $bldID = ([int]($global:arrMap["WORLD_LBLD"][$iPosX + 1][($iPosY)]))
                if($bldID -ne -1)
                {
                    $iOwner = $global:arrBuildings[$bldID][2]
                    $type = $global:arrBuildings[$bldID][3]
                    $state = $global:arrBuildings[$bldID][4]
                    if($type -eq $iBldID -and $state -eq 1 -and $iOwner -eq $iPlayerID) {return $True}
                }
                
            }
            
            #bot 
            if($iPosY -lt [int]$global:arrCreateMapOptions["HEIGHT"])
            {
                $bldID = ([int]($global:arrMap["WORLD_LBLD"][$iPosX][($iPosY + 1)]))
                if($bldID -ne -1)
                {
                    $iOwner = $global:arrBuildings[$bldID][2]
                    $type = $global:arrBuildings[$bldID][3]
                    $state = $global:arrBuildings[$bldID][4]
                    if($type -eq $iBldID -and $state -eq 1 -and $iOwner -eq $iPlayerID) {return $True}
                }
            }

            return $False
    }
    elseif($iMode -gt 0 -and $iMode -le 5)
    {
        # each column
            for($i = ($iPosX - $iMode); $i -le ($iPosX + $iMode); $i++)
            {
                if($i -lt 0) {continue}
                if($i -ge [int]$global:arrCreateMapOptions["WIDTH"]) {continue}

                for($j = ($iPosY - $iMode);$j -le ($iPosY + $iMode); $j++)
                {
                    if($j -lt 0) {continue}
                    if($j -ge [int]$global:arrCreateMapOptions["HEIGHT"]) {continue}

                    $bldID = ([int]($global:arrMap["WORLD_LBLD"][$i][$j]))
                    if($bldID -ne -1)
                    {
                        $iOwner = $global:arrBuildings[$bldID][2]
                        $type = $global:arrBuildings[$bldID][3]
                        $state = $global:arrBuildings[$bldID][4]
                        if($type -eq $iBldID -and $state -eq 1 -and $iOwner -eq $iPlayerID) {return $True}
                    }
                }
            }

            return $False
    }

    return $False
}

function handleClickEditor($posX, $posY)
{
    $tile_x = [math]::floor($posX / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($posY / $global:arrSettings["TILESIZE"]) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]
    
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

        $global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)] = $global:arrCreateMapOptions["SELECT_LAYER01"]
        $global:arrMap["WORLD_L2"][([int]$tile_x - 2)][([int]$tile_y - 2)] = -1
        $global:arrMap["WORLD_L3"][([int]$tile_x - 2)][([int]$tile_y - 2)] = -1

    }
    elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 2 -and (($global:arrCreateMapOptions["LAST_CHANGED_X"] -ne $tile_x) -or ($global:arrCreateMapOptions["LAST_CHANGED_Y"] -ne $tile_y) -or ($global:arrCreateMapOptions["LAST_MODE"] -ne 2) -or ($global:arrCreateMapOptions["LAST_CHANGED_TEX"] -ne $global:arrCreateMapOptions["SELECT_LAYER02"])))
    {
        $playerAtPos = getPlayerAtPosition ([int]$tile_x - 2) ([int]$tile_y - 2)
        if($playerAtPos -ne 0) {return}

        MAP_changeTile ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrMap["WORLD_L1"][([int]$tile_x - 2)][([int]$tile_y - 2)]]]) $tile_x $tile_y

        MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) $tile_x $tile_y
        $global:arrCreateMapOptions["LAST_CHANGED_TEX"] = $global:arrCreateMapOptions["SELECT_LAYER02"];
        $global:arrCreateMapOptions["LAST_MODE"] = $global:arrCreateMapOptions["EDIT_MODE"];
        $global:arrCreateMapOptions["LAST_CHANGED_X"] = $tile_x;
        $global:arrCreateMapOptions["LAST_CHANGED_Y"] = $tile_y;

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
        return;
    }

    if($global:strGameState -eq "SINGLEPLAYER_TILEINFO" -and $posX -lt ($DrawingSizeX - 160))
    {
        Write-Host "Hier ist schonmal gut"
        handleButtonKlick "BTN_TILEINFO_QUIT" 0 0 0 0
        return;
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

function handleEndTurnPlayer()
{
    Write-Host "handleEndTurnPlayer"

    if((isLastPlayer $global:arrPlayerInfo.currentPlayer))
    {
        handleNextDay
        $global:arrPlayerInfo.currentPlayer = getFirstActivePlayer
    }
    else
    {
        $global:arrPlayerInfo.currentPlayer = getNextActivePlayer ($global:arrPlayerInfo.currentPlayer)
    }
}

function handleNextDay
{
    # 1 - update wares
    for($i = 1; $i -le $global:arrSettingsInternal["PLAYER_MAX"];$i++)
    {
        $global:arrPlayerInfo[$i][6] = $global:arrPlayerInfo[$i][6] + $global:arrPlayerInfo[$i][1]
        $global:arrPlayerInfo[$i][7] = $global:arrPlayerInfo[$i][7] + $global:arrPlayerInfo[$i][2]
        $global:arrPlayerInfo[$i][8] = $global:arrPlayerInfo[$i][8] + $global:arrPlayerInfo[$i][3]
    }

    # 2 - update buildings (after wares because buildings which are finished dont produce something this day)
    for($i = 1; $i -lt $global:arrMap["BUILDING_INDEX"]; $i++)
    {
        if(!($global:arrBuildings[$i])){continue}

        # check if building is in progress
        if(([int]($global:arrBuildings[$i][4]) -eq 0))
        {
            #percentage of building state (0 = nothing, 1 = done)
            $global:arrBuildings[$i][5] += $arrBuilding[$global:arrBuildingIDToKey[$global:arrBuildings[$i][3]]].buildspeed

            $percent = $global:arrBuildings[$i][5]
            $buildspeed = $arrBuilding[$global:arrBuildingIDToKey[$global:arrBuildings[$i][3]]].buildspeed

            # building is done, so update it
            if($global:arrBuildings[$i][5] -ge 0.99)
            {
                $global:arrBuildings[$i][5] = 1
                $global:arrBuildings[$i][4] = 1
                drawBuildingAt ($global:arrBuildings[$i][0]) ($global:arrBuildings[$i][1]) ($global:arrBuildings[$i][3]) ($global:arrBuildings[$i][2]) 0

                finishBuilding ($global:arrBuildings[$i][2]) ($global:arrBuildings[$i][3]) 1
            }
            else
            {
                MAP_addBuildingBar $i
            }
        }
    }

    

    $pictureBox.Refresh();
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
            showWindow "WND_SINGLEPLAYER_TYPESELECTION"
            #showWindow "WND_SINGLEPLAYER_SETUP"
        }
        "BTN_CAMPAIGN"
        {
            showWindow "WND_ERROR_NOTIMPLEMENTED"
        }
        "BTN_FREEPLAY"
        {
            showWindow "WND_SINGLEPLAYER_SETUP"
        }
        "BTN_TUTORIAL"
        {
            showWindow "WND_RTFM"
        }
        "BTN_SINGLEPLAYER_TYPESELECTION_BACK"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_MULTIPLAYER"
        {
            showWindow "WND_ERROR_NOTIMPLEMENTED"
        }
        "BTN_SINGLEPLAYER_SETUP_START"
        {
            if($global:strMapFile -eq "")
            {
                return;
            }

            # no local player?
            if(!(gameHasPlayerType(3)))
            {
                showWindow "WND_ERROR_NOLOCALPLAYER"
                return;
            }
            # open slots?
            elseif (gameHasPlayerType(4))
            {
                showWindow "WND_ERROR_HASOPENSLOTS"
                return;
            }

            $global:arrMap["WIDTH"] = 0
            $global:arrMap["HEIGHT"] = 0
            
            # reset buildings
            $global:arrBuildings = @{}
            $global:arrBuildings[0] = @{}

            showWindow "WND_PLEASE_WAIT"
            loadMap $global:strMapFile

            showWindow "WND_SINGLEPLAYER_MENU"
            $global:strGameState = "SINGLEPLAYER_INGAME";
            $global:arrPlayerInfo.currentPlayer = getFirstActivePlayer

            $pictureBox.Refresh();
        }
        "BTN_ERROR_NOTIMPLEMENTED_BACK"
        {
            showWindow "WND_ESC_MAIN"
        }
        "BTN_ERROR_OK_SINGLEPLAYER_SETUP"
        {
            showWindow "WND_SINGLEPLAYER_SETUP"
        }
        "BTN_EDITOR"
        {
            #Reset Variables
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
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 210 74 1
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
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 210 74 1
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
            initMapArray

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
                addButtonToWindow "WND_SINGLEPLAYER_SETUP" "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 338 20 90 12 $filename 6 6 "Gold" $False

                # header load map
                loadMapHeader $global:strMapFile

                # Playercount
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 90 46 100 26
                [string]$playerCount = getPlayerCount
                addText "WND_SINGLEPLAYER_SETUP" $playerCount 90 46 "Gold" $False

                # Author
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 90 76 100 26
                addText "WND_SINGLEPLAYER_SETUP" $global:arrMap["AUTHOR"] 90 76 "Gold" $False

                # Size
                redrawWindowBack "WND_SINGLEPLAYER_SETUP" 90 106 100 26
                addText "WND_SINGLEPLAYER_SETUP" ($global:arrMap["WIDTH"] + " x " + $global:arrMap["HEIGHT"]) 90 106 "Gold" $False

                # preview
                addImageToWindow "WND_SINGLEPLAYER_SETUP" $global:arrMap.preview_wnd 90 136 2
                
                # remove all buttons
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove(("BTN_SINGLEPLAYER_SETUP_P1"))
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove(("BTN_SINGLEPLAYER_SETUP_P2"))
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove(("BTN_SINGLEPLAYER_SETUP_P3"))
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove(("BTN_SINGLEPLAYER_SETUP_P4"))
                redrawWindowBack "WND_SINGLEPLAYER_SETUP"  200 46 170 110

                for($p = 1; $p -le $playerCount; $p++)
                {
                    $global:arrPlayerInfo[$p] = @{}

                    $global:arrPlayerInfo[$p][0] = ("Player " + $p)
                    $global:arrPlayerInfo[$p][1] = 0
                    $global:arrPlayerInfo[$p][2] = 0
                    $global:arrPlayerInfo[$p][3] = 0
                    $global:arrPlayerInfo[$p][4] = 0
                    $global:arrPlayerInfo[$p][5] = 0
                    $global:arrPlayerInfo[$p][6] = 250
                    $global:arrPlayerInfo[$p][7] = 250
                    $global:arrPlayerInfo[$p][8] = 50
                }

                for($p = 1; $p -le $playerCount; $p++)
                {
                    addText "WND_SINGLEPLAYER_SETUP" ("Player #" + $p + ":") 200 (16 + $p * 30) "Gold" $False
                    addColoredArea "WND_SINGLEPLAYER_SETUP"  200 (24 + $p * 30) 66 10 ($global:arrColors[("CLR_PLAYER_" + $p + "1")])
                    $global:arrPlayerInfo[$p][5] = 3

                    addButtonToWindow "WND_SINGLEPLAYER_SETUP" ("BTN_SINGLEPLAYER_SETUP_P" + $p) "Gray" 100 20 270 (16 + $p * 30) ($global:arrPlayertypeIndexString[($global:arrPlayerInfo[$p][5])]) 6 6 "Gold" $False
                }

                $objForm.Refresh();
            }  
        }
        "BTN_SINGLEPLAYER_SETUP_P1"
        {
            handleSingleplayerPlayerButton 1
        }
        "BTN_SINGLEPLAYER_SETUP_P2"
        {
            handleSingleplayerPlayerButton 2
        }
        "BTN_SINGLEPLAYER_SETUP_P3"
        {
            handleSingleplayerPlayerButton 3
        }
        "BTN_SINGLEPLAYER_SETUP_P4"
        {
            handleSingleplayerPlayerButton 4
        }
        "BTN_SWITCH_TOPMOST"
        {
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_SWITCH_TOPMOST")
            $global:arrSettings["TOPMOST"] = !$global:arrSettings["TOPMOST"];
            $objForm.Topmost = $global:arrSettings["TOPMOST"];
            addSwitchButtonToWindow "WND_GAME_OPTIONS" "BTN_SWITCH_TOPMOST" $global:arrSettings["TOPMOST"] 60 20 240 12 $True $False
        }
        "BTN_WND_GAME_OPTIONS_SCREENSIZE"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_SCREENSIZE")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_SCREENSIZE" 20 20 240 36 3 ($newX + 1) $False
            
            $global:arrSettings["STARTUPSIZE"] = ($newX + 1);
        }
        "BTN_GAME_OPTIONS_FACE_SUB"
        {
            if(([int]($global:arrSettings["PLAYER_FACE"])) -eq 0)
            {
                ([int]($global:arrSettings["PLAYER_FACE"])) = ([int]($global:arrSettingsInternal["PLAYER_FACE_MAX"]))
            }
            else
            {
                ([int]($global:arrSettings["PLAYER_FACE"])) = ([int]($global:arrSettingsInternal["PLAYER_FACE"])) - 1
            }

            Write-Host "Face: " $global:arrSettings["PLAYER_FACE"]

            addImageToWindow "WND_GAME_OPTIONS" ($global:arrTextures[(nameToId "FACE_" $global:arrSettings["PLAYER_FACE"])]) 270 110 1
            $objForm.Refresh();
        }
        "BTN_GAME_OPTIONS_FACE_ADD"
        {
            if(([int]($global:arrSettings["PLAYER_FACE"])) -eq ([int]($global:arrSettingsInternal["PLAYER_FACE_MAX"])))
            {
                ([int]($global:arrSettings["PLAYER_FACE"])) = 0
            }
            else
            {
                ([int]($global:arrSettings["PLAYER_FACE"])) = ([int]($global:arrSettings["PLAYER_FACE"])) + 1
            }
            
            Write-Host "Face: " $global:arrSettings["PLAYER_FACE"]

            addImageToWindow "WND_GAME_OPTIONS" ($global:arrTextures[(nameToId "FACE_" $global:arrSettings["PLAYER_FACE"])]) 270 110 1
            $objForm.Refresh();
        }
        "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_VOLUMEMUSIC")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC" 20 20 240 60 5 ($newX + 1) $False
            
            Write-Host "Setting music volume..."
            $global:arrSettings["VOLUMEMUSIC"] = $newX * 0.025;
             if([int]$global:arrSettingsInternal["SONGS"] -gt 0){ playSongs }
        }
        "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS"
        {
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS")
            addCountButtonToWindow "WND_GAME_OPTIONS" "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS" 20 20 240 84 5 ($newX + 1) $False
            
            $global:arrSettings["VOLUMEEFFECTS"] = $newX * 0.025;
        }
        "BTN_EDITOR_QUIT"
        {
            showWindow "WND_QUIT_EDITOR"
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
        "BTN_SINGLEPLAYER_QUIT"
        {
            showWindow "WND_QUIT_SINGLEPLAYER"
        }
        "BTN_SINGLEPLAYER_QUIT_YES"
        {
            $global:strGameState = "MAIN_MENU"
            $global:strCurrentWindow = "WND_ESC_MAIN"
            $objForm.Refresh();
        }
        "BTN_SINGLEPLAYER_QUIT_NO"
        {
            showWindow "WND_ESC_SINGLEPLAYER"
            $objForm.Refresh();
        }
        "BTN_EDITOR_SAVEIMAGE"
        {
            showWindow "WND_PLEASE_WAIT"
            $objForm.Refresh();
            try
            {
                Write-Host "Path: " ($PSScriptRoot + ".\MAP\" + ($global:arrMap["MAPNAME"]) + ".png")
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
        # TODO cleanup BTN_IFE
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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
            
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
            
            # next and prev disabled for now
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_PREV" "Gray" 40 20 16 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 23 202 1
            
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_NEXT" "Gray" 40 20 104 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 111 202 1
            
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
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20) 1
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER01"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) (19 + $old_x * 20) (39 + $old_y * 20) 1
            
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
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) (18 + $old_x * 20) (38 + $old_y * 20) 1
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBaseTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20) 1
                
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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
            
            # next and prev disabled for now
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_NEXT" "Gray" 40 20 16 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 23 202 1
            #
            #addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_PREV" "Gray" 40 20 104 200 "" 8 4 "Gold" $False
            #addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 111 202 1
            
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
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20) 1
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER02"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) (19 + $old_x * 20) (39 + $old_y * 20) 1
            
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
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) (18 + $old_x * 20) (38 + $old_y * 20) 1
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20) 1
                
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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
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
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$tex_id]]) (18 + $i * 20) (38 + $j * 20) 1
                    }
                }
            }
            
            # initiales markieren
            $old_x = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] / 8)
            $old_y = [math]::floor($global:arrCreateMapOptions["SELECT_LAYER03"] - ($old_x * 8))
            buildButton "Red"  20 20 (16 + $old_x * 20) (36 + $old_y * 20) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]) (19 + $old_x * 20) (39 + $old_y * 20) 1
            
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
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]) (18 + $old_x * 20) (38 + $old_y * 20) 1
            
                # neue markierung malen
                $tmp_i = [math]::floor($iPosX / 20)
                $tmp_j = [math]::floor($iPosY / 20)
                buildButton "Red"  20 20 (16 + $tmp_i * 20) (36 + $tmp_j * 20) $True
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrObjectTextureIDToKey[$texID]]) (19 + $tmp_i * 20) (39 + $tmp_j * 20) 1
                
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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_PLAYER_SELECT" "Transparent" 20 100 16 36 "" 8 4 "Gold" $False

            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220


            $max_tex_id = $arrObjectTextureIDToKey.Length
            for($i = 0; $i -lt 5; $i++)
            {
                buildButton "Gray"  20 20 16 (36 + $i * 20) $False
                addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$i]]) 18 (38 + $i * 20) 1
            }
            
            buildButton "Red"  20 20 16 (36 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 19 (39 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) 1


            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_PLAYER_SELECT"
        {
            $playerID = [math]::floor($iPosY / 20)

            # redraw old selection
            buildButton "Gray"  20 20 16 (36 + $global:arrCreateMapOptions["SELECT_PLAYER"] * 20) $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 18 (38 + $global:arrCreateMapOptions["SELECT_PLAYER"] * 20) 1

            $global:arrCreateMapOptions["SELECT_PLAYER"] = $playerID

            # redraw new selection
            buildButton "Red"  20 20 16 (36 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrPlayerIconsIDToKey[$global:arrCreateMapOptions["SELECT_PLAYER"]]]) 19 (39 + 20 * $global:arrCreateMapOptions["SELECT_PLAYER"]) 1

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
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            buildButton "Gray" 20 20 82 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            buildButton "Gray" 20 20 106 12 $False
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            buildButton "Gray" 20 20 130 12 $True
            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
        
            $pictureBox.Refresh();
        }
        "BTN_BUILDINGS_01"
        {
            $global:arrCreateMapOptions["CLICK_MODE"] = 1;
            $global:arrSettings["BUILDINGS_SELECTED"] = -1

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_BUILDING_02_SELECT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_AMOUNT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_PRODUCTION")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "Economy Buildings" -1 -1 "Gold" $False
            redrawWindowBack "WND_SINGLEPLAYER_MENU" 10 54 140 180

            Write-Host "After Redraw"

            buildButton "Gray" 20 20 10 12 $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14 1

            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14 1

            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WARES"]) 60 14 1

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_BUILDING_01_SELECT" "Transparent" 120 90 10 58 "" 8 4 "Gold" $False

            $offset_text_id = [int]($global:arrSettings["BUILDINGS_MIN"])
            $max_tex_id = [int]($global:arrSettings["BUILDINGS_CIVILS"])

            $offset_text_id = [int]($global:arrSettings["BUILDINGS_MIN"])
            $max_tex_id = $offset_text_id + [int]($global:arrSettings["BUILDINGS_CIVILS"])

            for($i = 0; $i -lt 4; $i++)
            {
                for($j = 0; $j -lt 3; $j++)
                {
                    $tex_id = (($i * 3) + $j) + $offset_text_id
                    
                    Write-Host "TexID is: $tex_id"

                    if($tex_id -lt $max_tex_id)
                    {
                        Write-Host "TexID is: $tex_id"
                        buildButton "Gray"  20 20 (10 + $i * 20 + $i * 18) (58 + $j * 20 + $j * 6) $False
                        addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$tex_id]][0]) (11 + $i * 20 + $i * 18) (59 + $j * 20 + $j * 6) 1
                    }
                }
            }

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 "" -1 -1 "Gold" $False

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_GOLDCOIN"]) 10 158 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WOOD"]) 10 176 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_FOOD"]) 10 194 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_PRODUCTION"]) 10 212 1
        }
        "BTN_BUILDING_01_SELECT"
        {
            $texID = -1

            $ColID = [math]::floor($iPosX / 38)
            $RowID = [math]::floor($iPosY / 26)

            if($iPosX -gt ($ColID * 20 + $ColID * 18) -and $iPosX -lt (20 + $ColID * 20 + $ColID * 18))
            {
                if($iPosY -gt ($RowID * 20 + $RowID * 6) -and $iPosY -lt (20 + $RowID * 20 + $RowID * 6))
                {
                    $texID = $ColID * 3 + $RowID + $global:arrSettings["BUILDINGS_MIN"]
                }
            }

            if($RowID -ge 3) {return;}

            if($texID -eq -1 -or $texID -gt $global:arrSettings["BUILDINGS_CIVILS"])
            {
                return;
            }

            # select new building
            buildButton "Gray"  20 20 (10 + $ColID * 20 + $ColID * 18) (58 + $RowID * 20 + $RowID * 6) $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$texID]][0]) (11 + $ColID * 20 + $ColID * 18) (59 + $RowID * 20 + $RowID * 6) 1

            if(([int]($global:arrSettings["BUILDINGS_SELECTED"])) -gt 0)
            {
                $prevColID = [math]::floor(($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) / 3)
                $prevRowID = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) - 3 *  $prevColID

                $val0 = $global:arrSettings["BUILDINGS_SELECTED"]
                $val1 = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"])
                $val2 = (($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) / 3)

                Write-Host "Vals: $val0 $val1 $val2"

                Write-Host "Prev: $prevColID $prevRowID"

                buildButton "Gray"  20 20 (10 + $prevColID * 20 + $prevColID * 18) (58 + $prevRowID * 20 + $prevRowID * 6) $False
                addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$global:arrSettings["BUILDINGS_SELECTED"]]][0]) (11 + $prevColID * 20 + $prevColID * 18) (59 + $prevRowID * 20 + $prevRowID * 6) 1
            }

            if($texID -eq ([int]($global:arrSettings["BUILDINGS_SELECTED"])))
            {
                $global:arrSettings["BUILDINGS_SELECTED"] = -1
                $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
                addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 "" -1 -1 "Gold" $False

                redrawWindowBack "WND_SINGLEPLAYER_MENU" 30 162 120 62
            }
            else
            {
                $global:arrSettings["BUILDINGS_SELECTED"] = $texID
                $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
                addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 ($global:arrBuilding[$arrBuildingIDToKey[$texID]].Name) -1 -1 "Gold" $False

                redrawWindowBack "WND_SINGLEPLAYER_MENU" 30 162 120 62

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].gold_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].gold_cost)) 30 162 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 162 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].wood_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].wood_cost)) 30 180 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 180 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].food_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].food_cost)) 30 198 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 198 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].production_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].production_cost)) 30 216 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 216 "Red" $False
                }

                if(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 1)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 2)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 3)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 4)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 216 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 5)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 216 "Green" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }

            }

            Write-Host "TextureID: $texID"
        }
        "BTN_BUILDINGS_02"
        {
            $global:arrCreateMapOptions["CLICK_MODE"] = 2;
            $global:arrSettings["BUILDINGS_SELECTED"] = -1

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_BUILDING_01_SELECT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_AMOUNT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_PRODUCTION")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "Military Buildings" -1 -1 "Gold" $False
            redrawWindowBack "WND_SINGLEPLAYER_MENU" 10 54 140 180

            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14 1

            buildButton "Gray" 20 20 34 12 $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14 1

            buildButton "Gray" 20 20 58 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WARES"]) 60 14 1

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_BUILDING_02_SELECT" "Transparent" 120 90 10 58 "" 8 4 "Gold" $False

            $offset_text_id = [int]($global:arrSettings["BUILDINGS_MIN"]) + [int]($global:arrSettings["BUILDINGS_CIVILS"])
            $max_tex_id = $offset_text_id + [int]($global:arrSettings["BUILDINGS_MILITARY"])

            Write-Host "Max Tex ID2 $max_tex_id $offset_text_id"
            for($i = 0; $i -lt 4; $i++)
            {
                for($j = 0; $j -lt 3; $j++)
                {
                    $tex_id = (($i * 3) + $j) + $offset_text_id
                    
                    Write-Host "TexID is: $tex_id " ($max_tex_id - $offset_text_id)

                    if($tex_id -lt $max_tex_id)
                    {
                        Write-Host "TexID is: $tex_id"
                        buildButton "Gray"  20 20 (10 + $i * 20 + $i * 18) (58 + $j * 20 + $j * 6) $False
                        addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$tex_id]][0]) (11 + $i * 20 + $i * 18) (59 + $j * 20 + $j * 6) 1
                    }
                }
            }

            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 "" -1 -1 "Gold" $False

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_GOLDCOIN"]) 10 158 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WOOD"]) 10 176 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_FOOD"]) 10 194 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_PRODUCTION"]) 10 212 1
        }
        "BTN_BUILDING_02_SELECT"
        {
            $texID = -1

            $ColID = [math]::floor($iPosX / 38)
            $RowID = [math]::floor($iPosY / 26)
            if($iPosX -gt ($ColID * 20 + $ColID * 18) -and $iPosX -lt (20 + $ColID * 20 + $ColID * 18))
            {
                if($iPosY -gt ($RowID * 20 + $RowID * 6) -and $iPosY -lt (20 + $RowID * 20 + $RowID * 6))
                {
                    $texID = $ColID * 3 + $RowID + ([int]($global:arrSettings["BUILDINGS_MIN"])) + ([int]($global:arrSettings["BUILDINGS_CIVILS"]))
                }
            }

            if($RowID -ge 3) {return;}

            if($texID -eq -1 -or $texID -gt (([int]($global:arrSettings["BUILDINGS_CIVILS"])) + ([int]($global:arrSettings["BUILDINGS_MILITARY"]))))
            {
                return;
            }

            Write-Host "TexID: " $texID

            # select new building
            buildButton "Gray"  20 20 (10 + $ColID * 20 + $ColID * 18) (58 + $RowID * 20 + $RowID * 6) $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$texID]][0]) (11 + $ColID * 20 + $ColID * 18) (59 + $RowID * 20 + $RowID * 6) 1

            if(([int]($global:arrSettings["BUILDINGS_SELECTED"])) -gt 0)
            {
                $prevColID = [math]::floor(($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"] - $global:arrSettings["BUILDINGS_CIVILS"]) / 3)
                $prevRowID = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"] - $global:arrSettings["BUILDINGS_CIVILS"]) - 3 *  $prevColID

                $val0 = $global:arrSettings["BUILDINGS_SELECTED"]
                $val1 = ($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"])
                $val2 = (($global:arrSettings["BUILDINGS_SELECTED"] - $global:arrSettings["BUILDINGS_MIN"]) / 3)

                Write-Host "Vals: $val0 $val1 $val2"

                Write-Host "Prev: $prevColID $prevRowID"

                buildButton "Gray"  20 20 (10 + $prevColID * 20 + $prevColID * 18) (58 + $prevRowID * 20 + $prevRowID * 6) $False
                addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrBuilding[$arrBuildingIDToKey[$global:arrSettings["BUILDINGS_SELECTED"]]][0]) (11 + $prevColID * 20 + $prevColID * 18) (59 + $prevRowID * 20 + $prevRowID * 6) 1
            }

            if($texID -eq ([int]($global:arrSettings["BUILDINGS_SELECTED"])))
            {
                $global:arrSettings["BUILDINGS_SELECTED"] = -1
                $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
                addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 "" -1 -1 "Gold" $False

                redrawWindowBack "WND_SINGLEPLAYER_MENU" 30 162 120 62
            }
            else
            {
                $global:arrSettings["BUILDINGS_SELECTED"] = $texID
                $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
                addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT2" "Gray" 136 20 10 134 ($global:arrBuilding[$arrBuildingIDToKey[$texID]].Name) -1 -1 "Gold" $False

                redrawWindowBack "WND_SINGLEPLAYER_MENU" 30 162 120 62

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].gold_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].gold_cost)) 30 162 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 162 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].wood_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].wood_cost)) 30 180 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 180 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].food_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].food_cost)) 30 198 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 198 "Red" $False
                }

                if(([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].production_cost)) -ne "")
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].production_cost)) 30 216 "Red" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 30 216 "Red" $False
                }

                if(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 1)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 2)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 3)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 4)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 216 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $Falsef
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                }
                elseif(($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionType) -eq 5)
                {
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" ([string]($global:arrBuilding[$arrBuildingIDToKey[$texID]].productionAmount)) 60 216 "Green" $False
                }
                else
                {
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 162 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 180 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 198 "Green" $False
                    addText "WND_SINGLEPLAYER_MENU" "-" 60 216 "Green" $False
                }
            }

            $objForm.Refresh()
            Write-Host "TextureID: $texID"
        }
        "BTN_WARES"
        {
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_BUILDING_01_SELECT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_BUILDING_02_SELECT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT2")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_AMOUNT")
            $global:arrWindows["WND_SINGLEPLAYER_MENU"].btn.Remove("BTN_DUMMY_TEXT_PRODUCTION")
            redrawWindowBack "WND_SINGLEPLAYER_MENU" 10 54 140 180

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "Wares Overview" -1 -1 "Gold" $False
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT_AMOUNT" "Gray" 50 20 46 54 "Amount" -1 -1 "Gold" $False
            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_DUMMY_TEXT_PRODUCTION" "Gray" 50 20 96 54 "Prod." -1 -1 "Gold" $False
            
            buildButton "Gray" 20 20 10 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_01"]) 12 14 1

            buildButton "Gray" 20 20 34 12 $False
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_BUILDING_02"]) 36 14 1

            buildButton "Gray" 20 20 58 12 $True
            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WARES"]) 60 14 1

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_GOLDCOIN"]) 10 76 1
            addColoredArea "WND_SINGLEPLAYER_MENU" 30 76 8 16 ($global:arrColors["CLR_PLAYER_11"])
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][6]) 50 80 "Gold" $False
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][1]) 100 80 "Gold" $False

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_WOOD"]) 10 94 1
            addColoredArea "WND_SINGLEPLAYER_MENU" 30 94 8 16 ($global:arrColors["CLR_PLAYER_21"])
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][7]) 50 98 "Gold" $False
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][2]) 100 98 "Gold" $False

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_FOOD"]) 10 112 1
            addColoredArea "WND_SINGLEPLAYER_MENU" 30 112 8 16 ($global:arrColors["CLR_PLAYER_31"])
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][8]) 50 116 "Gold" $False
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][3]) 100 116 "Gold" $False

            addImageToWindow "WND_SINGLEPLAYER_MENU" ($global:arrIcons["ICON_PRODUCTION"]) 10 130 1
            addColoredArea "WND_SINGLEPLAYER_MENU" 30 130 8 16 ($global:arrColors["CLR_PLAYER_41"])
            #addText "WND_SINGLEPLAYER_MENU" "5000" 50 130 "Gold" $False
            addText "WND_SINGLEPLAYER_MENU" ($global:arrPlayerInfo[($global:arrPlayerInfo.currentplayer)][4]) 100 134 "Gold" $False
        }
        "BTN_TILEINFO_QUIT"
        {
            $global:strGameState = "SINGLEPLAYER_INGAME"
            showWindow "WND_SINGLEPLAYER_MENU"
        }
        "BTN_TILEINFO_BURN_BUILDING"
        {
            destroySelectedBuilding
            $global:strGameState = "SINGLEPLAYER_INGAME"
            showWindow "WND_SINGLEPLAYER_MENU"
        }
        "BTN_EDITMAPNAME"
        {
            $global:strGameState = "INPUT_MAPNAME"
        }
        "BTN_EDITMAPAUTHOR"
        {
            $global:strGameState = "INPUT_MAPAUTHOR"
        }
        "BTN_END_TURN"
        {
            handleEndTurnPlayer
            # fake click so stats get updated
            handleButtonKlick "BTN_WARES"
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
            addButtonToWindow $strType "BTN_SINGLEPLAYER" "Gray" 136 20 12 14 "Singleplayer" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_MULTIPLAYER" "Gray" 136 20 12 40 "Multiplayer" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR" "Gray" 136 20 12 66 "Editor" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_OPTIONS" "Gray" 136 20 12 92 "Options" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREDITS" "Gray" 136 20 12 118 "Credits" -1 -1 "Gold" $False
            
            addText $strType ("v" + $global:VersionInfo[0] + "." + $global:VersionInfo[1] + "." + $global:VersionInfo[2] + " - " + $global:VersionInfo[3]) 12 148 "Gold" $False

            addButtonToWindow $strType "BTN_QUIT" "Red" 136 20 12 166 "Quit" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_MAIN"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Really quit?" 12 12 "Gold" $False
            addButtonToWindow $strType "BTN_QUIT_YES" "Red" 60 20 12 56 "Yes" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_QUIT_NO" "Green" 60 20 88 56 "No" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_CREDITS"
        {
            Write-Host "Building window: $strType"
            buildWindow 310 200 (($DrawingSizeX - 310) / 2) (($DrawingSizeY - 200) / 2) $strType
            addText $strType "Written by:" 10 10 "Gold" $False
            addText $strType "Spikeone" 10 22 "Gold" $False
            addText $strType "Story by:" 10 40 "Gold" $False
            addText $strType "-" 10 52 "Gold" $False
            addText $strType "Graphics by:" 10 70 "Gold" $False
            addText $strType "Andre Mari Coppola" 10 82 "Gold" $False
            addText $strType "Music By:" 10 100 "Gold" $False
            addText $strType "Ted" 10 112 "Gold" $False
            addButtonToWindow $strType "BTN_CREDITS_BACK" "Gray" 136 20 87 156 "Back" -1 -1 "Gold" $False
        }
        "WND_GAME_OPTIONS"
        {
            buildWindow 360 220 (($DrawingSizeX - 360) / 2) (($DrawingSizeY - 220) / 2) $strType
            addText $strType "Topmost:" 12 20 "Gold" $False
            addSwitchButtonToWindow $strType "BTN_SWITCH_TOPMOST" ($global:arrSettings["TOPMOST"]) 60 20 240 12 $True $False
            
            addText $strType "Startup Screensize:" 12 44 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_SCREENSIZE" 20 20 240 36 3 ([int]$global:arrSettings["STARTUPSIZE"]) $False
            
            addText $strType "Volume Music (0 = off):" 12 68 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_VOLUMEMUSIC" 20 20 240 60 5 ($global:arrSettings["VOLUMEMUSIC"] / 0.025 + 1) $False
            
            addText $strType "Volume Effects (0 = off):" 12 92 "Gold" $False
            addCountButtonToWindow $strType "BTN_WND_GAME_OPTIONS_VOLUMEEFFECTS" 20 20 240 84 5 ($global:arrSettings["VOLUMEEFFECTS"] / 0.025 + 1) $False
            
            addText $strType "Player face:" 12 116 "Gold" $False
            addButtonToWindow $strType "BTN_GAME_OPTIONS_FACE_SUB" "Gray" 20 20 240 108 "" 48 4 "Gold" $False
            addButtonToWindow $strType "BTN_GAME_OPTIONS_FACE_ADD" "Gray" 20 20 300 108 "" 48 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 242 110 1
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 302 110 1

            addImageToWindow $strType ($global:arrTextures[(nameToId "FACE_" $global:arrSettings["PLAYER_FACE"])]) 270 110 1

            addButtonToWindow $strType "BTN_GAME_OPTIONS_BACK" "Gray" 136 20 112 176 "Back" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_RTFM"
        {
            buildWindow 360 220 (($DrawingSizeX - 360) / 2) (($DrawingSizeY - 220) / 2) $strType

            addText $strType "        ________________"   100 20  "Gold" $False 
            addText $strType "       /                /)" 100 28  "Gold" $False
            addText $strType "   ___/_____ ___ __  __/ )" 100 36  "Gold" $False
            addText $strType "  | _ \_   _| __|  \/  | )" 100 44  "Gold" $False
            addText $strType "  |   / | | | _|| |\/| |/"  100 52  "Gold" $False
            addText $strType "  |_|_\ |_| |_| |_| /|_|"   100 60  "Gold" $False
            addText $strType "  /                /  /"    100 68  "Gold" $False
            addText $strType " /                /  /"     100 76  "Gold" $False
            addText $strType "/_______________ /  /"      100 84  "Gold" $False
            addText $strType ")_______________)  /"       100 92  "Gold" $False
            addText $strType ")_______________) /"        100 100 "Gold" $False
            addText $strType ")_______________)/"         100 108 "Gold" $False

            addButtonToWindow $strType "BTN_GAME_OPTIONS_BACK" "Gray" 136 20 112 176 "Back" -1 -1 "Gold" $False
        }
        "WND_ERROR_NOLOCALPLAYER"
        {
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Missing local player!" 10 10 "Gold" $False
            addText $strType "Can't start game..." 10 22 "Gold" $False
            addButtonToWindow $strType "BTN_ERROR_OK_SINGLEPLAYER_SETUP" "Gray" 136 20 12 56 "Ok" -1 -1 "Gold" $False
        }
        "WND_ERROR_HASOPENSLOTS"
        {
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Still open slots!" 10 10 "Gold" $False
            addText $strType "Can't start game..." 10 22 "Gold" $False
            addButtonToWindow $strType "BTN_ERROR_OK_SINGLEPLAYER_SETUP" "Gray" 136 20 12 56 "Ok" -1 -1 "Gold" $False
        }
        "WND_ERROR_NOTIMPLEMENTED"
        {
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Sorry! Not" 10 10 "Gold" $False
            addText $strType "implemented..." 10 22 "Gold" $False
            addButtonToWindow $strType "BTN_ERROR_NOTIMPLEMENTED_BACK" "Gray" 136 20 12 56 "Back" -1 -1 "Gold" $False
        }
        "WND_PLEASE_WAIT"
        {
            buildWindow 160 40 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 40) / 2) $strType
            addText $strType "Please wait!" 38 10 "Gold" $False
            addText $strType "Working..." 38 22 "Gold" $False
            $objForm.Refresh();
        }
        "WND_SINGLEPLAYER_SETUP"
        {
            buildWindow 440 230 (($DrawingSizeX - 440) / 2) (($DrawingSizeY - 230) / 2) $strType
            addText $strType "Map:" 12 16 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 338 20 90 12 "Open Map..." 6 6 "Gold" $False
            
            addText $strType "Players:" 12 46 "Gold" $False
            
            addText $strType "Author:" 12 76 "Gold" $False
            
            addText $strType "Size:" 12 106 "Gold" $False

            addText $strType "Preview:" 12 136 "Gold" $False

            addButtonToWindow $strType "BTN_ERROR_NOTIMPLEMENTED_BACK" "Red" 136 20 12 198 "Back" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_START" "Green" 136 20 292 198 "Start" -1 -1 "Gold" $False

            $global:arrSettingsInternal["PLAYERTYPE_MAX"] = 3;
        }
        "WND_SINGLEPLAYER_TYPESELECTION"
        {
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow $strType "BTN_CAMPAIGN" "Gray" 136 20 12 14 "Campaign" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_FREEPLAY" "Gray" 136 20 12 40 "Freeplay" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_TUTORIAL" "Gray" 136 20 12 66 "Tutorial" -1 -1 "Gold" $False
            
            addButtonToWindow $strType "BTN_SINGLEPLAYER_TYPESELECTION_BACK" "Red" 136 20 12 166 "Back" -1 -1 "Gold" $False
        }
        "WND_CREATE_MAP"
        {
            buildWindow 310 200 (($DrawingSizeX - 310) / 2) (($DrawingSizeY - 200) / 2) $strType
            
            $global:arrCreateMapOptions["WIDTH"] = 32;
            $global:arrCreateMapOptions["HEIGHT"] = 32;

            addText $strType "Width:" 12 15 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD01" "Gray" 30 20 140 12 "+16" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD02" "Gray" 30 20 170 12 "+ 2" -1 -1 "Gold" $False
            try {$global:arrWindows[$strType].btn.Remove("BTN_CREATEMAP_WIDTH")} catch{}
            addButtonToWindow $strType "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 ([string]($global:arrCreateMapOptions["WIDTH"])) -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB01" "Gray" 30 20 240 12 "- 2" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB02" "Gray" 30 20 270 12 "-16" -1 -1 "Gold" $False
            
            addText $strType "Height:" 12 45 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD01" "Gray" 30 20 140 42 "+16" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD02" "Gray" 30 20 170 42 "+ 2" -1 -1 "Gold" $False
            try {$global:arrWindows[$strType].btn.Remove("BTN_CREATEMAP_HEIGHT")} catch{}
            addButtonToWindow $strType "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 ([string]($global:arrCreateMapOptions["HEIGHT"])) -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB01" "Gray" 30 20 240 42 "- 2" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB02" "Gray" 30 20 270 42 "-16" -1 -1 "Gold" $False
            
            addText $strType "Basetexture:" 12 75 "Gold" $False

            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_PREV" "Gray" 30 20 170 72 "" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_NEXT" "Gray" 30 20 240 72 "" -1 -1 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_LEFT"]) 177 74 1
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 247 74 1
            
            addImageToWindow $strType ($global:arrTextures[$arrBaseTextureIDToKey[0]]) 210 74 1
            
            addButtonToWindow $strType "BTN_CREATE_MAP_CANCEL" "Red" 88 20 12 166 "Cancel" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATE_MAP_LOAD" "Gray" 88 20 111 166 "Load..." -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_CREATE_MAP_CONTINUE" "Green" 88 20 210 166 "Continue" -1 -1 "Gold" $False
        }
        "WND_ESC_EDITOR"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow $strType "BTN_EDITOR_SAVEMAP" "Gray" 136 20 12 14 "Save map" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR_SAVEIMAGE" "Gray" 136 20 12 40 "Save image" -1 -1 "Gold" $False
            
            addColoredArea $strType 12 66 136 20 ($global:arrColors["CLR_BLACK"])
            addText $strType $global:arrMap["MAPNAME"] 14 70 "Gold" $False
            addButtonToWindow $strType "BTN_EDITMAPNAME" "Transparent" 136 20 12 66 "" 8 4 "Gold" $False

            addColoredArea $strType 12 92 136 20 ($global:arrColors["CLR_BLACK"])
            addText $strType $global:arrMap["AUTHOR"] 14 96 "Gold" $False
            addButtonToWindow $strType "BTN_EDITMAPAUTHOR" "Transparent" 136 20 12 92 "" 8 4 "Gold" $False

            addButtonToWindow $strType "BTN_EDITOR_QUIT" "Red" 136 20 12 166 "Quit" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_TILEINFO"
        {
            buildWindow 160 270 ($DrawingSizeX - 160) 0 $strType

            addButtonToWindow $strType "BTN_TILEINFO_QUIT" "Red" 136 20 12 238 "Close" -1 -1 "Gold" $False

            addButtonToWindow "WND_SINGLEPLAYER_MENU" "BTN_NEXT_UNIT" "Gray" 64 20 8 238 "" -1 -1 "Gold" $False
        }
        "WND_ESC_SINGLEPLAYER"
        {
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType

            addButtonToWindow $strType "BTN_SINGLEPLAYER_QUIT" "Red" 136 20 12 166 "Quit" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_SINGLEPLAYER"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Really quit?" 12 12 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_QUIT_YES" "Red" 60 20 12 56 "Yes" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_QUIT_NO" "Green" 60 20 88 56 "No" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_EDITOR"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $strType "Really quit?" 12 12 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR_QUIT_YES" "Red" 60 20 12 56 "Yes" -1 -1 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR_QUIT_NO" "Green" 60 20 88 56 "No" -1 -1 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_INTERFACE_EDITOR"
        {
            buildWindow 160 270 ($DrawingSizeX - 160) 0 $strType
            addButtonToWindow $strType "BTN_IFE_EDIT_LAYER01" "Gray" 20 20 10 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_01"]) 12 14 1
            
            addButtonToWindow $strType "BTN_IFE_EDIT_LAYER02" "Gray" 20 20 34 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_02"]) 36 14 1
            
            addButtonToWindow $strType "BTN_IFE_EDIT_LAYER03" "Gray" 20 20 58 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_03"]) 60 14 1
        
            addButtonToWindow $strType "BTN_IFE_EDIT_DIRECTIONS" "Gray" 20 20 82 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_DIRECTION"]) 84 14 1
        
            addButtonToWindow $strType "BTN_IFE_EDIT_PLAYER" "Gray" 20 20 106 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_PLAYER"]) 108 14 1
            
            addButtonToWindow $strType "BTN_IFE_EDIT_LAYERSETTINGS" "Gray" 20 20 130 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_LAYER_SETTINGS"]) 132 14 1
        
            $pictureBox.Refresh();
        }

        "WND_SINGLEPLAYER_MENU"
        {

            buildWindow 160 270 ($DrawingSizeX - 160) 0 $strType
            addButtonToWindow $strType "BTN_BUILDINGS_01" "Gray" 20 20 10 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_BUILDING_01"]) 12 14 1

            addButtonToWindow $strType "BTN_BUILDINGS_02" "Gray" 20 20 34 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_BUILDING_02"]) 36 14 1

            addButtonToWindow $strType "BTN_WARES" "Gray" 20 20 58 12 "" 8 4 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_WARES"]) 60 14 1
            
            addButtonToWindow $strType "BTN_DUMMY_TEXT" "Gray" 136 20 10 34 "---" -1 -1 "Gold" $False

            addButtonToWindow $strType "BTN_END_TURN" "Gray" 64 20 88 238 "" -1 -1 "Gold" $False
            addImageToWindow $strType ($global:arrIcons["ICON_HOURGLAS"]) 100 240 1
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 114 240 1
            addImageToWindow $strType ($global:arrIcons["ICON_ARROW_GOLD_RIGHT"]) 128 240 1

            addButtonToWindow $strType "BTN_NEXT_UNIT" "Gray" 64 20 8 238 "" -1 -1 "Gold" $False
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
    if(!$global:arrWindows[$strWindow].btn)
    {
        # window has no buttons, create array and button
        $global:arrWindows[$strWindow].btn = @{}
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    elseif(!$global:arrWindows[$strWindow].btn[$strName])
    {
        # new button
        $global:arrWindows[$strWindow].btn[$strName] = @{}
    }
    else
    {
        # nothing new
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
        if($i -eq [int]($iActive - 1))
        {
            buildButton "Gray" $iSizeX $iSizeY ($iPosX + $i * $iSizeX) $iPosY $True
        }
        else
        {
            buildButton "Gray" $iSizeX $iSizeY ($iPosX + $i * $iSizeX) $iPosY $False
        }
        addText $strWindow ([string]$i) ($iPosX + 6 + $i * $iSizeX) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
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
            addText $global:strCurrentWindow "0" ($iPosX - 4 + $iSizeX / 4) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
        }
        else
        {
            addText $global:strCurrentWindow "1" ($iPosX - 4 + 3 * $iSizeX / 4) ($iPosY + 1 + ($iSizeY - 12) / 2) "Gold" $doOutline
        }
        
    }
    
    $objForm.Refresh();
}

function addImageToWindow($strWindow, $objImage, $iPosX, $iPosy, $scale)
{
    Write-Host "addImageToWindow: Adding image to window"

    Write-Host "Window: " $strWindow
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($scale -le 0)
    {
        Write-Host "addImageToWindow: Invalid scale"
        Write-Host "$scale"
        return;
    }

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

    $rect_src = New-Object System.Drawing.Rectangle(0, 0, $size_x_i, $size_y_i)
    $rect_dst = New-Object System.Drawing.Rectangle($iPosX, $iPosy, ($size_x_i * $scale), ($size_y_i * $scale))
    
    $objImage.MakeTransparent($global:arrColors["CLR_MAGENTA"]);

    $global:arrWindows[$strWindow].graphics.DrawImage($objImage, $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
}

function addColoredArea($strWindow, $iPosX, $iPosy, $iSizeX, $iSizeY, $color)
{
    Write-Host "addColoredArea: Adding image to window"
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($size_x_w -lt ($size_x_i + $iPosX))
    {
        Write-Host "addColoredArea: Image outside of window (x)"
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

function handleSingleplayerPlayerButton($iID)
{
    Write-Host "handleSingleplayerPlayerButton($iID)"

    if($iID -gt (getPlayerCount)) {return}

    # we can actually switch
    Write-Host "switch $iID"

    Write-Host "Max: " $global:arrSettingsInternal["PLAYERTYPE_MAX"]

    $global:arrPlayerInfo[$iID][5] = ($global:arrPlayerInfo[$iID][5] + 1)

    $btnColor = "Gray"

    if($global:arrPlayerInfo[$iID][5] -gt $global:arrSettingsInternal["PLAYERTYPE_MAX"])
    {
        $global:arrPlayerInfo[$iID][5] = 0
        $btnColor = "Red"
    }

    $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove(("BTN_SINGLEPLAYER_SETUP_P" + $iID))
    addButtonToWindow "WND_SINGLEPLAYER_SETUP" ("BTN_SINGLEPLAYER_SETUP_P" + $iID) $btnColor 100 20 270 (46 + (($iID - 1) * 30)) ($global:arrPlayertypeIndexString[($global:arrPlayerInfo[$iID][5])]) 6 6 "Gold" $False

}

function redrawWindowBack($strWindow, $iPosX, $iPosy, $iSizeX, $iSizeY)
{
    Write-Host "redrawWindowBack: Adding image to window"
    
    $size_x_w = $global:arrWindows[$strWindow].wnd.Width;
    $size_y_w = $global:arrWindows[$strWindow].wnd.Height;
    
    $size_x_i = $objImage.Width;
    $size_y_i = $objImage.Height;
    
    if($size_x_w -lt ($size_x_i + $iPosX))
    {
        Write-Host "redrawWindowBack: Image outside of window (x)"
        Write-Host "$iPosX $iPosy"
        return;
    }
    
    if($size_y_w -lt ($size_y_i + $iPosy))
    {
        Write-Host "redrawWindowBack: Image outside of window (y)"
        Write-Host "$iPosX $iPosy"
        return;
    }

    $arrBack = New-Object 'object[,]' $global:arrSettings["TILESIZE"],$global:arrSettings["TILESIZE"]
    
    for($i = 0; $i -lt $global:arrSettings["TILESIZE"]; $i++)
    {
        for($j = 0; $j -lt $global:arrSettings["TILESIZE"]; $j++)
        {
            $arrBack[$i,$j] = $global:arrInterface["TEX_BACK_GREEN_NOISE"].getPixel($i, $j)
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
                    $tmp_grd.DrawImage($global:arrInterface["TEX_RED_DARK"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
                "Green"
                {
                    $tmp_grd.DrawImage($global:arrInterface["TEX_GREEN_DARK"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
                default
                {
                    $tmp_grd.DrawImage($global:arrInterface["TEX_GRAY_DARK"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
                }
            }
        }
    }
    
    $objBackTex = $global:arrInterface["TEX_GRAY_LIGHT"]
    switch($strBtnColor)
    {
        "Red"
        {
            $objBackTex = $global:arrInterface["TEX_RED_LIGHT"]
        }
        "Green"
        {
            $objBackTex = $global:arrInterface["TEX_GREEN_LIGHT"]
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
                
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY + $i - 2), $objBackTex.GetPixel($posx, $posy));

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
                
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $objBackTex.GetPixel($posx, $posy));

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
                
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $i), $objBackTex.GetPixel($posx, $posy));
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
                
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $objBackTex.GetPixel($posx, $posy));

            }
            
        }
    }
}

function addBarToWindow($strWindow, $iSizeX, $iSizeY, $iPosX, $iPosY, $strText, $fPercent, $clrBar)
{
    buildButton "Gray" $iSizeX $iSizeY $iPosX $iPosY $True
    
    $iTextX = [int](($iSizeX - ($strText.Length * 7)) / 2)
    $iTextY = [int](($iSizeY - 7) / 2)

    $length = [math]::floor((([int]($iSizeX)) - 8) * $fPercent)

    Write-Host "Lenght: $length $fPercent"

    $rect = New-Object System.Drawing.Rectangle((4 + $iPosX), (4 + $iPosY), ($length), ($iSizeY - 8))
    $tmp_grd = [System.Drawing.Graphics]::FromImage($global:arrWindows[$strWindow].wnd);

    $brush = New-Object System.Drawing.SolidBrush($clrBar)
    $tmp_grd.FillRectangle($brush, $rect)
    
    addText $strWindow $strText ($iPosX + $iTextX) ($iPosY + $iTextY) "Gold" $False
    $objForm.Refresh();
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

    addText $global:strCurrentWindow $strText ($iPosX + $iTextX) ($iPosY + $iTextY) $strColor $doOutline
    $objForm.Refresh();
}

function setCharColor($strChar, $strColor, $doOutline)
{
    if ($strChar -eq "") {return}

    if (!$arrFont[$strChar]) {return}

    for($i = 0; $i -lt $arrFont[$strChar].Width; $i++)
    {
        for($j = 0; $j -lt $arrFont[$strChar].Height; $j++)
        {
            if($arrFont[$strChar].GetPixel($i, $j).A -gt 0 -and $arrFont[$strChar].GetPixel($i, $j) -ne $global:arrColors["CLR_MAGENTA"] -and (($arrFont[$strChar].GetPixel($i, $j) -ne ($global:arrColors["CLR_BLACK"])) -or ($doOutline -and $arrFont[$strChar].GetPixel($i, $j) -eq ($global:arrColors["CLR_BLACK"]))))
            {
                $tmpClr = $arrFont[$strChar].GetPixel($i, $j)

                switch($strColor)
                {
                    "Gold" {$tmpClr = $global:arrColors["CLR_GOLD_1"]}
                    "Red" {$tmpClr = $global:arrColors["CLR_RED"]}
                    "Gray" {$tmpClr = $global:arrColors["CLR_GRAY"]}
                    "Green" {$tmpClr = $global:arrColors["CLR_GREEN"]}
                    default {$tmpClr = $arrFont[$strChar].GetPixel($i, $j)}
                }

                $arrFont[$strChar].SetPixel($i, $j, $tmpClr)
            }
        }
    }
}

function addText($strWindow, $strText, $iPosX, $iPosY, $strColor, $doOutline)
{
    $strText = ([string]$strText)

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

        # char not in array? use '?'
        if(!$arrFont[$tempChar])
        {
            $tempChar = "?"
        }

        $rect_src = New-Object System.Drawing.Rectangle(0, 0, ($arrFont[$tempChar].Width), ($arrFont[$tempChar].Height))
        $rect_dst = New-Object System.Drawing.Rectangle(($iPosX + $offset_x), $iPosy, ($arrFont[$tempChar].Width), $sizeY)
        
        $arrFont[$tempChar].MakeTransparent($global:arrColors["CLR_MAGENTA"]);
        setCharColor $tempChar $strColor $doOutline

        $global:arrWindows[$strWindow].graphics.DrawImage($arrFont[$tempChar], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);

        $global:arrWindows[$strWindow].graphics.DrawImage

        $offset_x = $offset_x + $arrFont[$tempChar].Width
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
    $tmp_grd.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $tmp_grd.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $rect_src = New-Object System.Drawing.Rectangle(0, 0, 16, 16)
    for($i = 0; $i -lt ([int]($max_size_x / $global:arrSettings["TILESIZE"]) + 1); $i++)
    {
        for($j = 0; $j -lt ([int]($max_size_y / $global:arrSettings["TILESIZE"]) + 1); $j++)
        {
            
            $rect_dst = New-Object System.Drawing.Rectangle(($i * 16), ($j * 16), 16, 16)

            
        
            $tmp_grd.DrawImage($global:arrInterface["TEX_BACK_GREEN_NOISE"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);
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
            $tmp_wnd.SetPixel($i, ($j + 1), $global:arrInterface["MENU_SIDE_VERT"].GetPixel($posx, (5 - $j)));
            # bottom
            $tmp_wnd.SetPixel($i, ($j + $offset_y), $global:arrInterface["MENU_SIDE_VERT"].GetPixel($posx, $j));
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
            $tmp_wnd.SetPixel(($i + $offset_x), $j, $global:arrInterface["MENU_SIDE_HOR"].GetPixel($i, $posy));
            # right
            $tmp_wnd.SetPixel(($iSizeX - $offset_x - $i - 1), $j, $global:arrInterface["MENU_SIDE_HOR"].GetPixel($i, $posy));
        }
    }
    
    # corners
    # stays the same
    $rect_src = New-Object System.Drawing.Rectangle(0, 0, 8, 8)

    # changes
    $rect_dst = New-Object System.Drawing.Rectangle(1, 1, 8, 8)
    $tmp_grd.DrawImage($global:arrInterface["MENU_CORNER"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);

    $rect_dst = New-Object System.Drawing.Rectangle(1, ($iSizeY - 1 - 8), 8, 8)
    $tmp_grd.DrawImage($global:arrInterface["MENU_CORNER"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);

    $rect_dst = New-Object System.Drawing.Rectangle(($iSizeX - 1 - 8), 1, 8, 8)
    $tmp_grd.DrawImage($global:arrInterface["MENU_CORNER"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);

    $rect_dst = New-Object System.Drawing.Rectangle(($iSizeX - 1 - 8), ($iSizeY - 1 - 8), 8, 8)
    $tmp_grd.DrawImage($global:arrInterface["MENU_CORNER"], $rect_dst, $rect_src, [System.Drawing.GraphicsUnit]::Pixel);

    $global:arrWindows[$strWindow] = @{}
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
    
    if($global:strGameState -eq "EDIT_MAP" -or $global:strGameState -eq "EDIT_MAP_ESCAPE" -or $global:strGameState -eq "INPUT_MAPNAME" -or $global:strGameState -eq "INPUT_MAPAUTHOR" -or $global:strGameState -eq "SINGLEPLAYER_INGAME" -or $global:strGameState -eq "SINGLEPLAYER_TILEINFO")
    {
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
                $EventArgs.Graphics.DrawImage(($global:arrTextures[$arrObjectTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER03"]]]), $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
            }
            else
            {
                $global:arrCreateMapOptions["SHOW_PREVIEW"] = $False
            }
        }
        else
        {
            if([int]$global:arrSettings["BUILDINGS_SELECTED"] -ne -1)
            {
                $hovering_X = ($offset_curx/(([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )))* $global:arrSettings["TILESIZE"]))
                $hovering_Y = ($offset_cury/(([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )))* $global:arrSettings["TILESIZE"]))

                $hoovering_off_x = ($offset_x/ $global:arrSettings["TILESIZE"])
                $hoovering_off_y = ($offset_y/ $global:arrSettings["TILESIZE"])

                $hovering_X += $hoovering_off_x
                $hovering_Y += $hoovering_off_y


                # check if the currently hoovered tile is the same
                if([int]$global:arrSettingsInternal["HOOVER_X"] -ne $hovering_X -or [int]$global:arrSettingsInternal["HOOVER_Y"] -ne $hovering_Y -and $hovering_X -gt 1 -and $hovering_Y -gt 1 -and $hovering_X -lt ([int]$arrCreateMapOptions["WIDTH"] + 2) -and $hovering_Y -lt ([int]$arrCreateMapOptions["HEIGHT"] + 2))
                {
                    $global:arrSettingsInternal["HOOVER_X"] = $hovering_X
                    $global:arrSettingsInternal["HOOVER_Y"] = $hovering_Y

                    $global:arrSettingsInternal["HOOVER_CANBUILD"] = checkIfBuildingPossible ([int]($global:arrSettings["BUILDINGS_SELECTED"])) ([int]($global:arrSettingsInternal["HOOVER_X"] - 2)) ([int]($global:arrSettingsInternal["HOOVER_Y"] - 2)) ($global:arrPlayerInfo.currentPlayer)
                }
                elseif($hovering_X -lt 2 -or $hovering_Y -lt 2 -or $hovering_X -ge ([int]$arrCreateMapOptions["WIDTH"] + 2) -or $hovering_Y -ge ([int]$arrCreateMapOptions["HEIGHT"] + 2))
                {
                    $global:arrSettingsInternal["HOOVER_CANBUILD"] = $False
                    $global:arrSettingsInternal["HOOVER_X"] = -1
                    $global:arrSettingsInternal["HOOVER_Y"] = -1
                }

                if($global:arrSettingsInternal["HOOVER_CANBUILD"])
                {
                    $EventArgs.Graphics.DrawImage($global:arrInterface["SELECTION_TILE_VALID"], $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
                }
                else
                {
                    $EventArgs.Graphics.DrawImage($global:arrInterface["SELECTION_TILE_INVALID"], $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
                }
            }
            else
            {
                $EventArgs.Graphics.DrawImage($global:arrInterface["SELECTION_TILE_RED"], $rect_cur, 0, 0, $global:arrSettings["TILESIZE"], $global:arrSettings["TILESIZE"], [System.Drawing.GraphicsUnit]::Pixel)
            }
        }
    }
    else
    {
        $EventArgs.Graphics.DrawImage($global:bitmap, $rect, 0, 0, $global:bitmap.Width, $global:bitmap.Height, [System.Drawing.GraphicsUnit]::Pixel)
    }
    
    if($global:windowOpen)
    {
        # Position des rects anpassen, fenster soll sich gleichermaßen verschieben
        $rect_wnd = New-Object System.Drawing.Rectangle((([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].loc_x)), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].loc_y), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] -1 )) * $global:arrWindows[$global:strCurrentWindow].wnd.Size.Width), ([math]::pow(2, ([int]$global:arrSettings["SIZE"] - 1 )) * $global:arrWindows[$global:strCurrentWindow].wnd.Size.Height))
        
        $EventArgs.Graphics.DrawImage($global:arrWindows[$global:strCurrentWindow].wnd, $rect_wnd, 0, 0, $global:arrWindows[$global:strCurrentWindow].wnd.Width, $global:arrWindows[$global:strCurrentWindow].wnd.Height, [System.Drawing.GraphicsUnit]::Pixel)

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

function initGame()
{
    Write-Host "Init game"
    loadConfig
    applyConfig
    $global:bitmap = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));
    if([int]$global:arrSettingsInternal["SONGS"] -gt 0){ playSongs }
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

[void] $objForm.ShowDialog()