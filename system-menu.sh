#!/bin/bash

tempfile=`tempfile 2>/dev/null` || tempfile=~/.temp$$
trap "rm -f $tempfile" 0 1 2 5 15

#if [ -z $DISPLAY ]; then
#   DIALOG=dialog
#else
#   DIALOG=Xdialog
#fi

function main {
   dialog --backtitle "System Tools" --menu "Main Menu" 15 30 5 \
        1 "Burn" \
        2 "Games" \
        3 "Rootkit" \
        4 "Scanner" \
        5 "Portage" 2> $tempfile
        
    choice=`cat $tempfile`
    case ${choice} in
        1) mburn;;
        2) mgames;;
        3) mrootkit;;
        4) mscanners;;
        5) mportage;;
    esac
}

function mburn {
    dialog --backtitle "System Tools" --menu "Burn Menu" 15 30 9 \
        1 "Rip audio" \
        2 "Rip mp3" \
        3 "Rip ogg" \
        4 "Mkisofs" \
        5 "Burn audio" \
        6 "Burn CD ISO" \
        7 "Burn DVD ISO" \
       "" "" \
        8 "Main Menu" 2>$tempfile

    CDROM=`/bin/grep cdrom /etc/fstab | /usr/bin/awk -F " " '{print $1}'`
    choice=`cat $tempfile`
    case ${choice} in
        1) getTrack; /usr/bin/cdparanoia -B -- "-${numTracks}";;
        2) /usr/bin/rip -b 128 -vncT -f "%S - %A";;
        3) /usr/bin/rip -TOnc -q 6 "%S - %A";;
        4) fselect && /usr/bin/mkisofs -rJ -o IMAGE.ISO "$file";;
        5) fselect && /usr/bin/cdrecord -v -pad -dao speed=8 dev=${CDROM} \
            -audio "$file"/track*.cdda.wav;;
        6) fselect && /usr/bin/cdrecord -v -dao driveropts=burnfree \
            dev=${CDROM} "$file";;
        7) fselect && /usr/bin/growisofs -dvd-compat -Z /dev/dvd=${file};;
        8) main;;
    esac
}

function mrootkit {
    dialog --backtitle "System Tools" --menu "Rootkit Menu" 15 30 5 \
        1 "chkroot" \
        2 "rkhunter" \
       "" "" \
        4 "Main Menu" 2> $tempfile
    
    choice=`cat $tempfile`
    case ${choice} in
        1) sudo chkrootkit;;
        2) sudo rkhunter -c;;
        4) main;;
    esac
}

function mportage {
    dialog --backtitle "System Tools" --menu "Portage Menu" 20 30 13 \
        1 "Sync" \
        2 "Update" \
        3 "Depclean" \
        4 "Revdep-rebuild" \
        5 "GLSA fix" \
        6 "._configs" \
        7 "cfind + diff" \
        8 "Clean world" \
        9 "Rebuild world" \
       10 "Clean deps" \
       11 "Emerge info" \
       "" "" \
       12 "Main Menu" 2> $tempfile

    choice=`cat $tempfile`
    case ${choice} in
        1) sudo emerge --sync;;
        2) sudo emerge -uav world;;
        3) sudo emerge -av --depclean;;
        4) sudo revdep-rebuild -p;;
        5) sudo glsa-check -f all;;
        6) echo "Searching for new configs"; find /etc/ -iname '._*';;
        7) echo "Not yet implemented";;
        8) sudo /opt/bin/dep -wa;;
        9) sudo equery -C -q list | cut -d ' ' -f 5 | \
            sed -n 's/-[0-9]\{1,\}.*$//p' >> $HOME/world.new;;
       10) sudo /opt/bin/dep -da;;
       11) sudo emerge --info;;
       12) main;;
    esac
}

function fselect {
    file=`dialog --stdout --backtitle "System Tools" \
        --title "Select file" --fselect $HOME/ 14 48`
}

function getTrack {
    numTracks=`dialog --stdout --backtitle "System Tools" --inputbox \
        "Enter total number of tracks on CD" 15 40`
}

main
# Interesting tips: linuxTips, valgrind, gdb, strace, jacktheripper, sleuthkit, modprobes (usb-storage, *-hcd, ndiswrapper), 
