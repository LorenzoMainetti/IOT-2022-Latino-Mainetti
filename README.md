# IOT Project and Challenges - a.y. 2021-2022 
The repository is divided in the following two folders:
* [Project](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/tree/main/Project): containing the files related to the Smart Bracelets project

* [Challenges](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/tree/main/Challenges): containing the files related to the 4 challenges carried out during the semester

## Smart Bracalets Project
### Project Scope: 
You are requested to design, implement and test a software prototype for a smart bracelet. 
The bracelet is worn by a child and her/his parent to keep track of the child’s position and trigger alerts when a child goes too far.

The operation of the smart bracelet couple is as follows:
1. __Pairing__:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- broadcast a 20-char random key<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- upon reception of key checks whether the received random key is equal to the stored one<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- special message is transmitted to stop the pairing<br>
2. __Operation__:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- parent’s bracelet listens for messages and accepts only the ones coming from the child’s<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- child’s bracelet periodically transmits INFO messages<br>
3. __Alert__:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Upon reception of an INFO message, the parent’s bracelet reads it. If the kinematic status is FALLING, the bracelet displays a &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FALL alarm<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- if the parent’s bracelet does not receive any message, after one minute from the last received message, a MISSING alarm is sent &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;reporting the last position received

### Implementation Choices:
- TinyOS application -> [code](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/tree/main/Project/TinyOS)
- TOSSIM app simulation -> [log](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/blob/main/Project/simulation_log.txt)
- Node-RED alarm simulation -> [flow](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/blob/main/Project/node-RED%20flow.txt)

[Here](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/blob/main/Project/Project%20Report%20Smart%20Bracelets.pdf) is the project report.

## Challenges
### Challenge 1 - Sniffing
The scope of the challenge was to analyze the traffic with WireShark and answer a set of questions on COAP and MQTT protocols.

[Here](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/blob/main/Challenges/challenge_1%20Sniffing/Report%20Challenge%201.pdf) is the report.

### Challenge 2 - Node-RED
The scope of the challenge was to generate 100 messages from a provided CSV file and then sending them to the ThingSpeak channel using MQTT through a Node-RED simulation.

[Here](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/blob/main/Challenges/challenge_2%20Node-RED/Report%20Challenge%202.pdf) is the report.

### Challenge 3 - TinyOS & Node-RED
The scope of the challenge was to simulate a TinyOs device able to perform the division by three of a specific number (person code). Based on the remainder of this division, specific leds were turned on or off. In particular, remainder equal to zero toggles Led0 and so on. 

[Here](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/tree/main/Challenges/challenge_3%20TinyOS%20%2B%20Node-RED) is the code for the TinyOS application and the report.

### Challenge 4 - TinyOS & TOSSIM
The scope of the challenge was to simulate a TinyOS system made of two nodes communicating with each other. Node1 performs requests to Node2, where requests are identified by a counter. For each request, Node2 takes a value from a fake sensor and sends it back to Node1 inserting the counter in the response. This way the response can be associated with a request. Nodes require acks to make sure the receiver received the message. The simulation was done using TOSSIM.

[Here](https://github.com/LorenzoMainetti/IOT-2022-Latino-Mainetti/tree/main/Challenges/challenge_4%20TinyOS%20%2B%20TOSSIM) is the code for the TinyOS application and the report.

## Group Members
- [__Alberto Latino__](https://github.com/albertolatino)
- [__Lorenzo Mainetti__](https://github.com/LorenzoMainetti)
