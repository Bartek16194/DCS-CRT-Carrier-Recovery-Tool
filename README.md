

# Welcome to DCS-CRT (Carrier Recovery Tool)
 <br>
This tool allows for automatic detection of weather conditions, visibility, time of day/night, and based on that, it provides you with two options:<br>
<br>

**Managment of MOOSE AIRBOSS**, with this tool you can automaticaly set recowery window for any weather conditions (except dynamic weather due to DCS limitations). It also manages things like TACAN, ICLS, Wind Over Deck and other Airboss features see below<br>

**Displaying information on which CASE should currently be executed** and the reason for this decision.<br>

# In game usage without managing carrier
Select 'Other' from the comms menu, and then choose 'CRT - What CASE?'<br>

You will see what CASE should be executed and reason for that:<br>

![Zrzut ekranu 2024-01-25 020543](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/5e116716-bb02-4ec1-800e-ff28d3b42b13)
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/9518c3a2-38b8-40f4-969a-b4303d821aa5)
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/a79ae9d6-858c-4bec-a5eb-de0360728f08)
# In game usage with MOOSE Airboss carrier
Same as standard MOOSE Airbos with additional features:
- Automatic managment of recovery windows<br>

![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/2deba06e-66a6-415a-b548-d069e490f13f)<br>
Landing windows are determined after launching the Airboss; first window begins when script is called, and next windows are added as the current list ends. <br>

If CASE 1/2 conditions are met, it will persist until 30 minutes before sunset. In the case of CASE 3, it will last continuously in adverse weather and during the night until 30 minutes after sunrise, mirroring real-world procedures.

# Installation
### Prerequisites
[latest MOOSE](https://github.com/FlightControl-Master/MOOSE/releases)

### Adding script into mission
- First make sure MOOSE is loaded.
- Load CRT.lua after MOOSE using a second trigger with a "TIME MORE" (**minimum 1 sec after moose**) and a DO SCRIPT of CRT.lua.<br>
<br>		

# Moose Airboss integration Setup

If you want to use integration with Moose Airboss, you need to set the at least two values in the CRT.lua, with the two most important ones being:
- `carrier_MOOSE_airboss` - boolean (true/false)
- `carrier_unit_name` - string (carrier unit name in DCS, NOT GROUP)
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/bf8a98be-2b6a-47ef-b4ab-433da582fe6e)<br><br>

- Below that you can also set most common things like:
![image](https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool/assets/30091139/1e190183-6e2e-4967-a127-264ca4c72f4f)

**Remember if you set `carrier_MOOSE_airboss` to true you need to fill `carrier_unit_name`** 

Change other values or leave them at default. Reffer to [Moose guide](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airboss.html) for more. 
For more customization see function `carrier_on()`.


## Due to DCS limitations:
Due to limitations in DCS, specifically the lack of an effective method for dynamically determining visibility range:

-   For CASE 2, the rule is that if the cloud coverage is below 6/10 between cloud base altitudes above 1000FT and below 3000FT, CASE 2 is allowed.
-   In the presence of atmospheric precipitation, CASE 2 or 3 will always apply depending on the cloud base altitude.
-   Dynamic weather is not supported, and in such cases, the script will only select CASE 3.

## Contact / Support
If you need support or if you like to contribute, jump into my [Discord](https://discord.gg/yYs9HSq).

See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release.
