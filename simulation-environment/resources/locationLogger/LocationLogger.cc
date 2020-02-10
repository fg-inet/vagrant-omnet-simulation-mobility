/*
 *  LocationLogger.cc
 */

#include "LocationLogger.h"

#include "inet/applications/tcpapp/GenericAppMsg_m.h"

#include "inet/common/ModuleAccess.h"
#include "inet/mobility/contract/IMobility.h"

namespace inet {

#define MSGKIND_LOGPOSITION     0

//Register_Class(TCPVideoStreamCliApp);
Define_Module(LocationLogger);

LocationLogger::~LocationLogger() {
    cancelAndDelete(timeoutMsg);
}

LocationLogger::LocationLogger() {
    timeoutMsg = NULL;
}


void LocationLogger::initialize(int stage) {
    cSimpleModule::initialize(stage);
    logInterval = par("loggingFrequency");

    cModule *host = getContainingNode(this);
    IMobility  *mod = check_and_cast<IMobility *>(host->getSubmodule("mobility"));
    Coord pos = mod->getCurrentPosition();

    EV << "Node position " << pos.x << pos.y << endl;

//    xLoc = pos.x;
    WATCH(xLoc);
    XLocation = registerSignal("XLocation");
//    emit(XLocation, xLoc);

//    yLoc = pos.y;
    WATCH(yLoc);
    YLocation = registerSignal("YLocation");
//    emit(YLocation, yLoc);

    timeoutMsg = new cMessage("timer");
    timeoutMsg->setKind(MSGKIND_LOGPOSITION);
    scheduleAt(simTime(), timeoutMsg);

    EV << "TCP Video Stream client initialization complete" << endl;
}

void LocationLogger::handleMessage(cMessage *msg) {
    EV << "Handling the timer\n";
    cModule *host = getContainingNode(this);
    IMobility  *mod = check_and_cast<IMobility *>(host->getSubmodule("mobility"));
    Coord pos = mod->getCurrentPosition();

    EV << "Node position " << pos.x << pos.y << endl;

    xLoc = pos.x;
    emit(XLocation, xLoc);

    yLoc = pos.y;
    emit(YLocation, yLoc);
    scheduleAt(simTime()+(simtime_t)logInterval, timeoutMsg);
}

}


