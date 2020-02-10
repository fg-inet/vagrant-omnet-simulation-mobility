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


network simpleNetwork
{
    parameters:
        int numUe = default(1);
        string resFolder = default("results");
        //        @display("i=block/network2;bgb=1600,1000;bgi=background/mapTU,s");
//        @display("bgb=920,500,#FFFFFF");
		@display("i=block/network2;bgb=920,500;bgi=background/mapTU,s");
    submodules:
        channelControl: LteChannelControl {
            @display("p=66,20;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=66,70;is=s");
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=66,120");
            config = xmldoc("demo.xml");
        }
        binder: LteBinder {
            @display("p=66,170;is=s");
        }
        pgw: PgwStandardSimplified {
            nodeType = "PGW";
            @display("p=460,90;is=l;t=Packet Gateway (PGW),t,#FF0000");
        }
        eNodeB: eNodeB {
            @display("t=eNodeB,t,#FF0000;i=device/greenantennatower1,#FF00FF,100;is=n;i2=status/connect;p=460,240");
        }
        ue[numUe]: Ue {
            @display("p=800.992,845.368;t=Client,t,#FF0000");
        }
        VideoServer: StandardHost {
            @display("p=700,90;is=n;i=device/server;t=Video Server,t,#FF0000");
        }
        routerI0: Router {
            @display("p=220,90;t=Internal Router,t,#FF0000");
        }
    connections:
        VideoServer.pppg++ <--> Eth40G { @display("ls=#0000FF,2,s"); } <--> pgw.filterGate;
        pgw.pppg++ <--> Eth40G { @display("ls=#0000FF,2,s"); } <--> routerI0.pppg++;
        eNodeB.ppp <--> Eth40G { @display("ls=#0000FF,2,s"); } <--> routerI0.pppg++;
}
