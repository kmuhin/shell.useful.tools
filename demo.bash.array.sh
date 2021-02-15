#!/bin/bash

echo https://www.linuxjournal.com/content/bash-arrays

function echoarr() {
    printf '%-15s: %-15s # %-s\n' "${@}"
}

arr=(Hello World)


echoarr '${arr}' ${arr}
echoarr '${arr[0]}' ${arr[0]}
echoarr '${arr[1]}' ${arr[1]}
echoarr '${arr[2]}' ${arr[2]}

echoarr '${arr[*]}' "${arr[*]}" "All of the items in the array"
echoarr '${!arr[*]}' "${!arr[*]}" "All of the indexes in the array" 
echoarr '${#arr[*]}' "${#arr[*]}" "Number of items in the array" 
echoarr '${#arr[0]}' "${#arr[0]}" "Length of item zero" 


echo
array=(one two three four [5]=five)
echo 'array=(one two three four [5]=five)'

echo "Array size: ${#array[*]}"

echo "Array items:"
for item in ${array[*]}
do
    printf "   %s\n" $item
done

echo "Array indexes:"
for index in ${!array[*]}
do
    printf "   %d\n" $index
done

echo "Array items and indexes:"
for index in ${!array[*]}
do
    printf "%4d: %s\n" $index ${array[$index]}
done

