Config { 
font = "xft:UbuntuMono Nerd Font:style=Regular:pixelsize=13:antialias=true:hinting=true",additionalFonts = [ "xft:FontAwesome:pixelsize=13" ]
       , borderColor = "black"
       , border = TopB
       , bgColor = "black"
       , fgColor = "white"
       , alpha = 221
       , position = TopW L 100 23
       , allDesktops = True
       , overrideRedirect = False
       , iconRoot = ".xmonad/xpm/"  
       , commands = [
              Run UnsafeStdinReader
            , Run Uptime ["-t","<icon=clock_alt.xpm/> <days>:<hours>"] 24000
            , Run Network "enp2s0" ["--template", "<icon=netup.xpm/> <tx>kB | <icon=netdown.xpm/> <rx>kB", "-L","1000","-H","5000", "--low", "gray", "--normal","green","--high","red"] 7
            , Run DiskU [("/","<icon=hdd.xpm/> <free>")] [] 21
            , Run CoreTemp ["-t","<icon=temp.xpm/> <core0>C | <icon=temp.xpm/> <core1>C","-L", "40", "-H", "60","-l", "#b3afc2", "-n", "#b3afc2", "-h", "red"] 3     
            , Run Cpu ["-t","<icon=cpu.xpm/> <total>%","-H","50","--normal","green","--high","red"] 7
            , Run Memory ["-t","<icon=ram.xpm/> <usedratio>%","-H","50","--normal","green","--high","red"] 7
            , Run Swap ["-t","<icon=swap.xpm/> <usedratio>%"] 7
  		    , Run Alsa "default" "Master" ["-t", "<icon=volume.xpm/> <volume>%"] 
            , Run Com ".xmonad/scripts/mail" [] "count" 21
		    , Run Com "echo" ["<icon=mail.xpm/> "] "mail" 3600
            , Run Com "sh" ["-c", "checkupdates | wc -l"] "checkupdates" 21
            , Run Com "echo" ["<icon=pacman.xpm/> "] "pacman" 3600
            , Run Date "<icon=calendar.xpm/> <fc=#b3afc2>%H:%M</fc>" "date" 7     
            , Run Weather "LGTS" ["-t","<station>: <tempC>C","-L","18","-H","25","--normal","green","--high","red","--low","lightblue"] 24000        
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "<icon=haskell.xpm/> | %UnsafeStdinReader%} { %uptime% | %enp2s0% | %disku% | %cpu% | %memory% | %swap% | %alsa:default:Master% | %date% |"}





