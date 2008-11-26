
SOUND_MASTERVOLUME_STEP = 0.1;

local tonumber = tonumber;
local GetCVar = GetCVar;
local SetCVar = SetCVar;


function Sound_ToggleMusic()
	if ( GetCVar("Sound_EnableMusic") == "0" ) then
		SetCVar("Sound_EnableMusic", 1);
	else
		SetCVar("Sound_EnableMusic", 0);
	end
end

function Sound_ToggleSound()
	if ( GetCVar("Sound_EnableSFX") == "0" ) then
		SetCVar("Sound_EnableSFX", 1);
		SetCVar("Sound_EnableAmbience", 1);
	else
		SetCVar("Sound_EnableSFX", 0);
		SetCVar("Sound_EnableAmbience", 0);
	end
end

function Sound_MasterVolumeUp()
	local volume = tonumber(GetCVar("Sound_MasterVolume"));
	if ( volume ) then
		SetCVar("Sound_MasterVolume", volume + SOUND_MASTERVOLUME_STEP);
	end
end

function Sound_MasterVolumeDown()
	local volume = tonumber(GetCVar("Sound_MasterVolume"));
	if ( volume ) then
		SetCVar("Sound_MasterVolume", volume - SOUND_MASTERVOLUME_STEP);
	end
end
