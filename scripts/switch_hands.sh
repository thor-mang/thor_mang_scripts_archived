#!/bin/bash

source $ROSWSS_BASE_SCRIPTS/helper/helper.sh

# read arguments if given
if [ ! -z "$1" ]; then
    hand="$1"
    shift
else
    hand=""
fi

if [ ! -z "$1" ]; then
    hand_type="$1"
    shift
else
    hand_type=""
fi

# get which hand(s) to be swapped
while [ ! "$hand" == "l" ] && [ ! "$hand" == "r" ] && [ ! "$hand" == "b" ]; do
    echo -ne "Do you want to change (l)eft, (r)ight or (b)oth hands? "
    read -N 1 hand
    echo
done

# get hand type to set
while [ ! "$hand_type" == "v" ] && [ ! "$hand_type" == "r" ] && [ ! "$hand_type" == "n" ]; do
    echo -ne "Select type: (v)t_hand, (r)h_p12_rn or (n)one "
    read -N 1 hand_type
    echo
done

# dispatch hand type
case $hand_type in
    n)
        hand_type="none"
        ;;
    v)
        hand_type="vt_hand"
        ;;
    r)
        hand_type="rh_p12_rn"
        ;;
esac

# set hand type
if [ "$hand" == "b" ] || [ "$hand" == "l" ]; then
  export L_HAND_TYPE="$hand_type"
fi
if [ "$hand" == "b" ] || [ "$hand" == "r" ]; then
  export R_HAND_TYPE="$hand_type"
fi

echo_info "New robot hand setup:"
echo "  Left hand type  = $L_HAND_TYPE"
echo "  Right hand type = $R_HAND_TYPE"
echo

last_pwd=$PWD

# regenerate URDF model
echo_info "Regenerating URDF model..."
roscd thormang3_description/urdf
rosrun xacro xacro --inorder -o johnny5.urdf thormang3.xacro robot_name:="johnny5" l_hand_type:=$L_HAND_TYPE r_hand_type:=$R_HAND_TYPE
echo_info "Done!"
echo

# setup robot config
echo_info "Generation of custom robot config..."
roscd thormang3_manager/config
echo "### AUTOGENERATED FILE! DO NOT MODIFY! ###" > THORMANG3_generated.robot
cat hand_configs/THORMANG3_no_hands.robot >> THORMANG3_generated.robot
cat hand_configs/l_${L_HAND_TYPE}.robot >> THORMANG3_generated.robot
cat hand_configs/r_${R_HAND_TYPE}.robot >> THORMANG3_generated.robot
export ROBOT_SETUP="THORMANG3_generated"
echo_info "Done!"

cd $last_pwd
