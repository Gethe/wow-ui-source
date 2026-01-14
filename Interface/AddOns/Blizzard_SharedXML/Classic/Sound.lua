SOUND_MASTERVOLUME_STEP = 0.1;

function Sound_ToggleMusic()
	if ( GetCVar("Sound_EnableAllSound") == "0" ) then
		ActionStatus_DisplayMessage(SOUND_DISABLED, true);
	else
		if ( GetCVar("Sound_EnableMusic") == "0" ) then
			SetCVar("Sound_EnableMusic", 1);
			ActionStatus_DisplayMessage(MUSIC_ENABLED, true)
		else
			SetCVar("Sound_EnableMusic", 0);
			ActionStatus_DisplayMessage(MUSIC_DISABLED, true)
		end
	end
end

function Sound_ToggleSound()
	if ( GetCVar("Sound_EnableAllSound") == "0" ) then
		ActionStatus_DisplayMessage(SOUND_DISABLED, true);
	else
		if ( GetCVar("Sound_EnableSFX") == "0" ) then
			SetCVar("Sound_EnableSFX", 1);
			SetCVar("Sound_EnableAmbience", 1);
			SetCVar("Sound_EnableDialog", 1);
			ActionStatus_DisplayMessage(SOUND_EFFECTS_ENABLED, true);
		else
			SetCVar("Sound_EnableSFX", 0);
			SetCVar("Sound_EnableAmbience", 0);
			SetCVar("Sound_EnableDialog", 0);
			ActionStatus_DisplayMessage(SOUND_EFFECTS_DISABLED, true);
		end
	end
end

local function AdjustMasterVolume(amount)
	local volume = tonumber(GetCVar("Sound_MasterVolume"));
	if ( volume ) then
		volume = volume + amount;

		if ( volume > 1.0 ) then
			volume = 1.0;
		elseif ( volume < 0.0 ) then
			volume = 0.0;
		end

		SetCVar("Sound_MasterVolume", volume);
	end
end

function Sound_MasterVolumeUp()
	AdjustMasterVolume(SOUND_MASTERVOLUME_STEP);
end

function Sound_MasterVolumeDown()
	AdjustMasterVolume(-SOUND_MASTERVOLUME_STEP);
end
