#include "stdlib.h"

generic module FakeSensorP() {

	provides interface Read<char>;
	
	uses interface Timer<TMilli> as Timer0;

} implementation {

	// 0: STANDING, 1: RUNNING, 2: WALKING, 3: FALLLING
    char distribution[10] = {'S', 'S', 'S', 'R', 'R', 'R', 'W', 'W', 'W', 'F'};

	//***************** Boot interface ********************//
	command error_t Read.read(){
		call Timer0.startOneShot(10);
		return SUCCESS;
	}

	//***************** Timer0 interface ********************//
	event void Timer0.fired() {
		signal Read.readDone(SUCCESS, distribution[rand()%10]);
	}
}
