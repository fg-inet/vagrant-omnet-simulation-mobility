package inet.applications.tcpapp;
import inet.applications.contract.ITCPApp;

simple LocationLogger like ITCPApp {
    
    parameters:
        double loggingFrequency @unit(s) = default(0.1s); // Location logging interval
        
        // Position statistics
        @signal[XLocation](type="double");
        @statistic[XLocation](title="Node location on the X axis"; record=vector);
        @signal[YLocation](type="double");
        @statistic[YLocation](title="Node location on the Y axis"; record=vector);
    gates:
        input tcpIn @labels(TCPCommand/up);
        output tcpOut @labels(TCPCommand/down);
}