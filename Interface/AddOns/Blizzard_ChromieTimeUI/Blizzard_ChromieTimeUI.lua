local MAX_EXPANSIONS_IN_ROW = 3; 
ChromieTimeFrameMixin = { }; 

function ChromieTimeFrameMixin:OnLoad() 
	self.ExpansionOptionsPool = CreateFramePool("BUTTON", self.OptionsFrame, "ChromieTimeExpansionButtonTemplate");
end 

function ChromieTimeFrameMixin:OnEvent(event, ...) 
	if (event == "CHROMIE_TIME_CLOSE") then
		self.selectedNewExpansion = true;
		HideUIPanel(self);
	end 
end 

function ChromieTimeFrameMixin:OnShow()
	self:RegisterEvent("CHROMIE_TIME_CLOSE");
	self:SetupExpansionButtons(); 
end

function ChromieTimeFrameMixin:OnHide()
	self:UnregisterEvent("CHROMIE_TIME_CLOSE");

	if (self.currentExpansionSelection) then 
		self.currentExpansionSelection:ClearSelection(); 
	end 

	if (not self.selectedNewExpansion) then
		PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	end

	self.CurrentlySelectedExpansionInfoFrame:ResetSelection(); 
	self.currentExpansionSelection = nil;
	self.previousRowOption = nil; 
	self.lastOption = nil; 
	self.selectedNewExpansion = nil;

	C_ChromieTime.CloseUI();
end 

function ChromieTimeFrameMixin:SelectExpansionOption()
	if (self.currentExpansionSelection) then 
		C_ChromieTime.SelectChromieTimeOption(self.currentExpansionSelection.buttonInfo.id); 
	end
end 

function ChromieTimeFrameMixin:SetupExpansionButtons()
	self.lastOption = nil;
	self.ExpansionOptionsPool:ReleaseAll(); 
	local expansionOptions = C_ChromieTime.GetChromieTimeExpansionOptions(); 
	for optionIndex, option in ipairs(expansionOptions) do 
		self.lastOption = self:GetExpansionOptionButton(optionIndex, option);
	end 
end 

function ChromieTimeFrameMixin:GetExpansionOptionButton(index, optionInfo)
	local expansionOptionButton = self.ExpansionOptionsPool:Acquire(); 

	if (not self.lastOption) then 
		expansionOptionButton:SetPoint("TOPLEFT", self.OptionsFrame); 
		self.previousRowOption = expansionOptionButton; 
	elseif (mod(index - 1, MAX_EXPANSIONS_IN_ROW) == 0) then -- If we are one past our max per row that means we want to hold onto that to anchor for later. 
		expansionOptionButton:SetPoint("TOP", self.previousRowOption, "BOTTOM", 0, -20);
		self.previousRowOption = expansionOptionButton; 
	else 
		expansionOptionButton:SetPoint("LEFT", self.lastOption, "RIGHT", 20, 0);
	end		

	expansionOptionButton:SetupButton(optionInfo);
	return expansionOptionButton;
end 

function ChromieTimeFrameMixin:SetSelectedExpansion(expansionSelection)
	if (expansionSelection == self.currentExpansionSelection) then -- can't select the same option
		return;
	end 

	if (self.currentExpansionSelection) then 
		self.currentExpansionSelection:ClearSelection(); 
	end 

	self.currentExpansionSelection = expansionSelection; 
	self.SelectButton:UpdateButtonState(self.currentExpansionSelection); 
	self.CurrentlySelectedExpansionInfoFrame:SetCurrentlySelectedExpansion(self.currentExpansionSelection);
end 

function ChromieTimeFrameMixin:GetSelectedExpansion(expansionSelection)
	return self.currentExpansionSelection; 
end 

CurrentlySelectedExpansionInfoFrameMixin = { };

function CurrentlySelectedExpansionInfoFrameMixin:SetCurrentlySelectedExpansion(expacSelection) 
	local expacInfo = expacSelection.buttonInfo; 
	self.Portrait:SetAtlas(expacInfo.mapAtlas);
	self.Name:SetText(expacInfo.name);
	self.Description:SetText(expacInfo.description);
end 

function CurrentlySelectedExpansionInfoFrameMixin:ResetSelection() 
	self.Portrait:SetAtlas("ChromieTime-Portrait-Chrome");
	self.Name:SetText(CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE);
	self.Description:SetText(CHROMIE_TIME_PREVIEW_CARD_DEFAULT_DESCRIPTION);
end 

ChromieTimeExpansionButtonMixin = { };

function ChromieTimeExpansionButtonMixin:SetupButton(buttonInfo)
	if(not buttonInfo) then 
		return; 
	end 
	self.Name:SetText(buttonInfo.name);
	self.Background:SetAtlas(buttonInfo.previewAtlas);
	self.buttonInfo = buttonInfo; 
	local disabled = buttonInfo.alreadyOn or buttonInfo.completed; 

	self:SetEnabled(not disabled);
	self.CompletedCheck:SetShown(buttonInfo.completed);
	self.Background:SetDesaturated(disabled);
	self:GetNormalTexture():SetDesaturated(disabled);

	local nameColor = NORMAL_FONT_COLOR;
	if (disabled) then 
		nameColor = GRAY_FONT_COLOR;
	end 
	self.Name:SetTextColor(nameColor:GetRGB()); 
	self:Show(); 
end 

function ChromieTimeExpansionButtonMixin:ClearSelection()
	self:SetNormalAtlas("ChromieTime-Button-Frame", TextureKitConstants.UseAtlasSize);
end 

function ChromieTimeExpansionButtonMixin:OnClick() 
	local ChromieTimeFrame = self:GetParent():GetParent();
	local selectedExpansion = ChromieTimeFrame:GetSelectedExpansion();

	if (selectedExpansion ~= self) then
		PlaySound(SOUNDKIT.UI_CHROMIE_TIME_SELECT_EXPANSION);
	end

	ChromieTimeFrame:SetSelectedExpansion(self);
	self:SetNormalAtlas("ChromieTime-Button-Selection", TextureKitConstants.UseAtlasSize); -- Would like to override the normal texture when it's selected
end 

function ChromieTimeExpansionButtonMixin:OnEnter()
	if (self.buttonInfo.completed) then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 170);
		GameTooltip_AddNormalLine(GameTooltip, CHROMIE_TIME_CAMPAIGN_COMPLETE, true);
	elseif (self.buttonInfo.alreadyOn) then 
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 170);
		GameTooltip_AddNormalLine(GameTooltip, CHROMIE_TIME_CAMPAIGN_ALREADY_ON, true);
	end 
	GameTooltip:Show(); 
end 

function ChromieTimeExpansionButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

ChromieTimeSelectButtonMixin = { }; 

function ChromieTimeSelectButtonMixin:OnShow()
	self:UpdateButtonState(false); 
end 

function ChromieTimeSelectButtonMixin:OnClick()
	self:GetParent():SelectExpansionOption(); 
end 

function ChromieTimeSelectButtonMixin:UpdateButtonState(enabled)
	self:SetEnabled(enabled); 
end 