
#include "bracelet.h"
#include "Timer.h"
#include "string.h"
#include "stdlib.h"

module braceletC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
    interface Receive;
    interface AMSend;
    interface AMPacket;
    interface PacketAcknowledgements;
    
	//interface for timer
	interface Timer<TMilli> as PairingTimer;
	interface Timer<TMilli> as OperationTimer;
	interface Timer<TMilli> as AlertTimer;
	
    //other interfaces, if needed
    interface SplitControl;
    interface Packet;
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<char>;
  }

} implementation {

  char mode = 'P';
  bool busy = FALSE;

  am_addr_t source_addr;
  message_t packet;
  
  uint8_t curr_x_pos;
  uint8_t curr_y_pos;

  void broadcastKey();
  void sendPairAck();
  void sendInfo();
  void displayAlarm(bool alarm_type);

  
  //***************** Send message functions ********************//
  void broadcastKey() {
  	if (!busy) {
  		pair_msg_t* msg = (pair_msg_t*)call Packet.getPayload(&packet, sizeof(pair_msg_t));
  		
	  	if (msg == NULL) {
			return;
	  	}
	   
		msg->type = KEY_MSG;
		strcpy(msg->key, RANDOM_KEY[TOS_NODE_ID/3]);
		
	  	if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(pair_msg_t)) == SUCCESS) {
			dbg("radio_send", "[PAIRING] Broadcasting key");	
			dbg_clear("radio_send", " at time %s \n", sim_time_string());
			busy = TRUE;
		}
  	}
  }  
  
  void sendPairAck() {	
  	if (!busy) {
  		pair_msg_t* msg = (pair_msg_t*)call Packet.getPayload(&packet, sizeof(pair_msg_t));
  		
  		if (msg == NULL) {
			return;
	  	}
	  	msg->type = PAIR_ACK;
	  	
		if (call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {	
			//Ack requested
		}
	  	
	  	if (call AMSend.send(source_addr, &packet, sizeof(pair_msg_t)) == SUCCESS) {
			dbg("radio_send", "[PAIRING] Sending pair ack");	
			dbg_clear("radio_send", " at time %s \n", sim_time_string());
			busy = TRUE;
		}	
  	} 
  }
  
  void sendInfo() {
  	/* This function is called when we the OperationTimer is fired.
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raises the event read done.
  	 */
	call Read.read();
  }
  
  
  //***************** Display alarm function ********************//
  void displayAlarm(bool alarm_type) {
	if (alarm_type == TRUE) {
		dbg("radio_display", "[ALERT] Displaying FALL ALARM message:\n");
		dbg_clear("radio_display", "\t\t x_pos: %hhu \n", curr_x_pos);
		dbg_clear("radio_display", "\t\t y_pos: %hhu \n", curr_y_pos);	
	}
	else {
		dbg("radio_display", "[ALERT] Displaying MISSING ALARM message:\n");
		dbg_clear("radio_display", "\t\t last x_pos received: %hhu \n", curr_x_pos);
		dbg_clear("radio_display", "\t\t last y_pos received: %hhu \n", curr_y_pos);	
	} 
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
      call PairingTimer.startPeriodic(10000);
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
  event void PairingTimer.fired() {
  	dbg("timer", "[PAIRING] Timer fired\n");
  	broadcastKey();
  }
  
  event void OperationTimer.fired() {
  	dbg("timer", "[OPERATION] Timer fired\n"); 
  	sendInfo();
  }
  
  event void AlertTimer.fired() {
  	dbg("timer", "[ALERT] Timer fired\n");
	displayAlarm(FALSE); 
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf, error_t err) {
  	busy = FALSE;
	 
	if (&packet == buf) {
		//dbg("radio_ack", "Send done");
	 	//dbg_clear("radio_rec", " at time %s \n", sim_time_string());
	 		
	 	if(call PacketAcknowledgements.wasAcked(&packet)) {
	 	    dbg("radio_ack", "[PAIRING] Received ack");
	 		dbg_clear("radio_ack", " at time %s \n", sim_time_string());
	 		
	 		call PairingTimer.stop();
	 		mode = 'O';
	 		
	 		if (TOS_NODE_ID%2 == 0) {
	 			//child
	 			call OperationTimer.startPeriodic(10000);
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
	 
	 if (len != sizeof(pair_msg_t) && len != sizeof(pos_msg_t)) {
	 	return buf;
	 }
     else {
		 if (mode == 'P') {
			pair_msg_t* msg = (pair_msg_t*)payload;	
		 	
		 	if (msg->type == KEY_MSG) {

		 		if (strcmp(msg->key, RANDOM_KEY[TOS_NODE_ID/3]) == 0) {
				 	dbg("radio_rec", "[PAIRING] Received matching key at time %s\n", sim_time_string());
					dbg_clear("radio_pack", "\t\t key: %s \n", msg->key);
					
			 	    source_addr = call AMPacket.source(buf);
			 	  
			 		sendPairAck();
		 		}
		 		else {
		 			//error: message has different key from stored one
		 		}	
		 	}
		 	else if (msg->type == PAIR_ACK) {
		 		dbg("radio_rec", "[PAIRING] Received pair ack at time %s\n", sim_time_string());
		 		//stop pairing
		 		call PairingTimer.stop();
		 		mode = 'O';
		 		
		 		if (TOS_NODE_ID%2 == 0) {
		 			//child
		 			call OperationTimer.startPeriodic(10000);
		 		}
     		}	 
		 }
		 else if (mode == 'O') {
		 	pos_msg_t* msg = (pos_msg_t*)payload;
		 	
		 	if (source_addr == call AMPacket.source(buf)) {
		 		//convert back int to char
		 		char status = msg->status + '0';
		 		
			 	dbg("radio_rec", "[OPERATION] Received INFO message at time %s\n", sim_time_string());
			 	
			 	dbg_clear("radio_pack","\t\t Payload \n" );
				dbg_clear("radio_pack", "\t\t status: %c \n", status); 
				dbg_clear("radio_pack", "\t\t x_pos: %hhu \n", msg->x_pos);
				dbg_clear("radio_pack", "\t\t y_pos: %hhu \n", msg->y_pos);	 
				
				curr_x_pos = msg->x_pos;
				curr_y_pos = msg->y_pos;
				
				if (status == 'F') {
					displayAlarm(TRUE);
				}
				
				if (call AlertTimer.isRunning()) {
					call AlertTimer.stop();
				}
								
				call AlertTimer.startOneShot(60000);
		 	}
		 	else {
		 		//error: message is not sent form child node
		 	}	
	 
	 	 }
     	   	
     	return buf;
     }
  }
  
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, char data) {
	/* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 
	if (!busy) {
		pos_msg_t* msg = (pos_msg_t*)call Packet.getPayload(&packet, sizeof(pos_msg_t));
		
		if (msg == NULL) {
			return;
	  	}
	  	msg->type = INFO;		
	  	msg->status = data - '0'; //convert char to int
	  	//TODO pos from fakeSensor
	  	msg->x_pos = rand()%100;
	  	msg->y_pos = rand()%100;
	  	
	  	if (call PacketAcknowledgements.noAck(&packet) == SUCCESS) {	
			//Ack disabled
		}
	  	
	  	if (call AMSend.send(source_addr, &packet, sizeof(pos_msg_t)) == SUCCESS) {
			dbg("radio_send", "[OPERATION] Sending INFO message");	
			dbg_clear("radio_send", " at time %s \n", sim_time_string());
			busy = TRUE;
		}
	}	
  }
  
}
  
  

