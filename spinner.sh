function start_spinner {
 function spin {
  local animation='/-\|'
  spinner_pid=1
   until [[ $spinner_pid == 0 ]] ; do
    for i in "${animation#?}"; do
      echo -n "${animation#$i}"
      sleep .1
    done
   done
 }
 spin
}
function stop_spinner {
  spinner_pid=0 &> /dev/null
}

function do_sth {
    start_spinner &
    for i in seq 1 3 ; do
        echo "dupa"
    done
    stop_spinner
  echo ""
}

do_sth