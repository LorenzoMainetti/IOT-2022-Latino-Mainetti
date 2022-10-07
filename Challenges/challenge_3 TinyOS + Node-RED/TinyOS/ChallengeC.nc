#include "printf.h"

module ChallengeC {
    uses interface Leds;
    uses interface Boot;
    uses interface Timer<TMilli> as Timer;
}

implementation {
	uint32_t person_code = 10600138;
	uint8_t remainder = 0; 
	bool led0 = 0;
	bool led1 = 0;
	bool led2 = 0;


    event void Boot.booted() {
         call Timer.startPeriodic( 60000 );   
    }
    
	event void Timer.fired() {
	 	
	 	if(person_code!=0) {
	 	
		 	remainder = person_code%3;
		 	person_code = person_code/3;
		 	
		 	if(remainder==0){
		 		call Leds.led0Toggle();
		 	
			 	if(led0==0) {
			 		led0 = 1;
			 	}
			 
			 	else {
			 		led0 = 0;
			 	}
		 	}
		 	
		 	else if (remainder==1) {
		 		call Leds.led1Toggle();
		 		
			 	if(led1==0) {
			 		led1 = 1;
			 	}
			 
			 	else {
			 		led1 = 0;
			 	}
		 	}
		 	
		 	else {
		 		call Leds.led2Toggle();
		 		
			 	if(led2==0){
			 		led2 = 1;
			 	}
		 
			 	else {
			 		led2 = 0;
			 	}
		 	
		 	}
		 	
		 	printf("%u,%u,%u\n",led0,led1,led2);
		 	
	 	}

	 	else {
	 		call Timer.stop();
	 	}
		        
	}
         

}
