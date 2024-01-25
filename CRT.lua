--[[
    Carrier Recovery Tool

    
	Tool allows for determining which CASE should be currently executed in the mission. It takes into account factors such as:
	-Time of day and 30-minute additional times before and after night
	-Cloud base
	-Visibility
	
	Due to DCS limitations:
	-It allows the CASE 2 when cloud coverage is less than 6/10.
	-It does not allow the execution of CASE 1, despite potential visibility above 5 miles, due to the lack of a method to determine visibility during precipitation.

	See https://github.com/Bartek16194/DCS-CRT-Carrier-Recovery-Tool for a user manual and the latest release

	Contributors:
		- Bartek16194 - https://github.com/Bartek16194/
		
	Contact / Support
	If you need support or if you like to contribute, jump into my [Discord](https://discord.gg/yYs9HSq).
]]

--VERSION: 1.0

function IsNight()
	local zero_point = COORDINATE:NewFromVec2({0,0})
	local sunset = zero_point:GetSunset(true)
	local sunrise = zero_point:GetSunrise(true)
	local night 
	
	if (timer.getAbsTime() < sunrise+1800) then
		night = true
	end
	if (timer.getAbsTime() > sunrise+1800) then
		night = false
	end
	if (timer.getAbsTime() > sunset-1800) then
		night = true
	end	
	
return night
end

function CloudInfo()
local clouds = env.mission.weather.clouds
local clouddens = clouds.density

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

function weather_case_factor()
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
	
	if IsNight() == false and dynamic_weather == 0 then	-- is DAY and not dynamic_weather
		REASON = "\n-Not night\n-Disabled dynamic_weather\n"
		if precepitation == 0 or (fog_visibility > 5 and fog_visibility ~=0 ) then --no RAIN/SNOW and no FOG
			REASON = REASON.."-No rain/snow\n-No fog\n"
			if base > 3000 then 
				REASON = REASON.."-Clouds base over 3000ft\n"
				CASE = 1 -- BASE +3000FT
			elseif base < 3000 and base > 1000 then
				REASON = REASON.."-Clouds base below 3000ft but over 1000ft\n"
				if clouddens > 6 then
					REASON = REASON.."-Clouds density over 6/10\n"
					CASE = 2 -- CLOUDY
				else
					REASON = REASON.."-Clouds density below 6/10\n"
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
	
	MESSAGE:New(tostring("CASE: " .. CASE), 10):ToAll()
	MESSAGE:New(tostring("REASON: " .. REASON), 10):ToAll()
	
end

weather_case_factor()

MENU_MISSION_COMMAND:New("CRT - What CASE?", nil, weather_case_factor)