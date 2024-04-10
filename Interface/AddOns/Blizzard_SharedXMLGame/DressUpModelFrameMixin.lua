--------------------------------------------------
-- DRESS UP MODEL FRAME RESET BUTTON MIXIN
DressUpModelFrameResetButtonMixin = {};
function DressUpModelFrameResetButtonMixin:OnLoad()
	self.modelScene = self:GetParent().ModelScene;
end

function DressUpModelFrameResetButtonMixin:OnClick()
	local itemModifiedAppearanceIDs = nil;
	local forcePlayerRefresh = true;
	DressUpFrame_Show(self:GetParent(), itemModifiedAppearanceIDs, forcePlayerRefresh, self:GetParent():GetLastLink())
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

--------------------------------------------------
-- DRESS UP MODEL FRAME LINK BUTTON MIXIN
DressUpModelFrameLinkButtonMixin = {};
function DressUpModelFrameLinkButtonMixin:OnShow()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LINK_TRANSMOG_OUTFIT) then
		local helpTipInfo = {
			text = LINK_TRANSMOG_OUTFIT_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_LINK_TRANSMOG_OUTFIT,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Left,
			offsetY = 5,
		};
		HelpTip:Show(self, helpTipInfo);
	end

	ChatEdit_RegisterForStickyFocus(self);
end

function DressUpModelFrameLinkButtonMixin:OnHide()
	ChatEdit_UnregisterForStickyFocus(self);
end

local function LinkOutfitDropDownInit()
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	local itemTransmogInfoList = playerActor and playerActor:GetItemTransmogInfoList();

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	info.text = TRANSMOG_OUTFIT_POST_IN_CHAT;
	info.func = function()
		local hyperlink = C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList(itemTransmogInfoList);
		if not ChatEdit_InsertLink(hyperlink) then
			ChatFrame_OpenChat(hyperlink);
		end
	end;
	UIDropDownMenu_AddButton(info);

	info.text = TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD;
	info.func = function()
		local slashCommand = TransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList);
		CopyToClipboard(slashCommand);
		DEFAULT_CHAT_FRAME:AddMessage(TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD_NOTICE, YELLOW_FONT_COLOR:GetRGB());
	end;
	UIDropDownMenu_AddButton(info);
end

function DressUpModelFrameLinkButtonMixin:OnLoad()
	UIDropDownMenu_Initialize(self.DropDown, LinkOutfitDropDownInit, "MENU");
end

function DressUpModelFrameLinkButtonMixin:OnClick()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LINK_TRANSMOG_OUTFIT, true);
	HelpTip:Hide(self, LINK_TRANSMOG_OUTFIT_HELPTIP);

	ToggleDropDownMenu(1, nil, self.DropDown, self, 136, 73);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function DressUpModelFrameLinkButtonMixin:HasStickyFocus()
	if self:IsMouseOver() then
		return true;
	end
	if UIDropDownMenu_GetCurrentDropDown() == self.DropDown and DropDownList1:IsMouseOver() then
		return true;
	end
	return false;
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
-- BASE MODEL FRAME FRAME MIXIN
DressUpModelFrameBaseMixin = { };
function DressUpModelFrameBaseMixin:OnLoad()
	self.ModelScene:SetResetCallback(GenerateClosure(self.OnModelSceneReset, self));
end

function DressUpModelFrameBaseMixin:GetLastLink()
	return self.lastLink;
end

function DressUpModelFrameBaseMixin:SetLastLink(link)
	self.lastLink = link;
end

function DressUpModelFrameBaseMixin:OnModelSceneReset()
	if self.lastLink then
		DressUpLink(self.lastLink, self);
	end
end

function DressUpModelFrameBaseMixin:SetMode(mode)
	self.mode = mode;
	if self.hasOutfitControls then
		local inPlayerMode = mode == "player";
		self.ResetButton:SetShown(inPlayerMode);
		self.LinkButton:SetShown(inPlayerMode);
		self.ToggleOutfitDetailsButton:SetShown(inPlayerMode);
		self.OutfitDropDown:SetShown(inPlayerMode);
		if not inPlayerMode then
			self:SetShownOutfitDetailsPanel(false);
		else
			self:SetShownOutfitDetailsPanel(GetCVarBool("showOutfitDetails"));
		end
	end
end

function DressUpModelFrameBaseMixin:GetMode()
	return self.mode;
end

--------------------------------------------------
-- DEFAULT MODEL FRAME FRAME MIXIN
DressUpModelFrameMixin = CreateFromMixins(DressUpModelFrameBaseMixin);
function DressUpModelFrameMixin:OnLoad()
	DressUpModelFrameBaseMixin.OnLoad(self);
	self:SetTitle(DRESSUP_FRAME);

	self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);
end

function DressUpModelFrameMixin:OnShow()
	SetPortraitTexture(DressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function DressUpModelFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	if self.forcedMaximized then
		self.forcedMaximized = nil;
		local minimized = GetCVarBool("miniDressUpFrame");
		if minimized then
			local isAutomaticAction = true;
			self.MaximizeMinimizeFrame:Minimize(isAutomaticAction);
		end
	end
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

function DressUpModelFrameMixin:ForceOutfitDetailsOn()
	self.forcedMaximized = true;
	local isAutomaticAction = true;
	self.MaximizeMinimizeFrame:Maximize(isAutomaticAction);
	self:SetShownOutfitDetailsPanel(true);
end

--------------------------------------------------
-- SIDE DRESS UP MODEL FRAME FRAME MIXIN
SideDressUpModelFrameFrameMixin = CreateFromMixins(DressUpModelFrameBaseMixin);
function SideDressUpModelFrameFrameMixin:OnLoad()
	DressUpModelFrameBaseMixin.OnLoad(self);
	self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);
end

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

--------------------------------------------------
-- TRANSMOG AND MOUNT DRESS UP MODEL FRAME FRAME MIXIN
TransmogAndMountDressupFrameMixin = CreateFromMixins(DressUpModelFrameBaseMixin);
function TransmogAndMountDressupFrameMixin:OnLoad()
	DressUpModelFrameBaseMixin.OnLoad(self);

	local checkButton = self.ShowMountCheckButton;
	checkButton.Text:SetFontObject("GameFontNormal");
	checkButton.Text:ClearAllPoints();
	checkButton.Text:SetPoint("RIGHT", checkButton, "LEFT");
	checkButton.Text:SetText(TRANSMOG_AND_MOUNT_DRESSUP_FRAME_SHOW_MOUNT);
end

function TransmogAndMountDressupFrameMixin:OnHide()
	self.mountID = nil;
	self.transmogSetID = nil;
	self.removeWeapons = nil;
	self.ShowMountCheckButton:SetChecked(false);
	if self.removingWeapons then
		self.removingWeapons = nil;
		self:SetScript("OnUpdate", nil);
	end
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function TransmogAndMountDressupFrameMixin:OnDressModel()
	if self.removeWeapons and not self.removingWeapons then
		self.removingWeapons = true;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function TransmogAndMountDressupFrameMixin:OnUpdate()
	self:RemoveWeapons();
	self.removingWeapons = nil;
	self:SetScript("OnUpdate", nil);
end
