#http://www.techotopia.com/index.php/Drawing_Graphics_using_PowerShell_1.0_and_GDI%2B

# load forms (GUI)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing.Graphics")
# Mediaplayer
Add-Type -AssemblyName PresentationCore
# Visual Styles
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

# STA Modus (Single Threading Apartment) - benötigt für OpenFileDialog
[threading.thread]::CurrentThread.SetApartmentState(0)

$global:arrWindows = @{}
$global:windowOpen = $False;
$global:strCurrentWindow = "";

$global:arrSettings = @{}
$global:arrSettings["TOPMOST"] = $False;
$global:arrSettings["SIZE"] = 1;
$global:arrSettings["STARTUPSIZE"] = 1;
$global:arrSettings["VOLUMEMUSIC"] = 0.2;
$global:arrSettings["VOLUMEEFFECTS"] = 0.2;

$global:strGameState = "WAIT_INIT_CLICK"
$global:strMapFile = "";

$global:arrCreateMapOptions = @{}
$global:arrCreateMapOptions["WIDTH"] = 32;
$global:arrCreateMapOptions["HEIGHT"] = 32;
$global:arrCreateMapOptions["BASTEXTUREID"] = 0;
$global:arrCreateMapOptions["EDITOR_CHUNK_X"] = 0;
$global:arrCreateMapOptions["EDITOR_CHUNK_Y"] = 0;
$global:arrCreateMapOptions["EDIT_MODE"] = 0;
$global:arrCreateMapOptions["IDX_LAYER01"] = 0;
$global:arrCreateMapOptions["SELECT_LAYER01"] = 0;
$global:arrCreateMapOptions["SELECT_LAYER02"] = 0;

$arrBastextureIDToKey = "GROUND_GREEN_01", "GROUND_GREEN_02", "GROUND_GREEN_03", "GROUND_GREEN_04", "GROUND_WATER_01", "GROUND_NOTHING_01"
$arrOverlayTextureIDToKey = "GROUND_EDGE_01", "GROUND_EDGE_02", "GROUND_EDGE_03", "GROUND_EDGE_04", "GROUND_EDGE_05", "GROUND_EDGE_06", "GROUND_EDGE_07", "GROUND_EDGE_08", "GROUND_EDGE_09", "GROUND_EDGE_10", "GROUND_EDGE_11", "GROUND_EDGE_12", "GROUND_EDGE_13", "GROUND_EDGE_14", "GROUND_EDGE_15", "GROUND_EDGE_16", "PATH_01", "PATH_02", "PATH_03", "PATH_04", "PATH_05", "PATH_06", "PATH_07", "PATH_08", "PATH_09", "PATH_10", "PATH_11", "PATH_12", "PATH_13", "STREET_01", "STREET_02", "STREET_03", "STREET_04", "STREET_05", "STREET_06", "STREET_07", "STREET_08", "STREET_09", "STREET_10", "STREET_11", "STREET_12", "STREET_13", "RIVER_01", "RIVER_02", "RIVER_03", "RIVER_04", "RIVER_05", "RIVER_06", "RIVER_07", "RIVER_08", "RIVER_09", "RIVER_10", "RIVER_11", "RIVER_12", "RIVER_13"
$arrObjectTextureIDToKey = "None"

$strPathTextureGFX = "..\..\DATA\GFX\WORLD\"
$global:arrTextures = @{}
$global:arrTextures["GROUND_GREEN_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_01.png'  ))));
$global:arrTextures["GROUND_GREEN_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_02.png'  ))));
$global:arrTextures["GROUND_GREEN_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_03.png'  ))));
$global:arrTextures["GROUND_GREEN_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_GREEN_04.png'  ))));
$global:arrTextures["GROUND_WATER_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_WATER_01.png'  ))));
$global:arrTextures["GROUND_NOTHING_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathTextureGFX + '.\GROUND_NOTHING_01.png'  ))));

$strPathIconGFX = "..\..\DATA\GFX\ICON\"
$global:arrIcons = @{}
$global:arrIcons["ICON_LAYER_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_01.png'  ))));
$global:arrIcons["ICON_LAYER_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_02.png'  ))));
$global:arrIcons["ICON_LAYER_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_03.png'  ))));
$global:arrIcons["ICON_LAYER_DIRECTION"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_DIRECTION.png'  ))));
$global:arrIcons["ICON_LAYER_PLAYER"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_PLAYER.png'  ))));
$global:arrIcons["ICON_LAYER_SETTINGS"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathIconGFX + 'ICON_LAYER_SETTINGS.png'  ))));

$global:arrTextures["GROUND_EDGE_01"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_01.png' ))));
$global:arrTextures["GROUND_EDGE_02"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_02.png' ))));
$global:arrTextures["GROUND_EDGE_03"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_03.png' ))));
$global:arrTextures["GROUND_EDGE_04"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_04.png' ))));
$global:arrTextures["GROUND_EDGE_05"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_05.png' ))));
$global:arrTextures["GROUND_EDGE_06"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_06.png' ))));
$global:arrTextures["GROUND_EDGE_07"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_07.png' ))));
$global:arrTextures["GROUND_EDGE_08"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_08.png' ))));
$global:arrTextures["GROUND_EDGE_09"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_09.png' ))));
$global:arrTextures["GROUND_EDGE_10"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_10.png' ))));
$global:arrTextures["GROUND_EDGE_11"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_11.png' ))));
$global:arrTextures["GROUND_EDGE_12"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_12.png' ))));
$global:arrTextures["GROUND_EDGE_13"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_13.png' ))));
$global:arrTextures["GROUND_EDGE_14"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_14.png' ))));
$global:arrTextures["GROUND_EDGE_15"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_15.png' ))));
$global:arrTextures["GROUND_EDGE_16"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'GROUND_EDGE_16.png' ))));
$global:arrTextures["PATH_01"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_01.png' ))));
$global:arrTextures["PATH_02"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_02.png' ))));
$global:arrTextures["PATH_03"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_03.png' ))));
$global:arrTextures["PATH_04"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_04.png' ))));
$global:arrTextures["PATH_05"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_05.png' ))));
$global:arrTextures["PATH_06"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_06.png' ))));
$global:arrTextures["PATH_07"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_07.png' ))));
$global:arrTextures["PATH_08"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_08.png' ))));
$global:arrTextures["PATH_09"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_09.png' ))));
$global:arrTextures["PATH_10"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_10.png' ))));
$global:arrTextures["PATH_11"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_11.png' ))));
$global:arrTextures["PATH_12"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_12.png' ))));
$global:arrTextures["PATH_13"]        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'PATH_13.png' ))));
$global:arrTextures["STREET_01"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_01.png' ))));
$global:arrTextures["STREET_02"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_02.png' ))));
$global:arrTextures["STREET_03"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_03.png' ))));
$global:arrTextures["STREET_04"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_04.png' ))));
$global:arrTextures["STREET_05"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_05.png' ))));
$global:arrTextures["STREET_06"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_06.png' ))));
$global:arrTextures["STREET_07"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_07.png' ))));
$global:arrTextures["STREET_08"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_08.png' ))));
$global:arrTextures["STREET_09"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_09.png' ))));
$global:arrTextures["STREET_10"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_10.png' ))));
$global:arrTextures["STREET_11"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_11.png' ))));
$global:arrTextures["STREET_12"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_12.png' ))));
$global:arrTextures["STREET_13"]      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'STREET_13.png' ))));
$global:arrTextures["RIVER_01"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_01.png' ))));
$global:arrTextures["RIVER_02"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_02.png' ))));
$global:arrTextures["RIVER_03"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_03.png' ))));
$global:arrTextures["RIVER_04"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_04.png' ))));
$global:arrTextures["RIVER_05"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_05.png' ))));
$global:arrTextures["RIVER_06"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_06.png' ))));
$global:arrTextures["RIVER_07"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_07.png' ))));
$global:arrTextures["RIVER_08"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_08.png' ))));
$global:arrTextures["RIVER_09"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_09.png' ))));
$global:arrTextures["RIVER_10"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_10.png' ))));
$global:arrTextures["RIVER_11"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_11.png' ))));
$global:arrTextures["RIVER_12"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_12.png' ))));
$global:arrTextures["RIVER_13"]       = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item($strPathTextureGFX + 'RIVER_13.png' ))));

#Music
$strPathMusic = "..\..\DATA\SOUND\MUSIC\"
$file = Get-Item ("..\..\DATA\SOUND\MUSIC\" + "Medieval.mp3")
$global:objMusic001 = New-Object System.Windows.Media.Mediaplayer
$global:objMusic001.Open([uri]($file.FullName))
$global:objMusic001.Volume = $global:arrSettings["VOLUMEMUSIC"];
$global:objMusic001.Add_MediaEnded({
$global:objMusic001.Position = New-TimeSpan -Hour 0 -Minute 0 -Seconds 0
$global:objMusic001.Play();
})

### Arrays ###

$DrawingSizeX	= 480
$DrawingSizeY	= 270
$global:bitmap  = New-Object System.Drawing.Bitmap($DrawingSizeX, $DrawingSizeY);
$black          = [System.Drawing.Color]::FromArgb(0, 0, 0)
$transparent 	= [System.Drawing.Color]::FromArgb(255, 0, 143)

$color_gold     = [System.Drawing.Color]::FromArgb(255, 255, 0)
$color_gold_1   = [System.Drawing.Color]::FromArgb(255, 219, 23)
$color_gold_2   = [System.Drawing.Color]::FromArgb(255, 191, 51)

$color_blue     = [System.Drawing.Color]::FromArgb(0, 211, 247)
$color_blue_1   = [System.Drawing.Color]::FromArgb(0, 123, 219)
$color_blue_2   = [System.Drawing.Color]::FromArgb(0, 55, 191)

# zoomed?
[int]$global:arrSettings["SIZE"] = 1;

$strPathImageGFX = "..\..\DATA\GFX\IMAG\"
$global:objWorld = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_02.png'))));

$global:arrImages = @{}
$global:arrImages["SCREEN_BACK_MAP"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathImageGFX + 'SCREEN_BACK_MAP.png'  ))));



# textures etc.
$strPathToMenuGFX = "..\..\DATA\GFX\MENU\"
$tex_MENU_CORNER        = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\MENU_CORNER.png'          ))));
$tex_MENU_SIDE_VERT     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\MENU_SIDE_VERT.png'       ))));
$tex_MENU_SIDE_HOR      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\MENU_SIDE_HOR.png'        ))));
#$tex_MENU_TEX_BACK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_BACK_GREEN_DARK.bmp'  ))));
$tex_MENU_TEX_BACK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_BACK_GREEN_NOISE.bmp'  ))));
$tex_MENU_GRAY_DARK     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_GRAY_DARK.bmp'        ))));
$tex_MENU_GRAY_LIGHT    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_GRAY_LIGHT.bmp'       ))));
$tex_MENU_RED_DARK      = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_RED_DARK.bmp'         ))));
$tex_MENU_RED_LIGHT     = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_RED_LIGHT.bmp'        ))));
$tex_MENU_GREEN_DARK    = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_GREEN_DARK.bmp'       ))));
$tex_MENU_GREEN_LIGHT   = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToMenuGFX + '.\TEX_GREEN_LIGHT.bmp'      ))));

$strPathToFontGFX = "..\..\DATA\GFX\FONT\"
$arrFont = @{}
$arrFont["!"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '1.bmp'  ))));
$arrFont[""""] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '2.bmp'  ))));
$arrFont["#"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '3.bmp'  ))));
#$arrFont["$"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '4.bmp'  ))));
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
#$arrFont["(C)"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '58.bmp'  ))));
$arrFont["Ä"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '63.bmp'  ))));
$arrFont["Ö"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '64.bmp'  ))));
$arrFont["Ü"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '65.bmp'  ))));
$arrFont["ß"] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '66.bmp'  ))));
$arrFont[" "] = New-Object System.Drawing.Bitmap([System.Drawing.Image]::Fromfile((get-item ($strPathToFontGFX + '67.bmp'  ))));

# Create the form
$objForm = New-Object System.Windows.Forms.Form 
$objForm.minimumSize = New-Object System.Drawing.Size(($DrawingSizeX + 16), ($DrawingSizeY + 36)) 
$objForm.maximumSize = New-Object System.Drawing.Size(($DrawingSizeX + 16), ($DrawingSizeY + 36)) 
$objForm.MaximizeBox = $False;
$objForm.MinimizeBox = $False;
$objForm.Topmost = $global:arrSettings["TOPMOST"]; 
#https://i-msdn.sec.s-msft.com/dynimg/IC24340.jpeg
#$objForm.BackColor = "SlateGray"

$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.SizeMode = 4
$pictureBox.Size = New-Object System.Drawing.Size($DrawingSizeX	, $DrawingSizeY)
$objForm.controls.add($pictureBox)
$objForm.AutoSize = $False
$pictureBox.Add_Click({onMouseClick "Picturebox"})
$objForm.Add_Shown({$objForm.Activate()})
$objForm.Add_Click({})
$pictureBox.Add_Paint({onRedraw $this $_})
$objForm.Add_KeyDown({onKeyPress $this $_})
$objForm.Add_Click({onMouseClick "Form"})
$objForm.Text = "PowerHeroes"
##
## onKeyPress
##

function MAP_changeTile($objImage, $iTileX, $iTileY)
{
    $offset_x = $iTileX * 32
    $offset_y = $iTileY * 32

    for($i = 0; $i -lt 32; $i++)
    {
        for($j = 0; $j -lt 32; $j++)
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
	
	$size_x = $global:arrCreateMapOptions["WIDTH"] + 4;
	$size_y = $global:arrCreateMapOptions["HEIGHT"] + 4;
	
	$global:objWorld = New-Object System.Drawing.Bitmap(($size_x * 32), ($size_y * 32));
	
	$runs = $size_x * $size_y
	$runs5 = [math]::floor($runs * 0.05)
	$runs = $runs5;
	
    $arrImage = New-Object 'object[,]' 32,32
    
    for($i = 0; $i -lt 32; $i++)
    {
        for($j = 0; $j -lt 32; $j++)
        {
            $arrImage[$i,$j] = $global:arrTextures[$arrBastextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]].getPixel($i, $j)
        }
    }
    
    $arrImageNothing = New-Object 'object[,]' 32,32
    
    for($i = 0; $i -lt 32; $i++)
    {
        for($j = 0; $j -lt 32; $j++)
        {
            $arrImageNothing[$i,$j] = $global:arrTextures["GROUND_NOTHING_01"].getPixel($i, $j)
        }
    }
    
    
	for($i = 0; $i -lt $size_x; $i++)
	{
		for($j = 0; $j -lt $size_y; $j++)
		{
			$offset_x = (32 * $i);
			$offset_y = (32 * $j);
            
			for($ix = 0; $ix -lt 32; $ix ++)
			{
				for($iy = 0; $iy -lt 32; $iy++)
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
				$objForm.Refresh();
			}
		}
	}
	
	Write-Host "... done."
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

function onKeyPress($sender, $EventArgs)
{
    $keyCode = $EventArgs.KeyCode
    
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
			if($global:strGameState -eq "EDIT_MAP" -and !$global:windowOpen)
			{
				showWindow "WND_ESC_EDITOR"
			}
			elseif($global:strGameState -eq "EDIT_MAP" -and $global:windowOpen)
			{
				$global:windowOpen = $False;
				$objForm.Refresh();
			}
        }
        "T"
        {
            Write-Host "Testfunction!"
            #$global:arrWindows["WND_ESC_MAIN"].btn.Remove("BTN_SINGLEPLAYER")
            #addButtonToWindow "WND_ESC_MAIN" "BTN_SINGLEPLAYER_KRAM" "Gray" 136 20 12 24 "Singlekram" 8 4 "Gold" $False
            
        }
        "Right"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_X"] -lt ($global:arrCreateMapOptions["WIDTH"] - 7) -and $global:strGameState -eq "EDIT_MAP")
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
        }
        "Down"
        {
            if($global:arrCreateMapOptions["EDITOR_CHUNK_Y"] -lt ($global:arrCreateMapOptions["HEIGHT"] - 5) -and $global:strGameState -eq "EDIT_MAP")
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
        }
        
        default     {Write-Host "Unhandled keypress, code '$keyCode'"}
    }
}

function onMouseClick($strNameSender)
{
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
    elseif($global:windowOpen)
    {
        handleClickWindow $posX $posY
    }
    else
    {
        Write-Host "unhandled click at $relX $relY (in handleClickPicturebox)"
    }
}

function handleClickEditor($posX, $posY)
{
    $tile_x = [math]::floor($posX / 32) + $global:arrCreateMapOptions["EDITOR_CHUNK_X"]
    $tile_y = [math]::floor($posY / 32) + $global:arrCreateMapOptions["EDITOR_CHUNK_Y"]

    Write-Host "click at tile $tile_x $tile_y"
    
    if($tile_x -lt 2 -or $tile_y -lt 2 -or $tile_x -gt ($arrCreateMapOptions["WIDTH"] + 1) -or $tile_y -gt ($arrCreateMapOptions["HEIGHT"] + 1))
    {
        Write-Host "But border tile"
        return;
    }
    
    if($global:arrCreateMapOptions["EDIT_MODE"] -eq 1)
    {
        
        $idx = $global:arrCreateMapOptions["SELECT_LAYER01"]
        $key = $arrBastextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]
        
        Write-Host "changing tile... $idx $key"
        
        MAP_changeTile ($global:arrTextures[$arrBastextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER01"]]]) $tile_x $tile_y
    }
    elseif($global:arrCreateMapOptions["EDIT_MODE"] -eq 2)
    {
         MAP_changeTile ($global:arrTextures[$arrOverlayTextureIDToKey[$global:arrCreateMapOptions["SELECT_LAYER02"]]]) $tile_x $tile_y
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
            showWindow "WND_ERROR_NOTIMPLEMENTED"
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
                $global:arrCreateMapOptions["BASTEXTUREID"] = $arrBastextureIDToKey.Length - 1;
            }
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBastextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 204 102
            $pictureBox.Refresh();
        }
        "BTN_CREATEMAP_TEXTURE_NEXT"
        {
            if($global:arrCreateMapOptions["BASTEXTUREID"] -ne ($arrBastextureIDToKey.Length - 1))
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] += 1;
            }
            else
            {
                $global:arrCreateMapOptions["BASTEXTUREID"] = 0;
            }
            addImageToWindow "WND_CREATE_MAP" ($global:arrTextures[$arrBastextureIDToKey[$global:arrCreateMapOptions["BASTEXTUREID"]]]) 204 102
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
			MAP_createMapImage
			#$global:windowOpen = $False;
            showWindow "WND_INTERFACE_EDITOR"
			$global:strGameState = "EDIT_MAP";
            
			#$global:objWorld.Save("world.png")
			
			$objForm.Refresh();
		}
        "BTN_SINGLEPLAYER_SETUP_MAP"
        {
            openMapFile
            if($global:strMapFile -ne "")
            {
                $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove("BTN_SINGLEPLAYER_SETUP_MAP")
                $filename = Split-Path $global:strMapFile -leaf
                addButtonToWindow "WND_SINGLEPLAYER_SETUP" "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 286 20 142 12 $filename 4 4 "Gold" $False
                $pictureBox.Refresh();
            }  
        }
        "BTN_SWITCH_TOPMOST"
        {
            $global:arrWindows["WND_GAME_OPTIONS"].btn.Remove("BTN_SWITCH_TOPMOST")
            $global:arrSettings["TOPMOST"] = !$global:arrSettings["TOPMOST"];
            $objForm.Topmost = $global:arrSettings["TOPMOST"];
            addSwitchButtonToWindow "WND_GAME_OPTIONS" "BTN_SWITCH_TOPMOST" $global:arrSettings["TOPMOST"] 60 20 240 12 $True $False
        }
        "BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT"
        {
            
            $newX = [math]::floor($iPosX / 20)
            $global:arrWindows["WND_SINGLEPLAYER_SETUP"].btn.Remove("BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT")
            addCountButtonToWindow "WND_SINGLEPLAYER_SETUP" "BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT" 20 20 142 42 5 ($newX + 1) $False
        }
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
            $global:objWorld.Save("world.png")
        }
        "BTN_IFE_EDIT_LAYER01"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 1;
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER02_SELECT")
            
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
            
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER01_SELECT" "Transparent" 120 160 16 36 "" 8 4 "Gold" $False
            
            $max_tex_id = $arrBastextureIDToKey.Length
            for($i = 0; $i -lt 3; $i++)
            {
                for($j = 0; $j -lt 4; $j++)
                {
                    $tex_id = ($global:arrCreateMapOptions["IDX_LAYER01"] + ($i * 4) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  40 40 (16 + $i * 40) (36 + $j * 40) $False
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrBastextureIDToKey[$tex_id]]) (20 + $i * 40) (40 + $j * 40)
                    }
                }
            }
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYER01_SELECT"
        {
            $texID = [math]::floor($iPosX / 40) * 4 + [math]::floor($iPosY / 40)
            $max_tex_id = $arrBastextureIDToKey.Length
            $texID += $global:arrCreateMapOptions["IDX_LAYER01"];
            
            if($texID -lt $max_tex_id)
            {
                Write-Host "Selected $texID"
                $global:arrCreateMapOptions["SELECT_LAYER01"] = $texID;
            }
            
            Write-Host "TextureID: $texID"
        }
        "BTN_IFE_EDIT_LAYER02"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 2;
            $global:arrWindows["WND_INTERFACE_EDITOR"].btn.Remove("BTN_IFE_EDIT_LAYER01_SELECT")
            
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
            addButtonToWindow "WND_INTERFACE_EDITOR" "BTN_IFE_EDIT_LAYER02_SELECT" "Transparent" 120 160 16 36 "" 8 4 "Gold" $False
        
            $max_tex_id = $arrOverlayTextureIDToKey.Length
            for($i = 0; $i -lt 3; $i++)
            {
                for($j = 0; $j -lt 4; $j++)
                {
                    $tex_id = ($global:arrCreateMapOptions["IDX_LAYER01"] + ($i * 4) + $j)
                    
                    if($tex_id -lt $max_tex_id)
                    {
                        buildButton "Gray"  40 40 (16 + $i * 40) (36 + $j * 40) $False
                        addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$tex_id]]) (20 + $i * 40) (40 + $j * 40)
                    }
                }
            }
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYER02_SELECT"
        {
            $texID = [math]::floor($iPosX / 40) * 4 + [math]::floor($iPosY / 40)
            $max_tex_id = $arrOverlayTextureIDToKey.Length
            $texID += $global:arrCreateMapOptions["IDX_LAYER02"];
            
            if($texID -lt $max_tex_id)
            {
                Write-Host "Selected $texID"
                $global:arrCreateMapOptions["SELECT_LAYER02"] = $texID;
            }
            
            Write-Host "TextureID: $texID"
        }
        "BTN_IFE_EDIT_LAYER03"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 3;
            
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
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
        
            #$max_tex_id = $arrOverlayTextureIDToKey.Length
            #for($i = 0; $i -lt 3; $i++)
            #{
            #    for($j = 0; $j -lt 4; $j++)
            #    {
            #        $tex_id = ($global:arrCreateMapOptions["IDX_LAYER01"] + ($i * 4) + $j)
            #        
            #        if($tex_id -lt $max_tex_id)
            #        {
            #            addImageToWindow "WND_INTERFACE_EDITOR" ($global:arrTextures[$arrOverlayTextureIDToKey[$tex_id]]) (20 + $i * 40) (40 + $j * 40)
            #        }
            #    }
            #}
            
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_DIRECTIONS"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 3;
            
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
            $global:arrCreateMapOptions["EDIT_MODE"] = 3;
            
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
        
            redrawWindowBack "WND_INTERFACE_EDITOR" 16 36 120 220
        
            $pictureBox.Refresh();
        }
        "BTN_IFE_EDIT_LAYERSETTINGS"
        {
            $global:arrCreateMapOptions["EDIT_MODE"] = 3;
            
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
        default
        {
            Write-Host "Button $strButtonID was clicked but has no function?"
        }
    }
}

function showWindow($strType)
{
    switch($strType)
    {
        "WND_ESC_MAIN"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow "WND_ESC_MAIN" "BTN_SINGLEPLAYER" "Gray" 136 20 12 14 "Singleplayer" 8 4 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_MULTIPLAYER" "Gray" 136 20 12 40 "Multiplayer" 12 4 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_EDITOR" "Gray" 136 20 12 66 "Editor" 39 4 "Gold" $False
            
            addButtonToWindow "WND_ESC_MAIN" "BTN_OPTIONS" "Gray" 136 20 12 92 "Options" 33 4 "Gold" $False
            addButtonToWindow "WND_ESC_MAIN" "BTN_CREDITS" "Gray" 136 20 12 118 "Credits" 35 4 "Gold" $False
            
            addButtonToWindow "WND_ESC_MAIN" "BTN_QUIT" "Red" 136 20 12 166 "Quit" 48 4 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_QUIT_MAIN"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 100 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 100) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Really quit?" 12 12 "Gold" $False
            addButtonToWindow "WND_QUIT_MAIN" "BTN_QUIT_YES" "Red" 60 20 12 56 "Yes" 8 4 "Gold" $False
            addButtonToWindow "WND_QUIT_MAIN" "BTN_QUIT_NO" "Green" 60 20 88 56 "No" 8 4 "Gold" $False
            $pictureBox.Refresh();
        }
        "WND_CREDITS"
        {
            Write-Host "Building window: $strType"
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Written by:" 10 10 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Spikeone" 10 22 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Story by:" 10 40 "Gold" $False
            addText $global:arrWindows[$strType].wnd "-" 10 52 "Gold" $False
            addText $global:arrWindows[$strType].wnd "Graphics by:" 10 70 "Gold" $False
            addText $global:arrWindows[$strType].wnd "-" 10 82 "Gold" $False
            addButtonToWindow $strType "BTN_CREDITS_BACK" "Gray" 136 20 12 156 "Back" 48 4 "Gold" $False
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
        "WND_SINGLEPLAYER_SETUP"
        {
            buildWindow 440 230 (($DrawingSizeX - 440) / 2) (($DrawingSizeY - 230) / 2) $strType
            addText $global:arrWindows[$strType].wnd "Map:" 12 16 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_MAP" "Gray" 286 20 142 12 "Open Map..." 4 4 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Players:" 12 46 "Gold" $False
            addCountButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_PLAYERCOUNT" 20 20 142 42 5 1 $False
            
            addButtonToWindow $strType "BTN_ERROR_NOTIMPLEMENTED_BACK" "Red" 136 20 12 198 "Back" 48 4 "Gold" $False
            addButtonToWindow $strType "BTN_SINGLEPLAYER_SETUP_START" "Green" 136 20 292 198 "Start" 48 4 "Gold" $False
        }
        "WND_CREATE_MAP"
        {
            buildWindow 310 200 (($DrawingSizeX - 310) / 2) (($DrawingSizeY - 200) / 2) $strType
            
            addText $global:arrWindows[$strType].wnd "Width:" 12 12 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD01" "Gray" 30 20 140 12 "+16" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WADD02" "Gray" 30 20 170 12 "+ 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WIDTH" "Red"   40 20 200 12 "32" 10 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB01" "Gray" 30 20 240 12 "- 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_WSUB02" "Gray" 30 20 270 12 "-16" 4 4 "Gold" $False
			
			addText $global:arrWindows[$strType].wnd "Height:" 12 46 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD01" "Gray" 30 20 140 42 "+16" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HADD02" "Gray" 30 20 170 42 "+ 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HEIGHT" "Red"   40 20 200 42 "32" 10 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB01" "Gray" 30 20 240 42 "- 2" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_HSUB02" "Gray" 30 20 270 42 "-16" 4 4 "Gold" $False
            
            addText $global:arrWindows[$strType].wnd "Basetexture:" 12 114 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_PREV" "Gray" 20 64 170 86 "<" 4 26 "Gold" $False
            addButtonToWindow $strType "BTN_CREATEMAP_TEXTURE_NEXT" "Gray" 20 64 250 86 ">" 4 26 "Gold" $False
            
            addImageToWindow $strType ($global:arrTextures[$arrBastextureIDToKey[0]]) 204 102
            
            addButtonToWindow $strType "BTN_CREATE_MAP_CANCEL" "Red" 116 20 12 166 "Cancel" 4 4 "Gold" $False
            addButtonToWindow $strType "BTN_CREATE_MAP_CONTINUE" "Green" 116 20 182 166 "Continue" 4 4 "Gold" $False
        }
		"WND_ESC_EDITOR"
		{
			Write-Host "Building window: $strType"
            buildWindow 160 200 (($DrawingSizeX - 160) / 2) (($DrawingSizeY - 200) / 2) $strType
            addButtonToWindow $strType "BTN_EDITOR_SAVEAS" "Gray" 136 20 12 14 "Save as..." 8 4 "Gold" $False
            addButtonToWindow $strType "BTN_EDITOR_SAVEIMAGE" "Gray" 136 20 12 40 "Save image" 12 4 "Gold" $False
            #addButtonToWindow "WND_ESC_MAIN" "BTN_EDITOR" "Gray" 136 20 12 66 "Editor" 39 4 "Gold" $False

            #addButtonToWindow "WND_ESC_MAIN" "BTN_OPTIONS" "Gray" 136 20 12 92 "Options" 33 4 "Gold" $False
            #addButtonToWindow "WND_ESC_MAIN" "BTN_CREDITS" "Gray" 136 20 12 118 "Credits" 35 4 "Gold" $False
			
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

    $arrBack = New-Object 'object[,]' 64,64
    
    for($i = 0; $i -lt 64; $i++)
    {
        for($j = 0; $j -lt 64; $j++)
        {
            $arrBack[$i,$j] = $tex_MENU_TEX_BACK.getPixel($i, $j)
        }
    }
    
    for($i = $iPosX; $i -lt ($iPosX + $iSizeX); $i++)
    {
        for($j = $iPosy; $j -lt ($iPosY + $iSizeY); $j++)
        {
            $posx = $i - [math]::floor($i / 64) * 64;
            $posy = $j - [math]::floor($j / 64) * 64;
            
            $global:arrWindows[$strWindow].wnd.SetPixel($i, $j, ($arrBack[$posx,$posy]));
        }
    }
}

function buildButton($strBtnColor, $iSizeX, $iSizeY, $iPosX, $iPosY, $isPressed)
{
    # well, first of all just fill the button area
    for($i = 0; $i -lt $iSizeX; $i++)
    {
        for($j = 0; $j -lt $iSizeY; $j++)
        {
            $posx = $i - [math]::floor($i / 64) * 64;
            $posy = $j - [math]::floor($j / 64) * 64;
            
            switch($strBtnColor)
            {
                "Red"
                {
                    $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_RED_DARK.GetPixel($posx, $posy));
                }
                "Green"
                {
                    $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GREEN_DARK.GetPixel($posx, $posy));
                }
                default
                {
                    $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($i + $iPosX), ($j + $iPosY), $tex_MENU_GRAY_DARK.GetPixel($posx, $posy));
                }
            }
        }
    }
    
    # and special effects...
    # $i = y
    for($i = 0; $i -lt 2; $i++)
    {
        for($j = $i; $j -lt $iSizeX; $j++)
        {   
            if(!$isPressed)
            {
                $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY - $i), "Black");
            }
            else
            {
                $posx = $i - [math]::floor($i / 64) * 64;
                $posy = $j - [math]::floor($j / 64) * 64;
                
                switch($strBtnColor)
                {
                    "Red"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY - $i), $tex_MENU_RED_LIGHT.GetPixel($posx, $posy));
                    }
                    "Green"
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY - $i), $tex_MENU_GREEN_LIGHT.GetPixel($posx, $posy));
                    }
                    default
                    {
                        $global:arrWindows[$global:strCurrentWindow].wnd.SetPixel(($iPosX + $j), ($iPosY + $iSizeY - $i), $tex_MENU_GRAY_LIGHT.GetPixel($posx, $posy));
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
                $posx = $i - [math]::floor($i / 64) * 64;
                $posy = $j - [math]::floor($j / 64) * 64;
                
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
                $posx = $i - [math]::floor($i / 64) * 64;
                $posy = $j - [math]::floor($j / 64) * 64;
                
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
                $posx = $i - [math]::floor($i / 64) * 64;
                $posy = $j - [math]::floor($j / 64) * 64;
                
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
    
    if(($strText.Length * 12) -ge $iSizeX)
    {
        $l = ($strText.Length * 12)
        Write-Host "ERROR: Button Text too long ($l > $iSizeX)"
    }
 
    if($strBtnColor -eq "Transparent")
    {
        return;
    }
    
    buildButton $strBtnColor $iSizeX $iSizeY $iPosX $iPosY $False
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
    $sizeY      = 12;
    #$tmp_rec    = New-Object System.Drawing.Rectangle(0, 0, $sizeX, $sizeY)
    #$tmp_img    = $global:bitmap.Clone($tmp_rec, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $tmp_img    = New-Object System.Drawing.Bitmap($sizeX, $sizeY);
    
    Write-Host "$strText $iPosX $iPosY"
    
    $offset_x = 0;
    
    for($i = 0; $i -lt ($strText.Length); $i++)
    {
        $tempChar = $strText.Substring($i, 1);
        
        if($arrFont[$tempChar])
        {
            # valid char
            for($j = 0; $j -lt ($arrFont[$tempChar].Width); $j++)
            {
                for($k = 0; $k -lt 12; $k++)
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
                for($k = 0; $k -lt 12; $k++)
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
    
    Write-Host "Building window $strWindow"
    
    #$global:windowOpen = !$global:windowOpen;
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
    
    # draw back
    $offset_x_l     = 1 + 6;
    $offset_x_r     = $iSizeX - 1 - 6;
    
    $offset_y_l     = 1 + 6;
    $offset_y_r     = $iSizeY - 1 - 6;
    
    $arrBack = New-Object 'object[,]' 64,64
    
    for($i = 0; $i -lt 64; $i++)
    {
        for($j = 0; $j -lt 64; $j++)
        {
            $arrBack[$i,$j] = $tex_MENU_TEX_BACK.getPixel($i, $j)
        }
    }
    
    for($i = ($offset_x_l); $i -lt ($offset_x_r); $i++)
    {
        for($j = ($offset_y_l); $j -lt ($offset_y_r); $j++)
        {
            $posx = $i - [math]::floor($i / 64) * 64;
            $posy = $j - [math]::floor($j / 64) * 64;
            
            $tmp_wnd.SetPixel($i, $j, ($arrBack[$posx,$posy]));
        }
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
    $global:arrWindows[$strWindow].wnd = $tmp_wnd;
    $global:arrWindows[$strWindow].loc_x = $iPosX;
    $global:arrWindows[$strWindow].loc_y = $iPosY;
    $objForm.Refresh();
    #addSpriteAt $tmp_wnd $iPosX $iPosY
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
	$rect = New-Object System.Drawing.Rectangle(0, 0, $pictureBox.Size.Width, $pictureBox.Size.Height)
	
	if($global:strGameState -eq "EDIT_MAP")
	{
        # display empty back
        #$EventArgs.Graphics.DrawImage($global:arrImages["SCREEN_BACK_MAP"], $rect, 0, 0, $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
        #
        #$rect_map = New-Object System.Drawing.Rectangle(32, 32, ($pictureBox.Size.Width - 32), ($pictureBox.Size.Height - 32))
        #$EventArgs.Graphics.DrawImage($global:objWorld, $rect_map, 0, 0, $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
        
        #$global:arrCreateMapOptions["EDITOR_CHUNK_X"]
        $offset_x = $global:arrCreateMapOptions["EDITOR_CHUNK_X"] * 32;
        $offset_y = $global:arrCreateMapOptions["EDITOR_CHUNK_Y"] * 32;
        
		$EventArgs.Graphics.DrawImage($global:objWorld, $rect, ($offset_x), ($offset_y), $DrawingSizeX, $DrawingSizeY, [System.Drawing.GraphicsUnit]::Pixel)
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
        $EventArgs.Graphics.DrawImage($global:arrWindows[$global:strCurrentWindow].wnd, $rect_wnd, 0, 0, $global:arrWindows[$global:strCurrentWindow].wnd.Width, $global:arrWindows[$global:strCurrentWindow].wnd.Height, [System.Drawing.GraphicsUnit]::Pixel)
        
        #$global:arrWindows[$global:strCurrentWindow].wnd.Save("Test.png")
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

    $strFileName = "..\..\DATA\CFG\game.cfg"

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
    $strFileName = "..\..\DATA\CFG\game.cfg"
    
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
    $OpenFileDialog.initialDirectory = "..\..\DATA\MAP"
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