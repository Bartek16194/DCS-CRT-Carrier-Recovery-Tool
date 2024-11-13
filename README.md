# Welcome to DCS-CRT (Carrier Recovery Tool)  
This tool allows for automatic detection of weather conditions, visibility, time of day/night, and based on that, it provides you with two options:<br> <br>

**Management of MOOSE AIRBOSS**, with this tool you can automatically set recovery windows for any weather conditions (except dynamic weather due to DCS limitations). **Coastline detection and avoidance.** It also manages things like TACAN, ICLS, Link4, EPLRS, Wind Over Deck, and other Airboss/Moose features (see below).<br>  

**Displaying information on which CASE should currently be executed** and the reason for this decision.<br>  

# In-game usage without managing carrier  
Select 'Other' from the comms menu, and then choose 'CRT - What CASE?'<br>  
You will see which CASE should be executed and the reason for that:<br>  

![Zrzut ekranu 2024-01-25 020543](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/5e116716-bb02-4ec1-800e-ff28d3b42b13)  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/9518c3a2-38b8-40f4-969a-b4303d821aa5)  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/a79ae9d6-858c-4bec-a5eb-de0360728f08)  

# In-game usage with MOOSE Airboss carrier  
Same as standard MOOSE Airboss with additional features:  
- Automatic management of recovery windows<br>  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/2deba06e-66a6-415a-b548-d069e490f13f)  
- Automatic coastline detection and avoidance!  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/914c2da3-7ecd-41cd-8f1c-d8a110a63594)<br>  

Landing windows are determined after launching the Airboss; the first window begins when the script is called, and next windows are added as the current list ends.<br>  

If CASE 1/2 conditions are met, it will persist until 30 minutes before sunset. In the case of CASE 3, it will last continuously in adverse weather and during the night until 30 minutes after sunrise, mirroring real-world procedures.<br>  

# Installation  
### Prerequisites  
[latest MOOSE](https://github.com/FlightControl-Master/MOOSE/releases)<br>  

### Adding script into mission  
- First, make sure MOOSE is loaded.  
- Load CRT.lua after MOOSE using a second trigger with a "TIME MORE" (**minimum 1 sec after MOOSE**) and a DO SCRIPT of CRT.lua.<br>  

# Moose Airboss integration setup  
If you want to use integration with Moose Airboss, you need to set at least two values in the CRT.lua, with the two most important ones being:  
- `carrier_MOOSE_airboss` - boolean (true/false)  
- `carrier_unit_name` - string (carrier unit name in DCS, NOT GROUP)  

![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/bf8a98be-2b6a-47ef-b4ab-433da582fe6e)<br><br>  

- Below that, you can also set the most common things like:  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/36a9dff7-80df-4221-af46-6c627469e448)<br>  

**Remember, if you set `carrier_MOOSE_airboss` to true, you need to fill `carrier_unit_name`**. Change other values or leave them at default. Refer to the [Moose guide](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airboss.html) for more. For more customization, see the function `carrier_on()`.<br>  

### Mission Editor setup  
In the mission editor:  
- Carrier must be the first unit in the group, preferably the only one to avoid path crossing during turns.  
- Carrier must not have any waypoints set.  
- Speed should be set to the maximum value possible to enter.  
- You don't need any actions on waypoint zero because the script overrides them.  
- Carrier should be positioned on the map in such a way that it cannot encounter the map boundary while moving into the wind, especially in missions lasting several days. The collision detection with the coastline doesn't recognize map boundaries.<br>  

Example ME correct setup: (Wind from 030, 8 kts)  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/bdee1503-07bd-46a4-8254-7bb1783a2ac3)<br>  

Example ME incorrect setup: (Map boundary marked by purple; carrier will be stuck when it meets the map limit)  
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/824fa4f9-091e-410c-b3cf-e3ab39410ded)<br>  

## Due to DCS limitations  
Due to limitations in DCS, specifically the lack of an effective method for dynamically determining visibility range:  
- For CASE 1, the rule is that if cloud coverage is below 4/10 between cloud base altitudes above 1000 FT and below 3000 FT, CASE 1 is allowed.  
- In the presence of atmospheric precipitation, CASE 2 or 3 will always apply depending on the cloud base altitude.  
- Dynamic weather is not supported, and in such cases, the script will only select CASE 3.<br>  

## Contact / Support  
If you need support, contact me on Discord: bartek16194  
See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release.
