#define NEW_PRINTF_SEMANTICS 
#include "printf.h"

configuration ChallengeAppC{ 
}

implementation {

components MainC, ChallengeC, LedsC;
components new TimerMilliC();
components SerialPrintfC;
components SerialStartC;

ChallengeC -> MainC.Boot;

ChallengeC.Timer -> TimerMilliC; 

ChallengeC.Leds -> LedsC;

}
