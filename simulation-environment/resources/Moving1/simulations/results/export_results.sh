#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -n numRuns -s sourceFolder -o resultsFolder -d experimentDescriptor"
   echo -e "\t-n Number of runs from which to export scalars and vecorts into .csv files"
   echo -e "\t-s Folder which contains the source .vec and .sca files"
   echo -e "\t-o Destination folder"
   echo -e "\t-d Descriptor of the experiment"
   exit 1 # Exit script after printing help
}

while getopts "n:s:o:d:" opt
do
   case "$opt" in
      n ) numRuns="$OPTARG" ;;
      s ) sourceFolder="$OPTARG" ;;
      o ) resultsFolder="$OPTARG" ;;
      d ) experimentDescriptor="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$numRuns" ] || [ -z "$sourceFolder" ] || [ -z "$resultsFolder" ] || [ -z "$experimentDescriptor" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

if [ -d "${sourceFolder}" ] 
then
    echo "Source directory ${sourceFolder} exists. Continuing..." 
else
    echo "Error: Source directory ${sourceFolder} does not exist. Quitting..."
    exit 2
fi

if [ -d "${resultsFolder}" ] 
then
    echo "Results directory ${resultsFolder} exists. Continuing..." 
else
    echo "Results directory ${resultsFolder} does not exist. Creating the directory..."
    mkdir ${resultsFolder}
    if [ -d "${resultsFolder}" ] 
    then
        echo "Results directory ${resultsFolder} successfully created. Continuing..." 
    else
        echo "Error: Results directory ${resultsFolder} Couldn't be created. Quitting..."
        exit 3
    fi
fi

if [ -d "${resultsFolder}/vectors" ] 
then
    echo "Vectors directory ${resultsFolder}/vectors exists. Continuing..." 
else
    echo "Results directory ${resultsFolder}/vectors does not exist. Creating the directory..."
    mkdir ${resultsFolder}/vectors
    if [ -d "${resultsFolder}/vectors" ] 
    then
        echo "Results directory ${resultsFolder}/vectors successfully created. Continuing..." 
    else
        echo "Error: Results directory ${resultsFolder}/vectors Couldn't be created. Quitting..."
        exit 4
    fi
fi

if [ -d "${resultsFolder}/scalars" ] 
then
    echo "Vectors directory ${resultsFolder}/scalars exists. Continuing..." 
else
    echo "Results directory ${resultsFolder}/scalars does not exist. Creating the directory..."
    mkdir ${resultsFolder}/scalars
    if [ -d "${resultsFolder}/scalars" ] 
    then
        echo "Results directory ${resultsFolder}/scalars successfully created. Continuing..." 
    else
        echo "Error: Results directory ${resultsFolder}/scalars Couldn't be created. Quitting..."
        exit 4
    fi
fi

firstResult=0
lastResult=$(($numRuns - 1))

for run_num in $(eval echo "{$firstResult..$lastResult}")
do
    echo "Exporting run $run_num..."
    scavetool export -f '(module(*.ue[*].tcpApp[0]*) AND name(*rcvdPk*)) OR (module(*.ue[*].tcpApp[0]*) AND name(*sentPk*))' -F CSV -o ${resultsFolder}/vectors/${experimentDescriptor}_${run_num}_less_vec.csv ${sourceFolder}/*-${run_num}.vec
    scavetool export -f '(module(*.ue[*].tcpApp[0]) AND name(*endToEndDelay*)) OR (module(*.ue[*].tcpApp[0]) AND name(*DASH*)) OR (module(*.ue[*].tcpApp[0]*) AND name(*rcvdPk*)) OR (module(*.ue[*].tcpApp[0]*) AND name(*sentPk*)) OR (module(*.ue[*].tcp) AND name("*measured RTT*")) OR (module(*.ue[*].tcp) AND name("*smoothed RTT*")) OR (module(*.pgw.ppp[0].ppp*) AND name(*rxPk*)) OR (module(*.pgw.ppp[0].ppp*) AND name(*txPk*)) OR (module(*.pgw.ppp[0].queue*) AND name(*Length*))' -F CSV -o ${resultsFolder}/vectors/${experimentDescriptor}_${run_num}_full_vec.csv ${sourceFolder}/*-${run_num}.vec
    scavetool export -f '(module(*.ue[*].tcpApp[0]) AND name(*Pk:sum*)) OR (module(*.pgw.ppp[0].ppp*) AND name(*rxPkOk:sum*)) OR (module(*.pgw.ppp[0].ppp*) AND name(*txPk:sum*)) OR (name(*Cqi*)) OR (name(*position*))' -F CSV -o ${resultsFolder}/scalars/${experimentDescriptor}_${run_num}_sca.csv ${sourceFolder}/*-${run_num}.sca
done