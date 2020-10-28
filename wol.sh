#!/bin/bash
#-----------------------------------------------------------------------
# Author: Bartosz Szewczyk
# Data: 13/10/2020
#-----------------------------------------------------------------------
# WakeOnLan - "Simple" start/stop hosts program on Linux
# Program uses wakeonlan, openssh packages and ping.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# DATA
#-----------------------------------------------------------------------
# USER to HOST and MASTERS
USER="lsm"

# MASTERS
declare -A IP_MASTER                  ; declare -a orderIP_MASTER
IP_MASTER["master1"]="10.4.8.116"     ; orderIP_MASTER+=( "master1" )
IP_MASTER["master2"]="10.4.8.117"     ; orderIP_MASTER+=( "master2" )

# HOSTS
declare -A IP                  ; declare -a orderIP
IP["ubuntu101"]="10.4.8.101"   ; orderIP+=( "ubuntu101" )
IP["ubuntu102"]="10.4.8.102"   ; orderIP+=( "ubuntu102" )
IP["ubuntu103"]="10.4.8.103"   ; orderIP+=( "ubuntu103" )
IP["ubuntu104"]="10.4.8.104"   ; orderIP+=( "ubuntu104" )
IP["ubuntu105"]="10.4.8.105"   ; orderIP+=( "ubuntu105" )
IP["ubuntu106"]="10.4.8.106"   ; orderIP+=( "ubuntu106" )
IP["ubuntu107"]="10.4.8.107"   ; orderIP+=( "ubuntu107" )
IP["ubuntu108"]="10.4.8.108"   ; orderIP+=( "ubuntu108" )
IP["ubuntu109"]="10.4.8.109"   ; orderIP+=( "ubuntu109" )
IP["ubuntu110"]="10.4.8.110"   ; orderIP+=( "ubuntu110" )
IP["ubuntu111"]="10.4.8.111"   ; orderIP+=( "ubuntu111" )
IP["ubuntu112"]="10.4.8.112"   ; orderIP+=( "ubuntu112" )
IP["ubuntu113"]="10.4.8.113"   ; orderIP+=( "ubuntu113" )
IP["ubuntu114"]="10.4.8.114"   ; orderIP+=( "ubuntu114" )

# MASTERS
declare -A MAC_MASTER
MAC_MASTER["master1"]="44:a8:42:48:14:57"
MAC_MASTER["master2"]="44:a8:42:48:14:15"

declare -A MAC
# HOSTS
MAC["ubuntu101"]="44:a8:42:42:a9:0a"
MAC["ubuntu102"]="44:a8:42:42:a6:52"
MAC["ubuntu103"]="44:a8:42:42:af:32"
MAC["ubuntu104"]="44:a8:42:42:a8:76"
MAC["ubuntu105"]="44:a8:42:42:a7:fe"
MAC["ubuntu106"]="44:a8:42:42:a8:16"
MAC["ubuntu107"]="44:a8:42:42:aa:fb"
MAC["ubuntu108"]="44:a8:42:42:ae:21"
MAC["ubuntu109"]="44:a8:42:42:a0:62"
MAC["ubuntu110"]="44:a8:42:42:a4:dc"
MAC["ubuntu111"]="44:a8:42:42:a8:f6"
MAC["ubuntu112"]="44:a8:42:42:a9:02"
MAC["ubuntu113"]="44:a8:42:42:a8:92"
MAC["ubuntu114"]="44:a8:42:42:a0:a6"


#-----------------------------------------------------------------------
# VARIABLES
#-----------------------------------------------------------------------
# Logo special characters
bs="\e[100m"
be="\e[49m"
cs="\e[30m"
ce="\e[39m"
# Displays prompt
color_prompt="\e[92;4;1mwakeonlan\e[39;0m:\e[94m~\e[39m$ "
prompt="echo -e -n $color_prompt"
# Color status
online="\e[42mONLINE\e[49m"
offline="\e[41mOFFLINE\e[49m"


#-----------------------------------------------------------------------
# LOGO
#-----------------------------------------------------------------------
# Displays main logo
logo_upper_border="$cs█$ce $cs◼ ◼ ◼ ◼ ◼$ce $cs█$ce"
logo_lower_border="$cs◼ ◼ ◼ ◼ ◼$ce"
logo_wakeonlan="$cs◼$ce \e[2mWakeOnLan\e[0m $cs◼$ce"
text_main="$cs$ce\e[2m « START/STOP hosts program. »\e[0m"
text_copy="\e[2m « 2020 © Bartosz Szewczyk » \e[0m"
text_start="$cs$ce\e[2m « START - Uses wakeonlan package by IP and MAC »\e[0m"
text_stop="$cs$ce\e[2m « STOP - Uses ssh to host with shutdown command »\e[0m"
text_check="$cs$ce\e[2m « CHECK - Ping hosts by IP »\e[0m"

function display_logo {
  clear
    local t1=$1
    local t2=$2
      echo -e "                              "
      echo -e "      $logo_upper_border      "
      echo -e "      $logo_wakeonlan     $t1  "
      echo -e "        $logo_lower_border        $t2  "
      echo -e "                                                "
}


#-----------------------------------------------------------------------
# FUNCTIONS
#-----------------------------------------------------------------------
# Just a spinner animation while waiting
function spinner {
 function spin {
  local -r pid="${1}"
  local -r delay='0.1'
  local spinstr='/-\|'
  local temp
   while ps a | awk '{print $1}' | grep -q "${pid}"; do
    temp="${spinstr#?}"
    printf " [%c]  " "${spinstr}"
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\b\b\b\b\b\b"
   done
  printf "    \b\b\b\b \n"
 }
 ("$@") &
 printf ""
 spin "$!"
}

# Displays when task is done
function say_task_done {
  echo ""
  echo "    Done! "
  echo "" ; sleep 1.5
}

# Displays warning when user chose wrong
function say_wrong_option {
  echo ""
  echo -n "    Please enter available option!" ; sleep 1
}

# Displays Bye! text
function say_bye {
  echo -n "Bye!" ; echo "" ; sleep 0.5 ; exit
}

# Displays instruction
function display_host_range {
  local a="${orderIP[0]}"
  local b="${orderIP[${#orderIP[@]}-1]}"
  echo ""
  echo "  6. Back" ; echo ""
  echo "    (Please enter name of host (eg. $a..$b) "
  echo ""
}

# Displays instruction
function display_master_range {
  local a="${orderIP_MASTER[0]}"
  local b="${orderIP_MASTER[${#orderIP_MASTER[@]}-1]}"
  echo ""
  echo "  6. Back" ; echo ""
  echo "    (Enter enter name of master (eg. $a..$b) "
  echo ""
}

# Pings host with given ip
function pingit {
  local ip=$1
  ping_output=`timeout 0.2 ping -c1 -w1 $ip &> /dev/null && echo $?`
}

# Displays status on host
function status {
  local hostname=$1
  local status=$2
  local print=`echo -e "$hostname $status" | tr -s '\t' ' '`
    echo "$print"
}

# Sets array with host status online/offline
declare -A ACTIVE;

# Checks if array contain value
function contain_value {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

# Timer - displays countdown
function countdown(){
  date1=$((`date +%s` + $1));
  text1=$2
  while [ "$date1" -ge `date +%s` ]; do
    echo -ne "$2" "$(date -u --date @$(($date1 - `date +%s`)) +%S)\r";
    sleep 0.1
  done
}
function stopwatch(){
  date1=`date +%s`;
  while true; do
   echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%S)\r";
   sleep 0.1
  done
}

#-----------------------------------------------------------------------
# CHECK MENU
#-----------------------------------------------------------------------
# Check menu with logic
function menu_check_host {
  display_logo "$text_check"
  local option=0
    echo "  1. CHECK ALL hosts and masters"
    echo "  2. CHECK hosts until ONLINE (100 times)"
    echo ""
    echo "  6. Back"
    echo "  7. Exit"
    echo ""
    echo "    (Please enter 1-2)"
    echo ""
    $prompt
    read option
    echo ""

  # Sets variable to be host or master (useless for now)
  # position="zero"

  function display_instruction_ping {
    echo "  6. Back"
    echo ""
    echo "    (Press enter to continue [n-times]) "
    echo ""
    $prompt
    read input
    if [[ "$input" == "6" ]]; then
      menu_check_host
    # elif [[ "$position" == "host" ]]; then
    #   check_host ; display_instruction_ping
    # elif [[ "$position" == "master" ]]; then
    #   check_master ; display_instruction_ping
    else
     check_host ; check_master ; display_instruction_ping
    fi
  }

  # Ping hosts and gives online/offline status
  function check_host {
    for no in "${!orderIP[@]}"; do
      pingit "${orderIP[$no]}"
      if [[ "$ping_output" == "0" ]] ; then
        ACTIVE+=([$no]=online)
        status " ${orderIP[$no]}" " $online"
      else
        ACTIVE+=([$no]=offline)
        status " ${orderIP[$no]}" " $offline"
      fi
    done
  echo ""
  }

  # Ping masters and gives online/offline status
  function check_master {
    for no in "${!orderIP_MASTER[@]}"; do
      pingit "${orderIP_MASTER[$no]}"
      if [[ "$ping_output" == "0" ]] ; then
        ACTIVE+=([$no]=1)
        status " ${orderIP_MASTER[$no]}" " $online"
      else
        ACTIVE+=([$no]=0)
        status " ${orderIP_MASTER[$no]}" " $offline"
      fi
    done
  echo ""
  }

  # Loop of check_host to ping hosts till ALL with online status (100 times)
  function check_host_till_active {
    check_host &> /dev/null & echo -n " ..Starting check status sequence "\
    & spinner sleep 3
    echo ""
    for i in {1..100} ; do
      echo -n " (Check $i - " ; date '+%T/%F) '
      check_host
      countdown 5 " Next check in: "
    done
  echo ""
  }


    # Functions initialize
    case $option in
    1 )   check_host ; sleep 0.2 ; check_master ; sleep 0.2 ; display_instruction_ping ;;
    2 )   check_host_till_active ; display_instruction_ping ;;
    6 )   main_menu ;;
    7 )   say_bye ;;
    * )   say_wrong_option ; menu_check_host ;;
    esac
}


#-----------------------------------------------------------------------
# START MENU
#-----------------------------------------------------------------------
# Start menu with functions
function menu_start_host {
  display_logo "$text_start"
  local option=0
    echo "  1. START ALL hosts!"
    echo "  2. START hosts first half"
    echo "  3. START hosts second half"
    echo "  4. START host [name]..    (eg. '${orderIP[0]}')"
    echo "  5. START master [name].. (eg. '${orderIP_MASTER[0]}')"
    echo ""
    echo "  6. Back"
    echo "  7. Exit"
    echo ""
    echo "    (Please enter 1-5)"
    echo ""
    $prompt
    read option
    echo ""

    # Displays starting host
    function say_start_host {
        local host=$1
        echo -n "    Starting $host  " ; spinner sleep 0.2
    }

    # Uses wakeonlan to send packet on port 9 by ip and mac
    function start {
        # local ip=$1
        local mac=$1
        # /usr/bin/wakeonlan -i $ip $mac > /dev/null 2>&1 # with ip
        /usr/bin/wakeonlan $mac > /dev/null 2>&1
    }

    # Uses start function to start all hosts
    function start_all {
        for no in "${orderIP[@]}" ; do
        start "${MAC[$no]}"
        say_start_host "$no"
        done
      say_task_done
    }

    # Uses start function to start first half of hosts array
    function start_first_half {
        for no in "${orderIP[@]:0:7}" ; do
        start "${MAC[$no]}"
        say_start_host "$no"
        done
      say_task_done
    }

    # Uses start function to start second half of hosts array
    function start_second_half {
        for no in "${orderIP[@]:7:13}" ; do
        start "${MAC[$no]}"
        say_start_host "$no"
        done
      say_task_done
    }

    # Reading user input (wich host) and uses start function
    function choose_host_to_start {
      display_logo "$text_start"
        display_host_range
        $prompt ; read input
        contain_value "$input" "${orderIP[@]}"
          if [[ $? == 1 ]] ; then
          echo ; say_start_host "$input"
          start "${MAC[$input]}"
          say_task_done ; menu_start_host
        elif [[ "$input" == "6" ]] ; then
          menu_start_host
        else
          say_wrong_option
          choose_host_to_start
        fi
    }

    # Reading user input (wich master) and uses start function
    function choose_master_to_start {
      display_logo "$text_start"
        display_master_range
        $prompt ; read input
        contain_value "$input" "${orderIP_MASTER[@]}"
          if [[ $? == 1 ]] ; then
            echo ; say_start_host "$input"
            start "${MAC_MASTER[$input]}"
            say_task_done ; menu_start_host
          elif [[ "$input" == "6" ]] ; then
            menu_start_host
          else
            say_wrong_option
            choose_master_to_start
          fi
    }


    # Functions initialize
    case $option in
    1 )   start_all ; menu_start_host ;;
    2 )   start_first_half ; menu_start_host ;;
    3 )   start_second_half ; menu_start_host ;;
    4 )   choose_host_to_start ; menu_start_host ;;
    5 )   choose_master_to_start ; menu_start_host ;;
    6 )   main_menu ;;
    7 )   say_bye ;;
    * )   say_wrong_option ; menu_start_host ;;
    esac
}


#-----------------------------------------------------------------------
# STOP MENU
#-----------------------------------------------------------------------
# Stop menu with logic
function menu_stop_host {
  display_logo "$text_stop"
  local option=0
    echo "  1. STOP ALL hosts"
    echo "  2. STOP hosts first half"
    echo "  3. STOP hosts second half"
    echo "  4. STOP host [name].. (eg. '${orderIP[0]}')"
    echo "  5. STOP master [name].. (eg. '${orderIP_MASTER[0]}')"
    echo ""
    echo "  6. Back"
    echo "  7. Exit"
    echo ""
    echo "    (Please enter 1-5)"
    echo ""
    $prompt
    read option
    echo ""

    # Displays stopping host
    function say_stop_host {
      local host=$1
      echo -n "    Stopping $host  " ; spinner sleep 0.2
    }

    # Uses ssh to send command to shutdown host
    function stop {
      local ip=$1
      ssh -t $USER@$ip 'sudo shutdown now' > /dev/null 2>&1
    }

    # Uses stop function to stop ALL hosts
    function stop_all {
        for no in "${orderIP[@]}" ; do
        stop "${IP[$no]}"
        say_stop_host "$no"
        done
      say_task_done
    }

    # Uses stop function to stop first half of hosts array
    function stop_first_half {
        for no in "${orderIP[@]:0:7}" ; do
        stop "${IP[$no]}"
        say_stop_host "$no"
        done
      say_task_done
    }

    # Uses stop function to stop second half of hosts array
    function stop_second_half {
        for no in "${orderIP[@]:7:13}" ; do
        stop "${IP[$no]}"
        say_stop_host "$no"
        done
      say_task_done
    }

    # Reading user input (wich host) and uses stop function
    function choose_host_to_stop {
      display_logo "$text_stop"
        display_host_range
        $prompt ; read input
        contain_value "$input" "${orderIP[@]}"
          if [[ $? == 1 ]] ; then
          echo ; say_stop_host "$input"
          stop "${IP[$input]}"
          say_task_done ; menu_stop_host
        elif [[ "$input" == "6" ]] ; then
          menu_stop_hosts
        else
          say_wrong_option
          choose_host_to_stop
        fi
    }

    # Reading user input (wich master) and uses stop function
    function choose_master_to_stop {
      display_logo "$text_stop"
        display_master_range
        $prompt ; read input
        contain_value "$input" "${orderIP_MASTER[@]}"
          if [[ $? == 1 ]] ; then
          echo ; say_stop_host "$input"
          stop "${IP_MASTER[$input]}"
          say_task_done ; menu_stop_host
        elif [[ "$input" == "6" ]] ; then
          menu_stop_hosts
        else
          say_wrong_option
          choose_master_to_stop
        fi
    }


    # Functions initialize
    case $option in
    1 )   stop_all ; menu_stop_host ;;
    2 )   stop_first_half ; menu_stop_host ;;
    3 )   stop_second_half ; menu_stop_host ;;
    4 )   choose_host_to_stop ; menu_stop_host ;;
    5 )   choose_master_to_stop ; menu_stop_host ;;
    6 )   sleep 0.1 ; main_menu ;;
    7 )   say_bye ;;
    * )   say_wrong_option ; menu_stop_host ;;
    esac
}


#-----------------------------------------------------------------------
# MAIN MENU
#-----------------------------------------------------------------------
# Displays main logo and menu with all options available
function main_menu {
  display_logo "$text_main" "$text_copy"
   local option=0
     echo "  1. START hosts"
     echo "  2. STOP hosts"
     echo "  3. CHECK hosts"
     echo ""
     echo "  7. Exit"
     echo ""
     echo "    (Please enter 1-3)"
     echo ""
     $prompt
     read option
     echo ""


     # Functions initialize
     case $option in
       1 ) menu_start_host ;;
       2 ) menu_stop_host ;;
       3 ) menu_check_host ;;
       7 ) say_bye ;;
       * ) say_wrong_option ; main_menu ;;
     esac
}


#-----------------------------------------------------------------------
# PROGRAM START
#-----------------------------------------------------------------------
main_menu
