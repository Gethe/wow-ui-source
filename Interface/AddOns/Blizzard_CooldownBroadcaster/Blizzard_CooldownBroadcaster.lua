local ADDON_NAME, namespace = ...;
local ADDON_PREFIX = "CDSyncTR";

local MSG_INF, MSG_CD = "INF", "CD";
local MAX_COOLDOWNS = 6;
local MAX_ADDON_MESSAGE_LENGTH = 250;
local THIRD_DECIMAL = "%.3f";
local TRUNCATE_ZEROS = "%.?0+$";

local CooldownSyncRelayMixin = {};


local function PackRowsIntoMessages(rows, header)
	local headerLen = #header + 1; -- account for comma separator
	local messages = {};
	local pendingRows = {};
	for i = 1, #rows do
		local row = rows[i];
		local candidate;
		if #pendingRows == 0 then
			candidate = row;
		else
			candidate = table.concat(pendingRows, ",") .. "," .. row;
		end
		if headerLen + #candidate <= MAX_ADDON_MESSAGE_LENGTH then
			pendingRows[#pendingRows + 1] = row;
		else
			if #pendingRows > 0 then
				messages[#messages + 1] = table.concat(pendingRows, ",");
				table.wipe(pendingRows);
			end
			pendingRows[1] = row;
		end
	end
	if #pendingRows > 0 then
		messages[#messages + 1] = table.concat(pendingRows, ",");
	end
	return messages;
end

function CooldownSyncRelayMixin:GetSupportedTrackedSpells()
	local out = {};

	local racialTable = namespace.RacialCooldowns;
	if racialTable then
		local _, raceName = UnitRace("player");
		local racialEntry = racialTable[raceName];
		if racialEntry then
			local racialSpellID = racialEntry;
			if type(racialSpellID) == "table" then
				local _, className = UnitClass("player");
				racialSpellID = racialEntry[className];
			end
			if type(racialSpellID) == "number" then
				local isKnown = C_SpellBook.IsSpellKnown(racialSpellID);
				if isKnown then
					out[1] = racialSpellID;
				end
			end
		end
	end

	local specID = PlayerUtil.GetCurrentSpecID();
	if not specID then
		return out, 0;
	end
	local trackedBySpec = namespace.TrackedCooldownsBySpec;
	local spellList = trackedBySpec and trackedBySpec[specID];
	if type(spellList) ~= "table" then
		return out, specID;
	end
	local outLookup = {};
	for i = 1, #spellList do
		local spellID = spellList[i];
		if C_SpellBook.IsSpellKnown(spellID) then
			local baseSpellID = C_SpellBook.FindBaseSpellByID(spellID);
			local isOverride = baseSpellID and baseSpellID ~= spellID;
			if isOverride and outLookup[baseSpellID] then
				outLookup[baseSpellID] = nil;
				for j = #out, 1, -1 do
					if out[j] == baseSpellID then
						table.remove(out, j);
						break;
					end
				end
			end
			if not outLookup[spellID] then
				out[#out + 1] = spellID;
				outLookup[spellID] = true;
				if #out >= MAX_COOLDOWNS then
					break;
				end
			end
		end
	end

	return out, specID;
end

function CooldownSyncRelayMixin:GetChannel()
	local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil);
	if channel and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInGroup(LE_PARTY_CATEGORY_HOME) then
		channel = "INSTANCE_CHAT";
	end
	return channel;
end

function CooldownSyncRelayMixin:SendComm(msg, key)
	local channel = self:GetChannel();
	if not channel then
		return;
	end
	namespace.MessageQueue.Send(ADDON_PREFIX, msg, channel, nil, key);
end

function CooldownSyncRelayMixin:SendSpellInfoMessage()
	local list = self.spellOrder;
	if #list == 0 then
		return;
	end
	local specID = self.playerSpecID or 0;
	local parts = {};
	for i = 1, math.min(#list, MAX_COOLDOWNS) do
		parts[i] = tostring(list[i]);
	end
	local msg = strjoin(",", MSG_INF, specID, unpack(parts));
	self:SendComm(msg, MSG_INF);
end

function CooldownSyncRelayMixin:RefreshSpellData(list, specID)
	if not list then
		list, specID = self:GetSupportedTrackedSpells();
	end
	table.wipe(self.spellData);
	table.wipe(self.spellOrder);
	self.playerSpecID = specID;
	for i = 1, #list do
		local id = list[i];
		self.spellOrder[i] = id;
		self.spellData[id] = {
			start = 0,
			duration = 0,
			modRate = 1,
			charges = -1,
		};
	end
end

function CooldownSyncRelayMixin:HasTrackedSpellsChanged()
	local newSpellList, newSpecID = self:GetSupportedTrackedSpells();
	if newSpecID ~= (self.playerSpecID or 0) then
		return true, newSpellList, newSpecID;
	end
	local currentSpellList = self.spellOrder;
	if #newSpellList ~= #currentSpellList then
		return true, newSpellList, newSpecID;
	end
	for i = 1, #newSpellList do
		if newSpellList[i] ~= currentSpellList[i] then
			return true, newSpellList, newSpecID;
		end
	end
	return false;
end

function CooldownSyncRelayMixin:GetSpellCooldown(spellID)
	local cooldownInfo = C_Spell.GetSpellCooldown(spellID);
	if not cooldownInfo then
		return 0, 0, 1, -1;
	end

	local start = cooldownInfo.startTime;
	local duration = cooldownInfo.duration;
	local enabled = cooldownInfo.isEnabled;
	local modRate = cooldownInfo.modRate or 1;

	local chargeInfo = C_Spell.GetSpellCharges(spellID);
	local currentCharges = chargeInfo and chargeInfo.currentCharges;
	local maxCharges = chargeInfo and chargeInfo.maxCharges;
	local chargeCooldownStart = chargeInfo and chargeInfo.cooldownStartTime;
	local chargeCooldownDuration = chargeInfo and chargeInfo.cooldownDuration;
	local chargeModRate = chargeInfo and chargeInfo.chargeModRate;
	local charges = (maxCharges and maxCharges > 1) and currentCharges or -1;

	if maxCharges and currentCharges and maxCharges > currentCharges then
		return chargeCooldownStart, chargeCooldownDuration, chargeModRate or 1, charges;
	end

	if enabled then
		if start and start > 0 then
			if cooldownInfo.isOnGCD then
				return nil;
			end
			return start, duration, modRate, charges;
		end
	end

	return 0, 0, 1, charges;
end

function CooldownSyncRelayMixin:EnableSync()
	if self.syncEnabled then
		return;
	end
	self.syncEnabled = true;
	self:RefreshSpellData();
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UNIT_CONNECTION");
end

function CooldownSyncRelayMixin:DisableSync()
	if not self.syncEnabled then
		return;
	end
	self.syncEnabled = false;
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("UNIT_CONNECTION");
end

function CooldownSyncRelayMixin:ShouldSyncBeEnabled()
	return IsInGroup();
end

function CooldownSyncRelayMixin:GetOnlineGroupMemberGUIDs()
	local guidSet = {};
	local playerGUID = UnitGUID("player");
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local unit = "raid" .. i;
			local guid = UnitGUID(unit);
			if guid and guid ~= playerGUID and UnitIsConnected(unit) then
				guidSet[guid] = true;
			end
		end
	elseif IsInGroup() then
		for i = 1, GetNumSubgroupMembers() do
			local unit = "party" .. i;
			local guid = UnitGUID(unit);
			if guid and UnitIsConnected(unit) then
				guidSet[guid] = true;
			end
		end
	end
	return guidSet;
end

function CooldownSyncRelayMixin:UpdateSyncState()
	if self:ShouldSyncBeEnabled() then
		self:EnableSync();
	else
		self:DisableSync();
	end
end

function CooldownSyncRelayMixin:BuildSpellCooldownRows(filterSpellIDs, force)
	local now = GetTime();
	local rows = {};

	for _, id in ipairs(self.spellOrder) do
		local info = self.spellData[id];
		if info and (not filterSpellIDs or filterSpellIDs[id]) then
			local start, duration, modRate, charges = self:GetSpellCooldown(id);
			if start then
				local prevDuration = info.duration or 0;
				local prevModRate = info.modRate or 1;
				local prevCharges = info.charges or -1;
				local prevStart = info.start or 0;

				if duration == 0 then
					if force or prevDuration > 0 or charges ~= prevCharges then
						rows[#rows + 1] = table.concat({ tostring(id), "0", "0", "1", tostring(charges) }, ",");
					end

					info.start = start;
					info.duration = 0;
					info.modRate = modRate or 1;
					info.charges = charges;
				else
					local startChanged = start ~= prevStart;
					local durationChanged = duration ~= prevDuration;
					local modRateChanged = (modRate or 1) ~= prevModRate;
					local chargesChanged = charges ~= prevCharges;

					if force or startChanged or durationChanged or modRateChanged or chargesChanged then
						local remaining = math.max(0, start + duration - now);
						local payloadDuration = duration;
						local payloadModRate = modRate;
						local payloadRemaining = remaining;
						if modRate ~= 1 then
							payloadDuration = string.format(THIRD_DECIMAL, duration):gsub(TRUNCATE_ZEROS, "");
							payloadModRate = string.format(THIRD_DECIMAL, modRate):gsub(TRUNCATE_ZEROS, "");
							payloadRemaining = string.format(THIRD_DECIMAL, remaining):gsub(TRUNCATE_ZEROS, "");
						else
							payloadRemaining = math.floor(remaining);
						end

						rows[#rows + 1] = table.concat({
							tostring(id),
							tostring(payloadDuration),
							tostring(payloadRemaining),
							tostring(payloadModRate),
							tostring(charges),
						}, ",");
					end

					info.start = start;
					info.duration = duration;
					info.modRate = modRate;
					info.charges = charges;
				end
			end
		end
	end

	return rows;
end

function CooldownSyncRelayMixin:SendSpellCooldownMessage(filterSpellIDs, force)
	if not self.syncEnabled then
		return;
	end
	local rows = self:BuildSpellCooldownRows(filterSpellIDs, force);
	if #rows == 0 then
		return;
	end
	local messages = PackRowsIntoMessages(rows, MSG_CD);
	local key;
	if #messages == 1 and filterSpellIDs then
		local spellID;
		for id in pairs(filterSpellIDs) do
			if spellID then
				spellID = nil;
				break;
			end
			spellID = id;
		end
		if spellID then
			key = MSG_CD .. ":" .. spellID;
		end
	end
	for i = 1, #messages do
		local msg = strjoin(",", MSG_CD, messages[i]);
		self:SendComm(msg, key);
	end
end

function CooldownSyncRelayMixin:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	self.lastGroupGUIDs = self:GetOnlineGroupMemberGUIDs();
	self:UpdateSyncState();
	if self.syncEnabled and not isReloadingUi then
		self:SendSpellInfoMessage();
		self:SendSpellCooldownMessage();
	end
end

function CooldownSyncRelayMixin:GROUP_ROSTER_UPDATE()
	local currentGroupGUIDs = self:GetOnlineGroupMemberGUIDs();
	local hasNewMember = false;
	for guid in pairs(currentGroupGUIDs) do
		if not self.lastGroupGUIDs[guid] then
			hasNewMember = true;
			break;
		end
	end
	self.lastGroupGUIDs = currentGroupGUIDs;

	self:UpdateSyncState();
	if self.syncEnabled and hasNewMember and not self.pendingGroupUpdate then
		self.pendingGroupUpdate = true;
		C_Timer.After(0.5, function()
			self.pendingGroupUpdate = nil;
			if not self.syncEnabled then
				return;
			end
			self:SendSpellInfoMessage();
			self:SendSpellCooldownMessage(nil, true);
		end);
	end
end

function CooldownSyncRelayMixin:UNIT_CONNECTION(unit, isConnected)
	local guid = UnitGUID(unit);
	if guid and self.lastGroupGUIDs[guid] and not isConnected then
		self.lastGroupGUIDs[guid] = nil;
	end
end

function CooldownSyncRelayMixin:SPELLS_CHANGED()
	if self.pendingTalentRefresh then
		return;
	end
	self.pendingTalentRefresh = true;
	C_Timer.After(0.25, function()
		self.pendingTalentRefresh = nil;
		local changed, newList, newSpecID = self:HasTrackedSpellsChanged();
		if not changed then
			return;
		end
		self:RefreshSpellData(newList, newSpecID);
		self:UpdateSyncState();
		if not self.syncEnabled then
			return;
		end
		self:SendSpellInfoMessage();
		self:SendSpellCooldownMessage();
	end);
end

function CooldownSyncRelayMixin:SPELL_UPDATE_COOLDOWN(spellID, baseSpellID, category, startRecoveryCategory)
	if not self.syncEnabled then
		return;
	end

	if not spellID then
		self:SendSpellCooldownMessage();
		return;
	end

	local matchedSpellID;
	if self.spellData[spellID] then
		matchedSpellID = spellID;
	elseif baseSpellID and self.spellData[baseSpellID] then
		matchedSpellID = baseSpellID;
	end

	if matchedSpellID then
		self:SendSpellCooldownMessage({ [matchedSpellID] = true });
	end
end

function CooldownSyncRelayMixin:OnLoad()
	self.playerSpecID = nil;
	self.spellData = {};
	self.spellOrder = {};
	self.syncEnabled = false;
	self.lastGroupGUIDs = {};

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	self:SetScript("OnEvent", function(owner, event, ...)
		local handler = owner[event];
		if type(handler) == "function" then
			handler(owner, ...);
		end
	end);
end

local frame = CreateFrame("Frame");
Mixin(frame, CooldownSyncRelayMixin);
frame:OnLoad();
