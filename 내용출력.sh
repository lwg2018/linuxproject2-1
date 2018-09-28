#!bin/bash

f_num=0
now_file=0
sub_now_file=0
d_num=0
n_num=0
s_num=0

subd_num=0
subn_num=0
subs_num=0
f_type="null"

del_files(){
    if [ "$1" = "now" ]
    then
	rm -f __directory_list.txt
	rm -f __normal_list.txt
	rm -f __special_list.txt
    fi

    if [ "$1" = "sub" ]
    then
        rm -f __sub_directory_list.txt
        rm -f __sub_normal_list.txt
        rm -f __sub_special_list.txt
    fi

    if [ "$1" = "tem" ]
    then
	rm -f __dl.txt
	rm -f __nl.txt
	rm -f __sl.txt
    fi
}

sort_Type(){
    f_type=`stat --format="%F" $1`
    
    if [ "$2" = "now" ]
    then
        case "$f_type" in
            "디렉토리")echo "$1" >> __dl.txt;d_num=`expr $d_num + 1`;;
            "일반 파일" | "일반 빈 파일")echo "$1" >> __nl.txt;n_num=`expr $n_num + 1`;;
            *)echo "$1" >> __sl.txt;s_num=`expr $s_num + 1`;;
        esac
    fi

    if [ "$2" = "sub" ]
    then
        case "$f_type" in
            "디렉토리")echo "$1" >> __dl.txt;subd_num=`expr $subd_num + 1`;;
            "일반 파일" | "일반 빈 파일")echo "$1" >> __nl.txt;subn_num=`expr $subn_num + 1`;;
            *)echo "$1" >> __sl.txt;subs_num=`expr $subs_num + 1`;;
        esac
    fi
}

sort_Name(){
    if [ "$1" = "now" ]
    then
        if [ -s __dl.txt ]
        then
            sort __dl.txt > __directory_list.txt
	fi
	if [ -s __nl.txt ]
	then
    	    sort __nl.txt > __normal_list.txt
	fi
	if [ -s __sl.txt ]
	then
    	    sort __sl.txt > __special_list.txt
	fi
    fi

    if [ "$1" = "sub" ]
    then
        if [ -s __dl.txt ]
        then
            sort __dl.txt > __sub_directory_list.txt
        fi
        if [ -s __nl.txt ]
        then
            sort __nl.txt > __sub_normal_list.txt
        fi
        if [ -s __sl.txt ]
        then
            sort __sl.txt > __sub_special_list.txt
        fi
    fi
}

file_Information(){
    if [ "$3" ]
    then
	echo "       [$1] File name : $2"
        echo "      --------------------------<Information>--------------------------"
        type=`stat --format="%F" $2`
        case "$type" in
            "디렉토리")echo "[34m       File type : $type";;
            "일반 파일" | "일반 빈 파일")echo "[0m       File type : $type";;
            *)echo "[32m       File type : $type";;

        esac
        echo "[0m       File size : `stat --format="%s" $2`"
        echo "       Last data modification : `stat --format="%y" $2`"
        echo "       Permission : `stat --format="%a" $2`"
        echo "       Absolute path : `readlink -f $2`"
        echo "       Relative path : ./$3/$2"
        echo "      -----------------------------------------------------------------"
	echo -e "\n"
    else
	echo -e "\n"
        echo " [$1] File name : $2"
        echo "--------------------------<Information>--------------------------"
        type=`stat --format="%F" $2`
        case "$type" in
            "디렉토리")echo "[34m File type : $type";;
            "일반 파일" | "일반 빈 파일")echo "[0m File type : $type";;
            *)echo "[32m File type : $type";;
        esac
        echo "[0m File size : `stat --format="%s" $2`"
        echo " Last data modification : `stat --format="%y" $2`"
        echo " Permission : `stat --format="%a" $2`"
        echo " Absolute path : `readlink -f $2`"
        echo " Relative path : ./$2"
        echo "-----------------------------------------------------------------"
    fi
}

del_files "tem"
del_files "now"

echo '======= print file information ======='
echo "current directory : `pwd`"
for file in *
do
    sort_Type $file now
    f_num=`expr $f_num + 1`
done
echo "the number of elements : $f_num"
echo "======================================"

sort_Name "now"

i=0
j=0
dfile="null"
file="null"
while [ $i -lt $d_num ]
do
    subd_num=0
    subn_num=0
    subs_num=0
    sub_now_file=0
    i=`expr $i + 1`
    now_file=`expr $now_file + 1`
    dfile=`sed -n -e "$i p" __directory_list.txt`
    file_Information $now_file $dfile
 
    cd ./$dfile
    del_files "tem"
    del_files "sub"
    
    _empty=0
    for file in *
    do
	if [ $file = "*" ]
	then
	    echo "       < Empty directory >"
	    _empty=1
	    break;
        fi
	sort_Type $file "sub"
    done
    
    if [ $_empty -eq 0 ]
    then
        echo "       < Subfile list >"
	sort_Name "sub"
    fi

    j=0
    while [ $j -lt $subd_num ]
    do
        j=`expr $j + 1`
	sub_now_file=`expr $sub_now_file + 1`
        file=`sed -n -e "$j p" __sub_directory_list.txt`
	file_Information $sub_now_file "$file" "$dfile"
    done

    j=0
    while [ $j -lt $subn_num ]
    do
        j=`expr $j + 1`
        sub_now_file=`expr $sub_now_file + 1`
        file=`sed -n -e "$j p" __sub_normal_list.txt`
        file_Information $sub_now_file "$file" "$dfile"
    done

    j=0
    while [ $j -lt $subs_num ]
    do
        j=`expr $j + 1`
        sub_now_file=`expr $sub_now_file + 1`
        file=`sed -n -e "$j p" __sub_special_list.txt`
        file_Information $sub_now_file "$file" "$dfile"
    done

    del_files "tem"
    del_files "sub"
    cd ..
done

i=0
while [ $i -lt $n_num ]
do
    i=`expr $i + 1`
    now_file=`expr $now_file + 1`
    file=`sed -n -e "$i p" __normal_list.txt`
    file_Information $now_file $file
done

i=0
while [ $i -lt $s_num ]
do
    i=`expr $i + 1`
    now_file=`expr $now_file + 1`
    file=`sed -n -e "$i p" __special_list.txt`
    file_Information $now_file $file
done

del_files "tem"
del_files "now"
