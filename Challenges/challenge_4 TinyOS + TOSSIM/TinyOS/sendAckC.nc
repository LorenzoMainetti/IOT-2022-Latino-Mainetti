/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
    interface Receive;
    interface AMSend;
    interface PacketAcknowledgements;
    
	//interface for timer
	interface Timer<TMilli> as MilliTimer;
	
    //other interfaces, if needed
    interface SplitControl;
    interface Packet;
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t x=9;
  uint8_t counter=0;
  uint8_t rec_id;
  uint8_t rec_ack_count;
  message_t packet;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  void sendReq() {
	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
  	my_msg_t* msg = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
  	if (msg == NULL) {
		return;
  	}
  	msg->msg_type = REQ;
  	msg->counter = counter;
  	msg->value = 0;	
  	
	if (call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {	
		//Ack requested
	}
  	
  	if (call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet");	
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
    }
 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raises the event read done.
  	 */
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	call SplitControl.start(); 
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    if (err == SUCCESS) {
      dbg("radio","Radio on on node %d!\n", TOS_NODE_ID);
      if ( TOS_NODE_ID == 1 ) {
      	call MilliTimer.startPeriodic(1000);
	  }
    }
    else {
      dbgerror("radio", "Radio failed to start, retrying...\n");
      call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    dbg("boot", "Radio stopped!\n");
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 */
	counter++;
    dbg("timer", "Timer fired, counter is %hu.\n", counter);

   	sendReq();
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf, error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
	 if (&packet == buf) {
	    dbg("radio_ack", "Send done");
     	dbg_clear("radio_rec", " at time %s \n", sim_time_string());
     	
     	if(call PacketAcknowledgements.wasAcked(&packet)) {
     	    dbg("radio_ack", "Received ack");
     		dbg_clear("radio_ack", " at time %s \n", sim_time_string());
     		
     		if(TOS_NODE_ID == 1) {
     		    rec_ack_count++;
     			if(rec_ack_count == x) {
		    		call MilliTimer.stop();
		    		printf("Counter reached max\n");
				}
     		}
     	}
     } 
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf, void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
	 if (len != sizeof(my_msg_t)) {
	 	return buf;
	 }
     else {
     	my_msg_t* msg = (my_msg_t*)payload;
     	dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
     	
     	dbg_clear("radio_pack","\t\t Payload \n" );
        dbg_clear("radio_pack", "\t\t msg_type: %hhu \n", msg->msg_type);
        dbg_clear("radio_pack", "\t\t counter: %hhu \n", msg->counter); 
        dbg_clear("radio_pack", "\t\t value: %hhu \n", msg->value); 
     	
     	if (msg->msg_type == REQ) {
     	    rec_id = msg->counter;
     		sendResp();
     	}
     	else {
     		//error: message is not of type REQUEST
     	}
     	return buf;
     }
  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 
	my_msg_t* msg = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
  	if (msg == NULL) {
		return;
  	}
  	msg->msg_type = RESP;
  	msg->counter = rec_id;
  	msg->value = data;	
  	
	if (call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {	
	    //Ack requested
	}
  	
  	if (call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet");	
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
    }
  }
  
}
  
  

