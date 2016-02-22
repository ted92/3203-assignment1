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
		#clear all output and generate foler output
		hadoop fs -rm -f Word_Count_outputdir
		rm -r Word_Count_outputdir
		#execute the Word Map
		hadoop fs -copyFromLocal ./divine_comedy.txt divine_comedy.txt
		#evaluate time
		SECONDS=0
		hadoop jar word_count.jar word_count.WordCount divine_comedy.txt Word_Count_outputdir
		duration=$SECONDS
		echo "computation time: $(($duration / 60))m $(($duration % 60))s"
		hadoop fs -copyToLocal Word_Count_outputdir
		#generate the plot
		set term pngcairo
		gnuplot<< EOF
		set terminal gif
		set output 'plot1.gif'
		plot '-' using 1:2
			1 10
			2 20
			3 30
			e
EOF
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
