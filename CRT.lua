--[[
	Welcome to DCS-CRT (Carrier Recovery Tool)
	
	This tool allows for automatic detection of weather conditions, visibility, time of day/night, and based on that, it provides you with two options:
		- Managment of MOOSE AIRBOSS, with this tool you can automaticaly set recowery window for any weather conditions (except dynamic weather due to DCS limitations). 
		Coastline detection and aviodance. It also manages things like TACAN, ICLS, Link4, EPLRS, Wind Over Deck and other Airboss/Moose features see below

		- Displaying information on which CASE should currently be executed and the reason for this decision.

	Contact / Support
	If you need support or if you like to contribute, contact me [Discord] Bartek16194.

	See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release.
	
]]

--VERSION: 2.1

----[[ ##### SCRIPT CONFIGURATION ##### ]]----

carrier_MOOSE_airboss = false

carrier_unit_name = "CVN71"
carrier_airboss_name = "Roosevelt"
carrier_morse_code = "ROS"
carrier_tacan = 1
carrier_tacan_mode = "X"
carrier_icls = true
	carrier_icls_channel = 1
carrier_link4 = true
	carrier_link4_freq = 336
carrier_acls = true
carrier_EPLRS = true
carrier_SetMenuSmokeZones = false
carrier_SetMenuMarkZones = false
carrier_SetMarshalRadio = 127.500
carrier_SetLSORadio = 127.500
carrier_SetDefaultPlayerSkill = AIRBOSS.Difficulty.Easy
carrier_SetAirbossNiceGuy = true

carrier_holdingoffset = {-30,-15,0,15,30} --only in CASE 3

----[[ ##### End of SCRIPT CONFIGURATION ##### ]]----

carrier_detour_arrow = nil
message_time = 20

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
	--MESSAGE:New("night = " .. tostring(night), message_time):ToAll()
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
	MESSAGE:New(tostring("CRT - CASE: " .. CASE), message_time):ToAll()
	MESSAGE:New(tostring("CRT - REASON: " .. REASON), message_time):ToAll()
	end
	
	return CASE
end

function carrier_on()
	myAirboss=AIRBOSS:New(carrier_unit_name, carrier_airboss_name)
	myAirboss:SetTACAN(carrier_tacan, carrier_tacan_mode, carrier_morse_code)
	if carrier_icls == true then myAirboss:SetICLS(carrier_icls_channel, carrier_morse_code) end
	--myAirboss:SetPatrolAdInfinitum(carrier_SetPatrolAdInfinitum)
	myAirboss:SetMenuSmokeZones(carrier_SetMenuSmokeZones)
	myAirboss:SetMenuMarkZones(carrier_SetMenuMarkZones)
	myAirboss:SetMarshalRadio(carrier_SetMarshalRadio)
	myAirboss:SetLSORadio(carrier_SetLSORadio)
	myAirboss:SetDefaultPlayerSkill(carrier_SetDefaultPlayerSkill)
	myAirboss:SetAirbossNiceGuy(carrier_SetAirbossNiceGuy)
	myAirboss:SetStaticWeather(env.mission.weather.atmosphere_type)
	myAirboss:SetSoundfilesFolder("Airboss Soundfiles/")
	myAirboss:SetMenuSingleCarrier(true)
	myAirboss:Start()
	carrier = NAVYGROUP:New(UNIT:FindByName(carrier_unit_name):GetGroup())
	carrier:SetDefaultEPLRS(carrier_EPLRS)
	
	local carrier_unit = UNIT:FindByName(carrier_unit_name)
	if carrier_link4 == true then carrier_unit:CommandActivateLink4(carrier_link4_freq, nil, carrier_morse_code) end
	if carrier_acls == true then carrier_unit:CommandActivateACLS(carrier_morse_code) end

	recovery_scheduler(myAirboss)
end

function calculateNewHeading(currentHeading)
	--local heading_offsets = {15,25,30,40,45,50,55,60,70,-15,-25,-30,-40,-45,-50,-55,-60,-70}
	local heading_offsets = {15,25,-15,-25}

	if currentHeading > 180 then
        newHeading = currentHeading - 180
    else
        newHeading = currentHeading + 180
	end
  
  if newHeading > 180 then
        newHeading = newHeading - 15
    else
        newHeading = newHeading + 15
    end
  
	--print("Dla currentHeading - "..currentHeading.." = "..newHeading)
	return newHeading
end

function detour()
	--remove current waypoint to overwrite it by new detour destination
	carrier:RemoveWaypointByID(carrier:GetWaypointIndexAfterID(carrier:GetWaypointCurrentUID()))
	carrier:RemoveWaypointByID(carrier:GetWaypointCurrentUID())
	
	--get current heading and add some possible offset to it
	local heding3=calculateNewHeading(carrier:GetHeading())
	MESSAGE:New(tostring("CRT - New heading - "..heding3), message_time):ToAll()


	--new position calculation
	local current_position = carrier:GetCoordinate()
	
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

function recovery_scheduler(carrier_instance)
	local sunrise = tostring( UTILS.SecondsToClock(select(2, IsNight()), true) )
	local sunset = tostring( UTILS.SecondsToClock(select(3, IsNight()), true) )
	local current_time = tostring( UTILS.SecondsToClock(timer.getAbsTime(), true) )

	if recovery_function_schedule then
	timer.removeFunction(recovery_function_schedule) 
	recovery_function_schedule = nil
	end
	days = math.floor(timer.getAbsTime() / 86400)
	
	if current_time > sunrise and current_time < sunset then --after sunrise but before sunset
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(  timer.getAbsTime()+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(3, IsNight()), true).."+"..days+0), weather_case_factor(false), nil, true,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(select(3, IsNight())+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(2, IsNight()), true).."+"..days+1), 3, math.random(1,#carrier_holdingoffset), true,25,true)
		
		recovery_function_schedule = timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+select(2, IsNight())) )		
	elseif current_time > sunrise and current_time > sunset then --after sunrise and sunset
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(  timer.getAbsTime()+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(2, IsNight()), true).."+"..days+1), 3, math.random(1,#carrier_holdingoffset), true,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(select(2, IsNight())+330, true).."+"..days+1),tostring( UTILS.SecondsToClock(select(3, IsNight()), true).."+"..days+1), weather_case_factor(false), nil, true,25,true)
		
		recovery_function_schedule = timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+select(3, IsNight())) )
	else --before sunrise
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(  timer.getAbsTime()+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(2, IsNight()), true).."+"..days+0), 3, math.random(1,#carrier_holdingoffset), true,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(select(2, IsNight())+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(3, IsNight()), true).."+"..days+0), weather_case_factor(false), nil, true,25,true)
		carrier_instance:AddRecoveryWindow(tostring(UTILS.SecondsToClock(select(3, IsNight())+330, true).."+"..days+0),tostring( UTILS.SecondsToClock(select(2, IsNight()), true).."+"..days+1), 3, math.random(1,#carrier_holdingoffset), true,25,true)
			
		recovery_function_schedule = timer.scheduleFunction(recovery_scheduler, carrier_instance,(timer.getTime()+(86400-timer.getAbsTime())+select(2, IsNight())) )
	end  
		
	detour_ongoing = false
	
	if carrier_detour_arrow ~= nil then
		trigger.action.removeMark(carrier_detour_arrow)
		carrier_detour_arrow = nil
	end
		
	MESSAGE:New(tostring("CRT - Resuming Recovery"), message_time):ToAll()
	
	function carrier:OnAfterCollisionWarning(From, Event, To)
		local reshedule
		--remove detour mark from previous if another collision detected
		if carrier_detour_arrow ~= nil then
			trigger.action.removeMark(carrier_detour_arrow)
			carrier_detour_arrow = nil
		end
	
		--delete all recoveries ongoing
		myAirboss:DeleteAllRecoveryWindows(2)
		--disable timer for recovery_scheduler
		if recovery_function_schedule ~= nil then
			timer.removeFunction(recovery_function_schedule) 
			recovery_function_schedule = nil
		end
		--plan new route
		timer.scheduleFunction(detour, nil, timer.getTime()+5)	
		
		
		if env.mission.weather.wind.atGround.speed == 0 then
			reshedule = 60*5
		else
			reshedule = 60*60
		end
		
		--new scheduler to fire up after detour
		recovery_function_schedule = timer.scheduleFunction(recovery_scheduler, myAirboss, timer.getTime()+(reshedule))
		
		if detour_ongoing == false then
			MESSAGE:New(tostring("CRT - Carrier Coastline Collision possible\nScheduling next recovery in "..UTILS.SecondsToClock(reshedule, true)), message_time):ToAll()
		end
		
		
		detour_ongoing = true
	end	
end

if carrier_MOOSE_airboss == true then
	timer.scheduleFunction(carrier_on, nil, timer.getTime() + 1)
	weather_case_factor(true)
	MESSAGE:New("Carrier Recovery Tool (CRT) - Managing carrier: "..carrier_unit_name.."\n if config is correct you should get new radio item in 'Others'", message_time):ToAll()
else
	weather_case_factor(true)
	MESSAGE:New("Carrier Recovery Tool (CRT) - No carrier set in config\nTool will not manage any carrier and only will show what CASE should be conducted in mission.", message_time):ToAll()
end
MENU_MISSION_COMMAND:New("Carrier Recovery Tool (CRT) - What CASE?", nil, weather_case_factor,true)
