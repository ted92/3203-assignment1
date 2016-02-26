#!bin/bash

# Enrico Tedeschi - ete011
# INF - 3203 Advanced Distributed Systems
# Assignment 1


# Word count script.
# 1) Menu to run Word Count with different input
# 2) Possibility to choose the number of reduce tasks
# 3) generate a pdf with a graph showing the performance using gnuplot

#function execution
function execution {
	len=$2
	numbers=$1
	#create the input_tab.dat that will be plotted
	touch Inputdir/input_tab.dat
	#table header
	printf "%s %10s %10s\n" "#" "reduce" "time" > Inputdir/input_tab.dat
	#buildthe numbers array
	i=0
	sum=0
	while [ $i -lt $len ]
	do
		#clear all output folders
		hadoop fs -rm -r Word_Count_outputdir
		rm -r Word_Count_outputdir
		#execute the Word Map
		hadoop fs -copyFromLocal Inputdir/$3 $3
		#time elapsed in millisecs
		time_start=$(date +%s%N)
		hadoop jar word_count.jar word_count.WordCount $3 Word_Count_outputdir -D mapred.reduce.tasks=${numbers[$i]}
		#declare the array durations containing the time elapsed
		time_elapsed=$((($(date +%s%N) - $time_start)/1000000))
		durations[$i]=$time_elapsed
		#write into input_tab.dat
		printf "%s %10d %10d\n" " " "${numbers[$i]}" "${durations[$i]}" >> Inputdir/input_tab.dat
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
	printf "\n" >> Inputdir/input_tab.dat
	printf "%s %10s %10s\n" "#" "reduce" "time" >> Inputdir/input_tab.dat
	#create a plot with the deviation standard
	touch Inputdir/standard_dev.dat
	printf "%s %20s %20s\n" "#" "standard_deviation" "time" > Inputdir/standard_dev.dat
	while [ $i -lt $len ]
	do
		#variance
		variance[$i]=$(( (durations[$i]-avg)*(durations[$i]-avg) ))
		#add average to the input_tab file
		printf "%s %10d %10d\n" " " "${numbers[$i]}" "$avg" >> Inputdir/input_tab.dat
		#add standard deviation to the standard_dev file
		printf "%s %20d %20d\n" " " "${numbers[$i]}" "${variance[$i]}" >> Inputdir/standard_dev.dat
		i=$[$i+1]
	done
	#generate plot with average and performances
	set term pngcairo
	gnuplot<< EOF
	set terminal gif
	set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
	set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5
	set output '$4'
	plot 'Inputdir/input_tab.dat' index 0 with linespoints ls 1
EOF
	#generate plot with standard deviation
	gnuplot<< EOF
	set terminal gif
	set style line 1 lc rgb '#dd181f' lt 1 lw 2 pt 7 ps 1.5
	set output '$5'
	plot 'Inputdir/standard_dev.dat' index 0 with linespoints ls 1
EOF
}

if [ "$1" == "-n" ]; then
	shift
	numbers=( $@ )
	len=${#numbers[@]}
	#numbers now contains all the number for the execution of the MapReduce with different number of reducers
	OPTIONS="divine_comedy project_Gutenberg input3 quit"
	select opt in $OPTIONS; do
		if [ "$opt" = "divine_comedy" ]; then
			#execution with divine_comedy paramters
			input_file="divine_comedy.txt"
			plot="Plotdir/plot_divine_comedy.gif"
			plot_sd="Plotdir/plot_divine_comedy_standard_dev.gif"
			#call the function execution with parameters
			execution $numbers $len $input_file $plot $plot_sd
		elif [ "$opt" = "project_Gutenberg" ]; then
			#execution with project_Gutenberg parameters
			input_file="proeject_Gutenberg.txt"
			plot="Plotdir/plot_project_Gutenberg.gif"
			plot_sd="Plotdir/plot_project_Gutenberg_standard_dev.gif"
			execution $numbers $len $input_file $plot $plot_sd
			echo project_Gutenberg
		elif [ "$opt" = "quit" ]; then
			exit
		fi
	done	
else
	#TODO execute with other parameters
	echo not an option
fi	
