#!/bin/bash

HEIGHT=15
WIDTH=50
CHOICE_HEIGHT=6
BACKTITLE="USER MENU"
TITLE="A SIMPLE TEST ON LINUX BASICS"
MENU="Choose one of the following options:"

OPTIONS=(1 "Sign in"
	 2 "Sign up"
         3 "EXIT")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)


function usernamefn()
{
	echo "Enter ID"
	read ID
	if ! [[ "$ID" =~ [^a-zA-Z0-9\ ] ]];
	then
		echo -e "Invalid user ID\nUserID must contain only the alphanumeric characters."
		usernamefn
	else
		echo "userID is valid"
		echo "$ID" >> userid
	fi
}

function passwordfn()
{
	echo "Enter password (must be 8 characters with atleast one number and one symbol)"
	read -s password
	if ! [[ "$password" =~ [^a-zA-Z0-9\ ] ]]; then
		echo "password is valid"
		echo "$password" >> userpswd
	else
		echo "password is invalid"
		passwordfn
	fi
}

function password_validation()
{

	echo "Re-Enter password for validation"	
	read -s validate
	pass=`grep -x "$validate" userpswd`
	if [[ "$pass" == "$validate" ]]; then
		echo "Sign up successful"
		exit 1
	else
		echo "Passwords are not matching"
		password_validation
	fi
}

function take_test()
{
	count_marks=0
	answered=0
	q_no=1
	array=( $(echo "1 2 3 " | sed -r 's/(.[^ ]* )/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	for q_no_bank in ${array[@]}
	do
		clear
		question=`cat question_bank.txt | cut -d'.' -f1 | head -n $q_no_bank | tail -n 1`
		echo "$q_no. $question"
		options=`grep "$question" question_bank.txt | cut -d'.' -f 2,3,4,5 | head -n $q_no_bank | tail -n 1`
		echo "$options"
		answer=`grep "$question" question_bank.txt | cut -d'.' -f6 | head -n $q_no_bank | tail -n 1`
		echo -n "Enter the correct option : ";
		read user_answer
		let q_no=$q_no+1
		echo "$question,$options, Your Answer:$user_answer Correct Answer:$answer" >> answer_file.txt
		answered=`expr $answered + 1`
		if [ "$user_answer" -eq "$answer" ]; then
			 count_marks=`echo $count_marks+1 | bc`
			 echo "$count_marks"
		fi
		if [[ $answered == 3 ]]; then
			echo "Test completed"
			echo "Your score out of $q_no is $count_marks"
			echo -e "\n\n"
			echo -e "\t\t\tTEST REVIEW"
			cat -n answer_file.txt
			exit
		fi
	done
}

function view_test()
{
	cat -n answer_file.txt
}


clear
case $CHOICE in	
		1)
			echo "User ID"
			read ID
			validate=`grep -v '[[:alnum:]]' userid`					
			if [[ "$ID" != "$validate" ]]; then
				echo "User ID doesn't exists. Create One."
				exit
			else
				echo "User id exists"
			fi
			i=0
			while [ $i -eq 0 ]
			do
				echo "Enter Password"
				read -s password
				validate_password=`grep "$password" userpswd`
				if [[ "$password" == "$validate_password" ]]; then
					clear
					echo "Sign in successful"
					timestamp=`date | cut -d' ' -f4`
					echo -e "New sign in at $timestamp  UID : $ID " >> test_activity.log
					echo "choose one of the following optons"
					echo "1 take test"
					echo "2 view test"
					read test_option
					case $test_option in
						1)
							take_test
							echo "$ID has taken a test" >> test_activity.log
							;;
						2) 
							view_test
							echo "$ID has viewed a test" >> test_activty.log
							;;
						*)
							echo "wrong option"
							;;
						esac
			else
				echo "Error: Incorrect Password"
			fi
			done
			;;
		2)	
			usernamefn
			passwordfn
			password_validation
			timestamp=`date | cut -d' ' -f4`
			echo "New user has signed up at $timestamp UID : $UID"
			;;
		3)
			echo "GOOD BYE!"
			exit
			;;
		*)
			echo "Wrong option"
			;;
	esac
