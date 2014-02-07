#!/bin/sh
sleep 1 
./adb -s ${PWD##*/} root
sleep 2
#ver=$( ls | find LinuxMG_*_Arm*.tar.gz | sed -n '$p') 
#tmp mark line 7
folder=$(ls | find LinuxMG_*.tar.gz | sed -n '$p' | sed 's/.tar.gz//g')
if [ "$folder" == "" ]; then 
	devfolder=$(./adb -s ${PWD##*/} shell ls /data/local/ | grep LinuxMG) 
	folder=$devfolder
fi
#echo "check file defore mg run"
#checkfile
#echo "@@@@@folder :  $folder"
#if [ "$(ls | find LinuxMG_*.tar.gz)" != "" ] && [ "$(./adb -s ${PWD##*/} shell ls /data/local/ | grep LinuxMG)" == "" ]; then
#	tar xzvf $ver
#	tar xzvf patch.tar.gz
#	./adb -s ${PWD##*/} push $folder /data/local/$folder/
#	./adb -s ${PWD##*/} push patch/MG-console /data/local/$folder/ 
#	./adb -s ${PWD##*/} push patch/maya.ini /data/local/$folder/ 
#	./adb -s ${PWD##*/} push patch/Slate7.ini /data/local/$folder/
#	./adb -s ${PWD##*/} push patch/terminfo /data/local/$folder/terminfo
#	echo "LinuxMG installation completed"
#	echo 'LinuxMG installation completed' >> $PVTlog.txt
#elif [ "$(./adb -s ${PWD##*/} shell ls /data/local/ | grep "LinuxMG")" != "" ]; then
#	echo "LinuxMG exists"
#	echo 'LinuxMG exists' >> $PVTlog.txt
#else
#	echo "*****************************************************************************"
#	echo "there is no LinuxMG Arm in folder, please download the latest LinuxMG Arm and put into ADBPVT folder" >> /dev/pts/1
#	echo 'there is no LinuxMG Arm in folder, please download the latest LinuxMG Arm and put into ADBPVT folder' >>  $PVTlog.txt
#	sleep 3
#	exit 0
#fi

#./adb push ETD_Lock_Config.txt /sdcard/ETDLock/config/
echo "It takes $MGtimes sec to run MG at each cycle"
WAITMG=$((MGtimes + 3))
#echo $WAITMG
str=$(./adb -s ${PWD##*/} devices)
#echo "detect on devices string ${#str}"

function tokencheckout()
{
	while true;
	do
		if [ "$(cat /dev/shm/traffic.txt)" == ${PWD##*/} ]; then
			cat /dev/shm/traffic.txt
			#echo "I GOT TOKEN '$(date)'"
			break;
		elif [ "$(cat /dev/shm/traffic.txt)" == "" ]; then
			echo ${PWD##*/} > /dev/shm/traffic.txt
			cat /dev/shm/traffic.txt
		else
			#echo "WAIT TOKEN for 5 secs...."
			sleep 5
		fi
	done
}

function tokencheckin()
{
	while true;
	do
		if [ "$(cat /dev/shm/traffic.txt)" == ${PWD##*/} ]; then
			echo "" > /dev/shm/traffic.txt
			cat /dev/shm/traffic.txt
			#echo "TOKEN RETURNED '$(date)'"
			break;
		fi
	done
}

function killxterm()
{
	#if [ "$(echo $PPID)" == "$(ps -ef | grep -v grep | grep "xterm" | awk '{print $2}' | sed -n '$p')" ]; then
		#kill $(cat )
	#fi
	#./xdotool windowkill $(./xdotool getwindowfocus) > /dev/null 2>&1
	#killwindow=$(./xdotool type 'cat testw')
	#echo "killwindow: '$killwindow'"
	#./xdotool keydown --delay 100 KP_Enter
	#./xdotool keyup --delay 100 KP_Enter
	
	sleep 1
	./xdotool type 'kill '$(ps aux | grep xterm | awk '{print $2}' | sed -n '2p')''
	./xdotool keydown --delay 100 KP_Enter
	./xdotool keyup --delay 100 KP_Enter
}

tokencheckout
MAINWINDOW=$(./xdotool getwindowfocus)

function TypingMG(){	
		./xdotool windowactivate $TESTWINDOW
	
		sleep 0.5 # Wait TESTWINDOW ready
		./xdotool type --delay 100 './adb -s '${PWD##*/}' root'
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter
		sleep 3 #wait adb daemondb to ready
		./xdotool windowactivate $TESTWINDOW
		sleep 0.5 # Wait TESTWINDOW ready
		./xdotool type './adb -s '${PWD##*/}' shell'
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter
		./xdotool windowactivate $TESTWINDOW
		sleep 0.5 # Wait TESTWINDOW ready
		./xdotool type 'cd data/local/'$1'/'
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter
		sleep 1 #wait folder changing is done
		./xdotool windowactivate $TESTWINDOW
		sleep 0.5 # Wait TESTWINDOW ready
		./xdotool type 'rm -r logs'
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter
		./xdotool windowactivate $TESTWINDOW
		sleep 0.5 # Wait TESTWINDOW ready
		./xdotool type 'mkdir logs'
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter
		./xdotool windowactivate $TESTWINDOW
		sleep 5 # Wait TESTWINDOW ready
		./xdotool type 'sh MG-console -ini='$Ini' -start -nologo -timeout='$MGtimes''
		./xdotool keydown --delay 100 KP_Enter
		./xdotool keyup --delay 100 KP_Enter

    		tokencheckin
		#sleep 0.5 #wait for press 'y'
		#./xdotool type 'y'
		#./xdotool keydown --delay 100 KP_Enter
		#./xdotool keyup --delay 100 KP_Enter
		#echo "@@@@@@@@@@@@@@ $WAITMG"
		sleep $WAITMG	#wait for LMG to finish
	#	./xdotool windowactivate $TESTWINDOW 
		sleep 3 # Wait TESTWINDOW ready
		tokencheckout
	#	for test
		./xdotool windowactivate $TESTWINDOW
		#./xdotool type 'exit'
		#./xdotool keydown --delay 100 KP_Enter
		#./xdotool keyup --delay 100 KP_Enter
		#CheckWindowAlive
		#for error msg debug ew
		#./xdotool windowkill $TESTWINDOW > /dev/null 2>&1
		#./xdotool keydown --delay 100 KP_Enter > /dev/null 2>&1
		#./xdotool keyup --delay 100 KP_Enter > /dev/null 2>&1
		sleep 3
		
		#./xdotool type 'exit'
		#./xdotool keydown --delay 100 KP_Enter
		#./xdotool keyup --delay 100 KP_Enter
		

		
		###########################################
		##         ADB PULL LOG DATA	         ##
		###########################################
		./xdotool windowactivate $MAINWINDOW 
		#sleep 1
		#./xdotool windowkill $TESTWINDOW > /dev/null 2>&1
		#./xdotool keydown --delay 100 KP_Enter > /dev/null 2>&1
		#./xdotool keyup --delay 100 KP_Enter > /dev/null 2>&1
		#./xdotool type 'kill '$(cat testw)''
		#./xdotool keydown --delay 100 KP_Enter
		#./xdotool keyup --delay 100 KP_Enter
		tokencheckin
		sleep 0.5 # Wait MAINWINDOW ready
		
}

if [ ${#str} -ge 20 ]; then
	sleep 1 #wait new terminal to ready
	for (( m=1; m<=$MGruns; m=m+1 ))
	do 
		###########################
		######open term each loop##
		###########################
		xterm&
#		sudo touch testw
#		sudo chmod 777 testw
#		echo $PPID > testw
#		echo "PPID : $PPID" 
		sleep 1
		TESTWINDOW=$(./xdotool getactivewindow)		
		echo "---------------------------------------------"
		echo '---------------------------------------------' >> $PVTlog.txt
		echo "This is $m th mg run"

		#echo '****************' >> $PVTlog.txt	
		echo 'This is '$m' th mg run' >> $PVTlog.txt
		./adb -s ${PWD##*/} shell date +"%m-%d-%y_%T" >> $PVTlog.txt
		#sh ./TypingMG "$TESTWINDOW" "$MGtimes" "$WAITMG"
		#readfile cfg
		
		if [ "$(./adb -s ${PWD##*/} shell cat /system/build.prop | grep -o HP_Slate7)" == "HP_Slate7" ]; then
			rdcfg=cfgs7
			readfile $rdcfg
		elif [ "$(./adb -s ${PWD##*/} shell cat /system/build.prop | grep ro.product.name=wolverine | tr -d '\r')" == 		"ro.product.name=wolverine" ]; then
			rdcfg=cfgw
			readfile $rdcfg
		else
			rdcfg=cfg
			readfile $rdcfg
		fi
		./adb -s ${PWD##*/} push patch/ /data/local/$folder/  #> /dev/null 2>&1	 
		echo "mg/Ini : $Ini"
		TypingMG $folder
		#killxterm
		./xdotool windowkill $TESTWINDOW > /dev/null 2>&1
		./xdotool keydown --delay 100 KP_Enter > /dev/null 2>&1
		./xdotool keyup --delay 100 KP_Enter > /dev/null 2>&1
		clear
		###########################################
		##	 kill all dead xterm 		 ##
		###########################################
#		killall -r xterm > /dev/null 2>&1
		#./adb -S pull data/local/LinuxMG/logs/
		#cd ..
		echo "Linux Meatgreinder Testing Result:"
		echo 'Linux Meatgreinder Testing Result:' >> $PVTlog.txt
		./adb -s ${PWD##*/} pull data/local/$folder/logs/ > /dev/null 2>&1	
		sleep 3 #wait a minute for cat log
		ls -lt | grep mgprogress | awk '{print $9}' | head -n 1 | xargs cat | grep Final -A 6 | grep -v Final
			
		#######################################################
		#####	Check whether "Summary" in mgprogress.txt #####
		#######################################################
		echo "					"
		ls -lt | grep mgprogress | awk '{print $9}' | head -n 1 | xargs cat | grep Summary > /dev/null 2>&1
				
		###########################################
		##	Record the newest log		 ##
		###########################################
echo '****************' >> $PVTlog.txt
echo '***  Errors  ***' >> $PVTlog.txt
echo '****************' >> $PVTlog.txt
		ls -lt | grep mgerror | awk '{print $9}' | head -n 1 | xargs cat >> $PVTlog.txt

echo '****************' >> $PVTlog.txt
echo '*** Warnings ***' >> $PVTlog.txt
echo '****************' >> $PVTlog.txt
		ls -lt | grep mgwarning | awk '{print $9}' | head -n 1 | xargs cat >> $PVTlog.txt
		
		#if [ $(find -name mg\*) ]; then
		#If !(mg*)
		#	close existing terminal
		#	open new terminal
		#	run mg...
		mv mgp* mgc* mge* mgw* $PVTlog/ > /dev/null 2>&1
		mv Meatgrinder__* $PVTlog/ > /dev/null 2>&1
	done #loop end
	#mv $PVTlog.txt $PVTlog/

	echo "$MGruns cycle(s) of the test is finished."
	echo ''$MGruns' cycle(s) of the test is finished.' >> $PVTlog.txt
	#./xdotool windowactivate $TESTWINDOW > /dev/null 2>&1
	#./xdotool type 'exit' 
	#debug
	sleep 1
	##./xdotool keydown --delay 100 KP_Enter > /dev/null 2>&1
	##./xdotool keyup --delay 100 KP_Enter > /dev/null 2>&1
	##./xdotool windowactivate $MAINWINDOW > /dev/null 2>&1
	echo "---------------------------------------------"
	echo '---------------------------------------------' >> $PVTlog.txt
		
else
	echo "device is sleeping or lost"	
fi 
rm Meatgrinder_* > /dev/null 2>&1
#exit 0

