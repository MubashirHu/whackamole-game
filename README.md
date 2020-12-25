# Whackamoleproject- 

The assembly file contains the main code for the overall functionality of the project. 

A video for the operation of the project is also included : https://youtu.be/bdDzNq3foCc 

The video covers the 5 states: 

1) Reset state- This state was achieved by contacting the on board reset button
2) Waiting state - In this state the micro-controller was displaying a certain pattern which shows the that it is waiting for user response
3) Playing state - This state is achieved on condition that the user has given response in the waiting state. While the MCU is in this state there is a random order or LED's that flash and the user is required to contact the corresponding switch before a timer on the LED expires.
4) Winning state - When the user has successfully beat all the levels defined there is a on and off flash displaying that he has won. After the flash the MCU then shows the user's proficiency level through the LED's.
5) Failed state - This state is entered based off of two conditions. First being that if the user makes contact with the wrong switch and the second condition is that if the timer runs out before any contact is made to the switches. Following that the score of the user will be displayed in binary from 0 to 15. The reason for this is that with the limitation of 4 LED's the maximum number that can be displayed would be 15.

6) extra: User settings
