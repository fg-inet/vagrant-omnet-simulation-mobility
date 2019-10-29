/*
 *  LocationLogger.h
 */

#ifndef LOCATIONLOGGER_H_
#define LOCATIONLOGGER_H_

#include <omnetpp.h>
#include "inet/common/INETDefs.h"

namespace inet {

class LocationLogger: public cSimpleModule {

protected:

    double xLoc;
    simsignal_t XLocation;
    double yLoc;
    simsignal_t YLocation;

    double logInterval;

    simtime_t startTime;
    cMessage *timeoutMsg;
    simtime_t stopTime;

public:
    LocationLogger();
    virtual ~LocationLogger();

protected:
    virtual void initialize(int stage);

    virtual void handleMessage(cMessage *msg);

};
} //namespace inet
#endif




