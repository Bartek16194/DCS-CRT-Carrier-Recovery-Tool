--[[
	Welcome to DCS-CRT (Carrier Recovery Tool)
	
	This tool allows for automatic detection of weather conditions, visibility, time of day/night, and based on that, it provides you with two options:
		- Managment of MOOSE AIRBOSS, with this tool you can automaticaly set recowery window for any weather conditions (except dynamic weather due to DCS limitations). 
		It also manages things like TACAN, ICLS, Wind Over Deck and other Airboss features see manual
		- Displaying information on which CASE should currently be executed and the reason for this decision.

	Installation
	### Prerequisites
	[latest MOOSE](https://github.com/FlightControl-Master/MOOSE/releases)

		Adding script into mission
		- First make sure MOOSE is loaded.
		- Load CRT.lua after MOOSE using a second trigger with a "TIME MORE" (**minimum 1 sec after moose**) and a DO SCRIPT of CRT.lua.		

	Moose Airboss integration Setup

	If you want to use integration with Moose Airboss, you need to set the at least two values in the CRT.lua, with the two most important ones being:
	- `carrier_MOOSE_airboss` - boolean (true/false)
	- `carrier_unit_name` - string (carrier unit name in DCS, NOT GROUP)
	- Below that you can also set most common things in config section

	**Remember if you set `carrier_MOOSE_airboss` to true you need to fill `carrier_unit_name`** 

	Change other values or leave them at default. Reffer to [Moose guide](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airboss.html) for more. 
	For more customization see function `carrier_on()`.

	Contact / Support
	If you need support or if you like to contribute, jump into my [Discord](https://discord.gg/yYs9HSq).

	See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release.
	
	Changelog: 
	1.0
	-Initial Release only with CASE selector
	
	2.0
	-Moose Airboss Integration 
	
	2.1
	-Coastline detection and aviodance
	
]]

--VERSION: 2.1

----[[ ##### SCRIPT CONFIGURATION ##### ]]----

carrier_MOOSE_airboss = true

carrier_unit_name = "Grupa CVN-71-1"
carrier_airboss_name = "Roosevelt"
carrier_morse_code = "ROS"
carrier_tacan = 1
carrier_tacan_mode = "X"
carrier_icls = 1
carrier_SetPatrolAdInfinitum = false
carrier_SetMenuSmokeZones = false
carrier_SetMenuMarkZones = false
carrier_SetMarshalRadio = 127.500
carrier_SetLSORadio = 127.500
carrier_SetDefaultPlayerSkill = AIRBOSS.Difficulty.Easy
carrier_SetAirbossNiceGuy = true


carrier_holdingoffset = {-30,-15,0,15,30} --only in CASE 3
carrier_turnintowind = true

----[[ ##### End of SCRIPT CONFIGURATION ##### ]]----

carrier_detour_arrow = nil


function IsNight()
	local zero_point = COORDINATE:NewFromVec2({0,0})
	local sunset = zero_point:GetSunset(true)-1800
	local sunrise = zero_point:GetSunrise(true)+1800
	local night 
	
	if (timer.getAbsTime() > sunset) or (timer.getAbsTime() < sunrise) then --NOC 
		night = true
	else
		night = false
	end	
	--MESSAGE:New("night = " .. tostring(night), 10):ToAll()
return night,sunrise,sunset
end

function CloudInfo()
local clouds = env.mission.weather.clouds
local clouddens = clouds.density
local temperature = env.mission.weather.season.temperature

local cloudspreset = clouds.preset or "Nothing"

local precepitation = 0 -- Precepitation: 0=None, 1=Rain, 2=Thunderstorm, 3=Snow, 4=Snowstorm.

	if cloudspreset=="Preset1" then
		-- Light Scattered 1
		clouddens = 1
	elseif cloudspreset=="Preset2" then
		-- Light Scattered 2
		clouddens = 1
	elseif cloudspreset=="Preset3"  then
		-- High Scattered 1
		clouddens = 4
	elseif cloudspreset=="Preset4"  then
		-- High Scattered 2
		clouddens = 4
	elseif cloudspreset=="Preset5"  then
		-- Scattered 1
		clouddens = 4
	elseif cloudspreset=="Preset6"  then
		-- Scattered 2
		clouddens = 4
	elseif cloudspreset=="Preset7"  then
		-- Scattered 3
		clouddens = 4
	elseif cloudspreset=="Preset8"  then
		-- High Scattered 3
		clouddens = 4
	elseif cloudspreset=="Preset9"  then
		-- Scattered 4
		clouddens = 4
	elseif cloudspreset=="Preset10"  then
		-- Scattered 5
		clouddens = 4
	elseif cloudspreset=="Preset11"  then
		-- Scattered 6
		clouddens = 4
	elseif cloudspreset=="Preset12"  then
		-- Scattered 7
		clouddens = 4
	elseif cloudspreset=="Preset13"  then
		-- Broken 1
		clouddens = 7
	elseif cloudspreset=="Preset14"  then
		-- Broken 2
		clouddens = 7
	elseif cloudspreset=="Preset15"  then
		-- Broken 3
		clouddens = 7
	elseif cloudspreset=="Preset16"  then
		-- Broken 4
		clouddens = 7
	elseif cloudspreset=="Preset17"  then
		-- Broken 5
		clouddens = 7
	elseif cloudspreset=="Preset18"  then
		-- Broken 6
		clouddens = 7
	elseif cloudspreset=="Preset19"  then
		-- Broken 7
		clouddens = 7
	elseif cloudspreset=="Preset20"  then
		-- Broken 8
		clouddens = 7
	elseif cloudspreset=="Preset21"  then
		-- Overcast 1
		clouddens = 9
	elseif cloudspreset=="Preset22"  then
		-- Overcast 2
		clouddens = 9
	elseif cloudspreset=="Preset23"  then
		-- Overcast 3
		clouddens = 9
	elseif cloudspreset=="Preset24"  then
		-- Overcast 4
		clouddens = 9
	elseif cloudspreset=="Preset25"  then
		-- Overcast 5
		clouddens = 9
	elseif cloudspreset=="Preset26"  then
		-- Overcast 6
		clouddens = 9
	elseif cloudspreset=="Preset27"  then
		-- Overcast 7
		clouddens = 9
	elseif cloudspreset=="RainyPreset"  then
		-- Overcast + Rain
		clouddens = 9
		if temperature > 5 then
			precepitation = 1 -- rain
		else
			precepitation = 3 -- snow
		end
	elseif cloudspreset=="RainyPreset1"  then
		-- Overcast + Rain
		clouddens = 9
		if temperature > 5 then
			precepitation = 1 -- rain
		else
			precepitation = 3 -- snow
		end
	elseif cloudspreset=="RainyPreset2"  then
		-- Overcast + Rain
		clouddens = 9
		if temperature > 5 then
			precepitation = 1 -- rain
		else
			precepitation = 3 -- snow
		end
	elseif cloudspreset=="RainyPreset3"  then
		-- Overcast + Rain
		clouddens = 9
		if temperature > 5 then
			precepitation = 1 -- rain
		else
			precepitation = 3 -- snow
		end
	else --if weather done by preset "NOTHING"
		clouddens = clouds.density
		precepitation = clouds.iprecptns
	end
	
return precepitation,clouddens

end 

function weather_case_factor(show_info)
    local weather = env.mission.weather
    --local visibility = UTILS.Round(weather.visibility.distance / 1852,2) --NM //broken
    local base = weather.clouds.base*3.281
    local CASE = 3
    local REASON
	local clouddens = select(2, CloudInfo())
	local precepitation = select(1, CloudInfo())
	
	local fog_visibility = UTILS.Round(weather.fog.visibility / 1852,2) --NM
	
	--local dust = weather.dust_density  --//seems no effect at all
	
    local dynamic_weather = weather.atmosphere_type 
	
	if (select(1, IsNight()) == false and dynamic_weather == 0) or (IsNight() == true and show_info == false) then	-- is DAY and not dynamic_weather
		REASON = "\n-Not night\n-Disabled dynamic_weather\n"
		if precepitation == 0 or (fog_visibility > 5 and fog_visibility ~=0 ) then --no RAIN/SNOW and no FOG
			REASON = REASON.."-No rain/snow\n-No fog\n"
			if base > 3000 then 
				REASON = REASON.."-Clouds base over 3000ft\n"
				CASE = 1 -- BASE +3000FT
			elseif base < 3000 and base > 1000 then
				REASON = REASON.."-Clouds base below 3000ft but over 1000ft\n"
				if clouddens > 4 then
					REASON = REASON.."-Clouds density over 4/10\n"
					CASE = 2 -- CLOUDY
				else
					REASON = REASON.."-Clouds density below 4/10\n"
					CASE = 1 -- NOT SO CLOUDY
				end
			else
				REASON = REASON.."-Clouds base below 1000ft\n"
				CASE = 3 -- BASE -1000FT
			end
		else -- RAIN/SNOW or FOG
			if base > 1000 and (fog_visibility > 5 and fog_visibility ~=0 ) then 
				REASON = REASON.."-Clouds base above 1000ft\n -No fog\n"
				CASE = 2 -- BASE +1000FT and fog_visibility +5NM
			else	
				CASE = 3 -- BASE -1000FT or FOG / rain
				REASON = REASON.."-Clouds base below 1000ft"
			end
		end
	else
		CASE = 3 -- NIGHT
		REASON = "\n-Night or enabled dynamic_weather\n"
	end
	
	if show_info == true then
	MESSAGE:New(tostring("CRT - CASE: " .. CASE), 10):ToAll()
	MESSAGE:New(tostring("CRT - REASON: " .. REASON), 10):ToAll()
	end
	
	return CASE
end

function carrier_on()
	myAirboss=AIRBOSS:New(carrier_unit_name, carrier_airboss_name)
	myAirboss:SetTACAN(carrier_tacan, carrier_tacan_mode, carrier_morse_code)
	myAirboss:SetICLS(carrier_icls, carrier_morse_code)
	--myAirboss:SetPatrolAdInfinitum(carrier_SetPatrolAdInfinitum)
	myAirboss:SetMenuSmokeZones(carrier_SetMenuSmokeZones)
	myAirboss:SetMenuMarkZones(carrier_SetMenuMarkZones)
	myAirboss:SetMarshalRadio(carrier_SetMarshalRadio)
	myAirboss:SetLSORadio(carrier_SetLSORadio)
	myAirboss:SetDefaultPlayerSkill(carrier_SetDefaultPlayerSkill)
	myAirboss:SetAirbossNiceGuy(carrier_SetAirbossNiceGuy)
	myAirboss:SetStaticWeather(env.mission.weather.atmosphere_type)
	myAirboss:SetSoundfilesFolder("Airboss Soundfiles/")
	myAirboss:Start()
	carrier = NAVYGROUP:New(UNIT:FindByName(carrier_unit_name):GetGroup())
	recovery_scheduler(myAirboss)
end

function randomMultiplier()
	return math.random()
end

--[[function calculateNewHeading(currentHeading)
	local randomMultiplier = randomMultiplier()
	currentHeading = currentHeading + (45 or -45 or 60 or -60 or 75 or -75 ) % 360 -- Zastosuj modulo 360 przed mnożeniem
	local newHeading = currentHeading * randomMultiplier
	newHeading = newHeading % 360 -- Zastosuj modulo 360 po mnożeniu

	if newHeading>180 then
		newHeading = newHeading - 180
	else
		newHeading = newHeading + 180
	end
	return newHeading
end]]

function calculateNewHeading(currentHeading)
	local heading_offsets = {15,25,30,40,45,50,55,60,70,-15,-25,-30,-40,-45,-50,-55,-60,-70}
	local newHeading = currentHeading - 180 + math.random(1,#heading_offsets)

	if currentHeading < 0 then
		newHeading = 360 - newHeading
	else
		newHeading = newHeading
	end
	return newHeading
end

function detour()
	--remove current waypoint to overwrite it by new detour destination
	carrier:RemoveWaypointByID(carrier:GetWaypointIndexAfterID(carrier:GetWaypointCurrentUID()))
	carrier:RemoveWaypointByID(carrier:GetWaypointCurrentUID())
	
	--get current heading and add some possible offset to it
	local heding3=calculateNewHeading(carrier:GetHeading())
	MESSAGE:New(tostring("CRT - New heading - "..heding3), 300):ToAll()


	--new position calculation
	local current_position = GROUP:FindByName("Grupa CVN-71"):GetCoordinate()
	
	local current_position_altered= current_position:Translate( UTILS.NMToMeters( 35 ), heding3)
	
	local new_destination = ZONE_RADIUS:New(tostring(timer.getAbsTime()), current_position_altered:GetVec2(), 100, false)

	carrier:AddWaypoint(new_destination:GetCoordinate(), 100, nil, nil, true)
	carrier_detour_arrow = current_position_altered:GetCoordinate():TextToAll("Carrier detour destination", -1,{1,0,0}, 0.6,{1,1,1}, 0.3, 20, true)

	--carrier:RemoveWaypointByID(1)
	carrier:MarkWaypoints(86400)
	carrier:SetPatrolAdInfinitum(false)
	carrier:Cruise(100)
end

local detour_ongoing
local recovery_scheduler_function

function recovery_scheduler(carrier_instance)
	local sunrise = tostring( UTILS.SecondsToClock(select(2, IsNight()), true) )
	local sunset = tostring( UTILS.SecondsToClock(select(3, IsNight()), true) )
	local current_time = tostring( UTILS.SecondsToClock(timer.getAbsTime(), true) )
	local first_recovery = tostring( UTILS.SecondsToClock(timer.getAbsTime()+330, true) )
	local sunrise_raw = select(2, IsNight())
	local sunset_raw = select(3, IsNight())

	if current_time > sunrise and current_time < sunset then --after sunrise but before sunset
		carrier_instance:AddRecoveryWindow(first_recovery,sunset, weather_case_factor(false), nil, carrier_turnintowind,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(sunset_raw+330, true)),sunrise.."+1", 3, math.random(1,#carrier_holdingoffset), carrier_turnintowind,25,true)
		
		timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+sunrise_raw) )		
	elseif current_time > sunrise and current_time > sunset then --after sunrise and sunset
		carrier_instance:AddRecoveryWindow(first_recovery,sunrise.."+1", 3, math.random(1,#carrier_holdingoffset), carrier_turnintowind,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(sunrise_raw+330, true)).."+1",sunset.."+1", weather_case_factor(false), nil, carrier_turnintowind,25,true)
		
		timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+sunset_raw) )
	else --before sunrise
		carrier_instance:AddRecoveryWindow(first_recovery,sunrise, 3, math.random(1,#carrier_holdingoffset), carrier_turnintowind,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(sunrise_raw+330, true)),sunset, weather_case_factor(false), nil, carrier_turnintowind,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(sunset_raw+330, true)),sunrise.."+1", 3, math.random(1,#carrier_holdingoffset), carrier_turnintowind,25,true)
			
		timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+sunrise_raw) )
	end  
		
	detour_ongoing = false
	
	if carrier_detour_arrow ~= nil then
		trigger.action.removeMark(carrier_detour_arrow)
		carrier_detour_arrow = nil
	end
		
	MESSAGE:New(tostring("CRT - Resuming Recovery"), 300):ToAll()
	
	function carrier:OnAfterCollisionWarning(From, Event, To)
		myAirboss:DeleteAllRecoveryWindows(2)
		
		timer.scheduleFunction(detour, nil, timer.getTime()+5)
		
		if carrier_detour_arrow ~= nil then
			trigger.action.removeMark(carrier_detour_arrow)
			carrier_detour_arrow = nil
		end
		
		if detour_ongoing == true then
			timer.removeFunction(recovery_scheduler_function)
		else
		MESSAGE:New(tostring("CRT - Carrier Coastline Collision possible\nScheduling next recovery in "..UTILS.SecondsToClock(60*60, true)), 300):ToAll()
		end
		
		recovery_scheduler_function = timer.scheduleFunction(recovery_scheduler, myAirboss, timer.getTime()+(60*60))
		detour_ongoing = true
	end	
end

if carrier_MOOSE_airboss == true then
	timer.scheduleFunction(carrier_on, nil, timer.getTime() + 1)
	weather_case_factor(true)
	MESSAGE:New("Carrier Recovery Tool - Managing carrier: "..carrier_unit_name.."\n if config is correct you should get new radio item in 'Others'", 30):ToAll()
else
	weather_case_factor(true)
	MESSAGE:New("Carrier Recovery Tool - No carrier set in config\nTool will not manage any carrier and only will show what CASE should be conducted in mission.", 30):ToAll()
end
MENU_MISSION_COMMAND:New("CRT - What CASE?", nil, weather_case_factor,true)
