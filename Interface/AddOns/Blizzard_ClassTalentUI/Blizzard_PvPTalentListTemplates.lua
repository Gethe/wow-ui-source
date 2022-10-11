
PvPTalentListButtonMixin = {};

function PvPTalentListButtonMixin:SetPvpTalent(talentID)
	self.talentID = talentID;
end

function PvPTalentListButtonMixin:Init(elementData)
	local talentID = elementData.talentID;
	local selectedHere = elementData.selectedHere;
	local selectedOther = elementData.selectedOther;
	local owner = elementData.owner;
	self:SetOwningFrame(owner);
	self:SetPvpTalent(talentID);
	self:Update(selectedHere, selectedOther);
end

function PvPTalentListButtonMixin:Update(selectedHere, selectedOther)
	local talentID, name, icon, selected, available, spellID, unlocked = GetPvpTalentInfoByID(self.talentID);

	self.New:Hide();
	self.NewGlow:Hide();

	if (not unlocked) then
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Icon:SetDesaturated(true);
		self.Selected:Hide();
		self.disallowNormalClicks = true;
	else
		if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID)) then
			self.New:Show();
			self.NewGlow:Show();
		end
		if selectedHere or selectedOther then
			self.Name:SetTextColor(YELLOW_FONT_COLOR:GetRGB());
		else
			self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
		self.Icon:SetDesaturated(false);
		self.Selected:SetShown(selectedHere);
		self.disallowNormalClicks = false; 
	end

	self.SelectedOtherCheck:SetShown(selectedOther);

	if selectedOther then
		self:SetAlpha(0.4);
	else
		self:SetAlpha(1);
	end

	self.Border:SetShown(not selectedHere and not selectedOther);

	self.Name:SetText(name);
	self.Icon:SetTexture(icon);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function PvPTalentListButtonMixin:SetOwningFrame(frame)
	self.owner = frame;
end

function PvPTalentListButtonMixin:OnClick(button)
	EventRegistry:TriggerEvent("PvPTalentButton.OnClick", self, button);

	if (IsModifiedClick("CHATLINK")) then
		local link = GetPvpTalentLink(self.talentID);
		ChatEdit_InsertLink(link);
		return;
	end

	if (not self.owner) then
		return;
	end

	if(not self.disallowNormalClicks) then 
		self.owner:SelectTalent(self.talentID);
	end
end

function PvPTalentListButtonMixin:OnEnter()
	if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID) and select(7,GetPvpTalentInfoByID(self.talentID))) then
		C_SpecializationInfo.SetPvpTalentLocked(self.talentID, false);
		self.New:Hide();
		self.NewGlow:Hide();
	end

	if (not self.owner) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetPvpTalent(self.talentID, false, GetActiveSpecGroup(true), self.owner.selectedSlotIndex);
	GameTooltip:Show();
end


PvPTalentListMixin = {};

function PvPTalentListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("PvPTalentListButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(1,0,0,0,PVP_TALENT_LIST_BUTTON_OFFSET);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function PvPTalentListMixin:SetTalentFrame(talentFrame)
	if self.talentFrame or not talentFrame then
		return;
	end

	self.talentFrame = talentFrame;

	self:AddStaticEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.OpenPvPTalentList, self.OnOpenPvPTalentList);
	self:AddDynamicEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.ClosePvPTalentList, self.OnClosePvPTalentList);
end

function PvPTalentListMixin:GetTalentFrame()
	return self.talentFrame;
end

function PvPTalentListMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
	self:Update();

	local view = self.ScrollBox:GetView();
	local viewHeight = view:GetExtent();
	self:SetSize(self:GetWidth(), viewHeight);
end

function PvPTalentListMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	local talentFrame = self:GetTalentFrame();
	if talentFrame then
		talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.PvPTalentListClosed);
	end
end

function PvPTalentListMixin:OnOpenPvPTalentList(slotIndex, slotFrame)
	self.slotIndex = slotIndex;

	self:Show();
	self:SetPoint("BOTTOM", slotFrame, "TOP", 0, 0);
end

function PvPTalentListMixin:OnClosePvPTalentList()
	self:Hide();
end

function PvPTalentListMixin:Update()
	local slotIndex = self.slotIndex;

	if (slotIndex) then
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
		if not slotInfo then
			return;
		end
		local numTalents = #slotInfo.availableTalentIDs;
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs();
		local availableTalentIDs = slotInfo.availableTalentIDs;

		table.sort(availableTalentIDs, function(a, b)
			local unlockedA = select(7,GetPvpTalentInfoByID(a));
			local unlockedB = select(7,GetPvpTalentInfoByID(b));

			if (unlockedA ~= unlockedB) then
				return unlockedA;
			end

			if (not unlockedA) then
				local reqLevelA = C_SpecializationInfo.GetPvpTalentUnlockLevel(a);
				local reqLevelB = C_SpecializationInfo.GetPvpTalentUnlockLevel(b);

				if (reqLevelA ~= reqLevelB) then
					return reqLevelA < reqLevelB;
				end
			end

			local selectedOtherA = tContains(selectedPvpTalents, a) and slotInfo.selectedTalentID ~= a;
			local selectedOtherB = tContains(selectedPvpTalents, b) and slotInfo.selectedTalentID ~= b;

			if (selectedOtherA ~= selectedOtherB) then
				return selectedOtherB;
			end

			return a < b;
		end);
		local selectedTalentID = slotInfo.selectedTalentID;

		local dataProvider = CreateDataProvider();
		for index = 1, numTalents do
			local talentID = availableTalentIDs[index];
			local selectedHere = selectedTalentID == talentID;
			local selectedOther = not selectedHere and tContains(selectedPvpTalents, talentID);
			dataProvider:Insert({talentID=talentID, selectedHere=selectedHere, selectedOther=selectedOther, owner=self});
		end
		self.ScrollBox:SetDataProvider(dataProvider);
	end
end

function PvPTalentListMixin:SelectTalent(talentID)
	local slotIndex = self.slotIndex;
	if not slotIndex then
		return;
	end

	local talentFrame = self:GetTalentFrame();
	if not talentFrame then
		return;
	end

	talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.SelectTalentIDForSlot, talentID, slotIndex);
end