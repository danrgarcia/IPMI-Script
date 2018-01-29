#!/bin/bash

#Function to list asset information screen
drawInfo ()
{
	if [[ $group == "Business Group 1" ]] 
	then
		echo $'\e[0;34m'
		echo "                       " $HOST_NAME
		echo $'\e[0;32m'
		echo $'\e[0;32m'
		echo "-----------------------------------------------------"
		echo "                   DB1"
		echo
		echo "Asset Tag:     " $asset_tag 
		echo "RFID tag:      " $rfid_tag
		echo "Serial Number: " $serial_num
		echo "Location:      " $location $ru
		echo "LOM MAC:       " $lom
		echo "MAC1:          " $mac1
		echo "-----------------------------------------------------"
		if [[ $oob_test == *Not* ]]
		then
				echo $'\e[0;31m'
			else
				echo $'\e[0;36m'
			fi
			echo 'OOB' $oob_test
			echo $'\e[0;0m'
		else
			echo $'\e[0;34m'
			echo "                       " $HOST_NAME
			echo $'\e[0;32m'
			echo $'\e[0;32m'
			RED='\033[0;31m'
			GREEN='\033[0;32m'
			echo "-----------------------------------------------------------------------------------"
			echo "                   DB 1                            DB 2"
			echo 
			if [[ $asset_tag != $asset_tag2 ]]
			then
				echo -n $'\e[0;31m'
				echo 'Asset Tag:     ' $asset_tag '                       ' $asset_tag2
			else
				echo -n $'\e[0;32m'
				echo 'Asset Tag:     ' $asset_tag '                       ' $asset_tag2
			fi
			if [[ $rfid_tag != $rfid_tag2 ]]
			then
				echo -n $'\e[0;31m'
				echo 'RFID tag:      ' $rfid_tag '                ' $rfid_tag2
			else
				echo -n $'\e[0;32m'
				echo 'RFID tag:      ' $rfid_tag '                ' $rfid_tag2
			fi
			if [[ $serial_num != $serial_num2 ]]
			then
				echo -n  $'\e[0;31m'
				echo 'Serial Number: ' $serial_num '               ' $serial_num2
			else
				echo  -n $'\e[0;32m'
				echo 'Serial Number: ' $serial_num '               ' $serial_num2
			fi
			if [[ $location != $location2 ]]
			then
				echo -n  $'\e[0;31m'
				echo 'Location:      ' $location $ru ' ' $location2 $ru2
			else
				echo  -n $'\e[0;32m'
				echo 'Location:      ' $location $ru ' ' $location2 $ru2
			fi
			if [[ $lom != $lom2 ]]
			then
				echo -n $'\e[0;31m'
				echo 'LOM MAC:       ' $lom '             ' $lom2 
			else
				echo -n $'\e[0;32m'
				echo 'LOM MAC:       ' $lom '             ' $lom2 
			fi
			if [[ $mac1 != $mac12 ]]
			then
				echo -n $'\e[0;31m'
				echo 'MAC1:          ' $mac1 '             ' $mac12
			else
				echo -n $'\e[0;32m'
				echo 'MAC1:          ' $mac1 '             ' $mac12
			fi
			echo -n $'\e[0;32m'
			echo "-----------------------------------------------------------------------------------"
			echo ""
			if [[ $oob_test == *Not* ]]
			then
			echo $'\e[0;31m'
			else
			echo $'\e[0;36m'
		fi
		echo 'OOB' $oob_test
		echo $'\e[0;0m'
	fi
}

# Function to pull oob address 
BG1Conv ()
{
	found='0'
	get_info=$(vd print $HOST)

	set -f 
	array=(${get_info//,/ })

	for i in "${!array[@]}"; do
        if [[ "${array[$i]}" = *"oob"* ]] && [[ "$found" != '1' ]]; then
            a="${i}"
            a="$((a + 3))"
            HOST="${array[$a]}"
            found='1'
	fi
	done
}

testConn ()
{
	echo 'Pinging Host...'
	ping -c1 $HOST > /dev/null

	if [ $? -eq 0 ]
	then
		oob_test="Reachable"
	else
		oob_test="Not Reachable"
	fi
}

getInfo ()
{
	echo "Getting DB1 info...."
	get_info=$(curl -s -i -H "APIFORDB1")

	set -f
	array=(${get_info//,/ })
	
	((x=0))
	for i in "${array[@]}"
		do
			if [[ $i == *ETHERNET_ID_1* ]] 
				then
				((f=$x))
				(( f = f + 1 ))
				mac1=${array[f]}
			fi
			if [[ $i == *lom_mac_address* ]]
				then
				((g=$x))
				lom=${array[g]}
			fi	
			if [[ $i == *rfid_tag* ]]
				then
				((f=$x))
				rfid=${array[f]}
			fi
			if [[ $i == *asset_tag* ]]
				then
				((f=$x))
				tag=${array[f]}
			fi
			if [[ $i == *serial_number* ]]
				then
				((f=$x))
				serial=${array[f]}
			fi
			if [[ $i == *location_in_building* ]]
				then
				((f=$x))
				loc=${array[f]}
			fi
			if [[ $i == *ru* ]]
				then
				((f=$x))
				ru=${array[f]}
			fi
		(( x = x + 1 ))
		done
	
		asset_tag=${tag##*:}
		serial_num=${serial##*:}
		rfid_tag=${rfid##*:}
		location=${loc##*:}
		ru=${ru##*:}
		lom=${lom#*:}
		mac1=${mac1#*:}
		mac1=${mac1%?}
	
	if [[ $group == "BG2" ]]
	then
		echo "Getting Cartographer info..."
	
		if [[ $HOST_NAME == *BG2* ]] 
		then
			get_info2=$(curl -s -i https://DATABASE2ADDRESS${HOST_NAME})
	
			set -f
			array2=(${get_info2//,/ })
			
			for i in "${array[@]}"
				do
					if [[ $i == *mac1* ]]
						then
						echo $i
					fi
				done
	
	
			tag2=${array2[42]}
			serial2=${array2[48]}
			rfid2=${array2[58]}
			loc2=${array2[57]}
			ru2=${array2[53]}
			lom2=${array2[66]}
			mac12=${array2[60]}
	
			tag2=$( tr '[a-z]' '[A-Z]' <<< $tag2)
			lom2=$( tr '[a-z]' '[A-Z]' <<< $lom2)
			mac12=$( tr '[a-z]' '[A-Z]' <<< $mac12)
	
			asset_tag2=${tag2##*:}
			serial_num2=${serial2##*:}
			rfid_tag2=${rfid2##*:}
			location2=${loc2##*:}
			ru2=${ru2##*:}
			lom2=${lom2#*:}
			mac12=${mac12#*:}
		
		elif [[ $HOST_NAME == *BG2* ]]
		then
			get_info2=$(curl -s -i https://DATABASE2ADDRESS${HOST_NAME})
	
			set -f
			array2=(${get_info2//,/ })
			
			((x=0))
			
	for i in "${array2[@]}"
		do
			if [[ $i == *ETHERNET_ID_1* ]] 
			then
				echo $i
			fi
			if [[ $i == *mac1* ]]
			then
				echo $i
			fi
		done
	
	
			tag2=${array2[42]}
			serial2=${array2[48]}
			rfid2=${array2[58]}
			loc2=${array2[57]}
			ru2=${array2[53]}
			lom2=${array2[66]}
			mac12=${array2[60]}
	
			tag2=$( tr '[a-z]' '[A-Z]' <<< $tag2)
			lom2=$( tr '[a-z]' '[A-Z]' <<< $lom2)
			mac12=$( tr '[a-z]' '[A-Z]' <<< $mac12)
	
			asset_tag2=${tag2##*:}
			serial_num2=${serial2##*:}
			rfid_tag2=${rfid2##*:}
			location2=${loc2##*:}
			ru2=${ru2##*:}
			lom2=${lom2#*:}
			mac12=${mac12#*:}
		
		else
			tag2=""
			serial2=""
			rfid2=""
			loc2=""
			ru2=""
			lom2=""
			mac12=""
		fi
	fi
	
}

boot ()
{
	while [[ $selection != "4" ]]; do
	
	echo
	echo '1. Force PXE Boot'
	echo '2. Force Disk Boot'
	echo '3. Force BIOS Boot'
	echo '4. Return to main menu'
	
	read -n 1 -s selection
	echo
	case $selection in
	1)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to force a PXE boot. Running this command will reset pxe boot (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
			echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P  password chassis bootdev pxe -H $HOST)
			(ipmitool -I lanplus -U Administrator -P password power cycle -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	2)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to force a Disk boot. Running this command will reset and boot from the disk (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
			echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P  password chassis bootdev disk -H $HOST)
			(ipmitool -I lanplus -U Administrator -P password power cycle -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	3)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to force a BIOS boot. Running this command will reset boot to the bios (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
			echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P  password chassis bootdev bios -H $HOST)
			(ipmitool -I lanplus -U Administrator -P password power cycle -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	4)
		menu
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

sol ()
{
	selection=0
	while [[ $selection != "4" ]]; do
	
	echo
	echo '1. Activate Sol'
	echo '2. De-Activate Sol'
	echo '3. Return to main menu'
	
	read -n 1 -s selection
	echo
	case $selection in
	1)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sol activate -H $HOST)
		echo $'\e[0;32m'
		;;
	2)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sol deactivate -H $HOST)
		echo $'\e[0;32m'
		;;
	3)
		menu
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

power ()
{
	while [[ $selection != "4" ]]; do
	
	echo
	echo '1. Power off'
	echo '2. Power On'
	echo '3. Power cycle'
	echo '4. Power Status'
	echo '5. Return to main menu'
	
	read -n 1 -s selection
	echo
	case $selection in
	1)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to turn off the power of this host (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
			echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P password power off -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	2)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password power on -H $HOST)
		echo $'\e[0;32m'
		;;
	3)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to power cycle. Running this command will reset the host (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
			echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P password power cycle -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	4)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password power status -H $HOST)
		echo $'\e[0;32m'
		;;
	5)
		menu
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

sdr ()
{
	selection=0
	while [[ $selection != "4" ]]; do
	
	echo
	echo '1. List SDR'
	echo '2. Grep SDR'
	echo '3. Return to main menu'
	
	read -n 1 -s selection
	echo
	case $selection in
	1)	
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sdr elist -H $HOST)
		echo $'\e[0;32m'
		;;
	2)
		echo "What would you like to grep from sdr: "
    	read entry
    	echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sdr -H $HOST |grep $entry)
		echo $'\e[0;32m'
		;;
	3)
		menu
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

sel ()
{
	selection=0
	while [[ $selection != "4" ]]; do
	
	echo
	echo '1. List SEL'
	echo '2. Get SEL Entry'
	echo '3. Grep SEL'
	echo '4. Clear SEL'
	echo '5. Return to main menu'
	
	read -n 1 -s selection
	echo
	case $selection in
	1)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sel list -H $HOST)
		echo $'\e[0;32m'
		;;
	2)
		echo "Which log entry would you like: "
    	read entry
    	hex=$((16#$entry))
    	echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sel get $hex -H $HOST)
		echo $'\e[0;32m'
		;;
	3)
		echo "What would you like to grep from SEL: "
    	read entry
    	echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password sel elist -H $HOST |grep $entry)
		echo $'\e[0;32m'
		;;
	4)
		read -n 1 -s -p $'\e[0;31mAre you sure you want to clear the SEL (y/n)\e[0m' check
		if [[ $check == y ]] ;
		then
		echo
			echo $'\e[0;33m'
			(ipmitool -I lanplus -U Administrator -P password sel clear -H $HOST)
			echo $'\e[0;32m'
		fi
		;;
	5)
		menu
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

menu ()

{ 	
	selection="0"
	testConn
	while [[ $selection != "q" ]]; do
	drawInfo
		
	echo "1 Turn on UID light"
	echo "2 FRU Print"
	echo "3 Sol Options"
	echo "4 SDR Options"
	echo "5 SEL options"
	echo "6 Power options"
	echo "7 Boot options"
	echo "8 Set default bmc username/password"
	echo "9 Change hosts"
	echo "q Exit menu"
	echo
	
	read -n 1 -s selection
	echo
	case $selection in
	1)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password chassis identify 50 -H $HOST)
		echo $'\e[0;32m'
		;;
	2)
		echo $'\e[0;33m'
		(ipmitool -I lanplus -U Administrator -P password fru print -H $HOST)
		echo $'\e[0;32m'
		;;
	3)
		sol
		;;
	4)
		sdr
		;;
	5)
		sel
		;;
	6)
		power
		;;
	7)
		boot
		;;
	8)
			(ipmitool -I lanplus -U admin -P 10697059 user set name 3 Administrator -H $HOST)
			(ipmitool -I lanplus -U admin -P 10697059 user set password 3 passwordd -H $HOST)
			(ipmitool -I lanplus -U admin -P 10697059 user priv 3 4 -H $HOST)
			(ipmitool -I lanplus -U admin -P 10697059 channel setaccess 1 3 ipmi=on -H $HOST)
			(ipmitool -I lanplus -U admin -P 10697059 user enable 3 -H $HOST)
			(ipmitool -I lanplus -U admin -P 10697059 sol payload enable 1 3 -H $HOST)
			(ipmitool -I lanplus -U Administrator -P password user list -H $HOST)
		;;
	9)
		Start
		;;
	q)
		exit
		;;
	*)
		echo "Invalid option"
		;;
	esac
	
	done
}

Start ()
{
	read -p 'Please enter hostname: ' HOST
	if [[ $HOST == "" ]];
	then
		echo 'No Host given'
		Start
	fi
	tries=1
	if [ -z "$HOST" ];
	then
		echo "No Host given"
	else
		if [[ $HOST == *BG2* ]] || [[ $HOST == *BG2* ]];
		then
			if [[ $HOST == *oob* ]] ;
			then
				HOST_NAME=${HOST/-oob}
				printf "\033c"
				getInfo
				menu
			else
				HOST_NAME=$HOST
				HOST_OOB="${HOST%%.*}-oob."
  				HOST_DOMAIN="${HOST#*.}"
 				HOST="$HOST_OOB$HOST_DOMAIN"
 				printf "\033c"
 				group="BG2"
				getInfo
  				menu
  			fi
		else
			HOST_NAME=$HOST
			BG1Conv
			group="BG1"
			printf "\033c"
			getInfo
			menu
		fi
	fi
}
	
Start