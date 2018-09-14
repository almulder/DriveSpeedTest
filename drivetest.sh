runtime=5
installed=$(dpkg-query -W -f='${Status}' bc)
if [ "$installed" = "install ok installed" ]; then
	echo ""
else
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}This script requires bc to be installed and is missing from your system \n" 
	infobox="${infobox}\n"
	infobox="${infobox}bc - command is used for command line calculator. It is similar to basic calculator by using which we can do basic mathematical calculations. \n"
	infobox="${infobox}\n"
	infobox="${infobox}Do you wish to install bc?\n"
	infobox="${infobox}\n\n"
	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title " Missing Dependency bc" \
	--yesno "${infobox}" 15 50
	response=$?
	case $response in
	   0) reset && sudo apt-get install bc && echo "\n bc - Installed.";;
			#libkodiplatform17 libp8-platform2 libtinyxml2.6.2v5
	   1) reset && echo "bc not installed, exiting." && closeapp;;
	   255) reset && echo "[ESC] key pressed - exiting." && closeapp;;
	esac
fi

infobox=""
infobox="${infobox}\n"
infobox="${infobox}This script test the read speeds of your \n" 
infobox="${infobox} SD Card and or USB drive.\n"
infobox="${infobox}\n"
infobox="${infobox}It will run 4 types of test when testing.\n"
infobox="${infobox}  Cached Reads, Buffered Disk Reads \n" 
infobox="${infobox}  Direct Cached read, Direct disk reads \n"
infobox="${infobox}\n"
infobox="${infobox}Once done it will display the results.\n"
infobox="${infobox}\n"
infobox="${infobox}You also have the ability to swap USB drives after each test.\n"
infobox="${infobox}\n"
infobox="${infobox}Note:You can only have one USB plugged in at a time.\n"
infobox="${infobox}\n\n"
dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
--title " Read Speed Tests - SD Card / Hard Drive" \
--msgbox "${infobox}" 19 50

function main_menu() {
    usbcheck
	if [ "$driveletter" = "USB Missing" ]; then
		local choice
			while true; do
			 choice=$(dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" --title " Main Menu " \
				--ok-label OK --cancel-label Exit \
				--menu " Select Option:" 13 50 4\
				1 "Test SD Card" \
				2 "Test USB - $driveletter" \
				3 "Test SD Card & USB - $driveletter" \
				4 "Scan for USB - USB Missing"\
				2>&1 > /dev/tty)
			case "$choice" in
				1) test_sdcard ;;
				2) test_usb ;;
				3) test_both ;;
				4) scanforusb ;;
				*) closeapp ;;
			esac
		done

	else
		local choice
			while true; do
			 choice=$(dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" --title " Main Menu " \
				--ok-label OK --cancel-label Exit \
				--menu " Select Option:" 13 50 4\
				1 "Test SD Card " \
				2 "Test USB - ./$driveletter" \
				3 "Test SD Card & USB - ./$driveletter" \
				2>&1 > /dev/tty)
			case "$choice" in
				1) test_sdcard ;;
				2) test_usb ;;
				3) test_both ;;
				*) closeapp ;;
			esac
		done

	fi	
}

function scanforusb(){
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}     Please Wait...\n"
	infobox="${infobox}\n\n"
	dialog --backtitle  " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title " Scanning for USB Drive" \
	--infobox "${infobox}" 5 27
	usbcheck
	sleep 3
	usbcheck
	if [ "$driveletter" = "USB Missing" ]; then
		infobox=""
		infobox="${infobox}\n"
		infobox="${infobox}  USB not detected!\n"
		infobox="${infobox}\n\n"
		dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
		--title "USB drive Not Found" \
		--infobox "${infobox}" 5 27
		sleep 3
	else
		infobox=""
		infobox="${infobox}\n"
		infobox="${infobox}  USB has been detected!\n"
		infobox="${infobox}\n\n"
		dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
		--title "USB drive detected - $driveletter" \
		--infobox "${infobox}" 5 35
		sleep 3
	fi
main_menu
}

function test_sdcard(){
(
	ctotal=0
	caverage=0
	btotal=0
	baverage=0
	dctotal=0
	dcaverage=0
	dbtotal=0
	dbaverage=0
    processed=1
	items=$(echo "$runtime * 4" | bc)
	cat /dev/null > results.txt
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T /dev/mmcblk0 2>&1 | sed -e '/Timing cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		ctotal=$( echo "$ctotal + $output" | bc )
        echo "XXX"
		echo "Test 1 of 4\nCached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t /dev/mmcblk0 2>&1 | sed -e '/Timing buffered disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		btotal=$( echo "$btotal + $output" | bc )
        echo "XXX"
		echo "Test 2 of 4\nBuffered Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
        sleep 0.1
		counter=$((counter+1))
	done	 
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T --direct /dev/mmcblk0 2>&1 | sed -e '/Timing O_DIRECT cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dctotal=$( echo "$dctotal + $output" | bc )
        echo "XXX"
		echo "Test 3 of 4\nDirect Cached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
        sleep 0.1
		counter=$((counter+1))
	done	 
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t --direct /dev/mmcblk0 2>&1 | sed -e '/Timing O_DIRECT disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dbtotal=$( echo "$dbtotal + $output" | bc )
        echo "XXX"
		echo "Test 4 of 4\nDirect Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done
	sleep 2
	echo " "  >> results.txt
	echo "Average SD Card Results:"  >> results.txt
	caverage=$( echo "scale=2; $ctotal / $runtime" | bc )
	baverage=$( echo "scale=2; $btotal / $runtime" | bc )
	dcaverage=$( echo "scale=2; $dctotal / $runtime" | bc )
	dbaverage=$( echo "scale=2; $dbtotal / $runtime" | bc )
	echo "     Cached Read: "$caverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Buffered Disk Read: "$baverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Cached Read: "$dcaverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Disk Read: "$dbaverage " MB/sec">> results.txt
) |	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" --title "Testing SD Card" --gauge "Loading.... Please Wait!" 10 60 0
	dialog --textbox results.txt 20 90
}

function test_usb() {
usbcheck
if [ "$driveletter" = "USB Missing" ]; then
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}Please check that the USB is connected\n"
	infobox="${infobox}\n\n"
	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title "USB drive not detected" \
	--infobox "${infobox}" 5 42
	sleep 3
	main_menu
else
 echo ""
fi

(
	ctotal=0
	caverage=0
	btotal=0
	baverage=0
	dctotal=0
	dcaverage=0
	dbtotal=0
	dbaverage=0
    processed=1
	items=$(echo "$runtime * 4" | bc)
	cat /dev/null > results.txt
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T /dev/$driveletter 2>&1 | sed -e '/Timing cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		ctotal=$( echo "$ctotal + $output" | bc )
        echo "XXX"
		echo "Test 1 of 4\nCached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t /dev/$driveletter 2>&1 | sed -e '/Timing buffered disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		btotal=$( echo "$btotal + $output" | bc )
        echo "XXX"
		echo "Test 2 of 4\nBuffered Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T --direct /dev/$driveletter 2>&1 | sed -e '/Timing O_DIRECT cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dctotal=$( echo "$dctotal + $output" | bc )
        echo "XXX"
		echo "Test 3 of 4\nDirect Cached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t --direct /dev/$driveletter 2>&1 | sed -e '/Timing O_DIRECT disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dbtotal=$( echo "$dbtotal + $output" | bc )
        echo "XXX"
		echo "Test 4 of 4\nDirect Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done
	sleep 2
	echo " "  >> results.txt
	echo "Average USB Drive (./$driveletter) Results:"  >> results.txt
	caverage=$( echo "scale=2; $ctotal / $runtime" | bc )
	baverage=$( echo "scale=2; $btotal / $runtime" | bc )
	dcaverage=$( echo "scale=2; $dctotal / $runtime" | bc )
	dbaverage=$( echo "scale=2; $dbtotal / $runtime" | bc )
	echo "     Cached Read: "$caverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Buffered Disk Read: "$baverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Cached Read: "$dcaverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Disk Read: "$dbaverage " MB/sec">> results.txt
) |	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" --title "Testing USB Drive" --gauge "Loading.... Please Wait!" 10 60 0
	dialog --textbox results.txt 20 90
}

function test_both() {
usbcheck
if [ "$driveletter" = "USB Missing" ]; then
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}Please check that the USB is connected\n"
	infobox="${infobox}\n\n"
	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title "USB drive not detected" \
	--infobox "${infobox}" 5 42
	sleep 3
	main_menu
else
 echo ""
fi
	(
	ctotal=0
	caverage=0
	btotal=0
	baverage=0
	dctotal=0
	dcaverage=0
	dbtotal=0
	dbaverage=0
    processed=1
	cat /dev/null > results.txt
	items=$(echo "$runtime * 8" | bc)
	counter=1
	while [ $counter -le $runtime ] ; do 
	#do some command here    
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T /dev/mmcblk0 2>&1 | sed -e '/Timing cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		ctotal=$( echo "$ctotal + $output" | bc )
        echo "XXX"
		echo "SD Card - Test 1 of 4\nCached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t /dev/mmcblk0 2>&1 | sed -e '/Timing buffered disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		btotal=$( echo "$btotal + $output" | bc )
        echo "XXX"
		echo "SD Card - Test 2 of 4\nBuffered Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T --direct /dev/mmcblk0 2>&1 | sed -e '/Timing O_DIRECT cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dctotal=$( echo "$dctotal + $output" | bc )
        echo "XXX"
		echo "SD Card - Test 3 of 4\nDirect Cached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t --direct /dev/mmcblk0 2>&1 | sed -e '/Timing O_DIRECT disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dbtotal=$( echo "$dbtotal + $output" | bc )
        echo "XXX"
		echo "SD Card - Test 4 of 4\nDirect Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done
	echo " "  >> results.txt
	echo "Average SD Card Results:"  >> results.txt
	caverage=$( echo "scale=2; $ctotal / $runtime" | bc )
	baverage=$( echo "scale=2; $btotal / $runtime" | bc )
	dcaverage=$( echo "scale=2; $dctotal / $runtime" | bc )
	dbaverage=$( echo "scale=2; $dbtotal / $runtime" | bc )
	echo "     Cached Read: "$caverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Buffered Disk Read: "$baverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Cached Read: "$dcaverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Disk Read: "$dbaverage " MB/sec">> results.txt
	
usbcheck
if [ "$driveletter" = "USB Missing" ]; then
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}Please check that the USB is connected\n"
	infobox="${infobox}\n\n"
	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title "USB drive not detected" \
	--infobox "${infobox}" 5 42
	sleep 3
	main_menu
else
 echo ""
fi
	ctotal=0
	caverage=0
	btotal=0
	baverage=0
	dctotal=0
	dcaverage=0
	dbtotal=0
	dbaverage=0
	counter=1
	while [ $counter -le $runtime ] ; do 
	#do some command here    
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T /dev/$driveletter 2>&1 | sed -e '/Timing cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		ctotal=$( echo "$ctotal + $output" | bc )
        echo "XXX"
		echo "USB Drive - Test 1 of 4\nCached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"

        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t /dev/$driveletter 2>&1 | sed -e '/Timing buffered disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		btotal=$( echo "$btotal + $output" | bc )
        echo "XXX"
		echo "USB Drive - Test 2 of 4\nBuffered Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -T --direct /dev/$driveletter 2>&1 | sed -e '/Timing O_DIRECT cached reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dctotal=$( echo "$dctotal + $output" | bc )
        echo "XXX"
		echo "USB Drive - Test 3 of 4\nDirect Cached Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done	
	counter=1
	while [ $counter -le $runtime ] ; do 
		pct=$(( $processed * 100 / $items ))
        output=$(sudo hdparm -t --direct /dev/$driveletter 2>&1 | sed -e '/Timing O_DIRECT disk reads/ s/.*= *\([0-9.]*\).*/\1/ p; d')
		dbtotal=$( echo "$dbtotal + $output" | bc )
        echo "XXX"
		echo "USB Drive - Test 4 of 4\nDirect Disk Read: $output MB/sec \n\n\n                      Pass $counter of $runtime"
        echo "XXX"
        echo "$pct"
        processed=$((processed+1))
        sleep 0.1
		counter=$((counter+1))
	done
	sleep 2
	echo " "  >> results.txt
	echo "Average USB Drive (./$driveletter) Results:"  >> results.txt
	caverage=$( echo "scale=2; $ctotal / $runtime" | bc )
	baverage=$( echo "scale=2; $btotal / $runtime" | bc )
	dcaverage=$( echo "scale=2; $dctotal / $runtime" | bc )
	dbaverage=$( echo "scale=2; $dbtotal / $runtime" | bc )
	echo "     Cached Read: "$caverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Buffered Disk Read: "$baverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Cached Read: "$dcaverage " MB/sec">> results.txt
	echo " " >> results
	echo "     Direct Disk Read: "$dbaverage " MB/sec">> results.txt
) |	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" --title "Testing SD Card & USB Drive" --gauge "Loading.... Please Wait!" 10 60 0
	dialog --textbox results.txt 20 90
}

function usbcheck() {
udevadm trigger
drivecheck=""
drivecheck=$(df /dev/sda)
if [ "$drivecheck" != "" ]; then
	driveletter="sda"
else
	drivecheck=$(df /dev/sdb)
	if [ "$drivecheck" != "" ]; then
		driveletter="sdb"
	else
		drivecheck=$(df /dev/sdc)
		if [ "$drivecheck" != "" ]; then
			driveletter="sdc"
		else
			drivecheck=$(df /dev/sdd)
			if [ "$drivecheck" != "" ]; then
				driveletter="sdd"
			else
				drivecheck=$(df /dev/sde)
				if [ "$drivecheck" != "" ]; then
					driveletter="sde"
				else
					drivecheck=$(df /dev/sdf)
					if [ "$drivecheck" != "" ]; then
						driveletter="sdf"
					else
						drivecheck=$(df /dev/sdg)
						if [ "$drivecheck" != "" ]; then
							driveletter="sdg"
						else
							drivecheck=$(df /dev/sdh)
							if [ "$drivecheck" != "" ]; then
								driveletter="sdh"
							else
								driveletter="USB Missing"
							fi
						fi
					fi
				fi
			fi
		fi
	fi
fi 
} &> /dev/null

function closeapp(){
	infobox=""
	infobox="${infobox}\n"
	infobox="${infobox}Hope you enjoyed it. \n"
	infobox="${infobox}\n"
	infobox="${infobox}                -almulder\n"
	infobox="${infobox}\n\n"
	dialog --backtitle " Read Speed Tests - SD Card / Hard Drive - by almulder" \
	--title "Exiting..." \
	--infobox "${infobox}" 6 35
	sleep 3
reset
exit 0
}


main_menu