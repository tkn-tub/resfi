#!/bin/bash
me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

if [ $# -eq 0 ]
  then
    echo -e echo "Unknown command in argument.\nPossible Commands:\n\t\t $me start \n\t\t $me stop \n\t\t $me del_logs"
    exit 0
fi

if [ "$1" == "start" ]
then
    echo "**********************************"
    echo "*********** ResFi DEMO ***********"
    echo "**********************************"
    sleep 1
    sudo blinkstick --morph red
	#1st start hostapds
	echo "-> starting Home Wi-Fi Networks in Worst Case Scenario (All on the same channel)"
    echo "-> starting hostapd on Home AP 1"
	ssh 192.168.200.29 "sudo killall hostapd &2>mute.log"
	ssh -f 192.168.200.29 "cd /home/robat/resfi/ && /home/robat/resfi/start_ap_only.sh phy0 &> /tmp/hostapd_home1.log"
	
	echo "-> starting hostapd on Home AP 2"
	ssh 192.168.200.10 "sudo killall -9 hostapd &2>mute.log"
	ssh -f 192.168.200.10 "cd /home/robat/resfi/ && /home/robat/resfi/start_ap_only.sh phy0 &> /tmp/hostapd_home2.log"
    
    echo "-> starting hostapd on Home AP 3"
	ssh 192.168.200.40 "sudo killall -9 hostapd &2>mute.log"
	ssh -f 192.168.200.40 "cd /home/robat/resfi/ && /home/robat/resfi/start_ap_only.sh phy0 &> /tmp/hostapd_home3.log"
    
    echo "-> starting hostapd on Home AP 4"
	ssh 192.168.200.15 "sudo killall -9 hostapd &2>mute.log"
	ssh -f 192.168.200.15 "cd /home/robat/resfi/ && /home/robat/resfi/start_ap_only.sh phy0 &> /tmp/hostapd_home4.log"

secs=$((45))
while [ $secs -gt 0 ]; do
   echo -ne "Home APs started, starting ResFi on Home APs in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
#sudo blinkstick --blink yellow --duration 50
    echo "-> starting ResFi on Home AP 1"
        ssh -f 192.168.200.29 "cd /home/robat/resfi/ && /home/robat/resfi/start_resfi_only.sh &> /tmp/resfi_console_demo.log"
        ssh -f 192.168.200.29 "cd /home/robat/resfi/ && /home/robat/resfi/control_mailbox_failure.sh &> /tmp/resfi_mailbox_failure.log"
secs=$((20))
while [ $secs -gt 0 ]; do
   #sudo blinkstick --blink yellow --duration 50
   echo -ne "Starting ResFi on Home AP 2 in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
	#sudo blinkstick --blink yellow --duration 50
	echo "-> starting ResFi on Home AP 2"
#	ssh 192.168.200.10 "sudo killall -9 python &2>mute.log"
	ssh -f 192.168.200.10 "cd /home/robat/resfi/ && /home/robat/resfi/start_resfi_only.sh &> /tmp/resfi_console_demo.log"
        ssh -f 192.168.200.10 "cd /home/robat/resfi/ && /home/robat/resfi/control_mailbox_failure.sh &> /tmp/resfi_mailbox_failure.log"

secs=$((20))
while [ $secs -gt 0 ]; do
    #sudo blinkstick --blink yellow --duration 50
   echo -ne "Starting ResFi on Home AP 3 in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

sudo blinkstick --blink yellow --duration 20
    echo "-> starting ResFi on Home AP 3"
#	ssh 192.168.200.40 "sudo killall -9 python &2>mute.log"
	ssh -f 192.168.200.40 "cd /home/robat/resfi/ && /home/robat/resfi/start_resfi_only.sh &> /tmp/resfi_console_demo.log"
        ssh -f 192.168.200.40 "cd /home/robat/resfi/ && /home/robat/resfi/control_mailbox_failure.sh &> /tmp/resfi_mailbox_failure.log"

secs=$((20))
while [ $secs -gt 0 ]; do
    sudo blinkstick --blink yellow --duration 20
   echo -ne "Starting ResFi on Home AP 4 in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

    
    echo "-> starting ResFi on Home AP 4"
#	ssh 192.168.200.15 "sudo killall -9 python &2>mute.log"
	ssh -f 192.168.200.15 "cd /home/robat/resfi/ && /home/robat/resfi/start_resfi_only.sh &> /tmp/resfi_console_demo.log"
        ssh -f 192.168.200.15 "cd /home/robat/resfi/ && /home/robat/resfi/control_mailbox_failure.sh &> /tmp/resfi_mailbox_failure.log"

secs=$((20))
while [ $secs -gt 0 ]; do
    sudo blinkstick --blink yellow --duration 20
   echo -ne "Waiting till ResFi on Home AP 4 is started: $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

sudo blinkstick --morph green
    echo  "ResFi with Channel Assignment Application on all Home APs started"

secs=$((40))
while [ $secs -gt 0 ]; do
   echo -ne "Starting Interferring Non-Cooperative AP on channel 120 in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
 
    echo "Starting Interfering Wi-Fi Network"
    sudo /home/robat/resfi/test/start_nrf_ap.sh phy1
    sleep 1
    #echo "Interferer turned off, waiting till ResFi APs found good assignment again"
secs=$((10))
while [ $secs -gt 0 ]; do
   echo -ne "Repeating Demo in : $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

    echo "Repeating Demo, stopping everything."
    /home/robat/resfi/demo.sh stop
    sleep 1
    /home/robat/resfi/demo.sh start    
	
elif [ $1 = "stop" ]
then
	ssh 192.168.200.29 "sudo killall -9 hostapd"
	ssh 192.168.200.29 "sudo ifconfig ap5 down"
        ssh 192.168.200.29 "sudo killall -9 python"
        ssh 192.168.200.29 "rm /tmp/resfi_console_demo.log"
        ssh 192.168.200.10 "sudo killall -9 hostapd"
        ssh 192.168.200.10 "sudo ifconfig ap5 down"
        ssh 192.168.200.10 "sudo killall -9 python"
        ssh 192.168.200.10 "rm /tmp/resfi_console_demo.log"
        ssh 192.168.200.40 "sudo killall -9 hostapd"
        ssh 192.168.200.40 "sudo ifconfig ap5 down"
        ssh 192.168.200.40 "sudo killall -9 python"
        ssh 192.168.200.40 "rm /tmp/resfi_console_demo.log"
        ssh 192.168.200.15 "sudo killall -9 hostapd"
        ssh 192.168.200.15 "sudo ifconfig ap5 down"
        ssh 192.168.200.15 "sudo killall -9 python"
        ssh 192.168.200.15 "rm /tmp/resfi_console_demo.log"
        sudo blinkstick --pulse red
else
	echo "Unknown command in argument.\nPossible Commands:\n\t\t $me start \n\t\t $me stop \n\t\t $me del_logs"
fi

