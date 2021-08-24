BattlefieldFlagDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function BattlefieldFlagDataProviderMixin:OnShow()
	self:RegisterEvent("UNIT_AURA");
end

function BattlefieldFlagDataProviderMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");
end

function BattlefieldFlagDataProviderMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		self:RefreshAllData(false);
	end
end

function BattlefieldFlagDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BattlefieldFlagPinTemplate");
end

function BattlefieldFlagDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	for flagIndex = 1, GetNumBattlefieldFlagPositions() do
		self:GetMap():AcquirePin("BattlefieldFlagPinTemplate", flagIndex);
	end
end

--[[ Battlefield Flag Pin ]]--
BattlefieldFlagMixin = CreateFromMixins(MapCanvasPinMixin);

function BattlefieldFlagMixin:OnLoad()	
	self:SetScalingLimits(1, 0.825, 0.85);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
end

function BattlefieldFlagMixin:OnAcquired(flagIndex)
	self.flagIndex = flagIndex;
	self:Refresh();
end

function BattlefieldFlagMixin:Refresh()
	local flagX, flagY, flagTexture = GetBattlefieldFlagPosition(self.flagIndex);
	self.Texture:SetTexture(flagTexture);
	self:SetPosition(flagX or 0, flagY or 0);
	local shown = flagX ~= nil;
	self:SetAlpha(shown and 1.0 or 0);
end

function BattlefieldFlagMixin:OnUpdate()
	if self.flagIndex then
		self:Refresh();
	else
		self:Hide();
	end
end