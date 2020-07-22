
RuneforgePowerButtonMixin = {};

function RuneforgePowerButtonMixin:SetPowerID(powerID)
	self.powerID = powerID;

	local hasPowerID = powerID ~= nil;
	self.powerInfo = hasPowerID and C_LegendaryCrafting.GetRuneforgePowerInfo(powerID) or nil;
	self.Icon:SetShown(hasPowerID);
	if hasPowerID then
		self.Icon:SetTexture(self.powerInfo and self.powerInfo.iconFileID or QUESTION_MARK_ICON);

		local isAvailable = self.powerInfo.state == Enum.RuneforgePowerState.Available;
		local isActive = isAvailable and self:IsEnabled();
		self.Icon:SetDesaturated(not isAvailable);
		self.Icon:SetAlpha(isActive and 1.0 or 0.5);
		self:SetEnabled(isActive);

		self:RegisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	else
		self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	end
end

function RuneforgePowerButtonMixin:GetPowerID()
	return self.powerID;
end

function RuneforgePowerButtonMixin:OnHide()
	self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
end

function RuneforgePowerButtonMixin:OnEvent(event, ...)
	if event == "RUNEFORGE_POWER_INFO_UPDATED" then
		local powerID = ...;
		if powerID == self:GetPowerID() then
			self:SetPowerID(powerID);

			if self:IsMouseOver() then
				self:OnEnter();
			end
		end
	end
end

function RuneforgePowerButtonMixin:OnEnter()
	if self.powerInfo then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", self.tooltipOffsetX or 0, self.tooltipOffsetY or 0);

		local wrap = true;
		GameTooltip_SetTitle(GameTooltip, self.powerInfo.name, nil, wrap);
	
		local wrap = true;
		GameTooltip_AddColoredLine(GameTooltip, self.powerInfo.description, GREEN_FONT_COLOR, wrap);
	
		if self.powerInfo.source then
			local wrap = true;
			GameTooltip_AddErrorLine(GameTooltip, self.powerInfo.source, wrap);
		end

		GameTooltip:Show();
	end
end

function RuneforgePowerButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgePowerButtonMixin:OnHide()
	self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
end


RuneforgePowerSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerSlotMixin:OnLoad()
	self.Icon:SetPoint("CENTER", -5, 2);
	self.Icon:SetSize(64, 64);

	self:AddEffectData("primary", RuneforgeUtil.Effect.PowerSlotted, RuneforgeUtil.EffectTarget.None);
	self:AddEffectData("chains", RuneforgeUtil.Effect.PowerInChainsEffect, RuneforgeUtil.EffectTarget.ItemSlot);
	self:AddEffectData("chains2", RuneforgeUtil.Effect.PowerOutChainsEffect, RuneforgeUtil.EffectTarget.ReverseItemSlot);
end

function RuneforgePowerSlotMixin:OnShow()
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnHide()
	RuneforgePowerButtonMixin.OnHide(self);

	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnClick(buttonName)
	self:GetRuneforgeFrame():TogglePowerList();
end

function RuneforgePowerSlotMixin:Reset()
	self:SetPowerID(nil);
	self.SelectedTexture:Hide();
end

function RuneforgePowerSlotMixin:UpdateState()
	local powerSelected = self:GetPowerID() ~= nil;
	self.SelectedTexture:SetShown(powerSelected);

	local isUpgrading = self:IsRuneforgeUpgrading();
	local hasItem = self:GetRuneforgeFrame():GetItem() ~= nil;
	local alpha = (not powerSelected and hasItem and not isUpgrading) and 1 or 0;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);

	local slotAlpha = isUpgrading and 0.35 or 1.0;
	self.SelectedTexture:SetAlpha(slotAlpha);
	self:SetAlpha(slotAlpha);

	self:SetEnabled(not isUpgrading);

	local showEffects = powerSelected and not isUpgrading;
	self:SetEffectShown("primary", showEffects);
	self:SetEffectShown("chains", showEffects);
	self:SetEffectShown("chains2", showEffects);
end

function RuneforgePowerSlotMixin:SetPowerID(powerID)
	if self:GetPowerID() == powerID then
		return;
	end

	RuneforgePowerButtonMixin.SetPowerID(self, powerID);

	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.PowerSelected, powerID);
	self:UpdateState();
end

function RuneforgePowerSlotMixin:OnBaseItemChanged()
	if self:IsRuneforgeCrafting() then
		self:Reset();
		self:UpdateState();
	elseif self:IsRuneforgeUpgrading() then
		local runeforgeFrame = self:GetRuneforgeFrame();
		local item = runeforgeFrame:GetItem();
		if item == nil then
			self:Reset();
			self:UpdateState();
		else
			local info = runeforgeFrame:GetRuneforgeComponentInfo();
			self:SetPowerID(info.powerID);
		end
	end
end


RuneforgePowerMixin = {};

function RuneforgePowerMixin:GetPowerList()
	return self:GetParent():GetParent();
end

function RuneforgePowerMixin:SetPowerIndex(powerIndex)
	self.powerIndex = powerIndex;

	local powerID, isSelected = self:GetPowerList():GetPower(powerIndex);
	self:SetPowerID(powerID);
	self.SelectedTexture:SetShown(isSelected);
end

function RuneforgePowerMixin:OnShow()
	self:SetAlpha(self:IsEnabled() and 1.0 or 0.5);
end

function RuneforgePowerMixin:OnClick()
	self:GetPowerList():OnPowerSelected(self.powerIndex);
end


RuneforgePowerListMixin = {};

function RuneforgePowerListMixin:OnLoad()
	ScrollFrame_OnLoad(self);

	self.powerPool = CreateFramePool("BUTTON", self.ScrollChild, "RuneforgePowerTemplate");
end

function RuneforgePowerListMixin:OpenPowerList(powers)
	self.powers = powers;
	self:GeneratePowerFrames();
end

function RuneforgePowerListMixin:GeneratePowerFrames()
	self.powerPool:ReleaseAll();

	local numPowers = self:GetNumPowers();
	local buttonsEnabled = self:GetParent():GetRuneforgeFrame():HasItem();

	local function FactoryFunction(index)
		if index > numPowers then
			return nil;
		end

		local frame = self.powerPool:Acquire();
		frame:SetEnabled(buttonsEnabled);
		frame:SetPowerIndex(index);
		frame:Show();
		return frame;
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.ScrollChild, "TOPLEFT");
	local totalWidth = self:GetWidth();
	local totalHeight = nil;
	local overrideDirection = nil;
	local overridePadding = -4;
	AnchorUtil.GridLayoutFactory(FactoryFunction, anchor, totalWidth, totalHeight, overrideDirection, overridePadding, overridePadding);
end

function RuneforgePowerListMixin:GetNumPowers()
	return self.powers and #self.powers or 0;
end

function RuneforgePowerListMixin:GetPower(index)
	local powerID = self.powers[index];
	return powerID, self:GetParent():GetPowerID() == powerID;
end

function RuneforgePowerListMixin:OnPowerSelected(index)
	self:GetParent():SelectPowerID(self:GetPower(index));
end


RuneforgePowerFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerFrameMixin:OpenPowerList(powers)
	self.PowerList:OpenPowerList(powers);
end

function RuneforgePowerFrameMixin:SelectPowerID(powerID)
	self:GetRuneforgeFrame():SetPowerID(powerID);
	self:Hide();
end

function RuneforgePowerFrameMixin:GetPowerID()
	return self:GetRuneforgeFrame():GetPowerID();
end
