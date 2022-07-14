local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

-- ============================================================================================================
-- Helper Functions
-- ============================================================================================================
TutorialHelper = {};

-- ------------------------------------------------------------------------------------------------------------
-- get the Player's Race
function TutorialHelper:GetRace()
	local _, race = UnitRace("player");
	return race;
end

-- ------------------------------------------------------------------------------------------------------------
-- get the Player's Faction
function TutorialHelper:GetFaction()
	return (UnitFactionGroup("player"));
end

-- ------------------------------------------------------------------------------------------------------------
-- get the Player's Class
function TutorialHelper:GetClass()
	local _, class = UnitClass("player");
	return class;
end

-- ------------------------------------------------------------------------------------------------------------
-- get the Player's Race
function TutorialHelper:IsMeleeClass()
	local class = TutorialHelper:GetClass();
	if class == "WARRIOR" or class == "ROGUE" or class == "PALADIN" or class == "MONK" then
		return true;
	end
	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:FormatString(str)
	-- Spell Names and Icons e.g. {$1234}
	str = string.gsub(str, "{%$(%d+)}", function(spellID)
			local name, _, icon = GetSpellInfo(spellID);
			--return string.format("|cFF00FFFF%s|r |T%s:16|t", name, icon);
			return string.format("|cFF00FFFF%s|r", name);
		end);

	-- Spell Keybindings e.g. {KB|1234}
	str = string.gsub(str, "{KB|(%d+)}", function(spellID)
			local bindingString;

			if (spellID) then
				local btn = self:GetActionButtonBySpellID(tonumber(spellID));
				if (btn) then
					bindingString = GetBindingKey("ACTIONBUTTON" .. btn.action);
				end
			end

			return string.format("%s", bindingString or "?");
		end);

	-- Atlas icons e.g. {Atlas|NPE_RightClick:16}
	str = string.gsub(str, "{Atlas|([%w_-]+):?(%d*)}", function(atlasName, size)
				size = tonumber(size) or 0;
				return CreateAtlasMarkup(atlasName, size, size);
			end);

	return str;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetClassString(key)
	local classStr = _G[key .. "_" .. self:GetClass()];
	if (classStr and (classStr ~= nil)) then
		return classStr;
	end

	return _G[key];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetRacialData()
	return TutorialData[self:GetRace()];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetFactionData()
	return TutorialData[self:GetFaction()];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetItemContainerFrame(container, slot)
	local frameIndex = (GetContainerNumSlots(container) + 1) - slot;
	if (container == 0 and not IsAccountSecured()) then
		frameIndex = frameIndex + 4;
	end
	return _G["ContainerFrame" .. (container + 1) .. "Item" .. frameIndex];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:CloseAllBags()
	if IsBagOpen(0) then
		CloseBackpack()
	end

	for i = 1, NUM_BAG_FRAMES, 1 do
		if IsBagOpen(i) then
			CloseBag(i);
		end
	end
end

function TutorialHelper:OpenAllBags()
	if not IsBagOpen(0) then
		OpenBackpack()
	end

	for i = 1, NUM_BAG_FRAMES, 1 do
		if not IsBagOpen(i) then
			OpenBag(i);
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Takes a potential table of ID's keyed by player class and returns the appropriate one
-- if the set is not a table, the single item is returned
function TutorialHelper:FilterByClass(set)
	if (type(set) == "table") then
		return set[self:GetClass()];
	end

	return set;
end

-- ------------------------------------------------------------------------------------------------------------
-- Takes a potential table of ID's keyed by player class and returns the appropriate one
-- if the set is not a table, the single item is returned
function TutorialHelper:FilterByRace(set)
	if (type(set) == "table") then
		return set[self:GetRace()];
	end

	return set;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetBundleByQuestID(questID)
	local data = self:GetRacialData().MultiQuestPickup;

	if (not data) then return nil; end

	-- a bundle is a table of quests that should be picked up together
	for bk, bundle in pairs(data) do
		-- quest raw is either a quest or a set of quests keyed by class
		for qk, questRaw in pairs(bundle) do
			local quest = self:FilterByClass(questRaw);
			-- see if this bundle contains the quest
			if (quest == questID) then
				return bundle;
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:IsQuestCompleteOrActive(questID)
	local questComplete = C_QuestLog.IsQuestFlaggedCompleted(questID);
	local questActive = C_QuestLog.GetLogIndexForQuestID(questID) ~= nil;
	return questComplete or questActive;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:DoQuestsInBundleNeedPickup(questBundle)
	if (type(questBundle) ~= "table") then
		return nil;
	end

	for i, questRaw in ipairs(questBundle) do
		local questID = self:FilterByClass(questRaw);
		if (not self:IsQuestCompleteOrActive(questID)) then
			return true;
		end
	end

	return false;
end

local actionBars = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton"}
function TutorialHelper:FindEmptyButton(optionalPreferredActionBar)
	if optionalPreferredActionBar then
		for i = 1, 12 do
			local btn = _G[optionalPreferredActionBar .. i];
			if btn then
				local _, sID = GetActionInfo(btn.action);
				if not sID then
					return btn;
				end
			end
		end
	end

	for i, actionBar in pairs(actionBars) do
		for i = 1, 12 do
			local btn = _G[actionBar .. i];
			if btn then
				local _, sID = GetActionInfo(btn.action);
				if not sID then
					return btn;
				end
			end
		end
	end
end

function TutorialHelper:GetActionButtonBySpellID(spellID)
	if (type(spellID) ~= "number") then return nil; end

	for actionBarIndex, actionBar in pairs(actionBars) do
		for i = 1, 12 do
			local btn = _G[actionBar .. i];
			if btn and btn.action then
				local actionType, sID, subType = GetActionInfo(btn.action);

				if (sID == spellID) then
					return btn;
				elseif (actionType == "flyout" and FlyoutHasSpell(sID, spellID)) then
					return btn;
				end
			end
		end
	end

	-- backup for stance bars
	for i = 1, 10 do
		local btn = _G["StanceButton" .. i];
		local icon, isActive, isCastable, sID = GetShapeshiftFormInfo(btn:GetID());

		if (sID == spellID) then
			return btn;
		end
	end

	return nil;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetGossipBindIndex()
	local gossipOptions = C_GossipInfo.GetOptions();
	for i, optionInfo in ipairs(gossipOptions) do
		if optionInfo.type == "binder" then
			return i;
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- returns the x and y offset from the gossip frames TOPRIGHT point
function TutorialHelper:GetFrameButtonEdgeOffset(frame, button)
	local posY = -100;
	local posX = 0;

	if (button) then
		posY = button:GetTop() - frame:GetTop() - (button:GetHeight() / 2);

		local fontString = button:GetFontString();
		if (fontString) then
			posX = -(frame:GetRight() - fontString:GetLeft() - fontString:GetStringWidth());
		else
			posX = -(frame:GetRight() - button:GetLeft() - button:GetWidth());
		end
	end

	return math.min(-50, posX), posY;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:FindItemInContainer(itemID)
	for containerIndex = 0, 4 do
		local slots = GetContainerNumSlots(containerIndex);
		if (slots > 0) then
			for slotIndex = 1, slots do
				local id = select(10, GetContainerItemInfo(containerIndex, slotIndex));
				if (id == itemID) then
					return containerIndex, slotIndex;
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetMapBinding()
	return GetBindingKey("TOGGLEWORLDMAP") or "";
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetCharacterBinding()
	return GetBindingKey("TOGGLECHARACTER0") or "";
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetBagBinding()
	return GetBindingKey("OPENALLBAGS") or "";
end

function TutorialHelper:GetCreatureIDFromGUID(guid)
	return tonumber(string.match(guid, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
end
