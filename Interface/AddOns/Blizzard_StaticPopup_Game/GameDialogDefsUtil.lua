GameDialogDefsUtil = {};

function GameDialogDefsUtil.GetSelfResurrectDialogOptions()
	local resOptions = GetSortedSelfResurrectOptions();
	if ( resOptions ) then
		if ( IsEncounterLimitingResurrections() ) then
			return resOptions[1], resOptions[2];
		else
			return resOptions[1];
		end
	end
end

function GameDialogDefsUtil.OnResurrectButtonClick(selectedOption, reason)
	if ( reason == "override" ) then
		return;
	end
	if ( reason == "timeout" ) then
		return;
	end
	if ( reason == "clicked" ) then
		local found = false;
		local resOptions = C_DeathInfo.GetSelfResurrectOptions();
		if ( resOptions ) then
			for i, option in pairs(resOptions) do
				if ( option.optionType == selectedOption.optionType and option.id == selectedOption.id and option.canUse ) then
					C_DeathInfo.UseSelfResurrectOption(option.optionType, option.id);
					found = true;
					break;
				end
			end
		end
		if ( not found ) then
			RepopMe();
		end
		if ( CannotBeResurrected() ) then
			return true;
		end
	end
end

function GameDialogDefsUtil.GetDefaultExpirationText(dialog, data, timeleft)
	local dialogInfo = dialog.dialogInfo;
	local fmt = dialogInfo.text;
	if timeleft < 60 then
		return string.format(fmt, timeleft, SECONDS);
	else
		return string.format(fmt, ceil(timeleft / 60), MINUTES);
	end
end