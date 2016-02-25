#!bin/bash

# Enrico Tedeschi - ete011
# INF - 3203 Advanced Distributed Systems
# Assignment 1


# Word count script.
# 1) Menu to run Word Count with different input
# 2) Possibility to choose the number of reduce tasks
# 3) generate a pdf with a graph showing the performance using gnuplot

	
OPTIONS="input1 input2 input3 quit"
select opt in $OPTIONS; do
	if [ "$opt" = "input1" ]; then
	#choose the first input: divine_comedy.txt
		echo divine comedy
		#choose numbers of Reduce tasks for the evaluation from input parameter
		if [ "$1" == "-n" ]; then
			shift
			#create the input_tab.dat that will be plotted
			touch input_tab.dat
			#table header
			printf "%s %10s %10s\n" "#" "reduce" "time" > input_tab.dat
			#buildthe numbers array
			numbers=( $@ )
			len=${#numbers[@]}
			#numbers now contains all the number for the execution of the MapReduce with different number of reducers
			i=0
			while [ $i -lt $len ]
			do
				#clear all output folders
				hadoop fs -rm -r Word_Count_outputdir
				rm -r Word_Count_outputdir
				#execute the Word Map
				hadoop fs -copyFromLocal ./divine_comedy.txt divine_comedy.txt
				#time elapsed in millisecs
				time_start=$(date +%s%N)
				hadoop jar word_count.jar word_count.WordCount divine_comedy.txt Word_Count_outputdir -D mapred.reduce.tasks=$(numbers[$i])
				#declare the array durations containing the time elapsed
				time_elapsed=$((($(date +%s%N) - $time_start)/1000000))
				durations[$i]=$time_elapsed
				#write into input_tab.dat
				printf "%s %10d %10d\n" " " "${numbers[$i]}" "${durations[$i]}" >> input_tab.dat
				#to get the correct number in a loop: ${numbers[$i]}
				echo number: ${numbers[$i]} in i: $i
				hadoop fs -copyToLocal Word_Count_outputdir
				i=$[$i+1]
			done
			#generate the plot
			set term pngcairo
			gnuplot<< EOF
			set terminal gif
			set style line 1 lc rgb '#006ad' lt 1 lw 2 pt 7 ps 1.5
			set output 'plot1.gif'
			plot 'input_tab.dat' with linespoints ls 1
EOF
		else
			echo default Reduce settings
			SECONDS=0
			hadoop jar word_count.jar word_count.WordCount divine_comedy.txt Word_Count_outputdir
			duration=$SECONDS
			#generate the plot
			set term pngcairo
			gnuplot<< EOF
			set terminal gif
			set output 'plot1.gif'
			plot '-' using 1:2
				1 10
				$(($duration)* 10) 20
				3 30
				e
EOF
		fi
		echo "computation time: $(($duration / 60))m $(($duration % 60))s"
		#generate the plot
	elif [ "$opt" = "input2" ]; then
		#chose the second input
		echo hello
	elif [ "$opt" = "quit" ]; then
		exit	
	else
		clear
		echo bad option
	fi
done
