# Estimating Video QoE in 5G Networks Using Machine Learning - Supplementary Material

This is the simulation enviroment and supplementary data as used in paper:
Accuracy vs. Cost Trade-off for Machine Learning Based QoE Estimation in 5G Networks

An extension to:
Schwarzmann, S., Cassales Marquezan, C., Bosk, M., Liu, H., Trivisonno, R., & Zinner, T. (2019, October). Estimating Video Streaming QoE in the 5G Architecture Using Machine Learning. In <i>Proceedings of the 4th Internet-QoE Workshop on QoE-based Analysis and Management of Data Communication Networks</i> (pp. 7-12). ACM.

## Simulation Environment
### Requirements
Vagrant - Tested with version 2.2.4 (available at: https://www.vagrantup.com/downloads.html)

### Vagrant box setup
In the `/vagrant-omnet-simulation-mobility/simulation-environment` folder use: 
```bash
$ vagrant up
```

And wait until the vagrant box setup is complete.

### Using the Omnet++ simulator

To access the box and the simulation environment use the following command while remaining in the `/vagrant-omnet-simulation-mobility/simulation-environment` folder:

```bash
$ vagrant ssh
```

This will establish an ssh connection to the box. In there you can access the simulation environment.

#### Running a simulation

In order to run simulation scenarios (as they were run within the project) switch to the `Moving1/simulations` folder:

```bash
$ cd Moving1/simulations
```

and use the following command to run an exemplary simulation scenario:

```bash
$ ./run_sim_campaign.sh -c swimMovementFP_ds0_p2_s50-50 -t 1
```

This will run a simulation scenario with the config `[Config swimMovementFP_ds0_p2_s50-50]`.

-c argument specifies the scenario's config name. You can find what simulation scenarios are available in the `Moving1/simulations/omnetpp.ini` file.

-t argument specifies the number of threads that will be used to parallelize the simulation. 

#### Adjusting the movement of UEs

In the simulation we include 3 main types of UE movement - pedestrians (at 1mps), vehicles (at 10mps) and stationary clients. All of these can be adjusted in the `Moving1/simulations/omnetpp.ini` file. In each "Config" section (eg. `[Config swimMovementFP_ds0_p1_s100-0]`) the following can be used to set speed of UEs (examples):
- ```*.ue[0..39].mobility.speed = 1mps``` Sets movement speed of UEs 0 through 39 to 1 mps (pedestrian)
- ```*.ue[40..79].mobility.speed = 10mps``` Sets movement speed of UEs 40 through 79 to 10 mps (vehicle)
- ```*.ue[*].mobility.speed = 10mps``` Sets movement speed of all UEs to 10 mps (vehicle)

In order to make UEs stationary the following code can be used:
```
*.ue[0..55].mobilityType = "LinearMobility"
*.ue[0..55].mobility.speed = 0mps
```
In this example UEs 0 to 55 will become stationary.

#### Other Simulation settings

The following table shows the most relevant parameters used to configure the eNodeB in the simulated scenarios:
<p align="left">
  <img src="simulation-environment/omnet-eNB-configs.png" width=350>
</p>

**AMC** = Adaptive Modulation and Coding<br/>
**MAC** = Medium access control<br/>
**RLC** = Radio link control

### Links
1. Omnet++ - https://omnetpp.org
2. SimuLTE - https://simulte.com
3. INET Framework - https://inet.omnetpp.org
4. SWIM Mobility Model GitHub - https://github.com/ComNets-Bremen/SWIMMobility
5. Original version of the TCP Video Client by Joaquín Navarro - https://github.com/navarrojoaquin/adaptive-video-tcp-omnet
6. TCP Video Client Adaptation which the TCP Video Client used in this work is based on - https://github.com/inet-framework/inet/tree/topic/tcpvideosteaming/src/inet/applications/tcpapp (files `TcpVideoStreamCliApp.*`)

## Supplementary Data
### Number of features and monitoring points 


## Contact
1. Susanna Schwarzmann - susanna@inet.tu-berlin.de
2. Marcin Bosk - mbosk@inet.tu-berlin.de
3. Huiran Liu - huiran.liu@campus.tu-berlin.de
