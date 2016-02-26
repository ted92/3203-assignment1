Enrico Tedeschi - ete011@post.uit.no
INF - 3203 Advanced Distributed Systems - Assignment 1 WordCount

The whole directory is supposed to work on an uvrocks cluster.

Inputdir/ contains all the input files and the input tables that generate the plots.
Plotdir/ contains all the generated plots
Word_Count_outputdir/ automatically generated after MapReduce execution

script_wc.sh -- script that performs MapReduce tasks and the evaluation plot, less stable version
script_wc_V1.sh -- first version that performs MapReduce tasks, stable but no refactoring was done.

to execute:
	sh script_wc.sh -n <N_1 N_2 .. N_n>	perform the script using different number of reduce tasks

The input implemented are divine_comedy and project_Gutenberg.
