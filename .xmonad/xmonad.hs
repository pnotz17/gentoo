import XMonad
import System.IO
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Util.Cursor
import XMonad.Hooks.FadeInactive
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Circle
import XMonad.Layout.Tabbed (simpleTabbed)
import XMonad.Layout.MultiColumns (multiCol)
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeCol,ThreeColMid))
import XMonad.Layout.Renamed (renamed,Rename(Replace,CutWordsLeft))
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myModMask            = mod4Mask
myTerminal           = "st"
myBorderWidth        = 1
myFocusFollowsMouse  = True
myClickJustFocuses   = True
myNormalBorderColor  = "#B3AFC2"
myFocusedBorderColor = "#FF0000"
windowCount          = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myWorkspaces = 
  clickable $ 
  [" 01 ", 
   " 02 ", 
   " 03 ", 
   " 04 ", 
   " 05 ", 
   " 06 ", 
   " 07 ", 
   " 08 ", 
   " 09 " ]
 -- [" <icon=terminal.xpm/> ", 
  -- " <icon=folder.xpm/> ", 
  -- " <icon=browser.xpm/> ", 
  -- " <icon=image.xpm/> ", 
  -- " <icon=camera.xpm/> ", 
  -- " <icon=credit.xpm/> ", 
  -- " <icon=hacker.xpm/> ", 
  -- " <icon=tools.xpm/> ", 
  -- " <icon=magnet.xpm/> " ]
  where                                                                       
  clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" | (i,ws) <- zip [1..9] l,let n = i ]

myLayout = renamed [CutWordsLeft 1] $ spacing 1 $ avoidStruts $ smartBorders(
  Tall 1 (3/100) (1/2) |||
  Mirror (Tall 1 (3/100) (1/2)) |||
  ThreeColMid 1 (3/100) (1/2) |||
  Grid |||
  spiral (6/7)) |||
  multiCol [1] 1 0.01 (-0.5) |||
  simpleTabbed |||
  Circle |||
  noBorders (fullscreenFull Full)
  
myLogHook xmproc = dynamicLogWithPP xmobarPP { 
    ppOutput          = hPutStrLn xmproc
  , ppCurrent         = xmobarColor "#FFFFFF" "" . wrap "[" "]" 
  , ppVisible         = xmobarColor "#B3AFC2" ""                
  , ppHidden          = xmobarColor "#666666" "" . wrap "*" ""   
  , ppHiddenNoWindows = xmobarColor "#B3AFC2" ""       
  , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" 
  , ppTitle           = xmobarColor "#B3AFC2" "" . shorten 60    
  , ppLayout          = xmobarColor "#FF0000" "" 
  , ppSep             = " | "                     
  , ppExtras          = [windowCount]                          
  , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
  }

myManageHook = composeAll
  [className =? "mpv" --> doFloat]

myStartupHook = do
  setDefaultCursor xC_left_ptr
  setWMName "LG3D"

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  , ((modMask .|. shiftMask, xK_c),
     kill)

  , ((modMask, xK_space),
     sendMessage NextLayout)

  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  , ((modMask, xK_n),
     refresh)

  , ((modMask, xK_Tab),
     windows W.focusDown)

  , ((modMask, xK_j),
     windows W.focusDown)

  , ((modMask, xK_k),
     windows W.focusUp  )

  , ((modMask, xK_m),
     windows W.focusMaster  )

  , ((modMask, xK_Return),
     windows W.swapMaster)

  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  , ((modMask, xK_h),
     sendMessage Shrink)

  , ((modMask, xK_l),
     sendMessage Expand)

  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  , ((modMask .|. shiftMask, xK_f),
     spawn "spacefm")
  
  , ((modMask .|. shiftMask, xK_b),
     spawn "firefox")
   
  , ((modMask, xK_p),
     spawn "dmenu_run")
       
  , ((modMask .|. controlMask,xK_d),
     spawn "~/.local/bin/dm_fm")
         
  , ((modMask .|. controlMask,xK_e),
     spawn "~/.local/bin/dm_ed")
  
  , ((modMask .|. controlMask,xK_p),
     spawn "~/.local/bin/dm_pass")
  
  , ((mod1Mask, xK_d),
      spawn "~/.local/bin/dm_ytdl")
      
  , ((mod1Mask, xK_q),
     spawn "~/.local/bin/dm_power")
  
  , ((modMask,xK_b),
     sendMessage ToggleStruts)
      
  , ((0, xK_F10),
     spawn "amixer -q set Master toggle")

  , ((0, xK_F11),
     spawn "amixer -q set Master 5%-")

  , ((0, xK_F12),
     spawn "amixer -q set Master 5%+")
     
  , ((0, xK_Print),
     spawn  "~/.local/bin/dm_ss")
    
  , ((modMask .|. controlMask,xK_r),
     spawn "xmonad --recompile; xmonad --restart")
  ]

  ++

  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]
  
  ++

  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
  ]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [   ((modMask, button1),
       (\w -> focus w >> mouseMoveWindow w))

    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))
  ]

main = do
  xmproc <- spawnPipe "$HOME/.local/bin/xmobar ~/.xmonad/xmobar.hs"
  xmonad $ docks $ def {
  terminal             = myTerminal,
  focusFollowsMouse    = myFocusFollowsMouse,
  borderWidth          = myBorderWidth,
  modMask              = myModMask,
  workspaces           = myWorkspaces,
  normalBorderColor    = myNormalBorderColor,
  focusedBorderColor   = myFocusedBorderColor,
  keys                 = myKeys,
  mouseBindings        = myMouseBindings,
  layoutHook           = myLayout,
  manageHook           = myManageHook,
  startupHook          = myStartupHook, 
  logHook              = myLogHook xmproc <+> fadeInactiveLogHook 0.8
  }
