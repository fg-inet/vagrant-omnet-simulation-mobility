/*
 *  TCPVideoStreamCliApp.cc
 *
 *  1. An adaptation of Navarro Joaquim's code (https://github.com/navarrojoaquin/adaptive-video-tcp-omnet)
 *     created on 8 de dez de 2017 by Anderson Andrei da Silva & Patrick Menani Abrah������������������������������������������������������o at University of S������������������������������������������������������o Paulo
 *
 *  2. Edited and adapted for Omnet++ 5.1 with INET 3.5 by Marcin Bosk at the Technische Universit������t Berlin in January 2019
 *
 */

#include "TCPVideoStreamCliApp.h"
#include "inet/applications/tcpapp/GenericAppMsg_m.h"

#include "inet/common/ModuleAccess.h"
#include "inet/mobility/contract/IMobility.h"

namespace inet {

#define MSGKIND_CONNECT     0
#define MSGKIND_SEND        1
#define MSGKIND_VIDEO_PLAY  2

//Register_Class(TCPVideoStreamCliApp);
Define_Module(TCPVideoStreamCliApp);

simsignal_t TCPVideoStreamCliApp::rcvdPkSignal = registerSignal("rcvdPk");
simsignal_t TCPVideoStreamCliApp::sentPkSignal = registerSignal("sentPk");

simsignal_t TCPVideoStreamCliApp::positionX = registerSignal("positionX");
simsignal_t TCPVideoStreamCliApp::positionY = registerSignal("positionY");

TCPVideoStreamCliApp::~TCPVideoStreamCliApp() {
    cancelAndDelete(timeoutMsg);
}

TCPVideoStreamCliApp::TCPVideoStreamCliApp() {
    timeoutMsg = NULL;
}


void TCPVideoStreamCliApp::initialize(int stage) {
    TCPBasicClientApp::initialize(stage);
    if (stage != 3)
        return;

    // read Adaptive Video (AV) parameters
    const char *str = par("video_packet_size_per_second").stringValue();
    video_packet_size_per_second = cStringTokenizer(str).asIntVector(); //M:Number of kilobits per second in the video
    video_buffer_max_length = par("video_buffer_max_length"); //M:Maximal length of the video buffer in seconds EDIT? Do it in segments
    video_duration = par("video_duration");                   //M:EDIT? Do that also in segments?
    manifest_size = par("manifest_size");
    segment_length = par("segment_length");
    numRequestsToSend = ceil((double)video_duration/(double)segment_length);
    EV << "Initial numRequestsToSend = " << numRequestsToSend << endl;
    EV << "video_duration % segment_length = " << video_duration % segment_length << endl;
    WATCH(video_buffer);
    video_buffer = 0;
//    switch_timer++;
//    EV << "Switch timer: " << switch_timer << endl;
    DASH_buffer_length_signal = registerSignal("DASHBufferLength");
    emit(DASH_buffer_length_signal, video_buffer);
    video_playback_pointer = 0;
    WATCH(video_playback_pointer);
    DASH_playback_pointer = registerSignal("DASHVideoPlaybackPointer");
    emit(DASH_playback_pointer, video_playback_pointer);

    video_current_quality_index = 0;  // start with min quality
    DASH_video_bitrate_signal = registerSignal("DASHVideoBitrate");
    emit(DASH_video_bitrate_signal, video_packet_size_per_second[video_current_quality_index]);
    EV << "quality zones: " << video_packet_size_per_second[2] << endl;
    video_is_playing = false;
    DASH_video_is_playing_signal = registerSignal("DASHVideoPlaybackStatus");
    //emit(DASH_video_is_playing_signal, video_is_playing);

    received_bytes = 0;
    DASH_received_bytes = registerSignal("DASHReceivedBytes");

    //statistics
    msgsRcvd = msgsSent = bytesRcvd = bytesSent = 0;

    WATCH(msgsRcvd);
    WATCH(msgsSent);
    WATCH(bytesRcvd);
    WATCH(bytesSent);

    WATCH(numRequestsToSend);

    //What was that code supposed to do?!
//    //simtime_t startTime = par("startTime");
//    video_startTime = par("video_startTime").doubleValue();
//    stopTime = par("stopTime");
//    if (stopTime != 0 && stopTime <= video_startTime)
//        error("Invalid startTime/stopTime parameters");
//
    timeoutMsg = new cMessage("timer");
    timeoutMsg->setKind(MSGKIND_CONNECT);
//    //scheduleAt(startTime, timeoutMsg);
//    EV<< "start time: " << video_startTime << "\n";
//    scheduleAt(simTime()+(simtime_t)video_startTime, timeoutMsg);

    cModule *host = getContainingNode(this);
    IMobility  *mod = check_and_cast<IMobility *>(host->getSubmodule("mobility"));
    Coord pos = mod->getCurrentPosition();

    EV << "Node position " << pos.x << pos.y << endl;

    emit(TCPVideoStreamCliApp::positionX, pos.x);
    emit(TCPVideoStreamCliApp::positionY, pos.y);

    EV << "TCP Video Stream client initialization complete" << endl;
}

void TCPVideoStreamCliApp::sendRequest() {
    EV << "Send request function. ";
    if (video_buffer <= video_buffer_max_length - segment_length) {
        EV<< "Sending request, " << numRequestsToSend-1 << " more to go\n";

        // Request length
        long requestLength = par("requestLength");
        if (requestLength < 1) requestLength = 1;
        // Reply length
        long replyLength = -1;
        if (manifestAlreadySent) {
            if (video_duration % segment_length > 0 && numRequestsToSend == 1) {
                EV << "Download last partial segment" << endl;
                replyLength = (video_packet_size_per_second[video_current_quality_index] / 8 * 1000)*(video_duration % segment_length);  // kbits -> bytes. Download the partial remaining segment.
            } else {
                EV << "Download whole segment" << endl;
                replyLength = (video_packet_size_per_second[video_current_quality_index] / 8 * 1000)*segment_length;  // kbits -> bytes. Download the whole segment.
            }

            // Log requested quality
            emit(DASH_video_bitrate_signal, video_packet_size_per_second[video_current_quality_index]);
            numRequestsToSend--;
            // Switching algoritm
            tLastPacketRequested = simTime();
        } else {
            replyLength = manifest_size;
            EV<< "sending manifest request\n";
        }

        EV << "Requested reply size = " << replyLength << endl;

        msgsSent++;
        bytesSent += requestLength;

        GenericAppMsg *msg = new GenericAppMsg("data");
        msg->setByteLength(requestLength);
        msg->setExpectedReplyLength(replyLength);
        msg->setServerClose(false);
        EV << "TCPSocket - sendRequest - connectionId: " << msg->getControlInfo() << endl;
        sendPacket(msg);
    } else {
        EV << "Request will be sent at a later time, as there is not enough space in the buffer." << endl;
        simtime_t d = simTime() + 1;
        rescheduleOrDeleteTimer(d, MSGKIND_SEND);
    }
}

void TCPVideoStreamCliApp::handleTimer(cMessage *msg) {
    EV << "Handling the timer\n";
    switch (msg->getKind()) {
    case MSGKIND_CONNECT:       //M:Connect with the server on MSGKIND_CONNECT event
        EV<< "Start the session and connect with the server\n";
        emit(DASH_video_is_playing_signal, video_is_playing);
        connect(); // active OPEN
        break;

    case MSGKIND_SEND:          //M:Send a request to the server and ask for some video data on MSGKIND_SEND event
        EV << "Sending a request to the server\n";
        sendRequest();
        // no scheduleAt(): next request will be sent when reply to this one
        // arrives (see socketDataArrived())
        break;

    case MSGKIND_VIDEO_PLAY:    //M:"Play" one second of video on MSGKIND_VIDEO_PLAY event
        EV << "---------------------> Video play event" << endl;
        EV << "Playing one second of video" << endl;
        cancelAndDelete(msg);
        video_buffer -= 1;                                         //M:Take the played part of video (whole segment) out of the buffer
        emit(DASH_buffer_length_signal, video_buffer);
        video_playback_pointer += 1;                               //M:Advance the video pointer (by the whole segment)
        emit(DASH_playback_pointer, video_playback_pointer);
        if (video_buffer == 0) { //M:"Stop" the video from playing when we played the last segment present in the buffer
            video_is_playing = false;

            //cTimestampedValue tmp(simTime() + (simtime_t) 1, (long) video_is_playing);
            //emit(DASH_video_is_playing_signal, &tmp);
            emit(DASH_video_is_playing_signal, video_is_playing);
        }
        if (video_buffer > 0) {//M:When there is something in the buffer, schedule video playing event in one second
            simtime_t d = simTime() + 1; //M: This +1 is used to schedule a video play event in one second
            cMessage *videoPlaybackMsg = new cMessage("playback");
            videoPlaybackMsg->setKind(MSGKIND_VIDEO_PLAY);
            scheduleAt(d, videoPlaybackMsg);
            //rescheduleOrDeleteTimer(d, MSGKIND_VIDEO_PLAY);
        }
        if (!video_is_buffering && numRequestsToSend > 0 && video_buffer <= video_buffer_max_length - segment_length) { //M: Client is still loading segments (buffer not full) and there is still video left to download
            // Now the buffer has some space
            video_is_buffering = true;
            simtime_t d = simTime();
            rescheduleOrDeleteTimer(d, MSGKIND_SEND);
        }
        if (video_buffer == 0 && numRequestsToSend == 0) {    //EDIT! //M: Just a message that the video has been played completely
            EV << "Entire video has been played." << endl;    //EDIT!
        }                                                     //EDIT!
        break;
    default:
        EV << "Default case\n";
        throw cRuntimeError("Invalid timer msg: kind=%d", msg->getKind());
    }
}

void TCPVideoStreamCliApp::socketEstablished(int connId, void *ptr) { //M: When the socked has been established, send the first request
    EV << "Socket established\n";                           //EDIT!
    EV << "Connection id: " << connId << "\n";              //EDIT!
//    TCPBasicClientApp::socketEstablished(connId, ptr);    //EDIT! - This doubled the functionality of the function below...
    TCPAppBase::socketEstablished(connId, ptr);             //EDIT!

    // perform first request
    sendRequest();

}

void TCPVideoStreamCliApp::rescheduleOrDeleteTimer(simtime_t d, short int msgKind) { //M: Not entirely sure how to describe what is happening here. It probably has something to do with the lifetime of the video client in the simulation
    EV << "Reschedule or delete timer\n";                   //EDIT!
    cancelEvent (timeoutMsg);

    if (stopTime == 0 || stopTime > d) {
        timeoutMsg->setKind(msgKind);
        scheduleAt(d, timeoutMsg);
    } else {
        delete timeoutMsg;
        timeoutMsg = NULL;
    }
}

void TCPVideoStreamCliApp::socketDataArrived(int connId, void *ptr, cPacket *msg,
        bool urgent) {
    EV << "Socket data arrived! \n";                                    //EDIT!
    EV << "Connection id: " << connId << "\n";                          //EDIT!
    int just_received_bytes = msg->getByteLength();
//    TCPBasicClientApp::socketDataArrived(connId, ptr, msg, urgent);   //EDIT! - the functionality here doubled that of the rest of the function...
    TCPAppBase::socketDataArrived(connId, ptr, msg, urgent);            //EDIT!
    if (!manifestAlreadySent) {
        EV << "Something with manifest\n";
        manifestAlreadySent = true;
        if (timeoutMsg) {
            // Send new request
            simtime_t d = simTime();
            rescheduleOrDeleteTimer(d, MSGKIND_SEND);
        }
        return;
    }

    emit(DASH_received_bytes, just_received_bytes);

    // Switching algorithm - it limits the shortest time after which a quality change can be made
    packetTimePointer = (packetTimePointer + 1) % packetTimeArrayLength; //That should be ok...
    packetTime[packetTimePointer] = simTime() - tLastPacketRequested;

    int replySeconds = segment_length;

    if (numRequestsToSend == 0 && video_duration % segment_length > 0) {
        replySeconds = video_duration % segment_length;
    }

    EV << "replySeconds = " << replySeconds << endl;

    video_buffer += replySeconds;

    EV << "video_buffer = " << video_buffer << endl;

    emit(DASH_buffer_length_signal, video_buffer);
    // Update switch timer
    if(!can_switch) {
        EV << "Switch timer: " << switch_timer << endl;
        switch_timer--;
        if (switch_timer == 0) {
            can_switch = true;
            switch_timer = switch_timeout;
        }
    }
    // Full buffer
    if (video_buffer >= video_buffer_max_length) {  //EDIT!
        EV << "Video buffer full\n";
        video_is_buffering = false;
        // switch to higher quality (if possible)
//        if (can_switch) {
//            // Switching algorithm
//            simtime_t tSum = 0;
//            for (int i = 0; i < packetTimeArrayLength; i++) {
//                tSum = tSum + packetTime[i];
//            }
//            double estimatedBitRate = (packetTimeArrayLength * video_packet_size_per_second[video_current_quality_index]) / tSum;
//            EV<< "---------------------> Bit rate estimation:\n";
//            EV<< "---------------------> Estimated bit rate = " << estimatedBitRate << "\n";
//            int qmax = video_packet_size_per_second.size() -1;
//            if (estimatedBitRate > video_packet_size_per_second[std::min(video_current_quality_index + 1, qmax)]) {
//                video_current_quality_index = std::min(video_current_quality_index + 1, qmax);
//                can_switch = false;
//            }
//        }
        // the next video fragment will be requested when the buffer gets some space, so nothing to do here.
        return;
    }

    // Algorithm to choose the video quality
    int num_qualities = video_packet_size_per_second.size(); // Number of possible quality classes
    int quality_range = (video_buffer_max_length-10)/(num_qualities - 1); //Range of the quality classes in terms of the place in buffer when the switch occurs

    if (can_switch) {
        if (video_buffer <= 10) {
            video_current_quality_index = 0;
        } else {                                            // Otherwise choose the quality according to the buffer length zone it fits into
            int quality_zone = ceil((double)(video_buffer - 10)/(double)quality_range);
            video_current_quality_index = quality_zone;
        }
        can_switch = false;
    }


    EV<< "---------------------> Buffer=" << video_buffer << "    min= " << video_buffer_min_rebuffering << "\n";           //EDIT!
    // Exit rebuffering state and continue the video playback
    EV << "numRequestsToSend = " << numRequestsToSend << "; video_playback_pointer = " << video_playback_pointer << endl;   //EDIT!

    if ((numRequestsToSend >= 0 && video_buffer >= video_buffer_min_rebuffering) || (numRequestsToSend == 0 && video_playback_pointer < video_duration) ) { //EDIT!
        if (!video_is_playing) {
            EV << "Video is not playing anymore..." << endl;
            video_is_playing = true;
            emit(DASH_video_is_playing_signal, video_is_playing);
            simtime_t d = simTime() + 1;   //M: This +1 is used to schedule video play event in one second
            cMessage *videoPlaybackMsg = new cMessage("playback");
            videoPlaybackMsg->setKind(MSGKIND_VIDEO_PLAY);
            scheduleAt(d, videoPlaybackMsg);
            //rescheduleOrDeleteTimer(d, MSGKIND_VIDEO_PLAY);
        }
    } else {
        EV << "We are changing the video quality index" << endl;    //EDIT!
        video_current_quality_index = std::max(video_current_quality_index - 1, 0);
    }

    if (numRequestsToSend > 0) {
        EV<< "reply arrived\n";

        if (timeoutMsg)
        {
            // Send new request
            simtime_t d = simTime();
            rescheduleOrDeleteTimer(d, MSGKIND_SEND);
        }
        int recvd = just_received_bytes;
        msgsRcvd++;
        bytesRcvd += recvd;
    }
    else if (socket.getState() == 6)                            //EDIT! //M: There is still a case somewhere that tries to close the socket even though it has been already closed.
    {                                                           //EDIT! //M: That's the reason for this if...
        EV << "Session seems to be closed already" << endl;     //EDIT!
    }                                                           //EDIT!
    else //M: Only close if the socket is not closed already!
    {
        EV << "reply to last request arrived, closing session\n";
        close();
    }
}

void TCPVideoStreamCliApp::socketClosed(int connId, void *ptr) {
    EV << "Socket closed. Connection id: " << connId << "\n";   //EDIT!
//    TCPBasicClientApp::socketClosed(connId, ptr);             //EDIT!
    TCPAppBase::socketClosed(connId, ptr);                      //EDIT!

    // Nothing to do here...
}

void TCPVideoStreamCliApp::socketFailure(int connId, void *ptr, int code) {
    EV << "Socket failure. Connection id: " << connId << "\n";  //EDIT!
//    TCPBasicClientApp::socketFailure(connId, ptr, code);      //EDIT!
    TCPAppBase::socketFailure(connId, ptr, code);               //EDIT!

    // reconnect after a delay
    if (timeoutMsg) {
        simtime_t d = simTime() + (simtime_t) par("reconnectInterval");
        rescheduleOrDeleteTimer(d, MSGKIND_CONNECT);
    }
}

void TCPVideoStreamCliApp::refreshDisplay() const
{
    char buf[64];
    sprintf(buf, "rcvd: %ld pks %ld bytes\nsent: %ld pks %ld bytes", msgsRcvd, bytesRcvd, msgsSent, bytesSent);
    getDisplayString().setTagArg("t", 0, buf);
}

}


