#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Outputs
# pikles color: [38;5;41m]
# empoleon color: [38;5;68m]
PS1="\[\033[38;5;68m\][\u@\h\[$(tput sgr0)\] \[\033[38;5;244m\]\W\[\033[38;5;68m\]]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
LS_COLORS=$LS_COLORS:'di=0;35:'; export LS_COLORS

# efibootmgr command:
#efibootmgr --create --disk /dev/sda --part 1 --label "Arch Linux No IPv6" --loader /vmlinuz-linux --unicode 'root=/dev/sda2 rw initrd=/intel-ucode.img initrd=/initramfs-linux.img ipv6.disable=1'

# Aliases
alias ls='ls --color=auto'
alias vim='vim --servername vim'
alias grep='grep --color=auto'
alias please='sudo bash -c "$(history -p !!)"'
alias fpac='find /etc -regextype posix-extended -regex ".+\.pac(new|save|orig)" 2> /dev/null'
alias fbsym='find . -type l -! -exec test -e {} \; -print'
alias updmirrors="sudo reflector --verbose -c 'United States' -l 200 -p http -f 20 --sort rate --save /etc/pacman.d/mirrorlist"
alias clearpac="sudo paccache -rk2 && paccache -ruk0"
alias plugvga='xrandr --output VGA1 --left-of eDP1 --auto && . ~/.fehbg'
alias plugdp='xrandr --output HDMI1 --left-of eDP1 --auto && . ~/.fehbg'
alias unplug='xrandr --output VGA1 --off && xrandr --output HDMI1 --off && . ~/.fehbg'
alias ntetris='~/school/compsci/misc/dank-nooodls-vitetris/tetris'
alias lpr-4tile='lpr -o number-up=4 -o orientation-requested=5 -o number-up-layout-btlr -o sides=two-sided-long-edge'
alias swe5='feh --zoom 33 ~/misc/swe5.jpg & disown'
alias tcr='feh --zoom 33 ~/misc/tcr.jpg & disown'
alias left_gif='byzanz-record -v -x 1 -y 17 -w 681 -h 750'
alias resettp='sh ~/.reset_tp.sh'
alias ncwd='urxvt & disown'
alias gitempty='git add -A && git commit --allow-empty-message -m "" && git push'
alias rewi='sudo systemctl restart netctl-auto@wlp3s0'
alias reencodemp3all='for dir in ./*; do reencodemp3dir "$dir"; done'
alias youtube-dl-mp3='youtube-dl -x --audio-format mp3 --audio-quality 0'
alias bannedcamp='python $HOME/school/compsci/misc/bandcamp_not_safe/dl_album.py'
alias muxivfarm='python $HOME/school/compsci/misc/muxiv_farmer/dl_album.py'
alias riptistory='python $HOME/school/compsci/misc/rip_tistory/dl_album.py'

# Temporary aliases

# Environment Variables
export PATH="${PATH}"
export BROWSER="qutebrowser"
export R_ENVIRON_USER="~/.config/R/.Renviron"
export CLASSPATH="${CLASSPATH}:/usr/share/java/junit.jar:/usr/share/java/hamcrest-core.jar:./"
export PYTHONSTARTUP="$HOME/.python_startup.py"

# Functions
wipedisk() {
  if [[ -e "$1" && -b "$1" ]];then
    NOT_safe="$(lsblk -o "NAME,MOUNTPOINT" ${1//[0-9]/} | grep -e / -e '\]')";
    if [[ -z "$NOT_safe" ]];then
      sudo dd if=/dev/zero of="$1"
      # Here you can use any of your favourite wiping tools
      # to wipe destination passed on command line and stored in variable "$1"
      #
    else
      echo 'Not allowed to destroy if any of the partitions is mounted: '"$NOT_safe"
      fi
      fi
    }

find_containing() {
    # list files matching $1 that contain $2
    find ./ -name "$1" -exec grep -l "$2" {} +
}

cplsty() {
  cp $HOME/school/latextemplates/style.sty ${1-style.sty}
}

cpldoc() {
  cp $HOME/school/latextemplates/document.tex ${1-document.tex}
}

zpdfd() {
  zathura "$1" & disown
}

javacr() {
  javac $1 && java $(echo $1 | awk -F '.java' '{print $1}')
}

junittest() {
  java org.junit.runner.JUnitCore $(echo $1 | awk -F '.java' '{print $1}')
}

prevpac() {
  expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n $1
}

adbaddmusic() {
  adb push ~/music/ /sdcard/Music/
}

7zxo() {
  7z x -o"${1%.*}" "$1"
}

cl() {
  if [[ "$1" == "-a" ]]; then
    local dir="$2"
  else
    local dir="$1"
  fi

  local dir="${dir:=$HOME}"

  if [[ -d "$dir"  ]]; then
    if [[ "$1" == "-a" ]]; then
      cd "$dir" >/dev/null; ls -a
    else
      cd "$dir" >/dev/null; ls
    fi
  else
    echo "bash: cl: $dir: Directory not found"
  fi
}

mergepdf() {
  outputfile=$1
  shift
  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOUTPUTFILE=$outputfile "$@"
}

silenceremove() {
    ffmpeg -i "$1" -af "silenceremove=start_periods=1:start_duration=0:start_threshold=0.04:detection=peak,areverse,silenceremove=start_periods=1:start_duration=0:start_threshold=0.04:detection=peak,areverse" "$2"
}

silenceremovedir() {
  inputdir=$1
  outputdir=${inputdir%/}_silenceremoved
  mkdir "$outputdir"

  for inputfile in "${inputdir}"/*.mp3; do
    outputfile=${outputdir}/$(basename "$inputfile")
    silenceremove "$inputfile" "$outputfile"
  done
}

flacify() {
  ffmpeg -i "$1" -c:a flac -compression_level 0 -y "${1%.*}.flac"
}

libmp3lame_convert() {
  ffmpeg -i "$2" -c:a libmp3lame -q:a 0 -map_metadata 0 -y "${2%.*}.$1"
}

reencodemp3() {
  # for some reason libmp3lame causes seeking problems and lame doesn't
  mp3="$1"
  base="${mp3%.mp3}"
  wav="${base}.wav"
  tagged="${base}_tagged.mp3"
  libmp3lame_convert wav "$mp3"
  mv -v "$mp3" "$tagged"
  lame -V 0 "$wav" "$mp3"
  id3cp "$tagged" "$mp3"
  rm -v "$tagged" "$wav"
}

reencodemp3dir() {
  for mp3 in "$1"/*.mp3; do
    reencodemp3 "$mp3"
  done
}

# Temporary Functions

shopt -s extglob
set -o vi
set -o ignoreeof
