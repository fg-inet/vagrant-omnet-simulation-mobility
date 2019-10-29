// 
//                           SimuLTE
// 
// This file is part of a software released under the license included in file
// "license.pdf". This license can be also found at http://www.ltesimulator.com/
// The above file and the present reference are part of the software itself, 
// and cannot be removed from it.
// 
package lte.simulations.networks;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.node.ethernet.Eth100M;
import inet.node.ethernet.Eth10G;
import inet.node.ethernet.Eth1G;
import inet.node.ethernet.Eth10M;
import inet.node.ethernet.Eth40G;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import lte.corenetwork.binder.LteBinder;
import lte.corenetwork.nodes.Ue;
import lte.corenetwork.nodes.eNodeB;
import lte.world.radio.LteChannelControl;
import lte.epc.PgwStandardSimplified;
import lte.epc.PgwStandard;
import inet.applications.httptools.server.HttpServer;
import inet.applications.httptools.configurator.HttpController;


network DemoNetwork
{
    parameters:
        int numUe = default(1);
        string resFolder = default("results");
        @display("i=block/network2;bgb=1600,1000;bgi=background/mapTU,s");
        @display("bgb=1600,1000,#90EE90");
    submodules:
        channelControl: LteChannelControl {
            @display("p=50,25;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=50,75;is=s");
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=50,125");
            config = xmldoc("demo.xml");
        }
        binder: LteBinder {
            @display("p=50,175;is=s");
        }
		//Controller for the HTTP applications running on hosts in the network
        controller: HttpController {
            @display("p=50,225;is=s");
        }
        pgw: PgwStandardSimplified {
            nodeType = "PGW";
            @display("p=184.32373,599.8606;is=l;t=PGW,t,#F5FF00");
        }
        eNodeB: eNodeB {
            @display("p=312.05685,386.4331;t=eNodeB,t,#F5FF00;i=device/greenantennatower1,#00D5FF,100;is=n;i2=status/connect");
        }
        ue[numUe]: Ue {
            @display("p=1088.3359,190.76;t=Client,t,#F5FF00");
        }
        UAF: StandardHost {
            @display("p=588.5425,467.27682;is=n;i=device/server;t=UAF,t,#F5FF00");
        }
        VideoServer: StandardHost {
            @display("p=976.5924,824.6062;is=n;i=device/server;t=Video Server,l,#F5FF00");
        }
        NWDAF: StandardHost {
            @display("p=913.5343,522.2506;is=n;i=device/server;t=NWDAF,t,#F5FF00");
        }
        router0: Router {
            @display("p=455.9587,704.95746;t=Router,t,#F5FF00");
        }
        router2: Router {
            @display("p=488.2962,554.5881;t=Router,t,#F5FF00");
        }
        router3: Router {
            @display("p=627.3475,716.2756;t=Router,r,#F5FF00");
        }
        router4: Router {
            @display("p=748.6131,522.2506;t=Router,t,#F5FF00");
        }
        router7: Router {
            @display("p=945.8718,654.83435;t=Router,t,#F5FF00");
        }
		//Comment from here for the one mobile client scenario
    //        host: StandardHost {
    //            @display("p=1048.176,385.53598");
    //        }
    //        host1: StandardHost {
    //            @display("p=1303.192,385.53598");
    //        }
    //        host2: StandardHost {
    //            @display("p=1381.5039,638.544");
    //        }
    //        host3: StandardHost {
    //            @display("p=1381.5039,857.41595");
    //        }
    //        mUe1: Ue {
    //            @display("p=230.92,506.016");
    //        }
    //        mUe2: Ue {
    //            @display("p=469.87198,405.616");
    //        }
    //        mUe3: Ue {
    //            @display("p=347.384,236.944");
    //        }
    connections:
        router0.pppg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> pgw.filterGate;
        pgw.pppg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> eNodeB.ppp;
        router0.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router3.ethg++;
        router0.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router2.ethg++;
        router2.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router3.ethg++;
        router2.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router3.ethg++;
        router4.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router3.ethg++;
        router2.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router4.ethg++;
        router3.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router7.ethg++;
        router7.ethg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router4.ethg++;

        UAF.pppg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router2.pppg++;
        NWDAF.pppg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router4.pppg++;
        VideoServer.pppg++ <--> Eth40G { @display("ls=#EFEFEF,2,s"); } <--> router7.pppg++;
}
