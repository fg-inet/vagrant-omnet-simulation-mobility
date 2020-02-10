#!/bin/bash
helpFunction()
{
   echo ""
   echo "Usage: $0 -c configName -t numThreads"
   echo -e "\t-c Name of the configuration to run the campaign on"
   echo -e "\t-t Number of available threads for paralellization"
   exit 1 # Exit script after printing help
}

while getopts "c:t:" opt
do
   case "$opt" in
      c ) configName="$OPTARG" ;;
      t ) numThreads="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$configName" ] || [ -z "$numThreads" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

opp_runall -b1 -j$numThreads opp_run -u Cmdenv -f omnetpp.ini -c $configName -m -n .:../src:../../omnetpp-5.1/samples/inet/examples:../../omnetpp-5.1/samples/inet/src:../../omnetpp-5.1/samples/inet/tutorials:../../omnetpp-5.1/samples/simulte/simulations:../../omnetpp-5.1/samples/simulte/src --image-path=../images:../../omnetpp-5.1/samples/simulte/images -l ../../omnetpp-5.1/samples/inet/src/INET -l ../../omnetpp-5.1/samples/simulte/src/lte