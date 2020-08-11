
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
	local oldPowerID = self:GetPowerID();
	if oldPowerID == powerID then
		return;
	end

	RuneforgePowerButtonMixin.SetPowerID(self, powerID);

	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:TriggerEvent(RuneforgeFrameMixin.Event.PowerSelected, powerID);

	self:UpdateState();

	if oldPowerID == nil then
		runeforgeFrame:FlashRunes();
	end

	if not runeforgeFrame:IsRuneforgeUpgrading() then
		PlaySound(SOUNDKIT.UI_RUNECARVING_SELECT_LEGENDARY_POWER);
	end
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

function RuneforgePowerMixin:InitElement(powerList)
	self.powerList = powerList;
end

function RuneforgePowerMixin:GetPowerList()
	return self.powerList;
end

function RuneforgePowerMixin:UpdateDisplay()
	local powerIndex = self:GetListIndex();

	local powerList = self:GetPowerList();
	self:SetEnabled(powerList:GetRuneforgeFrame():HasItem());

	local powerID, isSelected = powerList:GetPower(powerIndex);
	self:SetPowerID(powerID);
	self.SelectedTexture:SetShown(isSelected);

	self:SetAlpha(self:IsEnabled() and 1.0 or 0.5);
end


RuneforgePowerListMixin = {};

function RuneforgePowerListMixin:OnLoad()
	PagedListMixin.OnLoad(self);
	
	self:SetGetNumResultsFunction(GenerateClosure(self.GetNumPowers, self));
	self:SetSelectionCallback(GenerateClosure(self.OnPowerSelected, self));
	self:SetElementTemplate("RuneforgePowerTemplate", self);

	local stride = 4;
	local padding = -4;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, padding, padding);
	local numDisplayedElements = 12;
	self:SetLayout(layout, numDisplayedElements);
end

function RuneforgePowerListMixin:OnHide()
	self:SetPage(1);
end

function RuneforgePowerListMixin:OpenPowerList(powers)
	self.powers = powers;
	self:RefreshListDisplay();
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

function RuneforgePowerListMixin:GetRuneforgeFrame()
	return self:GetParent():GetRuneforgeFrame();
end


RuneforgePowerFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerFrameMixin:OnLoad()
	self.PageControl:SetPagedList(self.PowerList);
end

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
