#!bin/bash


#create a file called ciao.txt and write in it 'hello world'
STR="Hello World!"

# write variable into text file
echo "$STR" > ciao.txt

#sed -e changes every a,e,i,o with letter u
ls -l | sed -e "s/[aeio]/u/g"

#print every item of the directory
for i in $( ls ); do
	echo item: $i
done

OPTIONS="Hello Quit"
select opt in $OPTIONS; do
	if [ "$opt" = "Quit" ]; then
		echo done
		exit
	elif [ "$opt" = "Hello" ]; then
		echo Hello World!
	else
		clear
		echo bad option
	fi
done
