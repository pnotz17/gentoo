/* See LICENSE file for copyright and license details. */

/* special command for directories */
static const char *dircmd = "st -e spacefm %s";

static const Pair pairs[] = {
	/*  regex                                   action */
	{ "\\.pdf$",                                "mupdf-x11 %s"        }, // pdf
	{ "\\.(jpg|png|tiff|gif)$",                 "feh -a %s"           }, // image
	{ "\\.(avi|mp4|mkv|mp3|ogg|flac|mov|wav)$", "mpv %s"           	  }, // video
	{ "\\.(html|svg)$",                         "firefox %s"          }, // local html and svg
	{ "^(http://|https://)?(www\\.)",           "firefox %s"          }, // web URI link
	{ "^magnet:\?",                             "transmission-gtk %s" }, // magnet URI link
	{ "^file:\?",                               "st -e nvim %s"       }, // file URI link
	{ ".",                                      "st -e nvim %s"       }, // catch-all default
};
