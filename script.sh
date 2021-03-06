#!/bin/bash
function levenshtein {
    if [ "$#" -ne "2" ]; then
        echo "Usage: $0 word1 word2" >&2
    elif [ "${#1}" -lt "${#2}" ]; then
        levenshtein "$2" "$1"
    else
        local str1len=$((${#1}))
        local str2len=$((${#2}))
        local d i j
        for i in $(seq 0 $(((str1len+1)*(str2len+1)))); do
            d[i]=0
        done
        for i in $(seq 0 $((str1len))); do
            d[$((i+0*str1len))]=$i
        done
        for j in $(seq 0 $((str2len))); do
            d[$((0+j*(str1len+1)))]=$j
        done

        for j in $(seq 1 $((str2len))); do
            for i in $(seq 1 $((str1len))); do
                [ "${1:i-1:1}" = "${2:j-1:1}" ] && local cost=0 || local cost=1
                local del=$((d[(i-1)+str1len*j]+1))
                local ins=$((d[i+str1len*(j-1)]+1))
                local alt=$((d[(i-1)+str1len*(j-1)]+cost))
                d[i+str1len*j]=$(echo -e "$del\n$ins\n$alt" | sort -n | head -1)
            done
        done
        echo ${d[str1len+str1len*(str2len)]}
    fi
}
array=()

read str1; 
array+=("$str1")
while read str2; do
    count=0
    for (( i=0; i<"${#array[@]}"; i++ )); do
        lev=$(levenshtein "$str2" "${array[$i]}");
        l1=${#str2}
        l2=${#array[$i]}
        if [ $l1 == $l2 ] && [ "$lev" == "0" ]; then 
            count=$((count+1))
        elif [ $l1 -gt $l2 ]; then
            val=$((l1/2))
            if [ "$lev" == "0" ] || [ "$lev" -lt $val ]; then
                count=$((count+1))
            fi 
        elif [ $l2 -gt $l1 ]; then
            val=$((l2/2))
            if [ "$lev" == "0" ] || [ "$lev" -lt $val ]; then
                count=$((count+1))
            fi 
        fi
        printf '%s / %s : %s\n' "$str2" "${array[$i]}" "$lev"
    done
    printf "Count of the string being repeated is %d \n" "$count"
    array+=("$str2")
done

