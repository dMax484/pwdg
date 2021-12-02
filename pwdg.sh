#!/bin/bash

#Douglas Maxwell, Nick Phillips - CPSC207 Final Project

#Options:
#default give a password of length 16
#-n number of characters
#-N generate N numbers of passwords
#-u DO NOT include lower char
#-l DO NOT include upper char
#-d DO NOT include numbers
#-s include special char
#-h HELP

LENGTH=16 #default=16
N_PASS=1  #default=1
CHAR_SCHEME='A-Za-z0-9' #Defualt Scheme
STRENGTH=0
STR_STRING=" "

# using gettops - options stucture from https://www.redhat.com/sysadmin/arguments-options-bash-scripts
while getopts "n:N:uldhs" opt; do
	case ${opt} in
		n ) #NUMBER OF CHAR
			LENGTH=$OPTARG;;
		N ) #NUMBER OF PASSWORDS GENERATED
			N_PASS=$(($OPTARG));;
		u )
			CHAR_SCHEME=$(echo "${CHAR_SCHEME/A-Z}");;
		l )
			CHAR_SCHEME=$(echo "${CHAR_SCHEME/a-z}");;
		d )
			CHAR_SCHEME=$(echo "${CHAR_SCHEME/0-9}");;
		s )
			CHAR_SCHEME+='!"#$&%()+,./:;<=>?@^_`{|}~';;
			
		h ) #HELP
			echo --------------------------------------------------------------------
			echo "HELP PAGE - pwdg"
			echo
			echo "Synopsis: generate radomized passwords"
			echo "Usage: pwdg [-n passLength] [-N passCount] [-u] [-l] [-d] [-s] [-h]"
			echo "-ul|-ud|-ld (cannot use -uld options together)"
			echo
			echo "[-n passLength] - determine number of characters in password"
			echo "[-N passCount] - determine number of passwords generated"
			echo "[-u] - do not include UPPERCASE characters (A-Z)"
			echo "[-l] - do not include lowercase characters (a-z)"
			echo "[-d] - do not include digits (0-9)"
			echo "[-s] - include special characters (!\"#$&%()+,./:;<=>?@^_\`{|}~)"
			echo "[-h] - display this help page"
			echo -------------------------------------------------------------------
			exit;;
		\? ) #INVALID OPTION
			echo "ERROR: Invalid option"
			echo "Usage: pwdg [-n passLength] [-N passCount] [-u] [-l] [-d] [-s] [-h]"
			exit;;
		: )
			echo "Invalid option: $OPTARG requires and argument" 1>&2
			exit;;
	esac
done

#Print Character scheme determined by options
echo
echo "CHARACTER SCHEME: $CHAR_SCHEME"
echo ---------------------------------------------------

#loop to genereate password(s) based on options and test the strength of each
for i in $(seq 1 1 $N_PASS); do
	declare -a passwd
	for j in $(seq 0 1 $(($LENGTH-1))); do
		# reference /dev/urandom - from - https://linuxhint.com/generate-random-string-bash/
		Val=$(cat /dev/urandom | tr -dc $CHAR_SCHEME | fold -w 1 | head -n 1)
		passwd+=($Val);
	done
	
	#PASSWORD STRENGTH TESTING - Based off of - https://www.uic.edu/apps/strong-password/
	UPPER_N=$(grep -o '[[:upper:]]' <<< ${passwd[@]} | wc -l)
	LOWER_N=$(grep -o '[[:lower:]]' <<< ${passwd[@]} | wc -l)
	NUMBER_N=$(grep -o '[0-9]' <<< ${passwd[@]} | wc -l)
	SPECIAL_N=$(grep -o '[!"#$&%()+,./:;<=>?@^_`{|}~]' <<< ${passwd[@]} | wc -l)
	
	#Strength Computation
	STRENGTH=$(( ($LENGTH*4)+($LENGTH-$UPPER_N*2)+($LENGTH-$LOWER_N*2)+($NUMBER_N*4)+($SPECIAL_N*6) ))
	
	#Special conditions 
	if [[ $NUMBER_N -eq $LENGTH ]]; then
		STRENGTH=$(( $STRENGTH-($NUMBER_N*4) ))
	fi
	if [[ $UPPER_N -eq 0 ]]; then
		STRENGTH=$(( $STRENGTH-($LENGTH*2) ))
	fi
	if [[ $LOWER_N -eq 0 ]]; then
		STRENGTH=$(( $STRENGTH-($LENGTH*2) ))
	fi
	
	#Determine the string to print from scoring system
	if [[ $STRENGTH -ge 0 && $STRENGTH -lt 20 ]]; then
		STR_STRING="very weak"
	elif [[ $STRENGTH -ge 20 && $STRENGTH -lt 40 ]]; then
		STR_STRING="weak"
	elif [[ $STRENGTH -ge 40 && $STRENGTH -lt 60 ]]; then
		STR_STRING="good"
	elif [[ $STRENGTH -ge 60 && $STRENGTH -lt 80 ]]; then 
		STR_STRING="strong"	 
	elif [[ $STRENGTH -ge 80 ]]; then
		STR_STRING="very strong"
	fi
	
	#Print the generated password and its attributes
	echo Upper: $UPPER_N Lower: $LOWER_N Numbers: $NUMBER_N Special: $SPECIAL_N
	echo Strength: $STRENGTH - \"$STR_STRING\"
	echo
	printf %s "Generated Password: ${passwd[@]}" $'\n'
	echo ---------------------------------------------------
	passwd=() #clear array and strength for next passwd
	STRENGTH=0	
done
echo

exit 0;