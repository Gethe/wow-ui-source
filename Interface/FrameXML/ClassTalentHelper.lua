-- These utils require going through the Class Talent Frame to ensure the UI can manage and react to change flows correctly.
-- This global code is just provided so that it's not required to manually open the Talents window once before being able to use these in macros.

local function CheckLoadTalentFrame()
	if not ClassTalentFrame then
		ClassTalentFrame_LoadUI();
	end
end


--------------------------- Script Command Helpers --------------------------------

ClassTalentHelper = {};

-- Loads loadout for the current specialization by name. Loads the first one found in the case of duplicate names.
function ClassTalentHelper.SwitchToLoadoutByName(loadoutName)
	CheckLoadTalentFrame();
	ClassTalentFrame.TalentsTab:LoadConfigByName(loadoutName);
end

-- Loads loadout for the current specialization by dropdown index. Indices start at 1.
function ClassTalentHelper.SwitchToLoadoutByIndex(loadoutIndex)
	CheckLoadTalentFrame();
	ClassTalentFrame.TalentsTab:LoadConfigByIndex(loadoutIndex);
end

-- Activates specialization for the current class by spec name.
function ClassTalentHelper.SwitchToSpecializationByName(specName)
	CheckLoadTalentFrame();
	ClassTalentFrame.SpecTab:ActivateSpecByName(specName);
end

-- Activates specialization for the current class by index in the order within the Specializations tab. Indices start at 1.
function ClassTalentHelper.SwitchToSpecializationByIndex(specIndex)
	CheckLoadTalentFrame();
	ClassTalentFrame.SpecTab:ActivateSpecByIndex(specIndex);
end

--------------------------- Slash Command Helpers --------------------------------

SlashCmdList["TALENT_LOADOUT_BY_NAME"] = function(msg)
	local loadoutName = SecureCmdOptionParse(msg);
	if loadoutName and loadoutName ~= "" then
		ClassTalentHelper.SwitchToLoadoutByName(loadoutName);
	end
end

SlashCmdList["TALENT_LOADOUT_BY_INDEX"] = function(msg)
	local loadoutIndex = SecureCmdOptionParse(msg);
	if loadoutIndex and loadoutIndex ~= "" then
		loadoutIndex = tonumber(loadoutIndex);
		if loadoutIndex then
			ClassTalentHelper.SwitchToLoadoutByIndex(loadoutIndex);
		end
	end
end

SlashCmdList["TALENT_SPEC_BY_NAME"] = function(msg)
	local specName = SecureCmdOptionParse(msg);
	if specName and specName ~= "" then
		ClassTalentHelper.SwitchToSpecializationByName(specName);
	end
end

SlashCmdList["TALENT_SPEC_BY_INDEX"] = function(msg)
	local specIndex = SecureCmdOptionParse(msg);
	if specIndex and specIndex ~= "" then
		specIndex = tonumber(specIndex);
		if specIndex then
			ClassTalentHelper.SwitchToSpecializationByIndex(specIndex);
		end
	end
end