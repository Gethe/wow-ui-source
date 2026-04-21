local ADDON_NAME, namespace = ...
local ADDON_PREFIX = "CDSyncTR"

local MSG_INF, MSG_CD = "INF", "CD"
local MAX_COOLDOWNS = 5
local GCD_SPELL_ID = 61304
local THIRD_DECIMAL = "%.3f"
local TRUNCATE_ZEROS = "%.?0+$"

local CooldownSyncRelayMixin = {}

local function IsSpellOnGCD(spellCooldownInfo, gcdInfo)
	if not gcdInfo or spellCooldownInfo.duration == 0 then
		return false
	end
	return spellCooldownInfo.startTime == gcdInfo.startTime and spellCooldownInfo.duration == gcdInfo.duration
end

function CooldownSyncRelayMixin:GetSupportedTrackedSpells()
	local out = {}
	local specID = PlayerUtil.GetCurrentSpecID()
	if not specID then
		return out
	end
	local trackedBySpec = namespace.TrackedCooldownsBySpec
	local list = trackedBySpec and trackedBySpec[specID]
	if type(list) ~= "table" then
		return out
	end
	for i = 1, #list do
		local spellID = list[i]
		if C_SpellBook.IsSpellKnown(spellID) then
			out[#out + 1] = spellID
			if #out >= MAX_COOLDOWNS then
				break
			end
		end
	end
	return out
end

function CooldownSyncRelayMixin:GetChannel()
	local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)
	if channel and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInGroup(LE_PARTY_CATEGORY_HOME) then
		channel = "INSTANCE_CHAT"
	end
	return channel
end

function CooldownSyncRelayMixin:SendComm(...)
	local channel = self:GetChannel()
	if not channel then return end
	C_Commentator.SendAddonMessage(ADDON_PREFIX, strjoin(",", ...), channel)
end

function CooldownSyncRelayMixin:SendINF()
	local list = self.cooldownSyncOrder
	if #list == 0 then return end
	local specID = PlayerUtil.GetCurrentSpecID() or 0
	local parts = {}
	for i = 1, math.min(#list, MAX_COOLDOWNS) do
		parts[i] = tostring(list[i])
	end
	self:SendComm(MSG_INF, specID, strjoin(",", unpack(parts)))
end

function CooldownSyncRelayMixin:RefreshCooldownSyncIDs()
	table.wipe(self.cooldownSyncIDs)
	table.wipe(self.cooldownSyncOrder)
	local list = self:GetSupportedTrackedSpells()
	for i = 1, #list do
		local id = list[i]
		self.cooldownSyncOrder[i] = id
		self.cooldownSyncIDs[id] = {
			start = 0,
			duration = 0,
			modRate = 1,
			charges = 0,
		}
	end
end

function CooldownSyncRelayMixin:GetSpellCooldown(spellID, gcdInfo)
	local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
	if not cooldownInfo then return 0, 0, 1, -1 end

	local start = cooldownInfo.startTime
	local duration = cooldownInfo.duration
	local enabled = cooldownInfo.isEnabled
	local modRate = cooldownInfo.modRate or 1

	local chargeInfo = C_Spell.GetSpellCharges(spellID)
	local currentCharges = chargeInfo and chargeInfo.currentCharges
	local maxCharges = chargeInfo and chargeInfo.maxCharges
	local chargeCooldownStart = chargeInfo and chargeInfo.cooldownStartTime
	local chargeCooldownDuration = chargeInfo and chargeInfo.cooldownDuration
	local chargeModRate = chargeInfo and chargeInfo.chargeModRate
	local charges = (maxCharges and maxCharges > 1) and currentCharges or -1

	if maxCharges and currentCharges and maxCharges > currentCharges then
		return chargeCooldownStart, chargeCooldownDuration, chargeModRate or 1, charges
	end

	if enabled then
		if start and start > 0 then
			if IsSpellOnGCD(cooldownInfo, gcdInfo) then return nil end
			return start, duration, modRate, charges
		end
	end

	return 0, 0, 1, charges
end

function CooldownSyncRelayMixin:EnableSync()
	if self.syncEnabled then return end
	self.syncEnabled = true
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RefreshCooldownSyncIDs()
	self:FlushCooldownsIfChanged()
end

function CooldownSyncRelayMixin:DisableSync()
	if not self.syncEnabled then return end
	self.syncEnabled = false
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
	self:UnregisterEvent("SPELLS_CHANGED")
end

function CooldownSyncRelayMixin:ShouldSyncBeEnabled()
	if not IsInGroup() then return false end
	local list = self:GetSupportedTrackedSpells()
	if #list == 0 then return false end
	return true
end

function CooldownSyncRelayMixin:UpdateSyncState()
	if self:ShouldSyncBeEnabled() then
		self:EnableSync()
	else
		self:DisableSync()
	end
end

function CooldownSyncRelayMixin:BuildCooldownPayload(filterSpellIDs, force)
	local now = GetTime()
	local gcdInfo = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
	local payloadParts = {}
	local payloadCount = 0
	local spellCount = 0

	local function push(value)
		payloadCount = payloadCount + 1
		payloadParts[payloadCount] = value
	end

	for _, id in ipairs(self.cooldownSyncOrder) do
		if spellCount >= MAX_COOLDOWNS then break end
		local info = self.cooldownSyncIDs[id]
		if info and (not filterSpellIDs or filterSpellIDs[id]) then
			local start, duration, modRate, charges = self:GetSpellCooldown(id, gcdInfo)
			if start then
				local prevStart = info.start or 0
				local prevDuration = info.duration or 0
				local prevModRate = info.modRate or 1
				local prevCharges = info.charges or 0

				if duration == 0 then
					if force or prevDuration > 0 or charges ~= prevCharges then
						push(id)
						push("0,0,1")
						push(charges)
						spellCount = spellCount + 1
					end

					info.start = start
					info.duration = 0
					info.modRate = modRate or 1
					info.charges = charges
				else
					local startChanged = start ~= prevStart
					local durationChanged = duration ~= prevDuration
					local modRateChanged = (modRate or 1) ~= prevModRate
					local chargesChanged = charges ~= prevCharges

					if force or startChanged or durationChanged or modRateChanged or chargesChanged then
						local remaining = start + duration - now
						local payloadDuration = duration
						local payloadModRate = modRate
						local payloadRemaining = remaining
						if modRate ~= 1 then
							payloadDuration = string.format(THIRD_DECIMAL, duration):gsub(TRUNCATE_ZEROS, "")
							payloadModRate = string.format(THIRD_DECIMAL, modRate):gsub(TRUNCATE_ZEROS, "")
							payloadRemaining = string.format(THIRD_DECIMAL, remaining):gsub(TRUNCATE_ZEROS, "")
						else
							payloadRemaining = math.floor(remaining)
						end

						push(id)
						push(payloadDuration)
						push(payloadRemaining)
						push(payloadModRate)
						push(charges)
						spellCount = spellCount + 1
					end

					info.start = start
					info.duration = duration
					info.modRate = modRate
					info.charges = charges
				end
			end
		end
	end

	return #payloadParts > 0 and table.concat(payloadParts, ",") or nil
end

function CooldownSyncRelayMixin:FlushCooldownsIfChanged(filterSpellIDs, force)
	if not self.syncEnabled or not self:GetChannel() then return end
	local payload = self:BuildCooldownPayload(filterSpellIDs, force)
	if not payload then return end
	self:SendComm(MSG_CD, payload)
end

function CooldownSyncRelayMixin:ADDON_LOADED(addon)
	if addon ~= ADDON_NAME then return end
	C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
	self:UnregisterEvent("ADDON_LOADED")
end

function CooldownSyncRelayMixin:PLAYER_ENTERING_WORLD()
	self:UpdateSyncState()
	if self.syncEnabled then
		self:SendINF()
		self:FlushCooldownsIfChanged()
	end
end

function CooldownSyncRelayMixin:GROUP_ROSTER_UPDATE()
	self:UpdateSyncState()
	if self.syncEnabled then
		self:SendINF()
		self:FlushCooldownsIfChanged(nil, true)
	end
end

function CooldownSyncRelayMixin:SPELLS_CHANGED()
	if self.pendingTalentRefresh then return end
	self.pendingTalentRefresh = true
	C_Timer.After(0.25, function()
		self.pendingTalentRefresh = nil
		self:RefreshCooldownSyncIDs()
		self:UpdateSyncState()
		if not self.syncEnabled then return end
		self:SendINF()
		self:FlushCooldownsIfChanged()
	end)
end

function CooldownSyncRelayMixin:SPELL_UPDATE_COOLDOWN(spellID, baseSpellID)
	if not self.syncEnabled then return end

	if not spellID and not baseSpellID then
		self:FlushCooldownsIfChanged()
		return
	end

	local filterSpellIDs = {}
	local hasMatch = false

	if spellID and self.cooldownSyncIDs[spellID] then
		filterSpellIDs[spellID] = true
		hasMatch = true
	end
	if baseSpellID and self.cooldownSyncIDs[baseSpellID] then
		filterSpellIDs[baseSpellID] = true
		hasMatch = true
	end

	if hasMatch then
		self:FlushCooldownsIfChanged(filterSpellIDs)
	end
end

function CooldownSyncRelayMixin:OnLoad()
	self.cooldownSyncIDs = self.cooldownSyncIDs or {}
	self.cooldownSyncOrder = self.cooldownSyncOrder or {}
	self.syncEnabled = false

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")

	self:SetScript("OnEvent", function(owner, event, ...)
		local handler = owner[event]
		if type(handler) == "function" then
			handler(owner, ...)
		end
	end)
end

CooldownBroadcasterFrame = CreateFrame("Frame");
Mixin(CooldownBroadcasterFrame, CooldownSyncRelayMixin)
CooldownBroadcasterFrame:OnLoad()
