#!/bin/bash

# ble/unicode/EmojiStatus 128512; echo $ret
# ble/unicode/EmojiStatus 128529; echo $ret
# ble/unicode/EmojiStatus 128533; echo $ret
# ble/unicode/EmojiStatus 128535; echo $ret
# ble/unicode/EmojiStatus 128537; echo $ret
# ble/unicode/EmojiStatus 128539; echo $ret
# ble/unicode/EmojiStatus 128543; echo $ret
# ble/unicode/EmojiStatus 128550; echo $ret
# ble/unicode/EmojiStatus 128556; echo $ret
# ble/unicode/EmojiStatus 128558; echo $ret
# ble/unicode/EmojiStatus 128564; echo $ret

function list-range-code-for-version-detection {
  local nversion=$_ble_unicode_c2w_UnicodeVersionCount
  local _ble_unicode_c2w_ambiguous=3
  local ver ret prev_ver
  for ((ver=1;ver<nversion;ver++)); do
    prev_ver=$((ver-1))

    local code
    for code in "${!_ble_unicode_c2w[@]}"; do
      ble/unicode/EmojiStatus "$code"
      ((ret)) && continue
      local -a _ble_unicode_c2w_custom=()
      _ble_unicode_c2w_version=$prev_ver ble/unicode/c2w "$code"; local oldw=$ret
      _ble_unicode_c2w_version=$ver ble/unicode/c2w "$code"; local neww=$ret
      ble/util/unlocal _ble_unicode_c2w_custom
      ((oldw==neww||oldw==3&&neww>0||neww==3&&oldw>0)) && continue

      ble/util/c2s "$code"; local ch=$ret

      local note=
      if [[ ${_ble_unicode_c2w_custom[code]} ]]; then
        note="${note:+$note, }overwritten by wcwidth-custom"
      fi

      printf 'ver%s U+%04X(%d) %s %d->%d (%s)%s\n' \
             "$ver" "$code" "$code" "$ch" \
             "$oldw" "$neww" "${_ble_unicode_c2w_UnicodeVersionMapping[*]:_ble_unicode_c2w[code]*nversion:nversion}" \
             "${note:+ # $note}"
    done
  done

}
list-range-code-for-version-detection
