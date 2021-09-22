--------------------------------------------------
-- DRESS UP MODEL FRAME RESET BUTTON MIXIN
DressUpModelFrameResetButtonMixin = {};

function DressUpModelFrameResetButtonMixin:OnLoad()
	self.modelScene = self:GetParent().ModelScene;
end

function DressUpModelFrameResetButtonMixin:OnClick()
	self.modelScene:Reset();

	local playerActor = self.modelScene:GetPlayerActor();

	if (playerActor) then
		playerActor:SetSheathed(false);
		playerActor:Dress();
	end	
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

--------------------------------------------------
-- DRESS UP MODEL FRAME LINK BUTTON MIXIN
DressUpModelFrameLinkButtonMixin = {};

function DressUpModelFrameLinkButtonMixin:OnClick()
	local playerActor = self:GetParent().ModelScene:GetPlayerActor();
	if playerActor then
		local list = playerActor:GetItemTransmogInfoList();
		local hyperlink = C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList(list);
		if not ChatEdit_InsertLink(hyperlink) then
			ChatFrame_OpenChat(hyperlink);
 	 	end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	end
end

--------------------------------------------------
-- DRESS UP MODEL FRAME CLOSE BUTTON MIXIN
DressUpModelFrameCloseButtonMixin = {};

function DressUpModelFrameCloseButtonMixin:OnClick()
	HideUIPanel(self:GetParent());
end


--------------------------------------------------
-- DRESS UP MODEL FRAME CANCEL BUTTON MIXIN
DressUpModelFrameCancelButtonMixin = {};

function DressUpModelFrameCancelButtonMixin:OnClick()
	HideParentPanel(self);
end


--------------------------------------------------
-- DRESS UP MODEL FRAME MAX MIN MIXIN
DressUpModelFrameMaximizeMinimizeMixin = {};

function DressUpModelFrameMaximizeMinimizeMixin:OnLoad()
	local function OnMaximize(frame)
		local isMinimized = false;
		frame:GetParent():ConfigureSize(isMinimized);
	end
						
	self:SetOnMaximizedCallback(OnMaximize);
						
	local function OnMinimize(frame)
		local isMinimized = true;
		frame:GetParent():ConfigureSize(isMinimized);
	end
						
	self:SetOnMinimizedCallback(OnMinimize);
						
	self:SetMinimizedCVar("miniDressUpFrame");
end

--------------------------------------------------
-- DEFAULT MODEL FRAME FRAME MIXIN
DressUpModelFrameMixin = {};

function DressUpModelFrameMixin:OnLoad()
	self.TitleText:SetText(DRESSUP_FRAME);
end

function DressUpModelFrameMixin:OnShow()
	SetPortraitTexture(DressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	local isAutomaticAction = true;
	local minimized = GetCVarBool("miniDressUpFrame");
	if minimized then
		self.MaximizeMinimizeFrame:Minimize(isAutomaticAction);
	else
		self.MaximizeMinimizeFrame:Maximize(isAutomaticAction);	
	end
	self:SetShownOutfitDetailsPanel(GetCVarBool("showOutfitDetails"));
end

function DressUpModelFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function DressUpModelFrameMixin:OnDressModel()
	if self.OutfitDropDown then	
		if not self.gotDressed then
			self.gotDressed = true;
			C_Timer.After(0, function()
				self.gotDressed = nil;
				self.OutfitDropDown:UpdateSaveButton();
				self.OutfitDetailsPanel:OnAppearanceChange();
			end);
		end
	end
end

function DressUpModelFrameMixin:ToggleOutfitDetails()
	local show = not self.OutfitDetailsPanel:IsShown();
	self:SetShownOutfitDetailsPanel(show);
	SetCVar("showOutfitDetails", show);
end

function DressUpModelFrameMixin:ConfigureSize(isMinimized)
	if isMinimized then
		self:SetSize(334, 423);
		self.OutfitDetailsPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", -4, -1);
		self.OutfitDropDown:SetPoint("TOP", -42, -28);
		UIDropDownMenu_SetWidth(self.OutfitDropDown, 120);
	else
		self:SetSize(450, 545);
		self.OutfitDetailsPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", -9, -29);
		self.OutfitDropDown:SetPoint("TOP", -23, -28);
		UIDropDownMenu_SetWidth(self.OutfitDropDown, 163);
	end
	UpdateUIPanelPositions(self);
end

function DressUpModelFrameMixin:SetShownOutfitDetailsPanel(show)
	self.OutfitDetailsPanel:SetShown(show);
	local outfitDetailsPanelWidth = 307;
	local extrawidth = show and outfitDetailsPanelWidth or 0;
	SetUIPanelAttribute(self, "extraWidth", extrawidth);
	UpdateUIPanelPositions(self);
end

--------------------------------------------------
-- SIDE DRESS UP MODEL FRAME FRAME MIXIN
SideDressUpModelFrameFrameMixin = {};

function SideDressUpModelFrameFrameMixin:OnShow()
	SetUIPanelAttribute(self.parentFrame, "width", self.openWidth);
	UpdateUIPanelPositions(self.parentFrame);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function SideDressUpModelFrameFrameMixin:OnHide()
	SetUIPanelAttribute(self.parentFrame, "width", self.closedWidth);
	UpdateUIPanelPositions();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

TransmogAndMountDressupFrameMixin = {};

function TransmogAndMountDressupFrameMixin:OnLoad()
	local checkButton = self.ShowMountCheckButton; 
	checkButton.text:SetFontObject("GameFontNormal");
	checkButton.text:ClearAllPoints(); 
	checkButton.text:SetPoint("RIGHT", checkButton, "LEFT"); 
	checkButton.text:SetText(TRANSMOG_AND_MOUNT_DRESSUP_FRAME_SHOW_MOUNT);
end 

function TransmogAndMountDressupFrameMixin:OnHide()
	self.mountID = nil; 
	self.transmogSetID = nil; 
	self.removeWeapons = nil; 
	self.ShowMountCheckButton:SetChecked(false);
end 

function TransmogAndMountDressupFrameMixin:RemoveWeapons()
	for actor in self.ModelScene:EnumerateActiveActors() do
		local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
		local offHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
		actor:UndressSlot(mainHandSlotID);
		actor:UndressSlot(offHandSlotID);
	end
end 

function TransmogAndMountDressupFrameMixin:CheckButtonOnClick()
	if(self.ShowMountCheckButton:GetChecked()) then
		DressUpMount(self.mountID, self);
	else
		local sources = C_TransmogSets.GetAllSourceIDs(self.transmogSetID);
		DressUpTransmogSet(sources, self);
	end

	if(self.removeWeapons) then 
		self:RemoveWeapons(); 
	end 
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end
