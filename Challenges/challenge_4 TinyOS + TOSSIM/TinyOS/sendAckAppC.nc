/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;
  components new TimerMilliC() as MilliTimer;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new FakeSensorC();
  components ActiveMessageC;
  
/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC.Acks; //ActiveMessageC (?)
  
  //Radio Control
  App.SplitControl -> ActiveMessageC;

  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  
  //Timer interface
  App.MilliTimer -> MilliTimer;
  
  //Fake Sensor read
  App.Read -> FakeSensorC;

}

