#!/usr/bin/env bash

sudo apt-get upgrade
sudo apt-get update
echo "#### Install software-properties-common ####"
sudo apt-get install -y software-properties-common
# echo "#### Add repository ppa:ubuntu-toolchain-r/test ####"
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test
# sudo apt-get update
echo "#### Install other packages ####"
sudo apt-get install -y xauth build-essential gcc-6 g++-6 bison flex perl tcl-dev tk-dev blt libxml2-dev zlib1g-dev openjdk-8-jre doxygen graphviz openmpi-bin libopenmpi-dev libpcap-dev
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
echo "#### Install git ####"
sudo apt-get install -y git
echo "#### Downloading Omnet++ version 5.1 ####"
echo "#### will try downloading up to 10 times with 10s timeouts between retries ####"
wget -c --tries=30 --read-timeout=15 --progress=bar:force https://gateway.ipfs.io/ipns/ipfs.omnetpp.org/release/5.1/omnetpp-5.1-src-linux.tgz
tar xvfz omnetpp-5.1-src-linux.tgz &> /dev/null
if [ -d "omnetpp-5.1" ]; then
  echo "#### Omnet++ successfully downloaded ####"
  cd omnetpp-5.1
  echo "#### Compiling and installing Omnet++ version 5.1 ####"
  ./configure WITH_TKENV=no WITH_QTENV=no WITH_OSG=no NO_TCL=yes WITH_OSGEARTH=no
  make
  cd ~
  echo "#### Download and extract INET version 3.5.0 ####"
  wget --progress=bar:force https://github.com/inet-framework/inet/releases/download/v3.5.0/inet-3.5.0-src.tgz
  tar xvfz inet-3.5.0-src.tgz &> /dev/null
  if [ -d "inet" ]; then
    mv inet omnetpp-5.1/samples/
    echo "#### Fetch the SWIM Movement Model ####"
    git clone https://github.com/ComNets-Bremen/SWIMMobility.git
    cp -a SWIMMobility/SWIM* omnetpp-5.1/samples/inet/src/inet/mobility/single/
    rm -rf SWIMMobility/
    echo "#### Copy the TCP Video Client to INET TCP applications folder ####"
    cp -a resources/tcpVideoClient/. omnetpp-5.1/samples/inet/src/inet/applications/tcpapp/
    echo "#### Copy the Location Logger to INET TCP applications folder ####"
    cp -a resources/locationLogger/. omnetpp-5.1/samples/inet/src/inet/applications/tcpapp/
    rm -rf inet-3.5.0-src.tgz
    rm -rf omnetpp-5.1-src-linux.tgz
    cd omnetpp-5.1/samples/inet
    echo "#### Compile INET ####"
    make makefiles
    make
    echo "#### Fetch SimuLTE ####"
    cd ..
    git clone https://github.com/inet-framework/simulte.git
    cd simulte
    git checkout 886f544bfe2f1600e0d9a75c06fb5d8e0e58cf11
    echo "#### Compile SimuLTE ####"
    make makefiles
    make
    echo "#### Prepare the simulation network ####"
    cd ~
    cp -r resources/Moving1 .
    echo "#### Simulation environment setup should be complete - assuming there were no compilation errors (this script does not do check that) ####"
  else
    echo "#### Could not download INET Framework successfully - setup was not successful ####"
  fi
else
  echo "#### Omnet++ downloaded unsuccessful - setup was not successful ####"
fi