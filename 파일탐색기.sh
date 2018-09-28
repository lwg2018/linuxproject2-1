#!/bin/bash

f_num=0 #총 파일 갯수
d_num=0 #디렉토리 갯수
n_num=0 #일반파일 갯수
s_num=0 #특수파일 갯수
now_size=0 #현재 디렉토리 파일들의 크기 총합

cp_num=0 #복사할 파일 갯수
mv_num=0 #이동할 파일 갯수

#cp, mv 파일들
cp_file1="null"
cp_file2="null"
cp_file3="null"
mv_file1="null"
mv_file2="null"
mv_file3="null"

now_file=1 #현재 가르키고 있는 파일
first_file=1 #화면에 출력할 첫번째 파일
last_file=25 #화면에 출력할 마지막 파일

f_type="null"

del_files(){ #정렬한 txt파일 삭제
    if [ "$1" = "now" ]
    then
	rm -f ~/__directory_list.txt
	rm -f ~/__normal_list.txt
	rm -f ~/__special_list.txt
    fi

    if [ "$1" = "tem" ]
    then
	rm -f ~/__dl.txt
	rm -f ~/__nl.txt
	rm -f ~/__sl.txt
    fi
}

sort_Type(){ #타입별 소트
    f_type=`stat --format="%F" $1`

    case "$f_type" in
        "디렉토리")echo "$1" >> ~/__dl.txt;d_num=`expr $d_num + 1`;;
        "일반 파일" | "일반 빈 파일")echo "$1" >> ~/__nl.txt;n_num=`expr $n_num + 1`;;
        *)echo "$1" >> ~/__sl.txt;s_num=`expr $s_num + 1`;;
    esac
}

sort_Name(){ #이름별 소트
        if [ -s ~/__dl.txt ]
        then
            sort ~/__dl.txt > ~/__directory_list.txt
	fi
	if [ -s ~/__nl.txt ]
	then
    	    sort ~/__nl.txt > ~/__normal_list.txt
	fi
	if [ -s ~/__sl.txt ]
	then
    	    sort ~/__sl.txt > ~/__special_list.txt
	fi
}

output_Parent(){ #상위 디렉토리 출력
    i=0
    j=1
    max=21 #최대 20개
    #UI
    while [ $i -lt 26 ]
    do
	i=`expr $i + 1`
	tput cup $i 0
        echo "|              |                                                               |"
    done

    i=0
    tput cup $j 1
    echo "[31m.." #상위 디렉토리
    echo "[0m"

    while [ $i -lt $d_num ] #디렉토리 출력
    do
        i=`expr $i + 1`
        j=`expr $j + 1`
	if [ $j -le $max ] #출력할 수 있는 갯수는 20개까지
	then
	    tput cup $j 0
	    filename=`sed -n -e "$i p" ~/__directory_list.txt`
	    tput cup $j 1
	    filename=${filename:0:10} #10글자까지만
	    echo "[34m$filename"
	    echo "[0m"
	fi
    done

    i=0
    while [ $i -lt $n_num ] #일반파일 출력
    do
        i=`expr $i + 1`
        j=`expr $j + 1`
        if [ $j -le $max ]
        then
	    tput cup $j 0
            filename=`sed -n -e "$i p" ~/__normal_list.txt`
            tput cup $j 1
	    if [ -x "$filename" ] #execute file
	    then
		echo "[31m${filename:0:10}"
	    else
		echo "[0m${filename:0:10}"
	    fi
	    echo "[0m"
        fi
    done

    i=0
    while [ $i -lt $s_num ] #특수파일 출력
    do
        i=`expr $i + 1`
        j=`expr $j + 1`
        if [ $j -le $max ]
        then
            tput cup $j 0
            filename=`sed -n -e "$i p" ~/__special_list.txt`
            tput cup $j 1
            filename=${filename:0:10}
            echo "[32m$filename"
	    echo "[0m"
        fi
    done

    if [ $j -gt $max ] #상위디렉토리의 파일갯수가 20개를 초과한다면
    then
	tput cup 22 1
	echo "...."
    fi
}

# $1=행 $2=열 $3=파일이름
output_D(){
    tput cup $1 $2
    echo "     __"
    tput cup `expr $1 + 1` $2
    echo "/---/ |"
    tput cup `expr $1 + 2` $2
    echo "|  d  |"
    tput cup `expr $1 + 3` $2
    echo "-------"
    tput cup `expr $1 + 4` $2
    echo "$3"
}

output_F(){
    tput cup $1 $2
    echo "_______"
    tput cup `expr $1 + 1` $2
    echo "|     |"
    tput cup `expr $1 + 2` $2
    echo "|  o  |"
    tput cup `expr $1 + 3` $2
    echo "-------"
    tput cup `expr $1 + 4` $2
    echo "$3"
}

output_S(){
    tput cup $1 $2
    echo "_______"
    tput cup `expr $1 + 1` $2
    echo "|     |"
    tput cup `expr $1 + 2` $2
    echo "|  s  |"
    tput cup `expr $1 + 3` $2
    echo "-------"
    tput cup `expr $1 + 4` $2
    echo "$3"
}

output_X(){
    tput cup $1 $2
    echo "_______"
    tput cup `expr $1 + 1` $2
    echo "|     |"
    tput cup `expr $1 + 2` $2
    echo "|  x  |"
    tput cup `expr $1 + 3` $2
    echo "-------"
    tput cup `expr $1 + 4` $2
    echo "$3"
}

output_Now(){
    i=$first_file #첫번째 파일 위치
    j=0
    #모든파일을 정렬한 TXT생성
    echo ".." > ~/__all_files.txt
    if [ -s ~/__directory_list.txt ]
    then
        cat ~/__directory_list.txt >> ~/__all_files.txt
    fi
    if [ -s ~/__normal_list.txt ]
    then
        cat ~/__normal_list.txt >> ~/__all_files.txt
    fi
    if [ -s ~/__special_list.txt ]
    then
        cat ~/__special_list.txt >> ~/__all_files.txt
    fi

    while [ $i -le $last_file ] #출력할 마지막 파일까지
    do
        if [ $i -le $f_num ] #단, 총 파일 갯수를 초과해서 출력할 수 없음
        then
            filename=`sed -n -e "$i p" ~/__all_files.txt`
            type=`stat --format="%F" $filename`
            height=`expr $j / 5` #위치 계산
            height=`expr $height \* 5`
	    height=`expr $height + 1`
            width=`expr $j % 5`
            width=`expr $width \* 13`
            width=`expr $width + 1`
	    width=`expr $width + 15`

	    if [ $i -eq 1 ] #..
	    then
                if [ $i -eq $now_file ] #커서가 가르키고있는 파일과 출력할 파일의 위치가 같다면
                then
                    echo "[41m[2;35m" #색반전
                    output_D $height $width ${filename:0:10} #10번째 글자까지
                    echo "[0m"
                else
                    echo "[31m"
                    output_D $height $width ${filename:0:10}
                    echo "[0m"
                fi

	    elif [ "$type" = "디렉토리" ]
	    then
		if [ $i -eq $now_file ]
		then
		    echo "[44m[2;35m"
		    output_D $height $width ${filename:0:10}
		    echo "[0m"
		else
	            echo "[34m"
		    output_D $height $width ${filename:0:10}
		    echo "[0m"
		fi
  	    elif [ -x "./$filename" ] #실행 파일이라면
	    then
                if [ $i -eq $now_file ]
                then
                    echo "[41m[2;35m"
                    output_X $height $width ${filename:0:10}
                    echo "[0m"
                else
                    echo "[31m"
                    output_X $height $width ${filename:0:10}
                    echo "[0m"
                fi
            elif [ "$type" = "일반 파일" ]
            then
                if [ $i -eq $now_file ]
                then
                    echo "[47m[2;35m"
                    output_F $height $width ${filename:0:10}
                    echo "[0m"
                else
                    echo "[0m"
                    output_F $height $width ${filename:0:10}
                    echo "[0m"
                fi

            elif [ "$type" = "일반 빈 파일" ]
            then
                if [ $i -eq $now_file ]
                then
                    echo "[47m[2;35m"
                    output_F $height $width ${filename:0:10}
                    echo "[0m"
                else
                    echo "[0m"
                    output_F $height $width ${filename:0:10}
                    echo "[0m"
                fi

            else
                if [ $i -eq $now_file ]
                then
                    echo "[42m[2;35m"
                    output_S $height $width ${filename:0:10}
                    echo "[0m"
                else
                    echo "[32m"
                    output_S $height $width ${filename:0:10}
                    echo "[0m"
                fi
	    fi
        fi
	i=`expr $i + 1`
	j=`expr $j + 1`
    done
}

output_Information(){ #information 출력함수
    tput cup 27 0
    echo "|*********************************information**********************************|"
    echo "|                                                                              |"
    echo "|                                                                              |"
    echo "|                                                                              |"
    echo "|                                                                              |"
    echo "|                                                                              |"
    echo "|                                                                              |"
    tput cup 28 1
    echo "        File name : $1"
    type=`stat --format="%F" $1`
    if [ $now_file -eq 1 ]
    then
	echo "[31m"
    elif [ "$type" = "디렉토리" ]
    then
	echo "[34m"
    elif [ -x $1 ]
    then
	echo "[31m"
    elif [ "$type" = "일반 빈 파일" ]
    then
	echo "[0m"
    elif [ "$type" = "일반 파일" ]
    then
	echo "[0m"
    else
	echo "[32m"
    fi
    tput cup 29 1
    echo "        File type : $type "
    echo "[0m"
    tput cup 30 1
    echo "        File size : `stat --format="%s" $1`"
    tput cup 31 1
    echo "        Last data modification : `stat --format="%y" $1`"
    tput cup 32 1
    echo "        Permission : `stat --format="%a" $1`"
    tput cup 33 1
    echo "        Absolute path : `readlink -f $1`"

    tput cup 34 0
    echo "|*********************************information**********************************|"
    echo "|                                                                              |"
    echo "================================================================================"
    tput cup 35 1
    total=`expr $d_num + $n_num + $s_num`
    echo "        $total total     $d_num dir     $n_num file     $s_num Sfile     $now_size byte"
}

while [ 1 ]
do
    clear
    d_num=0
    n_num=0
    s_num=0
    path=`pwd`
    cd .. #상위 디렉토리로 이동
    del_files "tem"
    del_files "now"
    for file in *
    do
	if [ "$file" = "*" ] #디렉토리가 비어있다면 반복문 빠져나옴
	then
	    break
	fi
	sort_Type $file
    done
    sort_Name

    echo "================================================================================"
    output_Parent #상위 디렉토리 파일목록 출력
    del_files "tem"
    del_files "now"

    cd "$path" #현재 디렉토리로 이동
    d_num=0
    n_num=0
    s_num=0
    del_files "tem"
    del_files "now"
    rm -f ~/__all_files.txt
    f_num=1 #super directory
    now_size=0
    for file in *
    do
        if [ "$file" = "*" ]
        then
            break
        fi
	sort_Type $file
    	f_num=`expr $f_num + 1`
	size=`stat --format="%s" $file` #파일 사이즈
	now_size=`expr $now_size + $size` #총 사이즈에 더함
    done
    sort_Name
    output_Now
    file=`sed -n -e "$now_file p" ~/__all_files.txt`
    file_path=`readlink -f $file`
    output_Information $file
    del_files "tem"
    del_files "now"
    rm -f ~/__all_files.txt

        IFS="" read -r -n 1 key

    if [ "$key" = "" ] #방향키 입력(방향키의 길이는 3)
    then
	read -n 2 key #두개를 더 입력받음
        if [ "$key" = "[A" ]
        then
            if [ $now_file -gt 5 ] #현재 커서의 위치가 5보다 커야 함(맨 윗줄이 아니어야함)
            then
                now_file=`expr $now_file - 5`
                if [ $now_file -lt $first_file ] #갱신
                then
                    first_file=`expr $first_file - 5`
                    last_file=`expr $last_file - 5`
                fi
            fi
        elif [ "$key" = "[B" ]
        then
            if [ $now_file -le `expr $f_num - 5` ] #현재 커서의 위치가 파일총합갯수 -5보다 작거나 같아야함
            then
                now_file=`expr $now_file + 5`
                if [ $now_file -gt $last_file ] #갱신
                then
                    first_file=`expr $first_file + 5`
                    last_file=`expr $last_file + 5`
                fi
            fi
        elif [ "$key" = "[C" ]
        then
            if [ $now_file -ne $f_num ] #맨마지막 파일을 가르키고있지 않아야함
	    then
                now_file=`expr $now_file + 1`
		if [ $now_file -gt $last_file ] #갱신
		then
		    first_file=`expr $first_file + 5`
		    last_file=`expr $last_file + 5`
		fi
	    fi
        elif [ "$key" = "[D" ]
        then
            if [ $now_file -ne 1 ] #맨처음 파일을 가르키고 있지 않아야함
            then
                now_file=`expr $now_file - 1`
                if [ $now_file -lt $first_file ] #갱신
                then
                    first_file=`expr $first_file - 5`
                    last_file=`expr $last_file - 5`
                fi
            fi
    fi


	elif [ "$key" = " " ] #spacebar
	then
	    if [ "`stat --format="%F" $file`" = "디렉토리" ] #디렉토리라면 이동
	    then
		now_file=1
		first_file=1
		last_file=25
		cd $file
  	    elif [ -x "$file" ] #실행파일이라면 실행
	    then
		./$file
	    fi
	elif [ "$key" = "c" ] || [ "$key" == "C" ] #cp명령어 구현
	then
	    cp_num=`expr $cp_num + 1`
	    if [ $cp_num -eq 1 ]
	    then
		cp_file1="$file_path"
	    elif [ $cp_num -eq 2 ]
	    then
		cp_file2="$file_path"
	    elif [ $cp_num -eq 3 ]
	    then
		cp_file3="$file_path"
	    fi
	elif [ "$key" = "p" ] || [ "$key" == "P" ]
	then
            if [ $cp_num -eq 1 ] #복사한 파일 갯수만큼 복사
            then
                cp $cp_file1 $path
            elif [ $cp_num -eq 2 ]
            then
		cp $cp_file1 $path
                cp $cp_file2 $path
            elif [ $cp_num -eq 3 ]
            then
                cp $cp_file1 $path
		cp $cp_file2 $path
		cp $cp_file3 $path
            fi
	    cp_num=0
	elif [ "$key" = "m" ] || [ "$key" == "M" ] #mv명령어 구현
	then
            mv_num=`expr $mv_num + 1`
            if [ $mv_num -eq 1 ]
            then
		mv_file1="$file_path"
            elif [ $mv_num -eq 2 ]
            then
		mv_file2="$file_path"
            elif [ $mv_num -eq 3 ]
	    then
		mv_file3="$file_path"
            fi
	elif [ "$key" = "v" ] || [ "$key" == "V" ]
        then
            if [ $mv_num -eq 1 ] #이동시킬 파일 갯수만큼 이동
            then
                mv $mv_file1 $path
            elif [ $mv_num -eq 2 ]
            then
                mv $mv_file1 $path
		mv $mv_file2 $path
            elif [ $mv_num -eq 3 ]
	    then
                mv $mv_file1 $path
		mv $mv_file2 $path
		mv $mv_file3 $path
            fi
	    mv_num=0
	fi
    done
