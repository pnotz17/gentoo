# -*- mode: sh; mode: sh-bash -*-

# Constants (様々な箇所から使うので此処に置く)
_ble_term_nl=$'\n'
_ble_term_FS=$'\034'
_ble_term_SOH=$'\001'
_ble_term_DEL=$'\177'
_ble_term_IFS=$' \t\n'
_ble_term_CR=$'\r'

function blehook/declare {
  local name=$1
  builtin eval "_ble_hook_h_$name=()"
  builtin eval "_ble_hook_c_$name=0"
}

# ble.pp

blehook/declare EXIT
blehook/declare INT
blehook/declare ERR
blehook/declare unload
blehook/declare ATTACH
blehook/declare DETACH

# util.sh

blehook/declare DA1R
blehook/declare DA2R

# color.sh

blehook/declare color_defface_load
blehook/declare color_setface_load

# history.sh

blehook/declare ADDHISTORY
blehook/declare history_reset_background
blehook/declare history_onleave
blehook/declare history_delete
blehook/declare history_insert
blehook/declare history_clear
blehook/declare history_message

# edit.sh

blehook/declare WINCH
blehook/declare CHPWD
blehook/declare PRECMD
blehook/declare PREEXEC
blehook/declare POSTEXEC
blehook/declare widget_bell
blehook/declare textarea_render_defer
blehook/declare info_reveal

# deprecated function
function ble-edit/prompt/print { ble/prompt/print "$@"; }
function ble-edit/prompt/process-prompt-string { ble/prompt/process-prompt-string "$@"; }

# keymap

blehook/declare keymap_load
blehook/declare keymap_vi_load
blehook/declare keymap_emacs_load

# core-syntax.sh

blehook/declare syntax_load

# core-complete.sh

blehook/declare complete_load
blehook/declare complete_insert

# for compatibility:
function blehook/.compatibility-ble-0.3 {
  blehook keymap_load+='ble/util/invoke-hook _ble_keymap_default_load_hook'
  blehook keymap_emacs_load+='ble/util/invoke-hook _ble_keymap_emacs_load_hook'
  blehook keymap_vi_load+='ble/util/invoke-hook _ble_keymap_vi_load_hook'
  blehook complete_load+='ble/util/invoke-hook _ble_complete_load_hook'
}
function blehook/.compatibility-ble-0.3/check {
  if ble/is-array _ble_keymap_default_load_hook ||
      ble/is-array _ble_keymap_vi_load_hook ||
      ble/is-array _ble_keymap_emacs_load_hook ||
      ble/is-array _ble_complete_load_hook
  then
    ble/bin/cat << EOF
# [Change in ble-0.4.0]
#
# Please update your blerc settings for ble-0.4+.
# In ble-0.4+, use the following form:
# 
#   blehook/eval-after-load keymap SHELL-COMMAND
#   blehook/eval-after-load keymap_vi SHELL-COMMAND
#   blehook/eval-after-load keymap_emacs SHELL-COMMAND
#   blehook/eval-after-load complete SHELL-COMMAND
# 
# instead of the following older form:
# 
#   ble/array#push _ble_keymap_default_load_hook SHELL-COMMAND
#   ble/array#push _ble_keymap_vi_load_hook SHELL-COMMAND
#   ble/array#push _ble_keymap_emacs_load_hook SHELL-COMMAND
#   ble/array#push _ble_complete_load_hook SHELL-COMMAND
# 
# Note: "blehook/eval-after-load" should be called
#   after you defined SHELL-COMMAND.
#
EOF
  fi
}
