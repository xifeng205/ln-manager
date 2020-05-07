#! /usr/bin/env bash
# *******************************************************************
# * Author        : cuiyunpeng
# * Email         : @163.com
# * Create time   : 2020-03-08 16:41
# * Last modified : 2020-03-08 16:41
# * Filename      : ln-manager.sh
# * Description   : link manager
# * Version       : v1.0.0
# *******************************************************************
REPOS_PATH=/home/cuiyunpeng/example/test/tools/systools/ln-manager

ln_help()
{
    echo [option:[add], [del], [list], [config]] 
}

ln_add_help()
{
    echo [arg1:ln from] 
    echo [arg1:ln from] 
    echo [arg2:ln to] 
    echo [arg3:ln bias] 
    echo [arg4:ln pri] 
    echo [arg4:ln select] 
}

ln_help_del()
{
    echo [arg1:ln from] 
    echo [arg2:ln to] 
    echo [arg3:ln bias] 
    echo [arg4:ln pri] 
    echo [arg4:ln select] 
}

ln_help_config()
{
    echo [arg1:config] 
    echo [arg2:] 
    echo [arg3:pri] 
}

ln_help_list()
{
    echo [arg1:ln from] 
    echo [arg1:ln from] 
    echo [arg2:ln to] 
    echo [arg3:ln bias] 
    echo [arg4:ln pri] 
    echo [arg4:ln select] 
}

ln_add()
{
    if test $# -lt 5
    then
        echo "format as follow" 
        echo "eg:ln_manager /xxx/xxx/ /yyy/yyy/  zzz  ok  1" 
        exit -1
    else 
        echo "$1 ------> $2    $3[$4]    $5" >> $REPOS_PATH/ln-repos.txt
        sync
    fi

    if [ $4 == "ok" ]
    then
        creat_ln $3 $5
    fi
}

sub_del()
{
    local tmp=$1
    local tmp2=$2

    find_from_path $1 $2 
    find_to_path $1 $2 

    if [ -e $ln_to_path ] 
    then
        rm $ln_to_path -i
    fi

    sed -i  "/$tmp\[ok\]    $tmp2/d" $REPOS_PATH/ln-repos.txt
    sed -i  "/$tmp\[no\]    $tmp2/d" $REPOS_PATH/ln-repos.txt
}

group_sub_del()
{
    local tmp=$1

    sed -i  "/\[$tmp\]\[ok\]/d" $REPOS_PATH/ln-group-repos.txt
    sed -i  "/\[$tmp\]\[no\]/d" $REPOS_PATH/ln-group-repos.txt
}

ln_del()
{
    local select
    case $1 in
        # --all) true 1   > $REPOS_PATH/ln-repos.txt;;
        *) list_sub $1;read -p "Please enter your select: " select;sub_del $1 $select;;
    esac
}

ln_list()
{
    if [ -z $1 ]
    then
        ln_help_list
        exit -1
    fi

    case $1 in
        --all)  cat $REPOS_PATH/ln-repos.txt;;
        *)  list_sub $1
    esac

}

list_sub()
{
    # local t=$(grep "$1" -w  $REPOS_PATH/ln-repos.txt)
    # if [ -z $t ]
    # then
        # echo nothing was found
        # exit -1
    # fi
    # grep "\<$1[okn]\{2\>"  $REPOS_PATH/ln-repos.txt
    grep "\\$1\["  $REPOS_PATH/ln-repos.txt
}

group_list_sub()
{
    # local t=$(grep "$1" -w  $REPOS_PATH/ln-repos.txt)
    # if [ -z $t ]
    # then
        # echo nothing was found
        # exit -1
    # fi
    grep "$1"  $REPOS_PATH/ln-group-repos.txt
}


find_from_path()
{
     ln_from_path=$(grep "$1" -w $REPOS_PATH/ln-repos.txt  | grep "$2" -w | awk '{print $1}')
     if [ -z $ln_from_path ]
     then
         echo "option error"
         exit -1
     fi
 }

find_to_path()
{
    ln_to_path=$(grep "$1" -w $REPOS_PATH/ln-repos.txt  |grep "$2" -w |awk '{print $3}')

    if [ -z $ln_to_path ]
    then
        exit -1
    fi
}

ln_check_and_subsitute()
{
    local tmp=$1
    local tmp2=$2
    sed -i  "s/$tmp\[ok\]/$tmp\[no\]/" $REPOS_PATH/ln-repos.txt
    sed -i  "s/$tmp\[no\]    $tmp2/$tmp\[ok\]    $tmp2/" $REPOS_PATH/ln-repos.txt
}

ln_group_check_and_subsitute()
{
    local tmp=$1
    # local tmp2=$2
    sed -i  "s/$tmp\[no\]/$tmp\[ok\]/" $REPOS_PATH/ln-group-repos.txt
    # sed -i  "s/$tmp\[no\]/$tmp\[ok\" $REPOS_PATH/ln-repos.txt
}
creat_ln() 
{
    find_from_path $1 $2 
    find_to_path $1 $2 
    ln_check_and_subsitute $1 $2
    if [ -e $ln_to_path ] 
    then
        rm $ln_to_path 
    fi

    if [ -e $ln_from_path ]
    then

        ln -s $ln_from_path $ln_to_path
    else
        echo "dir or file not exist!"
        exit -1
    fi

    echo "Handover successful!"
}

ln_config()
{
    local select
    local parm=$(echo $2 |sed -n '/[0-9]/p')

    if [ -z $parm ]
    then
        list_sub $1
        read -p "Please enter your select: " select
        creat_ln $1  $select
    else
        creat_ln $1 $2 
    fi
}

ln_group_add() 
{
    if test $# -lt  2
    then
        echo "format as follow" 
        echo "eg:ln_manager groupadd [group name] [ok/no]  $2 $3 $4  $5 $6  $7 $8" 
    else 
        echo "[$1][$2]    $3:$4    $5:$6    $7:$8" >> $REPOS_PATH/ln-group-repos.txt
        sync
    fi

    if [ $1 == "ok" ]
    then
        if [ -n $3  ] && [ -n $4 ]
        then
            # creat_ln $3 $4
            echo 1
        else
            exit 0
        fi

        if [ -n $5  ] && [ -n $6 ]
        then
            echo 1
            # creat_ln $5 $6
        else
            exit 0
        fi

        if [ -n $7  ] && [ -n $8 ]
        then
            echo 1
            # creat_ln $7 $8
        else
            exit 0
        fi
    fi
}

ln_getpath()
{

    p1=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt | \
        awk '{print $2}' |cut -d : -f 1)
    # p1=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
        # | grep "\\[okn\]{2}" -w | awk '{print $2}' |cut -d : -f 1)

    if [ -z $p1 ]
    then
        echo option error
        exit -1
    fi
    # ln_group_check_and_subsitute $1
    n1=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
    | awk '{print $2}' |cut -d ':' -f 2)

    if [ -z $n1 ]
    then
        n1=1
    fi

    p2=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
    | awk '{print $3}' |cut -d : -f 1)

    n2=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
    | awk '{print $3}' |cut -d ':' -f 2)

    if [ -z $n2 ]
    then
        n2=1
    fi
    p3=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
    | awk '{print $4}' |cut -d : -f 1)

    n3=$(grep "^\\[$1\]" -w $REPOS_PATH/ln-group-repos.txt  \
     | awk '{print $4}' |cut -d ':' -f 2)

    if [ -z $n3 ]
    then
        n3=1
    fi
}


group_creat_ln() 
{
    ln_getpath $1

    if [ -n $p1 ] && [ -n $n1 ]
    then

        creat_ln $p1 $n1
    else
        exit 0
    fi

    if [ -n $p2  ] && [ -n $n2 ]
    then
        creat_ln $p2 $n2
    else
        exit 0
    fi

    if [ -n $p3  ] && [ -n $n3 ]
    then
        creat_ln $p3 $n3
    else
        exit 0
    fi
}

ln_group_list() 
{
    if [ -z $1 ]
    then
        ln_help_list
        exit -1
    fi

    case $1 in
        --all)  cat $REPOS_PATH/ln-group-repos.txt;;
        *)  list_sub $1
    esac
}

ln_group_del() 
{
    local select
    # case $1 in
    # --all) true 1   > $REPOS_PATH/ln-repos.txt;;
    # *) list_sub $1;read -p "Please enter your select: " select;sub_del $select;;
    cat $REPOS_PATH/ln-group-repos.txt;read -p "Please enter your select: " select;group_sub_del $select
    # esac
}

ln_group_conf() 
{
    local select

    group_list_sub $1
    read -p "Please enter your select: " select

    group_creat_ln  $select
}

# main function

if [ $# -lt 1 ]
then 
    ln_help
else
    if test $1 == "add"
    then
        ln_add $2 $3 $4 $5 $6
    elif test $1 == "del"
    then
        ln_del $2  
    elif test $1 == "list"
    then
        ln_list $2
    elif test $1 == "config"
    then
        ln_config $2 $3
    elif test $1 == "gadd"
    then
        if [ -z $3 ]
        then
            ln_help_gconfig
        else
            ln_group_add $2 $3 $4 $5 $6 $7 $8 $9
        fi

    elif test $1 == "gdel"
    then
        ln_group_del $2 

    elif test $1 == "glist"
    then
        ln_group_list $2 

    elif test $1 == "gconfig"
    then
        ln_group_conf $2 $3 
    elif test $1 == "help"
    then
        ln_help
    else
        ln_help
    fi
fi
