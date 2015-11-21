ArtifactClassNameTemplateMixin = {}


function ArtifactClassNameTemplateMixin:OnShow()
	self.PointsRemainingLabel:SnapToTarget();

	local textureKit, titleName, titleX, titleY, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	self.ArtifactName:SetText(titleName);
	self.ArtifactName:SetVertexColor(barConnectedR, barConnectedG, barConnectedB);

	--[[ TODO: Remove placeholder data hacks ]]
	if self.isPlaceholder then
		self.TempName:Hide();
		self.ArtifactName:Show();
		for i, colorable in ipairs(self.Colorables) do
			colorable:SetVertexColor(barConnectedR, barConnectedG, barConnectedB, colorable:GetAlpha());
			colorable:SetDesaturated(true);
		end
	else
		self.TempName:Show();
		self.ArtifactName:Hide();
		for i, colorable in ipairs(self.Colorables) do
			colorable:SetVertexColor(1, 1, 1, colorable:GetAlpha());
			colorable:SetDesaturated(false);
		end
	end

	self:EvaluateRelics();

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("CURSOR_UPDATE");
	
end

function ArtifactClassNameTemplateMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_UPDATE");
	self:UnregisterEvent("CURSOR_UPDATE");
	StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
end

function ArtifactClassNameTemplateMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		self:EvaluateRelics();
		self:RefreshRelicTooltips();
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();

	end
end

function ArtifactClassNameTemplateMixin:OnCursorUpdate()
	if not CursorHasItem() then
		StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
	end

	for i, relicSlot in ipairs(self.RelicSlots) do
		if relicSlot:IsShown() then
			if C_ArtifactUI.CanApplyCursorRelicToSlot(i) then
				relicSlot:LockHighlight();
				relicSlot.HighlightTexture:Show();
				relicSlot.CanSlotAnim:Play();
			else
				relicSlot:UnlockHighlight();
				relicSlot.CanSlotAnim:Stop();
				if CursorHasItem() then
					relicSlot.HighlightTexture:Hide();
				else
					relicSlot.HighlightTexture:Show();
				end
			end
		end
	end
end


function ArtifactClassNameTemplateMixin:OnRelicSlotMouseEnter(relicSlot)
	if relicSlot.relicLink then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		GameTooltip:SetHyperlink(relicSlot.relicLink);
	elseif relicSlot.relicType then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		GameTooltip:SetText(EMPTY_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
		GameTooltip:AddLine(EMPTY_RELIC_TOOLTIP_BODY:format(slotName), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
	self:GetParent():OnRelicSlotMouseEnter(relicSlot.relicSlotIndex);
end

function ArtifactClassNameTemplateMixin:OnRelicSlotMouseLeave(relicSlot)
	GameTooltip_Hide();
	self:GetParent():OnRelicSlotMouseLeave(relicSlot.relicSlotIndex);
end

StaticPopupDialogs["CONFIRM_RELIC_REPLACE"] = {
	text = CONFIRM_ACCEPT_RELIC,
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, relicSlotIndex)
		C_ArtifactUI.ApplyCursorRelicToSlot(relicSlotIndex);
	end,
	OnCancel = function()
		ClearCursor();
	end,

	showAlert = true,
	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

function ArtifactClassNameTemplateMixin:OnRelicSlotClicked(relicSlot)
	for i = 1, #self.RelicSlots do
		if self.RelicSlots[i] == relicSlot then
			if C_ArtifactUI.CanApplyCursorRelicToSlot(i) then
				if C_ArtifactUI.GetRelicInfo(i) then
					StaticPopup_Show("CONFIRM_RELIC_REPLACE", nil, nil, i);
				else
					C_ArtifactUI.ApplyCursorRelicToSlot(i);
				end
			end
			break;
		end
	end
end

function ArtifactClassNameTemplateMixin:RefreshRelicTooltips()
	for i = 1, #self.RelicSlots do
		if GameTooltip:IsOwned(self.RelicSlots[i]) then
			self.RelicSlots[i]:GetScript("OnEnter")(self.RelicSlots[i]);
			break;
		end
	end
end

function ArtifactClassNameTemplateMixin:EvaluateRelics()
	local numRelicSlots = C_ArtifactUI.GetNumRelicSlots();

	self:SetExpandedState(numRelicSlots > 0);

	for i = 1, numRelicSlots do
		local relicSlot = self.RelicSlots[i];

		local relicType = C_ArtifactUI.GetRelicSlotType(i);

		local relicAtlasName = ("Relic-%s-Slot"):format(relicType);
		relicSlot:GetNormalTexture():SetAtlas(relicAtlasName, true);
		relicSlot:GetHighlightTexture():SetAtlas(relicAtlasName, true);

		local relicItemID, relicName, relicIcon, relicLink = C_ArtifactUI.GetRelicInfo(i);
		if relicIcon then
			relicSlot.Icon:SetSize(34, 34);
			relicSlot.Icon:SetTexture(relicIcon);
			relicSlot.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		else
			relicSlot.Icon:SetMask(nil);
			relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
		end

		relicSlot.relicLink = relicLink;
		relicSlot.relicType = relicType;
		relicSlot.relicSlotIndex = i;
		
		relicSlot:ClearAllPoints();
		local PADDING = 0;
		if i == 1 then
			local offsetX = -(numRelicSlots - 1) * (relicSlot:GetWidth() + PADDING) * .5;
			relicSlot:SetPoint("CENTER", self, "CENTER", offsetX, 0);
		else
			relicSlot:SetPoint("LEFT", self.RelicSlots[i - 1], "RIGHT", PADDING, 0);
		end

		relicSlot:Show();
	end

	for i = numRelicSlots + 1, #self.RelicSlots do
		self.RelicSlots[i]:Hide();
	end
end

function ArtifactClassNameTemplateMixin:SetPointsRemaining(value)
	self.PointsRemainingLabel:SetAnimatedValue(value);
end

function ArtifactClassNameTemplateMixin:SetMaxRanksLabel(purchasedRanks, maxRanks)
	-- placeholder
	self.MaxRanksLabel:SetText(("%d/%d"):format(purchasedRanks, maxRanks));
end

function ArtifactClassNameTemplateMixin:OnUpdate(elapsed)
	self.PointsRemainingLabel:UpdateAnimatedValue(elapsed);
end

function ArtifactClassNameTemplateMixin:SetExpandedState(expanded)
	if self.expanded ~= expanded then
		self.expanded = expanded;

		self:SetHeight(self.expanded and 165 or 100);
	end
end