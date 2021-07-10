/* See LICENSE file for copyright and license details. */

/* special command for directories */
static const char *dircmd = "st -e spacefm %s";

static const Pair pairs[] = {
	/*  regex                                   action */
	{ "\\.pdf$",                                "mupdf-x11 %s"        }, // pdf
	{ "\\.(jpg|png|tiff|gif)$",                 "feh -a %s"           }, // image
	{ "\\.(avi|mp4|mkv|mp3|ogg|flac|mov|wav)$", "mpv %s"           	  }, // video
	{ "\\.(html|svg)$",                         "waterfox %s"          }, // local html and svg
	{ "^(http://|https://)?(www\\.)",           "waterfox %s"          }, // web URI link
	{ "^magnet:\?",                             "transmission-gtk %s" }, // magnet URI link
	{ "^file:\?",                               "st -e vim %s"       }, // file URI link
	{ ".",                                      "st -e vim %s"       }, // catch-all default
};
