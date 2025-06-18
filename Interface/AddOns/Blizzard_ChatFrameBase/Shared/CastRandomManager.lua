local _, addonTbl = ...;
local SecureCmdList = addonTbl.SecureCmdList;

local CastRandomManager;
local CastRandomTable = {};

local function CreateCanonicalActions(entry, ...)
	entry.spells = {};
	entry.spellNames = {};
	entry.spellID = {};
	entry.items = {};
	local count = 0;
	for i=1, select("#", ...) do
		local action = strlower(strtrim((select(i, ...))));
		if ( action and action ~="" ) then
			count = count + 1;
			if ( C_Item.GetItemInfo(action) or select(3, SecureCmdItemParse(action)) ) then
				local spellName, spellID = C_Item.GetItemSpell(action);
				entry.items[count] = action;
				entry.spells[count] = strlower(spellName or "");
				entry.spellNames[count] = entry.spells[count];
				entry.spellID[count] = spellID;
			else
				entry.spells[count] = action;
				entry.spellNames[count] = gsub(action, "!*(.*)", "%1");
				entry.spellID[count] = C_Spell.GetSpellIDForSpellIdentifier(action);
			end
		end
	end
end

local function CastRandomManager_OnEvent(self, event, ...)
	local unit, castID, spellID = ...;

	if ( unit == "player" ) then
		local name = strlower(C_Spell.GetSpellName(spellID));
		local rank = strlower(C_Spell.GetSpellSubtext(spellID) or "");
		local nameplus = name.."()";
		local fullname = name.."("..rank..")";
		for sequence, entry in pairs(CastRandomTable) do
			if ( entry.pending and entry.value ) then
				local entryName = strlower(entry.value);
				if ( entryName == name or entryName == nameplus or entryName == fullname ) then
					entry.pending = nil;
					if ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
						entry.value = nil;
					end
				end
			end
		end
	end
end

local function ExecuteCastRandom(actions)
	if ( not CastRandomManager ) then
		CastRandomManager = CreateFrame("Frame");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_FAILED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
		CastRandomManager:SetScript("OnEvent", CastRandomManager_OnEvent);
	end

	local entry = CastRandomTable[actions];
	if ( not entry ) then
		entry = {};
		CreateCanonicalActions(entry, strsplit(",", actions));
		CastRandomTable[actions] = entry;
	end
	if ( not entry.value ) then
		entry.value = entry.spellNames[random(#entry.spellNames)];
	end
	entry.pending = true;
	return entry.value;
end

SecureCmdList["CASTRANDOM"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local actions, target = SecureCmdOptionParse(msg);
	if ( actions ) then
		local action = ExecuteCastRandom(actions);
		local name, bag, slot = SecureCmdItemParse(action);
		if ( slot or C_Item.GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		else
			CastSpellByName(action, target);
		end
	end
end

SecureCmdList["USERANDOM"] = SecureCmdList["CASTRANDOM"];
