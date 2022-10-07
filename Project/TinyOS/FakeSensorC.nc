
 
generic configuration FakeSensorC() {

	provides interface Read<char>;

} implementation {

	components MainC;
	components new FakeSensorP();
	components new TimerMilliC();
	
	//Connects the provided interface
	Read = FakeSensorP;
	
	//Timer interface	
	FakeSensorP.Timer0 -> TimerMilliC;

}
