#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -n numRuns -s sourceFolder -o resultsFolder -t resultsSubfolder -d experimentDescriptor"
   echo -e "\t-n Number of runs from which to export scalars and vecorts into .csv files"
   echo -e "\t-s Folder which contains the source .vec and .sca files"
   echo -e "\t-o Destination folder"
   echo -e "\t-t Destination subfolder"
   echo -e "\t-d Descriptor of the experiment"
   exit 1 # Exit script after printing help
}

while getopts "n:s:o:t:d:" opt
do
   case "$opt" in
      n ) numRuns="$OPTARG" ;;
      s ) sourceFolder="$OPTARG" ;;
      o ) resultsFolder="$OPTARG" ;;
      t ) resultsSubfolder="$OPTARG" ;;
      d ) experimentDescriptor="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$numRuns" ] || [ -z "$sourceFolder" ] || [ -z "$resultsFolder" ] || [ -z "$resultsSubfolder" ] || [ -z "$experimentDescriptor" ]
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

firstResult=0
lastResult=$(($numRuns - 1))

for run_num in $(eval echo "{$firstResult..$lastResult}")
do
    #num_ue=$(grep -oP '(?<=attr UE )[0-9]+' ${sourceFolder}/*-${run_num}.vci)
    num_ue=80
    last_ue=$(($num_ue - 1))
    echo "Num ue: $num_ue"
    subfolderName="${resultsSubfolder}_${num_ue}"
    echo "Subfolder name: $subfolderName"
    if [ -d "${resultsFolder}/${subfolderName}" ] 
    then
        echo "Vectors directory ${resultsFolder}/${subfolderName} exists. Continuing..." 
    else
        echo "Results directory ${resultsFolder}/${subfolderName} does not exist. Creating the directory..."
        mkdir ${resultsFolder}/${subfolderName}
        if [ -d "${resultsFolder}/${subfolderName}" ] 
        then
            echo "Results directory ${resultsFolder}/${subfolderName} successfully created. Continuing..." 
        else
            echo "Error: Results directory ${resultsFolder}/${subfolderName} Couldn't be created. Quitting..."
            exit 4
        fi
    fi
    
    if [ -d "${resultsFolder}/${subfolderName}/vectors" ] 
    then
        echo "Vectors directory ${resultsFolder}/${subfolderName}/vectors exists. Continuing..." 
    else
        echo "Results directory ${resultsFolder}/${subfolderName}/vectors does not exist. Creating the directory..."
        mkdir ${resultsFolder}/${subfolderName}/vectors
        if [ -d "${resultsFolder}/${subfolderName}/vectors" ] 
        then
            echo "Results directory ${resultsFolder}/${subfolderName}/vectors successfully created. Continuing..." 
        else
            echo "Error: Results directory ${resultsFolder}/${subfolderName}/vectors Couldn't be created. Quitting..."
            exit 4
        fi
    fi

    if [ -d "${resultsFolder}/${subfolderName}/scalars" ] 
    then
        echo "Vectors directory ${resultsFolder}/${subfolderName}/scalars exists. Continuing..." 
    else
        echo "Results directory ${resultsFolder}/${subfolderName}/scalars does not exist. Creating the directory..."
        mkdir ${resultsFolder}/${subfolderName}/scalars
        if [ -d "${resultsFolder}/${subfolderName}/scalars" ] 
        then
            echo "Results directory ${resultsFolder}/${subfolderName}/scalars successfully created. Continuing..." 
        else
            echo "Error: Results directory ${resultsFolder}/${subfolderName}/scalars Couldn't be created. Quitting..."
            exit 4
        fi
    fi
    
    echo "Exporting run $run_num which has $num_ue clients..."
    scavetool export -f "(module(*.pgw.ppp[0].ppp*) AND name(*rxPk*)) OR (module(*.pgw.ppp[0].ppp*) AND name(*txPk*)) OR (module(*.pgw.ppp[0].queue*) AND name(*Length*))"  -F CSV -o ${resultsFolder}/${subfolderName}/vectors/${experimentDescriptor}_${num_ue}_pgw_vec.csv ${sourceFolder}/*-${run_num}.vec
    scavetool export -f "(module(*.pgw.ppp[0].ppp*) AND name(*rxPkOk:sum*)) OR (module(*.pgw.ppp[0].ppp*) AND name(*txPk:sum*))" -F CSV -o ${resultsFolder}/${subfolderName}/scalars/${experimentDescriptor}_${num_ue}_pgw_sca.csv ${sourceFolder}/*-${run_num}.sca
    for cli_num in $(eval echo "{$firstResult..$last_ue}")
    do
        echo -e "\t Exporting for client $cli_num"
        scavetool export -f "(module(*.ue[$cli_num].tcpApp[0]) AND name(*endToEndDelay*)) OR (module(*.ue[$cli_num].tcpApp[0]) AND name(*DASH*)) OR (module(*.ue[$cli_num].tcpApp[0]*) AND name(*rcvdPk*)) OR (module(*.ue[$cli_num].tcpApp[0]*) AND name(*sentPk*)) OR (module(*.ue[$cli_num].tcp) AND name(\"*measured RTT*\")) OR (module(*.ue[$cli_num].tcp) AND name(\"*smoothed RTT*\")) OR (module(*.ue[$cli_num].lteNic.mac*) AND name(*Packet*Upper*))  OR (module(*.ue[$cli_num].*) AND name(*Cqi*)) OR (module(*.ue[$cli_num].*) AND name(*Location*))" -F CSV -o ${resultsFolder}/${subfolderName}/vectors/${experimentDescriptor}_${num_ue}_cli${cli_num}_vec.csv ${sourceFolder}/*-${run_num}.vec
        scavetool export -f "(module(*.ue[$cli_num].tcpApp[0]) AND name(*Pk:sum*)) OR (module(*.ue[$cli_num].*) AND name(*Cqi*)) OR (module(*.ue[$cli_num].*) AND name(*position*)) OR (module(*.ue[$cli_num].lteNic.mac*) AND name(*Packet*Upper*))" -F CSV -o ${resultsFolder}/${subfolderName}/scalars/${experimentDescriptor}_${num_ue}_cli${cli_num}_sca.csv ${sourceFolder}/*-${run_num}.sca
    done
done
