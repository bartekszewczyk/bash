#!/bin/bash
#---------------------------------------------------------------------------
# Autor: Bartosz Szewczyk
# Data: 13/10/2020
#---------------------------------------------------------------------------
# Wlacza konkretne hosty w klastrze, w zaleznosci od wybranej opcji
#---------------------------------------------------------------------------

#----------------------------
# Animacja podczas czekania
#----------------------------
spinner() {
spin() {
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
#----------------------------

#------------------
# Tytul aplikacji
#------------------
logo() {
clear
local prompt="   >"

    printf "\n"
    printf "\t___________\n\n"
    printf "\t WakeOnLan \n"
    printf "\t___________\n"
    printf "\n"

PS3="$prompt "
}
#------------------

#-----------------
# Funkcja glowna
#-----------------
wol() {
logo

# Wszystkie adresy MAC hostow
declare -A hosty=( [ubuntu101]=44:a8:42:42:a9:0a [ubuntu102]=44:a8:42:42:a6:52
                   [ubuntu103]=44:a8:42:42:af:32 [ubuntu104]=44:a8:42:42:a8:76
                   [ubuntu105]=44:a8:42:42:a7:fe [ubuntu106]=44:a8:42:42:a8:16
                   [ubuntu107]=44:a8:42:42:aa:fb [ubuntu108]=44:a8:42:42:ae:21
                   [ubuntu109]=44:a8:42:42:a0:62 [ubuntu110]=44:a8:42:42:a4:dc
                   [ubuntu111]=44:a8:42:42:a8:f6 [ubuntu112]=44:a8:42:42:a9:02
                   [ubuntu113]=44:a8:42:42:a8:92 [ubuntu114]=44:a8:42:42:a0:a6 )
# ubuntu109 wylaczony - grzeje sie do 95 stopni pod obciazeniem!!
# [ubuntu109]=44:a8:42:42:a0:62

# Adresy MAC hostow 1-7
declare -a hosty1=( 44:a8:42:42:a9:0a 44:a8:42:42:a6:52
                    44:a8:42:42:af:32 44:a8:42:42:a8:76
                    44:a8:42:42:a7:fe 44:a8:42:42:a8:16
                    44:a8:42:42:aa:fb )
# Adresy MAC hostow 7-14
declare -a hosty2=( 44:a8:42:42:ae:21 44:a8:42:42:a0:62
                    44:a8:42:42:a4:dc 44:a8:42:42:a8:f6
                    44:a8:42:42:a9:02 44:a8:42:42:a8:92
                    44:a8:42:42:a0:a6 )

declare -a menu=( "Wlacz WSZYSTKIE hosty w klastrze!       "
                  "Wlacz hosty 1-7                         "
                  "Wlacz hosty 7-14                        "
                  "Wlacz hosta ubuntu..    [101-114]       "
                  "Wyjdz                                   " )

select y in "${menu[@]}"
 do
  case $y in

    "${menu[0]}")

  for i in ${hosty[@]}
    do
      printf "\n\t Wlaczam WSZYSTKIE hosty w klastrze! \n" ; spinner sleep 3
      /usr/bin/wakeonlan $i > /dev/null 2>&1
      printf "\t Zrobione! \n\n" ; sleep 0.5
      exit
    done

;;

  "${menu[1]}")

  for i in ${hosty1[@]}
    do
      printf "\n\t Wlaczam hosty 1-7 \n" ; spinner sleep 3
      /usr/bin/wakeonlan $i > /dev/null 2>&1
      printf "\t Zrobione! \n\n" ; sleep 0.5
      exit
    done


;;

  "${menu[2]}")

  for i in ${hosty2[@]}
    do
      printf "\n\t Wlaczam hosty 7-14 \n" ; spinner sleep 3
      /usr/bin/wakeonlan $i > /dev/null 2>&1
      printf "\t Zrobione! \n\n" ; sleep 0.5
      exit
    done

;;

  "${menu[3]}")

    printf "\n"
    read -p "Podaj nr hosta od 101-114:  " host
      printf "\n\t Wlaczam ubuntu$host. \n" ; spinner sleep 1
      /usr/bin/wakeonlan ${hosty[ubuntu$host]} > /dev/null 2>&1
      printf "\t Zrobione! \n\n" ; sleep 0.5
    exit

;;

   "${menu[4]}") 

    printf "\n" ;  sleep 0.4 ; exit

;;

   *) printf "\n\nWybierz odpowiednia opcje!\n\n" ; sleep 1 

;;

  esac
 wol
 done
}
#----------------

wol



