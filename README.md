# Thermopi
Thermostat using Raspberry Pi to control wifi switches

## Project

The goal of this project was to regulate the temperature and energy use within my apartment while using 30+ year old air conditioning units that had no temperature regulation.

* Problem: The apartment would typically be quite warm because the ac units would lock up from condensation and need an hour to thaw before working again. They would also run most of the day for our cat so it was important that they continue working.
* Solution: Using a Raspberry Pi with thermometer leads on long wires, monitor the living room and bedroom temperatures. When the it gets too warm, turn on the AC units by sending messages over wifi directly to the wifi-enabled power switches that the units were connected to. Conversely, when the room is too cool, turn the AC units off to ensure they don't lock up from ice and condensation build up.
* Results: The project succeeded in keeping the temperature more consistent. And resulted in a drop of $100 in energy use.

Additional features included;
* Schedules for different rooms. For example, since our cat stayed in the bedroom. The livingroom could be warmer while we're at work, but cool off before we arrive home.
* An LCD display to show the current temperature including buttons to override the schedule and manually adjust the target temperature.

Challenges: To prevent the switches from turning off and on every few minutes, a range around the target has to be considered acceptable. For example, if the temperature is within 2 degrees, in either direction, continue current state. If outside of that range, turn off or on.

![Hardware](https://i.imgur.com/ZxpBHLr.jpg)
![Hardware2](https://i.imgur.com/GmYq5sD.jpg)
