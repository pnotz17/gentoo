static struct Config config = {.font = "Ubuntu Nerd Font:style=Book:size=7",

#
/* colors */
.background_color 	    = "#080808",
.foreground_color 	    = "#808080",
.selbackground_color 	    = "#121213",
.selforeground_color 	    = "#ffffff",
.separator_color 	    = "#CDC7C2",
.border_color 		    = "#E6E6E6",

/* sizes in pixels */
.width_pixels 		    = 105,        	/* minimum width of a menu */
.height_pixels 		    = 25,        	/* height of a single menu item */
.border_pixels 		    = 0,         	/* menu border */
.separator_pixels 	    = 3,      		/* space around separator */
.gap_pixels 		    = 0,            	/* gap between menus */
.triangle_width 	    = 3,		/* geometry of the right-pointing isoceles triangle for submenus */
.triangle_height 	    = 7,		/* geometry of the right-pointing isoceles triangle for submenus */
.iconpadding 		    = 2,		/* the icon size is equal to .height_pixels - .iconpadding * 2 */
.horzpadding 		    = 8,		/* area around the icon, the triangle and the separator */

};

#define KSYMFIRST	    XK_VoidSymbol       /* select first item */
#define KSYMLAST	    XK_VoidSymbol       /* select last item */
#define KSYMUP 		    XK_VoidSymbol       /* select previous item */
#define KSYMDOWN	    XK_VoidSymbol       /* select next item */
#define KSYMLEFT	    XK_VoidSymbol       /* close current menu */
#define KSYMRIGHT	    XK_VoidSymbol       /* enter selected item */
