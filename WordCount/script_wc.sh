#!bin/bash

# Enrico Tedeschi - ete011
# INF - 3203 Advanced Distributed Systems
# Assignment 1


# Word count script.
# 1) Menu to run Word Count with different input
# 2) Possibility to choose the number of reduce tasks
# 3) generate a pdf with a graph showing the performance using gnuplot

	
OPTIONS="divine_comedy input2 input3 quit"
select opt in $OPTIONS; do
	if [ "$opt" = "divine_comedy" ]; then
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
			sum=0
			while [ $i -lt $len ]
			do
				#clear all output folders
				hadoop fs -rm -r Word_Count_outputdir
				rm -r Word_Count_outputdir
				#execute the Word Map
				hadoop fs -copyFromLocal Inputdir/divine_comedy.txt divine_comedy.txt
				#time elapsed in millisecs
				time_start=$(date +%s%N)
				hadoop jar word_count.jar word_count.WordCount divine_comedy.txt Word_Count_outputdir -D mapred.reduce.tasks=${numbers[$i]}
				#declare the array durations containing the time elapsed
				time_elapsed=$((($(date +%s%N) - $time_start)/1000000))
				durations[$i]=$time_elapsed
				#write into input_tab.dat
				printf "%s %10d %10d\n" " " "${numbers[$i]}" "${durations[$i]}" >> input_tab.dat
				#to get the correct number in a loop: ${numbers[$i]}
				hadoop fs -copyToLocal Word_Count_outputdir
				#sum for the average
				sum=$(( sum+durations[$i] ))	
				i=$[$i+1]
			done
			#calculate average and then variance
			avg=$(( sum/len ))
			i=0
			#add average line in the file input_tab.dat to plot
			printf "\n" >> input_tab.dat
			printf "%s %10s %10s\n" "#" "reduce" "time" >> input_tab.dat
			#create a plot with the deviation standard
			touch standard_dev.dat
			printf "%s %20s %20s\n" "#" "standard_deviation" "time" > standard_dev.dat
			while [ $i -lt $len ]
			do
				#variance
				variance[$i]=$(( (durations[$i]-avg)*(durations[$i]-avg) ))
				#add average to the input_tab file
				printf "%s %10d %10d\n" " " "${numbers[$i]}" "$avg" >> input_tab.dat
				#add standard deviation to the standard_dev file
				printf "%s %20d %20d\n" " " "${numbers[$i]}" "${variance[$i]}" >> standard_dev.dat
				i=$[$i+1]
			done
			#generat plot
			set term pngcairo
			gnuplot<< EOF
			set terminal gif
			set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
			set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5
			set output 'plot_divine_comedy.gif'
			plot 'input_tab.dat' index 0 with linespoints ls 1
			plot 'input_tab.dat' index 1 with linespoints ls 2
EOF
		else
			echo default Reduce settings using default number of reduce tasks
			SECONDS=0
			hadoop jar word_count.jar word_count.WordCount divine_comedy.txt Word_Count_outputdir
			duration=$SECONDS
			echo "computation time: $(($duration / 60))m $(($duration % 60))s"
			#generate the plot
			set term pngcairo
			gnuplot<< EOF
			set terminal gif
			set output 'plot1.gif'
			plot '-' using 1:2
				$(($duration)* 10) 20
				e
EOF
		fi
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
