
#include "bracelet.h"

configuration braceletAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, braceletC as App;
  components new TimerMilliC() as PairingTimer;
  components new TimerMilliC() as OperationTimer;
  components new TimerMilliC() as AlertTimer;
  components new AMSenderC(AM_MSG);
  components new AMReceiverC(AM_MSG);
  components new FakeSensorC();
  components ActiveMessageC;
  
/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMPacket -> AMReceiverC;  
  App.AMSend -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC.Acks; 
  
  //Radio Control
  App.SplitControl -> ActiveMessageC;

  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  
  //Timer interface
  App.PairingTimer -> PairingTimer;
  App.OperationTimer -> OperationTimer;
  App.AlertTimer -> AlertTimer;
  
  //Fake Sensor read
  App.Read -> FakeSensorC;

}

