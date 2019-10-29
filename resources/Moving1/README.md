A readme for the AdvancedDemo Omnet++ project.
This demo is based on and inspired by an exemplary simulation from the SimuLTE library (the "demo" scenario from 'SimuLTE/simuletions/'). The "config_channel.xml" and "demo.xml" files are directly copied from the 'SimuLTE/simulations/demo' folder.

Requirements:
- Omnet++ version 5.1 (https://omnetpp.org/download/old/)
- INET version 3.5 (https://inet.omnetpp.org/Download.html)
- SimuLTE 0.9.1 simulation model (https://github.com/inet-framework/simulte/releases/tag/v0.9.1)

Steps necessary to run the simulation:
1. Install Omnet++.
2. Download the INET and SimuLTE
3. Import INET into Omnet++ (File -> Import -> Existing Projects into Workspace). It is advised to put the downloaded INET folder into the Samples Folder of Omnet++
4. Build INET project (right-click on the project and choose "Bulid Project")
5. Import SimuLTE into Omnet++ (File -> Import -> Existing Projects into Workspace). It is advised to put the downloaded INET folder into the Samples Folder of Omnet++
6. Right-click SimuLTE project, choose properties and in "Project references" tab make sure INET is selected.
7. Build SimuLTE project (right-click on the project and choose "Bulid Project")
8. Import the AdvancedDemo project into Omnet++
9. Right-click AdvancedDemo project, choose properties and in "Project references" tab make sure INET and SimuLTE are selected.
10. In order to run the simulation, select the simulations folder under the AdvancedDemo project and click run. The IDE should then build the project and run the simulation automatically.

If this doesn't work, please contact me (marcin.l.bosk@campus.tu-berlin.de) :)