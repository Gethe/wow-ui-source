
PvPTalentSlotButtonMixin = {};

local SLOT_NEW_STATE_OFF = 1;
local SLOT_NEW_STATE_SHOW_IF_ENABLED = 2;
local SLOT_NEW_STATE_ACKNOWLEDGED = 3;

function PvPTalentSlotButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.slotNewState = SLOT_NEW_STATE_OFF;
end

function PvPTalentSlotButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function PvPTalentSlotButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function PvPTalentSlotButtonMixin:OnEvent(event)
	if (event == "PLAYER_PVP_TALENT_UPDATE") then
		self.predictedSetting:Clear();
		self:Update();
	end
end

function PvPTalentSlotButtonMixin:GetSelectedTalent()
	local inspectUnit = self:GetInspectUnit();
	if (inspectUnit) then
		return C_SpecializationInfo.GetInspectSelectedPvpTalent(inspectUnit, self.slotIndex);
	end

	return self.predictedSetting:Get();
end

function PvPTalentSlotButtonMixin:SetSelectedTalent(talentID)
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID and selectedTalentID == talentID) then
		return;
	end
	self.predictedSetting:Set(talentID);
	self:Update();
end

function PvPTalentSlotButtonMixin:SetUp(slotIndex)
	self.slotIndex = slotIndex;
	self.predictedSetting = CreatePredictedSetting(
		{
			["setFunction"] = function(value)
				return LearnPvpTalent(value, slotIndex);
			end,
			["getFunction"] = function()
				if not self:IsPendingTalentRemoval() then
					local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
					return slotInfo and slotInfo.selectedTalentID;
				end
			end,
		}
	);

	self:Update();
end

function PvPTalentSlotButtonMixin:SetPendingTalentRemoval(isPending)
	self.isPendingRemoval = isPending;
end

function PvPTalentSlotButtonMixin:IsPendingTalentRemoval()
	return self.isPendingRemoval or false;
end

function PvPTalentSlotButtonMixin:Update()
	if (not self.slotIndex) then
		error("Slot must be setup with a slot index first.");
	end

	local inspectUnit = self:GetInspectUnit();
	if (inspectUnit) then
		local selectedTalentID = C_SpecializationInfo.GetInspectSelectedPvpTalent(inspectUnit, self.slotIndex);
		if (selectedTalentID) then
			local selectedTalentInfo = C_SpecializationInfo.GetPvpTalentInfo(selectedTalentID);
			SetPortraitToTexture(self.Texture, selectedTalentInfo.icon);
			self.Texture:SetVertexColor(1, 1, 1);

			self.Texture:Show();

			self.Border:SetAtlas("talents-node-pvp-inspect");
			self.Border:Show();
		else
			self.Border:SetAtlas("talents-node-pvp-inspect-empty");
			self.Border:Show();
		end

		if GameTooltip:GetOwner() == self then
			self:OnEnter();
		end

		return;
	else
		self.Border:Show();
	end

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	self.Texture:Show();
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID) then
		local selectedTalentInfo = C_SpecializationInfo.GetPvpTalentInfo(selectedTalentID);
		SetPortraitToTexture(self.Texture, selectedTalentInfo.icon);

		if (selectedTalentInfo.dependenciesUnmet) then
			self.Texture:SetVertexColor(0.9, 0, 0);
		else
			self.Texture:SetVertexColor(1, 1, 1);
		end
	else
		self.Texture:SetAtlas("pvptalents-talentborder-empty");
	end

	if (slotInfo and slotInfo.enabled) then
		if (selectedTalentID) then
			self.Border:SetAtlas("talents-node-pvp-filled");
		else
			self.Border:SetAtlas("talents-node-pvp-green");
		end
		self:Enable();
	else
		self.Border:SetAtlas("talents-node-pvp-locked");
		self:Disable();
		self.Texture:Hide();
		if slotInfo and not slotInfo.enabled and self.slotNewState == SLOT_NEW_STATE_OFF then
			if UnitLevel("player") < slotInfo.level then
				self.slotNewState = SLOT_NEW_STATE_SHOW_IF_ENABLED;
			end
		end
	end

	self:GetParent():UpdateNewNotification();

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function PvPTalentSlotButtonMixin:OnEnter()
	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	if not slotInfo then
		return;
	end

	self:GetParent():AcknowledgeNewNotification();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local selectedTalentID = self:GetSelectedTalent();
	local isInspecting = self:IsInspecting();
	if (selectedTalentID) then
		GameTooltip:SetPvpTalent(selectedTalentID, isInspecting, GetActiveSpecGroup(true), self.slotIndex);

		if (not isInspecting) then
			local selectedTalentInfo = C_SpecializationInfo.GetPvpTalentInfo(selectedTalentID);
			if (selectedTalentInfo and selectedTalentInfo.dependenciesUnmet) then
				local unmetReason = selectedTalentInfo.dependenciesUnmetReason or TALENT_BUTTON_TOOLTIP_PVP_TALENT_REQUIREMENT_ERROR;
				GameTooltip_AddErrorLine(GameTooltip, unmetReason);
			end
		end
	elseif (isInspecting) then
		GameTooltip:SetText(TALENT_NOT_SELECTED, HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		GameTooltip:SetText(PVP_TALENT_SLOT);
		if (not slotInfo.enabled) then
			GameTooltip:AddLine(PVP_TALENT_SLOT_LOCKED:format(C_SpecializationInfo.GetPvpTalentSlotUnlockLevel(self.slotIndex)), RED_FONT_COLOR:GetRGB());
		else
			GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB());
		end
	end

	GameTooltip:Show();
end

function PvPTalentSlotButtonMixin:OnClick()
	local selectedTalentID = self:GetSelectedTalent();
	if (IsModifiedClick("CHATLINK") and selectedTalentID) then
		local link = GetPvpTalentLink(selectedTalentID);
		ChatEdit_InsertLink(link);
		return;
	end

	if (self:IsInspecting()) then
		return;
	end

	self:GetParent():SelectSlot(self);
end

function PvPTalentSlotButtonMixin:OnDragStart()
	if (self:IsInspecting()) then
		return;
	end

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	if slotInfo and slotInfo.selectedTalentID then
		local predictedTalentID = self:GetSelectedTalent();
		if (not predictedTalentID or predictedTalentID == slotInfo.selectedTalentID) then
			PickupPvpTalent(slotInfo.selectedTalentID);
		end
	end
end

function PvPTalentSlotButtonMixin:IsInspecting()
	return self:GetParent():IsInspecting();
end

function PvPTalentSlotButtonMixin:GetInspectUnit()
	return self:GetParent():GetInspectUnit();
end


PvPTalentSlotTrayMixin = {};

local PvPTalentSlotTrayEvents = {
	"PLAYER_PVP_TALENT_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"WAR_MODE_STATUS_UPDATE",
	"TRAIT_CONFIG_UPDATED",
};

local PvPTalentSlotTrayUnitEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
};

function PvPTalentSlotTrayMixin:OnLoad()
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	for i, slot in ipairs(self.Slots) do
		slot:SetUp(i);
	end
end

function PvPTalentSlotTrayMixin:OnEvent(event, ...)
	if event == "PLAYER_PVP_TALENT_UPDATE" then
		self:ClearPendingRemoval();
		self:Update();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:Update();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Update();
	elseif event == "WAR_MODE_STATUS_UPDATE" then
		self:Update();
	elseif event == "PLAYER_LEVEL_CHANGED" then
		self:Update();
	elseif event == "TRAIT_CONFIG_UPDATED" then
		self:Update();
	end
end

function PvPTalentSlotTrayMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, PvPTalentSlotTrayEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, PvPTalentSlotTrayUnitEvents, "player");

	self:Update();
end

function PvPTalentSlotTrayMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, PvPTalentSlotTrayEvents);
	FrameUtil.UnregisterFrameForEvents(self, PvPTalentSlotTrayUnitEvents);

	self:UnselectSlot();
end

function PvPTalentSlotTrayMixin:SetTalentFrame(talentFrame)
	if self.talentFrame or not talentFrame then
		return;
	end

	self.talentFrame = talentFrame;

	self:AddDynamicEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.PvPTalentListClosed, self.OnPvPTalentListClosed);
	self:AddDynamicEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.SelectTalentIDForSlot, self.OnSelectTalentIDForSlot);
end

function PvPTalentSlotTrayMixin:OnPvPTalentListClosed()
	self:ClearSlotSelection();
end

function PvPTalentSlotTrayMixin:OnSelectTalentIDForSlot(talentID, slotIndex)
	self:SelectTalentForSlot(talentID, slotIndex);
end

function PvPTalentSlotTrayMixin:GetTalentFrame()
	return self.talentFrame;
end

function PvPTalentSlotTrayMixin:ClearPendingRemoval()
	for slotIndex = 1, #self.Slots do
		local slot = self.Slots[slotIndex];
		slot:SetPendingTalentRemoval(false);
		slot:Update();
	end
end

function PvPTalentSlotTrayMixin:Update()
	-- TODO:: Check C_SpecializationInfo.CanPlayerUsePVPTalentUI()

	for _, slot in pairs(self.Slots) do
		slot:Update();
	end
end

function PvPTalentSlotTrayMixin:SelectSlot(slot)
	local talentFrame = self:GetTalentFrame();
	if not talentFrame then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (self.selectedSlotIndex) then
		local sameSelected = self.selectedSlotIndex == slot.slotIndex;
		self:UnselectSlot();
		if (sameSelected) then
			return;
		end
	end

	self.selectedSlotIndex = slot.slotIndex;

	talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.OpenPvPTalentList, self.selectedSlotIndex, self.Slots[self.selectedSlotIndex]);
end

function PvPTalentSlotTrayMixin:UnselectSlot()
	if not self:ClearSlotSelection() then
		return;
	end

	local talentFrame = self:GetTalentFrame();
	if not talentFrame then
		return;
	end

	talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.ClosePvPTalentList);
end

function PvPTalentSlotTrayMixin:ClearSlotSelection()
	if (not self.selectedSlotIndex) then
		return false;
	end

	local slot = self.Slots[self.selectedSlotIndex];

	self.selectedSlotIndex = nil;
	return true;
end

function PvPTalentSlotTrayMixin:SelectTalentForSlot(talentID, slotIndex)
	local slot = self.Slots[slotIndex];

	if (not slot or slot:GetSelectedTalent() == talentID) then
		return;
	end

	for existingSlotIndex = 1, #self.Slots do
		local existingSlot = self.Slots[existingSlotIndex];
		if existingSlot:GetSelectedTalent() == talentID then
			existingSlot:SetPendingTalentRemoval(true);
			break;
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	slot:SetSelectedTalent(talentID);
	self:UnselectSlot();
end

function PvPTalentSlotTrayMixin:IsInspecting()
	local talentFrame = self:GetTalentFrame();
	if (not talentFrame) then
		return false;
	end

	return talentFrame:IsInspecting();
end

function PvPTalentSlotTrayMixin:GetInspectUnit()
	local talentFrame = self:GetTalentFrame();
	if (not talentFrame) then
		return nil;
	end

	return talentFrame:GetInspectUnit();
end

function PvPTalentSlotTrayMixin:UpdateNewNotification()
	self.NewContainer:Hide();
	for index, slot in ipairs(self.Slots) do
		if slot.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED and slot:IsEnabled() then
			self.NewContainer:SetPoint("CENTER", slot, "BOTTOMRIGHT", -8, 8);
			self.NewContainer:Show();
			break;
		end
	end
end

function PvPTalentSlotTrayMixin:AcknowledgeNewNotification()
	if self.NewContainer:IsShown() then
		for index, slot in ipairs(self.Slots) do
			if slot.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED and slot:IsEnabled() then
				slot.slotNewState = SLOT_NEW_STATE_ACKNOWLEDGED;
			end
		end

		self.NewContainer:Hide();
	end
end