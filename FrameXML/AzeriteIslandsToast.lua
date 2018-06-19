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
	if self.playerToastPool and self.playerToastPool:GetNumActive() > 0 then
		return true;
	end

	if self.partyToastPool and self.partyToastPool:GetNumActive() > 0 then
		return true;
	end

	return false;
end

function AzeriteIslandsToastMixin:OnEvent(event, ...)
	if ( event == "ISLAND_AZERITE_GAIN" ) then
		local amount, isPlayer, factionIndex = ...;
		
		local factionGroup = PLAYER_FACTION_GROUP[factionIndex];
		
		self:ShowWidgetGlow(factionGroup == "Horde");

		local toastFrame = self:AcquireToastFrame(isPlayer);
		self:SetupTextFrame(toastFrame, amount);

		self:Show();
	end
end