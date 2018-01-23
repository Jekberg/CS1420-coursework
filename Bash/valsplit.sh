#!/bin/bash

#=============================================================
#CS1140
#Name: John Berg
#Student Number: 159014260
#=============================================================

#Store the error messages detected during analysis.
#Cleared after each line is read.
error_message=()

#A regular expression containing known formats and their known instructions.
r_instructions="^((add)|(addu)|(and)|(div)|(divu)|(sub)|(mult)|(multu)|(nor)|(or)|(slt)|(sllv)|(sra)|(srav)|(sll))$"
i_instructions="^((addi)|(addiu)|(andi)|(ori)|(slti))$"
i_special="^((lw)|(sw)|(lh)|(sh)|(lb)|(sb))$"

#The function which validates MIPS registers.
#
#check_register must be provided one argument,
#if the provided argument is of length 0, then
#the function will return 1 and create an error
#message.
#
#1) check if a register starts with the "$"
#character, if not the function will return
#1 and create a message saying that the
#register must begin with the charactetr '$'.	
#If the register begins with the '$' character,
#continiue.
#
#2) Check the name of the register is a valid
#name (excluding register numbers), if the
#register does not match any names, then return
#1 and create an error message. If the name
#matches a register name, continiue.
#
#3) Check if the register has a correct number
#(if the matching register name has a number),
#If the register number is less than 0 or greater
#than the last register number, then return 1 and
#create an error message saying that the register
#is out of bound. If the matching register name
#has no number, or the register number is within
#the range, then return 0 and do nothing.
check_register() {

	#Check for a correct number of arguments to the function.
	if [ $# != 1 ];
	then
		error_message+=("One register must be provided")
		return 1
	fi
	
	#Set the first argument as reg.
	reg=$1
	
	#Check if the register argument is not of length 0.
	if ! [ ${#reg} -gt 0 ];
	then
		echo "No register provided"
		return 1
	fi
	
	#Check if the first character of the register is $.
	if [ ${reg:0:1} == "\$" ];
	then
		#Check if the register name exists.
		if [[ ${reg:1} =~ ^("zero"|"at"|"gp"|"sp"|"fp"|"ra")$ ]];
		then
			#The register matches.
			return 0

		elif [[ ${reg:1} =~ ^"v"[0-9]+$ ]];
		then
			#Check if the register number is in bound.
			if ! [ ${reg:2} -ge 0 ] || ! [ ${reg:2} -le 1 ];
			then
				error_message+=("Out of bound, \$v registers range beetween 0 and 1")
				return 1
			fi
		elif [[ ${reg:1} =~ ^"a"[0-9]+$ ]];
		then
			#Check if the register number is in bound.
			if ! [ ${reg:2} -ge 0 ] || ! [ ${reg:2} -le 3 ];
			then
				error_message+=("Out of bound, \$a registers range beetween 0 and 3")
				return 1
			fi
		elif [[ ${reg:1} =~ ^"t"[0-9]+$ ]];
		then
			#Check if the register number is in bound.
			if ! [ ${reg:2} -ge 0 ] || ! [ ${reg:2} -le 9 ];
			then
				error_message+=("Out of bound, \$t registers range beetween 0 and 9")
				return 1
			fi
		elif [[ ${reg:1} =~ ^"s"[0-9]+$ ]];
		then
			#Check if the register number is in bound.
			if ! [ ${reg:2} -ge 0 ] || ! [ ${reg:2} -le 7 ];
			then
				error_message+=("Out of bound, \$s registers range beetween 0 and 7")
				return 1
			fi
		elif [[ ${reg:1} =~ ^"k"[0-9]+$ ]];
		then
			#Check if the register number is in bound.
			if ! [ ${reg:2} -ge 0 ] || ! [ ${reg:2} -le 1 ];
			then
				error_message+=("Out of bound, \$k registers range beetween 0 and 1")
				return 1
			fi
		else
			#No register was identified.
			error_message+=("Unrecognised register name ${reg:1}")
			return 1
		fi
	else
		#The register did not start with $.
		error_message+=("$reg must begin with $")
		return 1
	fi

	#No errors deected.
	return 0
}
#The function that validates MIPS immidiates.
#
#The fuction must be povided exactly one argument.
#
#Check if the provided immidiate is in the range of
#-32768 and 32767, otherwise create an error message.
check_immidiate() {
	
	#Check the number of arguments.
	if [ $# != 1 ];
	then
		error_message+=("Only one argument must be provided")
		return 1
	fi
	
	#Set the first argument as imm.
	imm=$1
	
	#Check the range of the immidiate.
	if [ $imm -ge -32768 ] && [ $imm -le 32767 ];
	then
		#Immidiate is valid.
		return 0
	else
		#Immidiate out of bound.
		error_message+=("Immediate must be between -32768 and 32767")
		return 1
	fi
}
#Check the R type format.
#
#The R type format must have 3 registers, of which all must
#pass the check_register function.
#
#If the function is not provided exactly 3 arguments, then create
#an error messsage.
validate_r_type() {
	
	#Check if the R format has the correct number of arguments.
	if [ $# != 3 ];
	then
		error_message=("R instruction expected 'rd rs rt'")
		return 1
	fi
	
	#Set name of arguments.
	rd=$1
	rs=$2
	rt=$3	
	
	#Check the registers.
	check_register $rd #Check the first register.
	check_register $rs #Check the second register.
	check_register $rt #Check the third register.
	
	#Checks were performed.
	return 0
}
#Check the I type format.
#
#The I type format must have 2 registers which will be checkd in the
#check_register function, followed by an immidiate which will be
#checked in the check_immidiate function.
#
#If the function has not been provided exactly 3 arguments, then
#create an error message.
validate_i_type() {
	
	#Check the I format has the correct number of arguments.
	if [ $# != 3 ];
	then
		error_message+=("I instruction expected 'rd rs imm'")
		return 1
	fi
	
	#Set name of arguments.
	rd=$1
	rs=$2
	imm=$3
		
	#Check if op1 is valid
	check_register $rd	#Check the first register.
	check_register $rs	#Check the second register.
	check_immidiate $imm	#Check the immidiate.
	
	#Checks were performed sucessfully.
	return 0
}
#Check the I type format (for load/store instructions).
#
#The I type format must have 2 arguments provided where the first
#argument is a valid register checked by the check_register function,
#the second argument is the memory address consistting of an
#immidiate and a register "reg1 immidiayte(reg2)".
#
#If the function has not been provided exactly 3 arguments, then
#create an error message.
validate_i_special() {
	
	#Check the I format has the correct number of arguments.
	if [ $# != 2 ];
	then
		error_message+=("I instruction expected 'rd imm(rs)'")
		return 1
	fi
	
	#Set the name of the arguments
	rt=$1
	address=$2
	imm=${address%%(*)}	#Remove the first instance of ("anything").
	
	#Get the register of the lw/sw instruction.
	rs=${address:${#imm}}	#Remove the number from the address.
	rs=${rs:1}		#Remove the open bracket.
	rs=${rs:0:${#rs}-1}	#Remove the close bracket.
	
	#Check the registers and the immidiate.
	check_register $rt	#Check the first register.
	check_immidiate $imm	#Check the immidiate.
	check_register $rs	#Check the second register.
}
#Deduce and check the format of an instruction.
#
#Should be used if the instruction is not recognised.
#
#Check the number of arguments provided to deduce the correct type.
#If the number of arguments are 3, then check if the last argument is
#a sequance of characters.
validate_deduct_type() {
	
	#Deduce the tye by analysing the number of arguments.
	if [ $# == 3 ];
	then
		#Check if the third operand is an immidiate.
		if [[ $3 =~ ^"-"?[0-9]+$ ]]
		then
			#i type?
			validate_i_type $1 $2 $3
		else
			#r type?
			validate_r_type $1 $2 $3
		fi
	elif [ $# == 2 ];
	then
		#i type (lw/sw)?
		validate_i_special $1 $2 $3
	else
		#The format was unrecognised.
		error_message+=("No matching type format pattern")
	fi
}
#Check if the instruction of the line is valid.
#
#This function must be provided 3 or 4 arguments. The first argument
#is the argument which will be checked to see if it is a valid instruction,
#after which the subsiquent arguments will be chekced if the instruction is
#a valid instruction.
validate_instruction() {
	
	#Set the name of the arguments
	instruction=$1
	operand1=$2
	operand2=$3
	operand3=$4
	
	#Check if the instruction matches any known instructions.
	if [[ $instruction =~ $r_instructions ]];
	then
		#Check R format.
		validate_r_type $operand1 $operand2 $operand3
		return $?
	elif [[ $instruction =~ $i_instructions ]];
	then
		#Check I format.
		validate_i_type $operand1 $operand2 $operand3
		return $?		
	elif [[ $instruction =~ $i_special ]]
	then
		#Check I type.
		validate_i_special $operand1 $operand2
		return $?
	else
		#Instruction was not recognised.
		error_message+=("Unrecognised instruction")
		validate_deduct_type $operand1 $operand2 $operand3
		return 1
	fi
	
	#
	return 1
}
#Separate instructions into fules depending if the instruction is valid or not.
#
#
#The function accepts 3 arguments, a string representetion of an instruction,
#a file to output correct instructions to, and a file to output incorrect
#instructions along with error messafes.
#
#This function must be privuded exactly 3 arguments.
separate() {
	
	#Check if the sepaate function has the correct number of arguments.
	if [ $# != 3 ];
	then
		#Incorrect number of arguments.
		return 1
	fi
	
	#Name the parameters
	line=$1
	correct=$2
	incorrect=$3
	
	#Valiate the string.
	validate_instruction $line	
	
	#Check if 88($t2)($t2)the error_message is empty.
	if [ ${#error_message} != 0 ];
	then
		#Print the line into the incorrect file
		#then print the error_message to the
		#incorrect file.
		
		echo "$line" >> $incorrect
		for error in "${error_message[@]}"
		do
		    echo "$error"
		    echo "$error" >> $incorrect
		done
		
	else
		#Print the line to 
		echo "$line" >> $correct
	fi
	
	#Reset the error_message.
	error_message=()
}
#Check if the script has been provided 3 arguments
if [ $# == 3 ];
then
	#Name the parameters
	input=$1
	correct=$2
	incorrect=$3
else
	#The script was not provided 3 arguements.
	echo "Invalid arguments"
	echo "valsplit requires 3 input arguments"
	echo "input_file correct_file incorrect_file"
	echo "Using default values:"
	echo "input.txt correct.txt incorrect.txt"
	
	#Default values
	input="input.txt"
	correct="correct.txt"
	incorrect="incorrect.txt"
fi

#Print headers
echo "#Correct" > $correct
echo "#Incorrect" > $incorrect

#Read the target file
while read line
do
	#Echo the current line of the file
	#Run the separate function on the line and
	#provide the second and third argument as
	#output targets.
	echo "$line"
	separate "$line" "$correct" "$incorrect"
	
done < "$input"