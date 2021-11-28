#!/usr/bin/env bash

umask 022

function mkd {
  [[ -d $1 ]] || mkdir -p "$1"
}

function download {
  local url=$1 dst=$2
  if [[ ! -s $dst ]]; then
    [[ $dst == ?*/* ]] && mkd "${dst%/*}"
    if type wget &>/dev/null; then
      wget "$url" -O "$dst.part" && mv "$dst.part" "$dst"
    else
      echo "make_command: 'wget' not found." >&2
      exit 2
    fi
  fi
}

function ble/array#push {
  while (($#>=2)); do
    builtin eval "$1[\${#$1[@]}]=\$2"
    set -- "$1" "${@:3}"
  done
}

#------------------------------------------------------------------------------

function sub:help {
  printf '%s\n' \
         'usage: make_command.sh SUBCOMMAND args...' \
         '' 'SUBCOMMAND' ''
  local sub
  for sub in $(declare -F | sed -n 's|^declare -[fx]* sub:\([^/]*\)$|\1|p'); do
    if declare -f sub:"$sub"/help &>/dev/null; then
      sub:"$sub"/help
    else
      printf '  %s\n' "$sub"
    fi
  done
  printf '\n'
}

function sub:install {
  # read options
  local flag_error= flag_release=
  while [[ $1 == -* ]]; do
    local arg=$1; shift
    case $arg in
    (--release) flag_release=1 ;;
    (*) echo "install: unknown option $arg" >&2
        flag_error=1 ;;
    esac
  done
  [[ $flag_error ]] && return 1

  local src=$1
  local dst=$2
  mkd "${dst%/*}"
  if [[ $src == *.sh ]]; then
    local nl=$'\n' q=\' script=$'1i\\\n# this script is a part of blesh (https://github.com/akinomyoga/ble.sh) under BSD-3-Clause license'
    script=$script$nl'/^[[:space:]]*#/d;/^[[:space:]]*$/d'
    [[ $flag_release ]] &&
      script=$script$nl's/^\([[:space:]]*_ble_base_repository=\)'$q'.*'$q'\([[:space:]]*\)$/\1'${q}release:$dist_git_branch$q'/'
    sed "$script" "$src" >| "$dst.part" && mv "$dst.part" "$dst"
  else
    cp "$src" "$dst"
  fi
}
function sub:install/help {
  printf '  install src dst\n'
}

function sub:dist {
  local dist_git_branch=$(git rev-parse --abbrev-ref HEAD)
  local tmpdir=ble-$FULLVER
  local src
  for src in "$@"; do
    local dst=$tmpdir${src#out}
    sub:install --release "$src" "$dst"
  done
  [[ -d dist ]] || mkdir -p dist
  tar caf "dist/$tmpdir.$(date +'%Y%m%d').tar.xz" "$tmpdir" && rm -r "$tmpdir"
}

function sub:ignoreeof-messages {
  (
    cd ~/local/build/bash-4.3/po
    sed -nr '/msgid "Use \\"%s\\" to leave the shell\.\\n"/{n;s/^[[:space:]]*msgstr "(.*)"[^"]*$/\1/p;}' *.po | while builtin read -r line || [[ $line ]]; do
      [[ $line ]] || continue
      echo $(printf "$line" exit) # $() は末端の改行を削除するため
    done
  ) >| lib/core-edit.ignoreeof-messages.new
}

function sub:generate-emoji-table {
  local -x name=${1:-_ble_unicode_EmojiStatus}

  local unicode_version=14.0
  local cache=out/data/unicode-emoji-$unicode_version.txt
  download "https://unicode.org/Public/emoji/$unicode_version/emoji-test.txt" "$cache"

  local -x q=\'
  local versions=$(gawk 'match($0, / E([0-9]+\.[0-9]+)/, m) > 0 { print m[1]; }' "$cache" | sort -Vu | tr '\n' ' ')
  gawk -v versions="$versions" '
    BEGIN {
      NAME = ENVIRON["name"];
      q = ENVIRON["q"];

      EmojiStatus_None               = 0;
      EmojiStatus_FullyQualified     = 1;
      EmojiStatus_MinimallyQualified = 2;
      EmojiStatus_Unqualified        = 3;
      EmojiStatus_Component          = 4;
      print "_ble_unicode_EmojiStatus_None="               EmojiStatus_None;
      print "_ble_unicode_EmojiStatus_FullyQualified="     EmojiStatus_FullyQualified;
      print "_ble_unicode_EmojiStatus_MinimallyQualified=" EmojiStatus_MinimallyQualified;
      print "_ble_unicode_EmojiStatus_Unqualified="        EmojiStatus_Unqualified;
      print "_ble_unicode_EmojiStatus_Component="          EmojiStatus_Component;
    }

    function register_codepoint(char_code, char_emoji_version, char_qtype, _, iver) {
      iver = ver2iver[char_emoji_version];
      if (iver == "") {
        print "unknown version \"" char_emoji_version "\"" > "/dev/stderr";
        return;
      }

      g_code2qtype[char_code] = iver == 0 ? char_qtype : q "V>=" iver "?" char_qtype ":0" q;
      if (g_code2qtype[char_code + 1] == "")
        g_code2qtype[char_code + 1] = "0";
    }

    function register_RegionalIndicators(_, code) {
      for (code = 0x1F1E6; code <= 0x1F1FF; code++)
        register_codepoint(code, "0.6", EmojiStatus_FullyQualified);
    }

    BEGIN {
      split(versions, vers);
      nvers = length(vers);
      for (iver = 0; iver < nvers; iver++) {
        ver2iver[vers[iver + 1]] = iver;
        iver2ver[iver] = vers[iver + 1];
      }
      register_RegionalIndicators();
    }

    # 単一絵文字 (sequence でない) のみを登録する。
    match($0, / E([0-9]+\.[0-9]+)/, m) > 0 {
      if ($3 == "fully-qualified") {
        register_codepoint(strtonum("0x" $1), m[1], EmojiStatus_FullyQualified);
      } else if ($3 == "component") {
        register_codepoint(strtonum("0x" $1), m[1], EmojiStatus_Component);
      } else if ($3 == "unqualified") {
        register_codepoint(strtonum("0x" $1), m[1], EmojiStatus_Unqualified);
      }
    }

    function print_database(_, codes, qtypes, len, i, n, keys, code, qtype, prev_qtype) {

      # uniq g_code2qtype
      len = 0;
      prev_qtype = EmojiStatus_None;
      n = asorti(g_code2qtype, keys, "@ind_num_asc");
      for (i = 1; i <= n; i++) {
        code = int(keys[i]);
        qtype = g_code2qtype[code];
        if (qtype == "") qtype = EmojiStatus_None;
        if (qtype != prev_qtype) {
          codes[len] = code;
          qtypes[len] = qtype;
          len++;
        }
        prev_qtype = qtype;
      }

      output_values = "";
      output_ranges = "";
      prev_code = 0;
      prev_qtype = EmojiStatus_None;
      for (i = 0; i < len; i++) {
        code = codes[i];
        qtype = qtypes[i];

        if (i + 1 < len && (n = codes[i + 1]) - code <= 1) {
          # 孤立コード
          for (; code < n; code++)
            output_values = output_values " [" code "]=" qtype;

        } else if (qtype != prev_qtype) {
          output_values = output_values " [" code "]=" qtype;
          output_ranges = output_ranges " " code

          # 非孤立領域の範囲
          p = int(code);
          if (qtype == EmojiStatus_None) p--;
          if (p < 0x10000) {
            if (bmp_min == "" || p < bmp_min) bmp_min = p;
            if (bmp_max == "" || p > bmp_max) bmp_max = p;
          } else {
            if (smp_min == "" || p < smp_min) smp_min = p;
            if (smp_max == "" || p > smp_max) smp_max = p;
          }

          # 非孤立領域が BMP/SMP を跨がない事の確認
          if (prev_qtype != EmojiStatus_None && prev_code < 0x10000 && 0x10000 < code)
            print "\x1b[31mEmojiStatus_xmaybe: a BMP-SMP crossing range unexpected.\x1b[m" > "/dev/stderr";
          prev_code = code;
          prev_qtype = qtype;
        }
      }

      # printf("_ble_unicode_EmojiStatus_bmp_min=%-6d # U+%04X\n", bmp_min, bmp_min);
      # printf("_ble_unicode_EmojiStatus_bmp_max=%-6d # U+%04X\n", bmp_max, bmp_max);
      # printf("_ble_unicode_EmojiStatus_smp_min=%-6d # U+%04X\n", smp_min, smp_min);
      # printf("_ble_unicode_EmojiStatus_smp_max=%-6d # U+%04X\n", smp_max, smp_max);

      printf("_ble_unicode_EmojiStatus_xmaybe='$q'%d<=code&&code<=%d||%d<=code&&code<=%d'$q'\n", bmp_min, bmp_max, smp_min, smp_max);
      print NAME "=(" substr(output_values, 2) ")"
      print NAME "_ranges=(" substr(output_ranges, 2) ")";

    }

    function print_functions(_, iver) {
      print "function ble/unicode/EmojiStatus/version2index {";
      print "  case $1 in";
      for (iver = 0; iver < nvers; iver++)
        print "  (" iver2ver[iver] ") ret=" iver " ;;";
      print "  (*) return 1 ;;";
      print "  esac";
      print "}"
      print "_ble_unicode_EmojiStatus_version=" nvers - 1;
      print "bleopt/declare -n emoji_version " iver2ver[nvers - 1];
    }

    END {
      print_database();
      print_functions();
    }
  ' "$cache" | ifold -w 131 --spaces --no-text-justify --indent=..
}

function sub:generate-grapheme-cluster-table {
  local url=http://www.unicode.org/Public/UCD/latest/ucd/auxiliary/GraphemeBreakProperty.txt
  local cache=out/data/unicode-GraphemeBreakProperty-latest.txt
  if [[ ! -s $cache ]]; then
    mkd out/data
    wget "$url" -O "$cache.part" && mv "$cache.part" "$cache"
  fi

  local url2=https://www.unicode.org/Public/UCD/latest/ucd/emoji/emoji-data.txt
  local cache2=out/data/unicode-emoji-data-latest.txt
  if [[ ! -s $cache2 ]]; then
    mkd out/data
    wget "$url2" -O "$cache2.part" && mv "$cache2.part" "$cache2"
  fi

  local url3=http://www.unicode.org/Public/UCD/latest/ucd/auxiliary/GraphemeBreakTest.txt
  local cache3=out/data/unicode-GraphemeBreakTest-latest.txt
  if [[ ! -s $cache3 ]]; then
    mkd out/data
    wget "$url3" -O "$cache3.part" && mv "$cache3.part" "$cache3"
  fi

  gawk '
    BEGIN {
      #ITEMS_PER_LINE = 6;
      MAX_COLUMNS = 160;
      apos = "'\''";
      out = "   ";
      out_length = 3;
      out_count = 0;
    }
    { sub(/[[:space:]]*#.*$/, ""); sub(/[[:space:]]+$/, ""); }
    $0 == "" {next}

    function out_flush() {
      if (!out_count) return;
      print out;
      out = "   ";
      out_length = 3;
      out_count = 0;
    }

    function process_case(line, _, m, i, b, str, ans) {
      i = b = 0;
      ans = "";
      str = "";
      while (match(line, /([÷×])[[:space:]]*([[:xdigit:]]+)[[:space:]]*/, m) > 0) {
        if (m[1] == "÷") b = i;
        str = str "\\U" m[2];
        ans = ans (ans == "" ? "" : ",") b;
        line = substr(line, RLENGTH + 1);
        i++;
      }
      n = i;
      if (line == "÷") {
        ans = ans (ans == "" ? "" : ",") i;
      } else
        print "GraphemeBreakTest.txt: Unexpected line (" $0 ")" >"/dev/stderr";

      ent = ans ":" apos str apos;
      entlen = length(ent) + 1

      if (out_length + entlen >= MAX_COLUMNS) out_flush();
      out = out " " ent;
      out_length += entlen;
      out_count++;
      #if (out_count % ITEMS_PER_LINE == 0) out_flush();
    }
    {
      gsub(/000D × 000A/, "000D ÷ 000A"); # Tailored
      process_case($0);
    }
    END { out_flush(); }
  ' "$cache3" > lib/test-canvas.GraphemeClusterTest.sh

  {
    echo '# __Grapheme_Cluster_Break__'
    cat "$cache"
    echo '# __Extended_Pictographic__'
    cat "$cache2"
  } | gawk '
    BEGIN {
      # ble.sh 実装では CR/LF は独立した制御文字として扱う

      PropertyCount = 13;
      prop2v["Other"]              = Other              = 0;
      prop2v["CR"]                 = CR                 = 1;
      prop2v["LF"]                 = LF                 = 1;
      prop2v["Control"]            = Control            = 1;
      prop2v["ZWJ"]                = ZWJ                = 2;
      prop2v["Prepend"]            = Prepend            = 3;
      prop2v["Extend"]             = Extend             = 4;
      prop2v["SpacingMark"]        = SpacingMark        = 5;
      prop2v["Regional_Indicator"] = Regional_Indicator = 6;
      prop2v["L"]                  = L                  = 7;
      prop2v["V"]                  = V                  = 8;
      prop2v["T"]                  = T                  = 9;
      prop2v["LV"]                 = LV                 = 10;
      prop2v["LVT"]                = LVT                = 11;
      prop2v["Pictographic"]       = Pictographic       = 12;

      v2c[0] = "O";
      v2c[1] = "C";
      v2c[2] = "Z";
      v2c[3] = "P";
      v2c[4] = "E";
      v2c[5] = "S";
      v2c[6] = "R";
      v2c[7] = "L";
      v2c[8] = "V";
      v2c[9] = "T";
      v2c[10] = "v";
      v2c[11] = "t";
      v2c[12] = "G";
    }

    function process_GraphemeClusterBreak(_, v, m, b, e, i) {
      v = prop2v[$3];
      if (match($1, /([[:xdigit:]]+)\.\.([[:xdigit:]]+)/, m) > 0) {
        b = strtonum("0x" m[1]);
        e = strtonum("0x" m[2]);
      } else {
        b = e = strtonum("0x" $1);
      }

      for (i = b; i <= e; i++)
        table[i] = v;

      if (e > max_code) max_code = e;
    }
    function process_ExtendedPictographic(m, b, e, i) {
      if (match($1, /([[:xdigit:]]+)\.\.([[:xdigit:]]+)/, m) > 0) {
        b = strtonum("0x" m[1]);
        e = strtonum("0x" m[2]);
      } else {
        b = e = strtonum("0x" $1);
      }

      for (i = b; i <= e; i++) {
        if (table[i])
          printf("Extended_Pictograph: U+%04X already has Grapheme_Cluster_Break Property '\''%s'\''.\n", i, v2c[table[i]]) > "/dev/stderr";
        else
          table[i] = Pictographic;
      }

      if (e > max_code) max_code = e;
    }

    /__Grapheme_Cluster_Break__/ {mode = "break";}
    /__Extended_Pictographic__/ {mode = "picto";}
    /^[[:space:]]*(#|$)/ {next;}
    mode == "break" && $2 == ";" { process_GraphemeClusterBreak(); }
    mode == "picto" && /Extended_Pictographic/ { process_ExtendedPictographic(); }

    function rule_add(i, j, value) {
       if (rule[i, j] != "") return;
       rule[i, j] = value;
    }
    function rule_initialize() {
       for (i = 0; i < PropertyCount; i++) {
         rule_add(Control, i, 0);
         rule_add(i, Control, 0);
       }
       rule_add(L, L, 1);
       rule_add(L, V, 1);
       rule_add(L, LV, 1);
       rule_add(L, LVT, 1);
       rule_add(LV, V, 1);
       rule_add(LV, T, 1);
       rule_add(V, V, 1);
       rule_add(V, T, 1);
       rule_add(LVT, T, 1);
       rule_add(T, T, 1);
       for (i = 0; i < PropertyCount; i++) {
         rule_add(i, Extend, 1);
         rule_add(i, ZWJ, 1);
       }
       for (i = 0; i < PropertyCount; i++) {
         rule_add(i, SpacingMark, 2);
         rule_add(Prepend, i, 2);
       }
       rule_add(ZWJ, Pictographic, 3);
       rule_add(Regional_Indicator, Regional_Indicator, 4);
    }
    function rule_print(_, i, j, t, out) {
      out = "";
      for (i = 0; i < PropertyCount; i++) {
        out = out " ";
        for (j = 0; j < PropertyCount; j++) {
          t = rule[i, j];
          if (t == "") t = 0;
          out = out " " t;
        }
        out = out "\n";
      }
      print "_ble_unicode_GraphemeClusterBreak_rule=(";
      print out ")";
    }

    function print_table(_, out, i, p) {
      out = ""
      for (i = 0; i <= max_code; i++) {
        p = v2c[table[i]];
        if (p == "") p = "O";
        out = out p;
        if ((i + 1) % 128 == 0)
          out = out "\n";
      }
      print out;
    }

    # 孤立した物は先に出力
    function print_isolated(_, out, c, i, j, v) {
      out = "";
      count = 0;
      for (i = 0; i <= max_code; i = j) {
        j = i + 1;
        while (j <= max_code && table[j] == table[i]) j++;
        if (j - i <= 2) {
          v = table[i];
          if (v == "") v = 0;
          for (k = i; k < j; k++) {
            table[k] = "-";
            if (count++ % 16 == 0)
              out = out (out == "" ? "  " : "\n  ")
            out = out "[" k "]=" v " ";
          }
        }
      }
      print "_ble_unicode_GraphemeClusterBreak=("
      print "  # isolated Grapheme_Cluster_Break property (" count " chars)"
      print out;
    }
    function print_ranges(_, out1, c, i, j, v) {
      out1 = "";
      count1 = 0;
      count2 = 0;
      for (i = 0; i <= max_code; i = j) {
        j = i + 1;
        while (j <= max_code && table[j] == table[i] || table[j] == "-") j++;

        v = table[i];
        if (v == "") v = 0;

        if (count1++ % 16 == 0)
          out1 = out1 (out1 == "" ? "  " : "\n  ")
        out1 = out1 "[" i "]=" v " ";

        if (count2++ % 32 == 0)
          out2 = out2 (out2 == "" ? "  " : "\n  ")
        out2 = out2 i " ";
      }
      print "";
      print "  # Grapheme_Cluster_Break ranges (" count1 " ranges)"
      print out1;
      print ")"
      print "_ble_unicode_GraphemeClusterBreak_ranges=("
      print out2 (max_code+1);
      print ")"
    }

    function prop_print(_, key) {
      print "_ble_unicode_GraphemeClusterBreak_Count=" PropertyCount;
      for (key in prop2v)
        if (key != "CR" && key != "LF")
          print "_ble_unicode_GraphemeClusterBreak_" key "=" prop2v[key];
    }

    END {
      #print_table();

      prop_print();

      print "_ble_unicode_GraphemeClusterBreak_MaxCode=" (max_code + 1);
      print_isolated();
      print_ranges();

      rule_initialize();
      rule_print();
    }
  ' > src/canvas.GraphemeClusterBreak.sh
}

function sub:update-EastAsianWidth {
  local version
  for version in {4.1,5.{0,1,2},6.{0..3},{7..11}.0,12.{0,1},13.0}.0; do
    local data=out/data/unicode-EastAsianWidth-$version.txt
    download http://www.unicode.org/Public/$version/ucd/EastAsianWidth.txt "$data"
    gawk '
      /^[[:space:]]*(#|$)/ {next;}

      BEGIN {
        prev_end = 0;
        prev_w = "";
        cjkwidth = 1;
      }

      function determine_width(eastAsianWidth, generalCategory, _, eaw) {
        if (generalCategory ~ /^(C[ncs]|Z[lp])$/)
          return -1;
        else if (generalCategory ~ /^(M[ne]|Cf)$/)
          return 0;
        else if (eastAsianWidth == "A")
          return cjkwidth;
        else if (eastAsianWidth == "W" || eastAsianWidth == "F")
          return 2;
        else
          return 1;
      }

      function register_width(beg, end, w) {
        if (end > beg && w != prev_w) {
          printf("U+%04X %s\n", beg, w);
          prev_w = w;
        }
        prev_end = end;
      }

      $2 == "#" {
        if (match($1, /^([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
          beg = strtonum("0x" m[1]);
          end = beg + 1;
          eaw = m[2];
        } else if (match($1, /^([0-9a-fA-F]+)\.\.([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
          beg = strtonum("0x" m[1]);
          end = strtonum("0x" m[2]) + 1;
          eaw = m[3];
        } else {
          next;
        }

        w = determine_width(eaw, $3);

        # Undefined characters
        register_width(prev_end, beg, 1);

        # Current range
        register_width(beg, end, w);
      }
      END {
        register_width(prev_end, 0x110000, 1);
      }
    ' "$data" > "out/data/c2w.eaw-$version.txt"

    gawk '
      function lower_bound(arr, N, value, _, l, u, m) {
        l = 0;
        u = N - 1;
        while (u > l) {
          m = int((l + u) / 2);
          if (arr[m] < value)
            l = m + 1;
          else
            u = m;
        }
        return l;
      }
      function upper_bound(arr, N, value, _, l, u, m) {
        l = 0;
        u = N - 1;
        while (u > l) {
          m = int((l + u) / 2);
          if (arr[m] <= value)
            l = m + 1;
          else
            u = m;
        }
        return l;
      }
      function arr_range_inf(arr, N, value, _, r) {
        i = lower_bound(arr, N, value);
        if (i > 0 && value < arr[i]) i--;
        return i;
      }
      function arr_range_sup(arr, N, value, _, r) {
        i = upper_bound(arr, N, value);
        if (i + 1 < N && arr[i] < value) i++;
        return i;
      }

      /^[[:space:]]*(#|$)/ {next;}

      BEGIN {
        cjkwidth = 3;
        for (code = 0; code < 0x110000; code++) table[code] = -1;
      }

      function determine_width(eastAsianWidth, generalCategory) {
        if (generalCategory ~ /^(M[ne]|Cf)$/) return 0;

        if (eastAsianWidth == "A")
          eaw = cjkwidth;
        else if (eastAsianWidth == "W" || eastAsianWidth == "F")
          eaw = 2;
        else
          eaw = 1;

        if (generalCategory ~ /^(C[ncs]|Z[lp])$/)
          return -eaw;
        else
          return eaw;
      }

      $2 == "#" {
        if (match($1, /^([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
          beg = strtonum("0x" m[1]);
          end = beg + 1;
          eaw = m[2];
        } else if (match($1, /^([0-9a-fA-F]+)\.\.([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
          beg = strtonum("0x" m[1]);
          end = strtonum("0x" m[2]) + 1;
          eaw = m[3];
        } else {
          next;
        }

        w = determine_width(eaw, $3);
        for (code = beg; code < end; code++)
          table[code] = w;
      }

      function dump_table(filename) {
        printf "" > filename;
        out = "";
        for (c = 0; c < 0x110000; c++) {
          out = out " " table[c];
          if ((c + 1) % 32 == 0) {
            print out >> filename;
            out = "";
          }
        }
        close(filename);
      }

      function output_table(_, output_values, output_ranges, code, c0, v0, ranges, irange, p, c1, c2) {
        ISOLATED_THRESHOLD = 1; # 2 や 3 も試したが 1 が最も compact

        irange = 0;
        output_values = " ";
        output_ranges = " ";
        for (code = 0; code < 0x110000; ) {
          c0 = code++;
          v0 = table[c0];

          while (code < 0x110000 && table[code] == v0) code++;

          if (code - c0 <= ISOLATED_THRESHOLD) {
            for (; c0 < code; c0++)
              output_values = output_values " [" c0 "]=" v0;
          } else {
            ranges[irange++] = c0;
            output_values = output_values " [" c0 "]=" v0;
            output_ranges = output_ranges " " c0;
          }
        }
        ranges[irange++] = 0x110000;
        output_ranges = output_ranges " " 0x110000;

        sub(/^[[:space:]]+/, "", output_values);
        sub(/^[[:space:]]+/, "", output_ranges);
        print "_ble_unicode_EastAsianWidth_c2w=(" output_values ")"
        print "_ble_unicode_EastAsianWidth_c2w_ranges=(" output_ranges ")"

        output_index = " ";
        for (c1 = 0; c1 < 0x20000; c1 = c2) {
          c2 = c1 + 256;
          i1 = arr_range_inf(ranges, irange, c1);
          i2 = arr_range_sup(ranges, irange, c2);

          # assertion
          if (!(ranges[i1] <= c1 && c2 <= ranges[i2]))
            print "Error " ranges[i1] "<=" c1,c2 "<=" ranges[i2] > "/dev/stderr";

          if (i2 - i1 == 1)
            output_index = output_index " " table[c1];
          else
            output_index = output_index " " i1 ":" i2;
        }
        for (c1; c1 < 0x110000; c1 = c2) {
          c2 = c1 + 0x1000;
          i1 = arr_range_inf(ranges, irange, c1);
          i2 = arr_range_sup(ranges, irange, c2);
          if (i2 - i1 == 1)
            output_index = output_index " " table[c1];
          else
            output_index = output_index " " i1 ":" i2;
        }

        sub(/^[[:space:]]+/, "", output_index);
        print "_ble_unicode_EastAsianWidth_c2w_index=(" output_index ")";
      }

      END {
        output_table();
        dump_table("out/data/c2w.eaw-'"$version"'.dump");
      }

    ' "$data" | ifold -w 131 --spaces --no-text-justify --indent=.. > "out/data/c2w.eaw-$version.sh"
  done
}

function sub:generate-c2w-table {
  local version
  for version in {4.1,5.{0,1,2},6.{0..3},{7..11}.0,12.{0,1},13.0,14.0}.0; do
    local data=out/data/unicode-EastAsianWidth-$version.txt
    download http://www.unicode.org/Public/$version/ucd/EastAsianWidth.txt "$data"
    echo "__unicode_version__ $version"
    cat "$data"
  done | gawk '
    function lower_bound(arr, N, value, _, l, u, m) {
      l = 0;
      u = N - 1;
      while (u > l) {
        m = int((l + u) / 2);
        if (arr[m] < value)
          l = m + 1;
        else
          u = m;
      }
      return l;
    }
    function upper_bound(arr, N, value, _, l, u, m) {
      l = 0;
      u = N - 1;
      while (u > l) {
        m = int((l + u) / 2);
        if (arr[m] <= value)
          l = m + 1;
        else
          u = m;
      }
      return l;
    }
    function arr_range_inf(arr, N, value, _, r) {
      i = lower_bound(arr, N, value);
      if (i > 0 && value < arr[i]) i--;
      return i;
    }
    function arr_range_sup(arr, N, value, _, r) {
      i = upper_bound(arr, N, value);
      if (i + 1 < N && arr[i] < value) i++;
      return i;
    }

    function determine_width(EastAsianWidth, GeneralCategory) {
      if (GeneralCategory ~ /^(M[ne]|Cf)$/) return 0;

      if (EastAsianWidth == "A")
        eaw = cjkwidth;
      else if (EastAsianWidth == "W" || EastAsianWidth == "F")
        eaw = 2;
      else
        eaw = 1;

      if (GeneralCategory ~ /^(C[ncs]|Z[lp])$/)
        return -eaw;
      else
        return eaw;
    }

    BEGIN {
      cjkwidth = 3;
      iucsver = -1;
    }

    /^[[:space:]]*(#|$)/ {next;}

    $1 == "__unicode_version__" {
      print "Processing ucsver " $2 > "/dev/stderr";
      ucsver = $2;
      iucsver++;
      for (code = 0; code < 0x110000; code++)
        table[iucsver, code] = -1;

      if ($2 ~ /^[0-9]+\.[0-9]+\.[0-9]*$/)
        sub(/\.[0-9]*$/, "", $2)
      g_version_name[iucsver] = $2;
      next;
    }

    $2 == "#" {
      if (match($1, /^([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
        beg = strtonum("0x" m[1]);
        end = beg + 1;
        eaw = m[2];
      } else if (match($1, /^([0-9a-fA-F]+)\.\.([0-9a-fA-F]+);([^[:space:]]+)/, m)) {
        beg = strtonum("0x" m[1]);
        end = strtonum("0x" m[2]) + 1;
        eaw = m[3];
      } else {
        next;
      }

      w = determine_width(eaw, $3);
      for (code = beg; code < end; code++) table[iucsver, code] = w;
    }

    function combine_version(vermap_count, vermap_output, vermap_v2i, c, v, value) {
      vermap_count = 0;
      vermap_output = "";
      for (c = 0; c < 0x110000; c++) {
        value = table[0, c];
        for (v = 1; v <= iucsver; v++)
          value = value " " table[v, c];

        if (vermap_v2i[value] == "") {
          vermap_v2i[value] = vermap_count++;
          vermap_output = vermap_output "  " value "\n"
        }
        table[c] = vermap_v2i[value];
      }
      print "_ble_unicode_c2w_UnicodeVersionCount=" iucsver + 1;
      print "_ble_unicode_c2w_UnicodeVersionMapping=(";
      printf("%s", vermap_output);
      print ")";
    }

    function output_table(_, output_values, output_ranges, code, c0, v0, ranges, irange, p, c1, c2) {
      ISOLATED_THRESHOLD = 1; # 2 や 3 も試したが 1 が最も compact

      irange = 0;
      output_values = " ";
      output_ranges = " ";
      for (code = 0; code < 0x110000; ) {
        c0 = code++;
        v0 = table[c0];

        while (code < 0x110000 && table[code] == v0) code++;

        if (code - c0 <= ISOLATED_THRESHOLD) {
          for (; c0 < code; c0++)
            output_values = output_values " [" c0 "]=" v0;
        } else {
          ranges[irange++] = c0;
          output_values = output_values " [" c0 "]=" v0;
          output_ranges = output_ranges " " c0;
        }
      }
      ranges[irange++] = 0x110000;
      output_ranges = output_ranges " " 0x110000;

      sub(/^[[:space:]]+/, "", output_values);
      sub(/^[[:space:]]+/, "", output_ranges);
      print "_ble_unicode_c2w=(" output_values ")"
      print "_ble_unicode_c2w_ranges=(" output_ranges ")"

      output_index = " ";
      for (c1 = 0; c1 < 0x20000; c1 = c2) {
        c2 = c1 + 256;
        i1 = arr_range_inf(ranges, irange, c1);
        i2 = arr_range_sup(ranges, irange, c2);

        # assertion
        if (!(ranges[i1] <= c1 && c2 <= ranges[i2]))
          print "Error " ranges[i1] "<=" c1,c2 "<=" ranges[i2] > "/dev/stderr";

        if (i2 - i1 == 1)
          output_index = output_index " " table[c1];
        else
          output_index = output_index " " i1 ":" i2;
      }
      for (c1; c1 < 0x110000; c1 = c2) {
        c2 = c1 + 0x1000;
        i1 = arr_range_inf(ranges, irange, c1);
        i2 = arr_range_sup(ranges, irange, c2);
        if (i2 - i1 == 1)
          output_index = output_index " " table[c1];
        else
          output_index = output_index " " i1 ":" i2;
      }

      sub(/^[[:space:]]+/, "", output_index);
      print "_ble_unicode_c2w_index=(" output_index ")";
    }

    function generate_version_function() {
      print "function ble/unicode/c2w/version2index {";
      print "  case $1 in";
      for (v = 0; v <= iucsver; v++)
        print "  (" g_version_name[v] ") ret=" v " ;;";
      print "  (*) return 1 ;;";
      print "  esac";
      print "}"
      print "_ble_unicode_c2w_version=" iucsver;
    }

    END {
      print "Combining Unicode versions..." > "/dev/stderr";
      combine_version();
      print "Generating tables..." > "/dev/stderr";
      output_table();
      generate_version_function();
    }
  ' "$data" | ifold -w 131 --spaces --no-text-justify --indent=..
}

function sub:convert-custom-c2w-table {
  local -x name=$1
  gawk '
    match($0, /^[[:space:]]*U\+([[:xdigit:]]+)[[:space:]]+([0-9]+)/, m) {
      code = strtonum("0x" m[1]);
      w = m[2];

      g_output_values = g_output_values " [" code "]=" w;
      g_output_ranges = g_output_ranges " " code;
    }
    END {
      name = ENVIRON["name"];
      print name "=(" substr(g_output_values, 2) ")";
      # print name "_ranges=(" substr(g_output_ranges, 2) ")";
      print name "_ranges=(\"${!" name "[@]}\")"
    }
  ' | ifold -w 131 --spaces --no-text-justify --indent=..
}

function sub:update-GeneralCategory {
  local version
  for version in {4.1,5.{0,1,2},6.{0..3},{7..11}.0,12.{0,1},13.0}.0; do
    local data=out/data/unicode-UnicodeData-$version.txt
    download "http://www.unicode.org/Public/$version/ucd/UnicodeData.txt" "$data" || continue

    # 4.1 -> 401, 13.0 -> 1300, etc.
    local VER; IFS=. eval 'VER=($version)'
    printf -v VER '%d%02d' "${VER[0]}" "${VER[1]}"

    gawk -F ';' -v VER="$VER" '
      BEGIN {
        mode = 0;
        range_beg = 0;
        range_end = 0;
        range_cat = "";
        table = "";
        range = "";
      }

      function register_range(beg, end, cat, _, i) {
        # printf("%x %x %s\n", beg, end, cat);
        if (end - beg <= 2) {
          for (i = beg; i < end; i++)
            table = table " [" i "]=" cat;
        } else {
          range = range " " beg;
          table = table " [" beg "]=" cat;
        }
      }

      function close_range(){
        if (range_cat != "")
          register_range(range_beg, range_end, range_cat);
        if (code > range_end)
          register_range(range_end, code, "Cn");
      }

      {
        code = strtonum("0x" $1);
        cat = $3;

        if (mode == 1) {
          if (!($2 ~ /Last>/)) {
            print "Error: <..., First> is expected" > "/dev/stderr";
          } else if (range_cat != cat) {
            print "Error: mismatch of General_Category of First and Last." > "/dev/stderr";
          }
          range_end = code + 1;
          mode = 0;
        } else {
          if (code > range_end || range_cat != cat){
            close_range();
            range_beg = code;
            range_cat = cat;
          }
          range_end = code + 1;

          if ($2 ~ /First>/) {
            mode = 1;
          } else if ($2 ~ /Last>/) {
            print "Error: <..., Last> is unexpected" > "/dev/stderr";
          }
        }
      }

      END {
        code = 0x110000;
        close_range();

        print "_ble_unicode_GeneralCategory" VER "=(" substr(table, 2) ")";
        print "_ble_unicode_GeneralCategory" VER "_range=(" substr(range, 2) ")";
      }
    ' "$data" | ifold -w 131 --spaces --no-text-justify --indent=.. > "out/data/GeneralCategory.$version.txt"
  done
}

#------------------------------------------------------------------------------
# sub:check
# sub:check-all

function sub:check {
  bash out/ble.sh --test
}
function sub:check-all {
  local -x _ble_make_command_check_count=0
  local bash rex_version='^bash-([0-9]+)\.([0-9]+)$'
  for bash in $(compgen -c -- bash- | grep -E '^bash-[0-9]+\.[0-9]+$' | sort -Vr); do
    [[ $bash =~ $rex_version && ${BASH_REMATCH[1]} -ge 3 ]] || continue
    "$bash" out/ble.sh --test || return 1
    ((_ble_make_command_check_count++))
  done
}

#------------------------------------------------------------------------------
# sub:scan

function sub:scan/grc-source {
  local -a options=(--color --exclude=./{test,memo,ext,wiki,contrib,[TD]????.*} --exclude=\*.{md,awk} --exclude=./{GNUmakefile,make_command.sh})
  grc "${options[@]}" "$@"
}
function sub:scan/list-command {
  local -a options=(--color --exclude=./{test,memo,ext,wiki,contrib,[TD]????.*} --exclude=\*.{md,awk})

  # read arguments
  local flag_exclude_this= flag_error=
  local command=
  while (($#)); do
    local arg=$1; shift
    case $arg in
    (--exclude-this)
      flag_exclude_this=1 ;;
    (--exclude=*)
      ble/array#push options "$arg" ;;
    (--)
      [[ $1 ]] && command=$1
      break ;;
    (-*)
      echo "check: unknown option '$arg'" >&2
      flag_error=1 ;;
    (*)
      command=$arg ;;
    esac
  done
  if [[ ! $command ]]; then
    echo "check: command name is not specified." >&2
    flag_error=1
  fi
  [[ $flag_error ]] && return 1

  [[ $flag_exclude_this ]] && ble/array#push options --exclude=./make_command.sh
  grc "${options[@]}" "(^|[^-./\${}=#])\b$command"'\b([[:space:]|&;<>()`"'\'']|$)'
}

function sub:scan/builtin {
  echo "--- $FUNCNAME $1 ---"
  local command=$1 esc='(\[[ -?]*[@-~])*'
  sub:scan/list-command --exclude-this --exclude={generate-release-note.sh,lib/test-*.sh} "$command" "${@:2}" |
    grep -Ev "$rex_grep_head([[:space:]]*|[[:alnum:][:space:]]*[[:space:]])#|(\b|$esc)(builtin|function)$esc([[:space:]]$esc)+$command(\b|$esc)" |
    grep -Ev "$command(\b|$esc)=" |
    grep -Ev "ble\.sh $esc\($esc$command$esc\)$esc" |
    sed -E 'h;s/'"$esc"'//g;\Z(\.awk|push|load|==) \b'"$command"'\bZd;g'
}

function sub:scan/check-todo-mark {
  echo "--- $FUNCNAME ---"
  grc --color --exclude=./make_command.sh '@@@'
}
function sub:scan/a.txt {
  echo "--- $FUNCNAME ---"
  grc --color --exclude=./{test,ext} --exclude=./lib/test-*.sh --exclude=./make_command.sh --exclude=\*.md 'a\.txt|/dev/(pts/|pty)[0-9]*' |
    grep -Ev "$rex_grep_head#|[[:space:]]#|DEBUG_LEAKVAR"
}

function sub:scan/bash300bug {
  echo "--- $FUNCNAME ---"
  # bash-3.0 では local arr=(1 2 3) とすると
  # local arr='(1 2 3)' と解釈されてしまう。
  grc 'local [a-zA-Z_]+=\(' --exclude=./{test,ext} --exclude=./make_command.sh --exclude=ChangeLog.md

  # bash-3.0 では local -a arr=("$hello") とすると
  # クォートしているにも拘らず $hello の中身が単語分割されてしまう。
  grc 'local -a [[:alnum:]_]+=\([^)]*[\"'\''`]' --exclude=./{test,ext} --exclude=./make_command.sh

  # bash-3.0 では "${scalar[@]/xxxx}" は全て空になる
  grc '\$\{[a-zA-Z_0-9]+\[[*@]\]/' --exclude=./{text,ext} --exclude=./make_command.sh --exclude=\*.md --color |
    grep -v '#D1570'

}

function sub:scan/bash301bug-array-element-length {
  echo "--- $FUNCNAME ---"
  # bash-3.1 で ${#arr[index]} を用いると、
  # 日本語の文字数が変になる。
  grc '\$\{#[[:alnum:]]+\[[^@*]' --exclude={test,ChangeLog.md} | grep -Ev '^([^#]*[[:space:]])?#'
}

function sub:scan/assign {
  echo "--- $FUNCNAME ---"
  local command="$1"
  grc --color --exclude=./test --exclude=./memo '\$\([^()]' |
    grep -Ev "$rex_grep_head#|[[:space:]]#"
}

function sub:scan/memo-numbering {
  echo "--- $FUNCNAME ---"

  grep -ao '\[#D....\]' note.txt memo/done.txt | awk '
    function report_error(message) {
      printf("memo-numbering: \x1b[1;31m%s\x1b[m\n", message) > "/dev/stderr";
    }
    !/\[#D[0-9]{4}\]/ {
      report_error("invalid  number \"" $0 "\".");
      next;
    }
    {
      num = $0;
      gsub(/^\[#D0+|\]$/, "", num);
      if (prev != "" && num != prev - 1) {
        if (prev < num) {
          report_error("reverse ordering " num " has come after " prev ".");
        } else if (prev == num) {
          report_error("duplicate number " num ".");
        } else {
          for (i = prev - 1; i > num; i--) {
            report_error("memo-numbering: missing number " i ".");
          }
        }
      }
      prev = num;
    }
    END {
      if (prev != 1) {
        for (i = prev - 1; i >= 1; i--)
          report_error("memo-numbering: missing number " i ".");
      }
    }
  '
  cat note.txt memo/done.txt | sed -n '0,/^[[:space:]]\{1,\}Done/d;/  \* .*\[#D....\]$/d;/^  \* /p'
}

# 誤って ((${#arr[@]})) を ((${arr[@]})) などと書いてしまうミス。
function sub:scan/array-count-in-arithmetic-expression {
  echo "--- $FUNCNAME ---"
  grc --exclude=./make_command.sh '\(\([^[:space:]]*\$\{[[:alnum:]_]+\[[@*]\]\}'
}

# unset 変数名 としていると誤って関数が消えることがある。
function sub:scan/unset-variable {
  echo "--- $FUNCNAME ---"
  local esc='(\[[ -?]*[@-~])*'
  sub:scan/list-command unset --exclude-this |
    grep -Ev "unset$esc[[:space:]]$esc-[vf]|$rex_grep_head[[:space:]]*#"
}
function sub:scan/eval-literal {
  echo "--- $FUNCNAME ---"
  local esc='(\[[ -?]*[@-~])*'
  sub:scan/grc-source 'builtin eval "\$' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zeval "(\$[[:alnum:]_]+)+(\[[^]["'\''\$`]+\])?\+?=Zd
      g'
}

function sub:scan/WA-localvar_inherit {
  echo "--- $FUNCNAME ---"
  grc 'local [^;&|()]*"\$\{[a-zA-Z_0-9]+\[@*\]\}"'
}

function sub:scan/mistake-_ble_bash {
  echo "--- $FUNCNAME ---"
  grc '\(\(.*\b_ble_base\b.*\)\)'
}

function sub:scan {
  if ! type grc >/dev/null; then
    echo 'blesh check: grc not found. grc can be found in github.com:akinomyoga/mshex.git/' >&2
    exit
  fi

  local esc='(\[[ -?]*[@-~])*'
  local rex_grep_head="^$esc[[:graph:]]+$esc:$esc[[:digit:]]*$esc:$esc"

  # builtin return break continue : eval echo unset は unset しているので大丈夫のはず

  #sub:scan/builtin 'history'
  sub:scan/builtin 'echo' --exclude=./keymap/vi_test.sh --exclude=./ble.pp |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Z\bstty[[:space:]]+echoZd
      \Zecho \$PPIDZd
      g'
  #sub:scan/builtin '(compopt|type|printf)'
  sub:scan/builtin 'bind' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zinvalid bind typeZd
      \Zline = "bind"Zd
      \Z'\''  bindZd
      \Z\(bind\)    ble-bindZd
      g'
  sub:scan/builtin 'read' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \ZDo not read Zd
      \Zfailed to read Zd
      g'
  sub:scan/builtin 'exit' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zble.pp.*return 1 2>/dev/null || exit 1Zd
      \Z^[-[:space:][:alnum:]_./:=$#*]+('\''[^'\'']*|"[^"()`]*|([[:space:]]|^)#.*)\bexit\bZd
      \Z\(exit\) ;;Zd
      \Zprint NR; exit;Zd;g'
  sub:scan/builtin 'eval' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Z\('\''eval'\''\)Zd
      \Zbuiltins1=\(.* eval .*\)Zd
      \Z\^eval --Zd
      \Zt = "eval -- \$"Zd
      \Ztext = "eval -- \$'\''Zd
      \Zcmd '\''eval -- %q'\''Zd
      \Z\$\(eval \$\(call .*\)\)Zd
      g'
  sub:scan/builtin 'unset' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zunset _ble_init_(version|arg|exit|command)\bZd
      \Zreadonly -f unsetZd
      \Zunset -f builtinZd
      g'
  sub:scan/builtin 'unalias' |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zbuiltins1=\(.* unalias .*\)Zd
      g'

  #sub:scan/assign
  sub:scan/builtin trap |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zble/util/print "trap -- '\''\$\{h//\$Q/\$q}'\'' \$nZd
      \Zline = "bind"Zd
      \Zlocal trap_command="trap -- Zd
      \Zlocal trap$Zd
      g'

  sub:scan/a.txt
  sub:scan/check-todo-mark
  sub:scan/bash300bug
  sub:scan/bash301bug-array-element-length
  sub:scan/array-count-in-arithmetic-expression
  sub:scan/unset-variable |
    sed -E 'h;s/'"$esc"'//g;s/^[^:]*:[0-9]+:[[:space:]]*//
      \Zunset _ble_init_(version|arg|exit|command)\bZd
      \Zbuiltins1=\(.* unset .*\)Zd
      \Zfunction unsetZd
      \Zreadonly -f unsetZd
      g'
  sub:scan/eval-literal
  sub:scan/WA-localvar_inherit
  sub:scan/mistake-_ble_bash

  sub:scan/memo-numbering
}

function sub:show-contrib {
  local cache_contrib_github=out/contrib-github.txt
  if [[ ! ( $cache_contrib_github -nt .git/refs/remotes/origin/master ) ]]; then
    {
      wget 'https://api.github.com/repos/akinomyoga/ble.sh/issues?state=all&per_page=100&pulls=true' -O -
      wget 'https://api.github.com/repos/akinomyoga/blesh-contrib/issues?state=all&per_page=100&pulls=true' -O -
    } |
      sed -n 's/^[[:space:]]*"login": "\(.*\)",$/\1/p' |
      sort | uniq -c | sort -rn > "$cache_contrib_github"
  fi

  echo "Contributions (from GitHub Issues/PRs)"
  cat "$cache_contrib_github"

  echo "Contributions (from memo.txt)"
  sed -En 's/^  \* .*\([^()]+ by ([^()]+)\).*/\1/p' memo/done.txt note.txt |
    sort | uniq -c | sort -rn

  echo "Contributions (from ChangeLog.md)"
  sed -n 's/.*([^()]* by \([^()]*\)).*/\1/p' memo/ChangeLog.md |
    sort | uniq -c | sort -rn
  echo
}

#------------------------------------------------------------------------------
# sub:release-note
#
# 使い方
# ./make_command.sh release-note v0.3.2..v0.3.3

function sub:release-note/help {
  printf '  release-note v0.3.2..v0.3.3 [--changelog CHANGELOG]\n'
}

function sub:release-note/read-arguments {
  flags=
  fname_changelog=memo/ChangeLog.md
  while (($#)); do
    local arg=$1; shift 1
    case $arg in
    (--changelog)
      if (($#)); then
        fname_changelog=$1; shift
      else
        flags=E$flags
        echo "release-note: missing option argument for '$arg'." >&2
      fi ;;
    esac
  done
}

function sub:release-note/.find-commit-pairs {
  {
    echo __MODE_HEAD__
    git log --format=format:'%h%s' --date-order --abbrev-commit "$1"; echo
    echo __MODE_MASTER__
    git log --format=format:'%h%s' --date-order --abbrev-commit master; echo
  } | awk -F '' '
    /^__MODE_HEAD__$/ {
      mode = "head";
      nlist = 0;
      next;
    }
    /^__MODE_MASTER__$/ { mode = "master"; next; }

    mode == "head" {
      i = nlist++;
      titles[i] = $2
      commit_head[i] = $1;
      title2index[$2] = i;
    }
    mode == "master" && (i = title2index[$2]) != "" && commit_master[i] == "" {
      commit_master[i] = $1;
    }

    END {
      for (i = 0; i < nlist; i++) {
        print commit_head[i] ":" commit_master[i] ":" titles[i];
      }
    }
  '
}

function sub:release-note {
  local flags fname_changelog
  sub:release-note/read-arguments "$@"

  ## @arr commits
  ##   この配列は after:before の形式の要素を持つ。
  ##   但し after は前の version から release までに加えられた変更の commit である。
  ##   そして before は after に対応する master における commit である。
  local -a commits
  IFS=$'\n' eval 'commits=($(sub:release-note/.find-commit-pairs "$@"))'

  local commit_pair
  for commit_pair in "${commits[@]}"; do
    local a=${commit_pair%%:*}
    commit_pair=${commit_pair:${#a}+1}
    local b=${commit_pair%%:*}
    local c=${commit_pair#*:}

    local result=
    [[ $b ]] && result=$(awk '
        sub(/^##+ +/, "") { heading = "[" $0 "] "; next; }
        sub(/\y'"$b"'\y/, "'"$a (master: $b)"'") {print heading $0;}
      ' "$fname_changelog")
    if [[ $result ]]; then
      echo "$result"
    elif [[ $c ]]; then
      echo "- $c $a (master: ${b:-N/A}) ■NOT-FOUND■"
    else
      echo "■not found $a"
    fi
  done | tac
}

#------------------------------------------------------------------------------

function sub:list-functions/help {
  printf '  list-functions [-p] files...\n'
}
function sub:list-functions {
  local -a files; files=()
  local opt_literal=
  local i=0 N=$# args; args=("$@")
  while ((i<N)); do
    local arg=${args[i++]}
    if [[ ! $opt_literal && $arg == -* ]]; then
      if [[ $arg == -- ]]; then
        opt_literal=1
      elif [[ $arg == --* ]]; then
        printf 'list-functions: unknown option "%s"\n' "$arg" >&2
        opt_error=1
      elif [[ $arg == -* ]]; then
        local j
        for ((j=1;j<${#arg};j++)); do
          local o=${arg:j:1}
          case $o in
          (p) opt_public=1 ;;
          (*) printf 'list-functions: unknown option "-%c"\n' "$o" >&2
              opt_error=1 ;;
          esac
        done
      fi
    else
      files+=("$arg")
    fi
  done

  if ((${#files[@]}==0)); then
    files=($(find out -name \*.sh -o -name \*.bash))
  fi

  if [[ $opt_public ]]; then
    local rex_function_name='[^[:space:]()/]*'
  else
    local rex_function_name='[^[:space:]()]*'
  fi
  sed -n 's/^[[:space:]]*function \('"$rex_function_name"'\)[[:space:]].*/\1/p' "${files[@]}" | sort -u
}

function sub:first-defined {
  local name dir
  for name; do
    for dir in ../ble-0.{1..3} ../ble.sh; do
      (cd "$dir"; grc "$name" &>/dev/null) || continue
      echo "$name $dir"
      return 0
    done
  done
  echo "$name not found"
  return 1
}
function sub:first-defined/help {
  printf '  first-defined KEYWORDS...\n'
}

#------------------------------------------------------------------------------

function sub:scan-words {
  # sed -E "s/'[^']*'//g;s/(^| )[[:space:]]*#.*/ /g" $(findsrc --exclude={wiki,test,\*.md}) |
  #   grep -hoE '\$\{?[_a-zA-Z][_a-zA-Z0-9]*\b|\b[_a-zA-Z][-:._/a-zA-Z0-9]*\b' |
  #   sed -E 's/^\$\{?//g;s.^ble/widget/..;\./.!d;/:/d' |
  #   sort | uniq -c | sort -n
  sed -E "s/(^| )[[:space:]]*#.*/ /g" $(findsrc --exclude={memo,wiki,test,\*.md}) |
    grep -hoE '\b[_a-zA-Z][_a-zA-Z0-9]{3,}\b' |
    sed -E 's/^bleopt_//' |
    sort | uniq -c | sort -n | less
}
function sub:scan-varnames {
  sed -E "s/(^| )[[:space:]]*#.*/ /g" $(findsrc --exclude={wiki,test,\*.md}) |
    grep -hoE '\$\{?[_a-zA-Z][_a-zA-Z0-9]*\b|\b[_a-zA-Z][_a-zA-Z0-9]*=' |
    sed -E 's/^\$\{?(.*)/\1$/g;s/[$=]//' |
    sort | uniq -c | sort -n | less
}

#------------------------------------------------------------------------------
# sub:check-readline-bindable

function sub:check-readline-bindable {
  join -v1 <(
    for bash in bash $(compgen -c -- bash-); do
      [[ $bash == bash-[12]* ]] && continue
      "$bash" -c 'bind -l' 2>/dev/null
    done | sort -u
  ) <(sort lib/core-decode.emacs-rlfunc.txt)
}

#------------------------------------------------------------------------------

if (($#==0)); then
  sub:help
elif declare -f sub:"$1" &>/dev/null; then
  sub:"$@"
else
  echo "unknown subcommand '$1'" >&2
  builtin exit 1
fi
