createmenu ()
{
  arrsize=$1
  echo "Size of array: $arrsize"
  echo "${@:2}"
  select option in "${@:2}"; do
    if [ "$REPLY" -eq "$arrsize" ];
    then
      echo "Exiting..."
      break;
    elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((arrsize-1)) ];
    then
      echo "You selected $option which is option $REPLY"
      break;
    else
      echo "Incorrect Input: Select a number 1-$arrsize"
    fi
  done
}

createmenu "${#buckets[@]}" "${buckets[@]}"




