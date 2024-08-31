#!/bin/bash
# manl 2024-08-09
# dependencies: man-db nano leafpad xorg-server

#=======================================================================================================
			# Uncomment/edit next 3 lines if your EDITOR is not setup.

# CLIeditor=nano
# GUIeditor=leafpad
# [[ -z ${DISPLAY} ]] && Editor="${CLIeditor}" || Editor="${GUIeditor}"

[[ ! -v EDITOR ]] && [[ ! -v  Editor ]] && { echo " ERROR: EDITOR variable not set. See manl script, \"EDITOR is not setup\"." ; exit ; }

#=======================================================================================================
			# Check/install deps

if	! type man leafpad nano Xorg &>/dev/null; then
	printf '\n%s\n' " ERROR: Manl dependencies missing."
	printf '%s\n'   " Rechecking/installing dependencies with pacman."
	printf '%s\n\n' " Note: Password will fail with sudo if manl is backgrounded '&' for the 1st run and this comes up."
	sudo pacman --color=always -S --needed man-db leafpad nano xorg-server
	exit
fi

#=======================================================================================================

[[ -z ${Editor} ]] && Editor="${EDITOR}"								### SC2153 Setting Editor, not EDITOR.
[[ ! -d ${HOME}/.manl ]] && mkdir -p "${HOME}"/.manl							### Create ${HOME}/.manl if not setup.

#=======================================================================================================
	# Cleanup. If term closed without closing manl, leaves unwanted stuff in ~/.manl

	trap 'rm ~/.manl/"${1}_${2}_" /tmp/"${1}_${2}_" ~/.manl/"${1}_" /tmp/"${1}_" 2>/dev/null' INT TERM EXIT

#=======================================================================================================
			# Print [-h --help] page

if	[[ -z ${1} ]] || [[ ${1} = -h ]] || [[ ${1} = --help ]]; then

cat << 'EOF'

    manl opens man pages in your editor, prepended by either
    existing notes and/or conveniently edit/create notes.

    Operations:
		-h --help  =  help page
		-sn        =  Search for <manpage> numbers
		-st        =  Search manpages for <term> "man -k <term>"
		-la	   =  List all manpages on system.

    Usage   :  manl [operation] <manpage> -or-  manl <number> <manpage>
    Examples:  manl signal    -or-  manl 7 signal
               manl -sn signal
	       manl -la | grep ^pac

    Man pages path  : /usr/share/man/man<#>/<NAME>.<#>.gz
    Saved notes path:  ~/.manl/<NAME>  -OR-  ~/.manl/<#> <NAME>

    To save notes, just save in editor.
    manl will create or edit ~/.manl/<NAME>  -OR-  ~/.manl/<#> <NAME> as needed.
    Manpage is removed from notes after saving.
    No changes are made to manpages.

    IMPORTANT INFO: The manpage is removed from saved notes via setting ${del} variable, which is the first
    		    column in the first line of the man page, usually something like "MANPAGE-NAME(1)".
		    If you duplicate this in your notes, everything after it will be deleted.

EOF
	exit
fi

#=======================================================================================================
			# Search Operations 	# man -wK "${2}" | awk -F / '{print $5 " " $6}'

if	[[ $1 = -sn ]]; then
	find /usr/share/man/man* | awk -v manp="${2}" -F / ' $0 ~ "/"manp {print $5 " " $6}'
    exit
fi

if	[[ $1 = -st ]]; then
	man -k "${2}"
    exit
fi

if	[[ $1 = -la ]]; then
	/usr/bin/ls /usr/share/man/man* | grep -v '/usr/share/' | awk 'NF' | sort      # | awk -F.gz '{print $1}'
	echo; echo "Path: "/usr/share/man/man \<#\> / \<NAME\> ; echo
    exit
fi

#=======================================================================================================
			# Prep existing notes + manpage for editor
			# else
			# Prep manpage for editor + potential note save
			# Add ability when "manpage unavailable", to open if present ~/.manl/<notes>. (For "notes title" symlinks.)

if	[[ -n ${2} ]] && [[ -e  ~/.manl/${1}_${2} ]]; then		### IF [NUMBER]_[MANPAGE] exists in ~/.manl
	cp ~/.manl/"${1}_${2}" /tmp/"${1}_${2}_"
#	MANWIDTH=146 man "${1}" "${2}" >>/tmp/"${1}_${2}_"
	MANWIDTH=146 man "${1}" "${2}" >>/tmp/"${1}_${2}_" 2>/dev/null
    elif
	[[ -n ${2} ]]; then

#	MANWIDTH=146 man "${1}" "${2}" >>/tmp/"${1}_${2}_" || exit	#[[ -s ~/.manl/${1}_${2} ]] && "$Editor" ~/.manl/"${1}_${2}" ; exit || exit
	MANWIDTH=146 man "${1}" "${2}" >>/tmp/"${1}_${2}_"  2>/dev/null || exit
fi


if	[[ -z ${2} ]] && [[ -e ~/.manl/${1} ]]; then			### IF (no number) [MANPAGE] exists in ~/.manl
	cp ~/.manl/"${1}" /tmp/"${1}_"
#	MANWIDTH=146 man "${1}" >>/tmp/"${1}_"
	MANWIDTH=146 man "${1}" >>/tmp/"${1}_"  2>/dev/null
    elif
	[[ -z ${2} ]]; then

#	MANWIDTH=146 man "${1}" >>/tmp/"${1}_" || exit			#[[ -s ~/.manl/${1} ]] ; "$Editor" ~/.manl/"${1}" ; exit || exit
	MANWIDTH=146 man "${1}" >>/tmp/"${1}_" || exit   2>/dev/null
fi


#=======================================================================================================
			# Print manpage, or notes + manpage, in editor

if	[[ -n ${2} ]]; then						### IN EDITOR [NUMBER]_[MANPAGE]
	cp /tmp/"${1}_${2}_" ~/.manl/"${1}_${2}_"
	"$Editor" ~/.manl/"${1}_${2}_"

	tmpmd5=$(md5sum /tmp/"${1}_${2}_" | awk '{ print $1 }')
	manlmd5=$(md5sum ~/.manl/"${1}_${2}_" | awk '{ print $1 }')
	# echo "tmp  ${tmpmd5}"
	# echo "manl ${manlmd5}"
fi

if	[[ ${tmpmd5} != "${manlmd5}" ]]; then
	echo "New notes saved as ~/.manl/${1}_${2}"

		if	[[ -e  ~/.manl/${1}_${2} ]]; then
			mv ~/.manl/"${1}_${2}" ~/.manl/"${1}_${2}.manlbu"
			echo "Pre-edited notes saved as ~/.manl/${1}_${2}.manlbu"
		fi

	cp ~/.manl/"${1}_${2}_"  ~/.manl/"${1}_${2}"
	rm ~/.manl/"${1}_${2}_"
	rm /tmp/"${1}_${2}_"

	# del=$(echo "${1}" | tr '[:lower:]' '[:upper:]')			### "${del}" not covering all possible variations.
	# del=$(man "${1}" "${2}" | awk 'NR==1{print $1}')			### Revision to improve robustness Nov 10, 2020.
										### Man pages changed to blank first line, var was empty 2024-02-25.
	# del=$(man "${1}" "${2}" | awk 'NF{print $1; exit}')			### Revision finds first non blank line, then prints first field of it.
	  del=$(man "${1}" "${2}" 2>/dev/null | awk 'NF{print $1; exit}')

	echo "Deleted everything including first line with \"${del}\", to remove manpage from notes."

	sed -i '/'"$del"'/,$d' ~/.manl/"${1}_${2}"	# > ~/.manl/"${1}_${2}".tmp	### Implemented the sed "-i" edit in place option.
							# mv ~/.manl/"${1}_${2}".tmp  ~/.manl/"${1}_${2}"
    elif
	[[ -n ${2} ]]; then
	rm ~/.manl/"${1}_${2}_"
	rm /tmp/"${1}_${2}_"
fi


#=======================================================================================================
			# Print manpage, or notes + manpage, in editor

if	[[ -z ${2} ]]; then						### IN EDITOR (no number) [MANPAGE]
	cp /tmp/"${1}_" ~/.manl/"${1}_"
	"$Editor" ~/.manl/"${1}_"

	tmpmd5=$(md5sum /tmp/"${1}_" | awk '{ print $1 }')
	manlmd5=$(md5sum ~/.manl/"${1}_" | awk '{ print $1 }')
	# echo "tmp  ${tmpmd5}"						### for testing script
	# echo "manl ${manlmd5}"					### for testing script
fi

if	[[ -z ${2} ]] && [[ ${tmpmd5} != "${manlmd5}" ]]; then
	echo "New notes saved as ~/.manl/${1}"

		if	[[ -e  ~/.manl/"${1}" ]]; then
			mv ~/.manl/"${1}" ~/.manl/"${1}.manlbu"
			echo "Pre-edited notes saved as ~/.manl/${1}.manlbu"
		fi

	cp ~/.manl/"${1}_"  ~/.manl/"${1}"
	rm ~/.manl/"${1}_"
	rm /tmp/"${1}_"	

	# del=$(echo "${1}" | tr '[:lower:]' '[:upper:]')		### "${del}" not covering all possible variations.
	# del=$(man "${1}" | awk 'NR==1{print $1}')			### Revision to improve robustness Nov 10, 2020.
									### Man pages changed to blank first line, var was empty 2024-02-25.
	# del=$(man "${1}" | awk 'NF{print $1; exit}')			### Revision finds first non blank line, then prints first field of it.
	  del=$(man "${1}" 2>/dev/null | awk 'NF{print $1; exit}')

	echo "Deleted everything including first line with \"${del}\", to remove manpage from notes."

	sed -i '/'"$del"'/,$d' ~/.manl/"${1}"	#> ~/.manl/"${1}".tmp	### Implemented the sed "-i" edit in place option.
						# mv ~/.manl/"${1}".tmp  ~/.manl/"${1}"
    elif
	[[ -z ${2} ]]; then
	rm ~/.manl/"${1}_"
	rm /tmp/"${1}_"
fi
