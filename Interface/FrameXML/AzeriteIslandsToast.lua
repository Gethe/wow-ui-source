AzeriteIslandsToastMixin = { }; 

function AzeriteIslandsToastMixin:OnLoad()
	self:RegisterEvent("ISLAND_AZERITE_GAIN");
end

function AzeriteIslandsToastMixin:ShowWidgetGlow(isHorde)
	for widgetID, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag("azeriteBar") do
		widgetFrame:PlayBarGlow(isHorde);
	end
end

function AzeriteIslandsToastMixin:SetupTextFrame(frame, amount)
	frame.Text:SetFormattedText(AZERITE_ISLAND_POWER_GAIN_SHORT, amount);
	frame:Show();
	frame.ShowAnim:Play();
end

function AzeriteIslandsToastMixin:CreateAccumulator()
	local accumulator = CreateFromMixins(AzeriteIslandsToastAccumulatorMixin);
	local ACCUMULATION_DEFERRAL_TIME_SEC = .25;
	accumulator:OnLoad(ACCUMULATION_DEFERRAL_TIME_SEC);
	return accumulator;
end

function AzeriteIslandsToastMixin:GetAccumulator(isPlayer)
	if isPlayer then
		self.playerAccumulator = self.playerAccumulator or self:CreateAccumulator();
		return self.playerAccumulator;
	end

	self.partyAccumulator = self.partyAccumulator or self:CreateAccumulator();
	return self.partyAccumulator;
end

function AzeriteIslandsToastMixin:GetToastPool(isPlayer)
	-- If we end up with more types then swap this to a pool collection
	if isPlayer then
		self.playerToastPool = self.playerToastPool or CreateFramePool("FRAME", self, "AzeriteIslandsPlayerToastTextTemplate", FramePool_Hide);
		return self.playerToastPool;
	end

	self.partyToastPool = self.partyToastPool or CreateFramePool("FRAME", self, "AzeriteIslandsPartyToastTextTemplate", FramePool_Hide);
	return self.partyToastPool;
end

function AzeriteIslandsToastMixin:AcquireToastFrame(isPlayer)
	return self:GetToastPool(isPlayer):Acquire();
end

function AzeriteIslandsToastMixin:ReleaseToastFrame(isPlayer, toastFrame)
	return self:GetToastPool(isPlayer):Release(toastFrame);
end

function AzeriteIslandsToastMixin:OnAnimationFinished(toastFrame)
	self:ReleaseToastFrame(toastFrame.IsPlayer, toastFrame);
	self:SetShown(self:AreAnyAnimationsActive());
end

function AzeriteIslandsToastMixin:AreAnyAnimationsActive()
	if self.playerAccumulator and self.playerAccumulator:HasPendingAzerite() then
		return true;
	end

	if self.partyAccumulator and self.partyAccumulator:HasPendingAzerite() then
		return true;
	end

	if self.playerToastPool and self.playerToastPool:GetNumActive() > 0 then
		return true;
	end

	if self.partyToastPool and self.partyToastPool:GetNumActive() > 0 then
		return true;
	end

	return false;
end

function AzeriteIslandsToastMixin:ShowToast(isPlayer, amount)
	local toastFrame = self:AcquireToastFrame(isPlayer);
	self:SetupTextFrame(toastFrame, amount);
end

function AzeriteIslandsToastMixin:OnEvent(event, ...)
	if ( event == "ISLAND_AZERITE_GAIN" ) then
		local amount, isPlayer, factionIndex = ...;
		
		local factionGroup = PLAYER_FACTION_GROUP[factionIndex];
		local playerFactionGroup = UnitFactionGroup("player");
		
		self:ShowWidgetGlow(factionGroup == "Horde");

		if factionGroup == playerFactionGroup then
			self:GetAccumulator(isPlayer):AddAzerite(amount);
			self:Show();
		end
	end
end

function AzeriteIslandsToastMixin:OnUpdate(elapsed)
	if self.playerAccumulator and self.playerAccumulator:IsTimeToDisplay() then
		local isPlayer = true;
		self:ShowToast(isPlayer, self.playerAccumulator:Consume());
	end

	if self.partyAccumulator and self.partyAccumulator:IsTimeToDisplay() then
		local isPlayer = false;
		self:ShowToast(isPlayer, self.partyAccumulator:Consume());
	end
end

AzeriteIslandsToastAccumulatorMixin = {};

function AzeriteIslandsToastAccumulatorMixin:OnLoad(accumulationDeferralTimeSec)
	self.accumulationDeferralTimeSec = accumulationDeferralTimeSec;
end

function AzeriteIslandsToastAccumulatorMixin:AddAzerite(amount)
	self.lastAddedTimestamp = GetTime();
	self.pendingAzerite = (self.pendingAzerite or 0) + amount;
end

function AzeriteIslandsToastAccumulatorMixin:IsTimeToDisplay()
	if self:HasPendingAzerite() then
		return GetTime() - self.lastAddedTimestamp >= self.accumulationDeferralTimeSec;
	end
	return false;
end

function AzeriteIslandsToastAccumulatorMixin:HasPendingAzerite()
	return self.lastAddedTimestamp ~= nil;
end

function AzeriteIslandsToastAccumulatorMixin:Consume()
	assert(self.lastAddedTimestamp);
	assert(self.pendingAzerite);

	local pendingAzerite = self.pendingAzerite;
	self.pendingAzerite = nil;
	self.lastAddedTimestamp = nil;
	return pendingAzerite;
end