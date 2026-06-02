local function CheckLoadPlayerSpellsFrame()
	if not PlayerSpellsFrame then
		PlayerSpellsFrame_LoadUI();
	end
end


--------------------------- Script Command Helpers --------------------------------

-- These utils require going through the Class Talent Frame to ensure the UI can manage and react to change flows correctly.
-- This global code is just provided so that it's not required to manually open the Talents window once before being able to use these in macros.

ClassTalentHelper = {};

RegisterEventCallback("CLASS_TALENTS_SWITCH_TO_LOADOUT_BY_NAME", function(_nilOwner, loadoutName)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame.TalentsFrame:LoadConfigByName(loadoutName);
end);

RegisterEventCallback("CLASS_TALENTS_SWITCH_TO_LOADOUT_BY_INDEX", function(_nilOwner, loadoutIndex)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame.TalentsFrame:LoadConfigByIndex(loadoutIndex);
end);

RegisterEventCallback("CLASS_TALENTS_SWITCH_TO_SPECIALIZATION_BY_NAME", function(_nilOwner, specName)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame.SpecFrame:ActivateSpecByName(specName);
end);

RegisterEventCallback("CLASS_TALENTS_SWITCH_TO_SPECIALIZATION_BY_INDEX", function(_nilOwner, specIndex)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame.SpecFrame:ActivateSpecByIndex(specIndex);
end);

-- Loads loadout for the current specialization by name. Loads the first one found in the case of duplicate names.
function ClassTalentHelper.SwitchToLoadoutByName(loadoutName)
	C_ClassTalents.SwitchToLoadoutByName(loadoutName);
end

-- Loads loadout for the current specialization by dropdown index. Indices start at 1.
function ClassTalentHelper.SwitchToLoadoutByIndex(loadoutIndex)
	C_ClassTalents.SwitchToLoadoutByIndex(loadoutIndex);
end

-- Activates specialization for the current class by spec name.
function ClassTalentHelper.SwitchToSpecializationByName(specName)
	C_ClassTalents.SwitchToSpecializationByName(specName);
end

-- Activates specialization for the current class by index in the order within the Specializations tab. Indices start at 1.
function ClassTalentHelper.SwitchToSpecializationByIndex(specIndex)
	C_ClassTalents.SwitchToSpecializationByIndex(specIndex);
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

ChatFrameUtil.ImportAllListsToHash();
