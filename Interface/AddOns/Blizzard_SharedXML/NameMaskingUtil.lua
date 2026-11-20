NameMaskingUtil = {};

local NAME_UNMASKED_CHARACTER_COUNT = 3;
local NAME_MASK_CHARACTER = "*";
-- Used for names with embedded escape sequences (such as protected Battle.net names), which can't be partially masked safely.
local NAME_MASK_FALLBACK = "*****";

-- Keeps the first characters of the name and replaces the rest with asterisks, preserving the character count.
function NameMaskingUtil.MaskName(name)
	-- Some names contain markup that would disrupt the masking logic (BattleTags kstrings, class color markup, etc.).  In those cases we fallback to a default masking string.
	if string.find(name, "|", 1, true) then
		return NAME_MASK_FALLBACK;
	end

	local maskedName = {};
	local characterCount = 0;
	-- Matches one UTF-8 encoded character at a time so multi-byte names keep their character count.
	for character in string.gmatch(name, "[%z\1-\127\194-\244][\128-\191]*") do
		characterCount = characterCount + 1;
		if characterCount <= NAME_UNMASKED_CHARACTER_COUNT then
			table.insert(maskedName, character);
		else
			table.insert(maskedName, NAME_MASK_CHARACTER);
		end
	end

	return table.concat(maskedName);
end

function NameMaskingUtil.IsMaskingEnabled(cvar)
	-- The player's own BattleTag masking is independent of streamerMode and streamerNameMasking.
	if cvar == "playerBattleTagNameMasking" then
		return CVarCallbackRegistry:GetCVarValueBool(cvar);
	end

	if not (CVarCallbackRegistry:GetCVarValueBool("streamerMode") and CVarCallbackRegistry:GetCVarValueBool("streamerNameMasking") and CVarCallbackRegistry:GetCVarValueBool(cvar)) then
		return false;
	end

	return true;
end

function NameMaskingUtil.GetNameMaskingCVar(friendLevel, isSelf)
	-- The player's own BattleTag is controlled separately from other players' names.
	if isSelf then
		return "playerBattleTagNameMasking";
	end

	if friendLevel == Enum.BattleNetFriendLevel.RealID then
		return "realIDNameMasking";
	elseif friendLevel == Enum.BattleNetFriendLevel.Title then
		return nil;
	end

	-- A missing friend level (non-friends, or no account info) is treated as BattleTag, since the displayed name falls back to it.
	return "battleTagNameMasking";
end
