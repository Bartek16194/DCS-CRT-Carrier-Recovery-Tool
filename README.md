# Welcome to DCS-CRT (Carrier Recovery Tool)
 
Tool allows for determining which CASE should be currently executed in the mission. It takes into account factors such as:
-Time of day and 30-minute additional times before and after night
-Cloud base
-Visibility

Due to DCS limitations:
-It allows the CASE 2 when cloud coverage is less than 6/10.
-It does not allow the execution of CASE 1, despite potential visibility above 5 miles, due to the lack of a method to determine visibility during precipitation.

### Installation
## Prerequisites
[Only latest MOOSE](https://github.com/FlightControl-Master/MOOSE/releases)

## Adding into mission
First make sure MOOSE is loaded, either as an Initialization Script for the mission or the first DO SCRIPT with a "TIME MORE" of 1. "TIME MORE" means run the actions after X seconds into the mission.

Load the CRT a few seconds after MOOSE using a second trigger with a "TIME MORE" and a DO SCRIPT of CRT.lua.

### Contributors:
- Bartek16194 - https://github.com/Bartek16194/
		
## Contact / Support
If you need support or if you like to contribute, jump into my [Discord](https://discord.gg/yYs9HSq).

See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release.