--------------------------------------------------
-- DRESS UP MODEL FRAME RESET BUTTON MIXIN
DressUpModelFrameResetButtonMixin = {};
function DressUpModelFrameResetButtonMixin:OnLoad()
	self.modelScene = self:GetParent().ModelScene;
end

function DressUpModelFrameResetButtonMixin:OnClick()
	local itemModifiedAppearanceIDs = nil;
	local forcePlayerRefresh = true;
	local parent = self:GetParent();
	DressUpFrame_Show(parent, itemModifiedAppearanceIDs, forcePlayerRefresh, parent:GetLastLink())
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	parent.SetSelectionPanel:Hide();
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

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_DRESS_UP_MODEL");

		local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
		local itemTransmogInfoList = playerActor and playerActor:GetItemTransmogInfoList();
		if not itemTransmogInfoList then
			return;
		end

		rootDescription:CreateButton(TRANSMOG_OUTFIT_POST_IN_CHAT, function()
			local hyperlink = C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList(itemTransmogInfoList);
			if not ChatEdit_InsertLink(hyperlink) then
				ChatFrame_OpenChat(hyperlink);
			end
		end);

		rootDescription:CreateButton(TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD, function()
			local slashCommand = TransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList);
			CopyToClipboard(slashCommand);
			DEFAULT_CHAT_FRAME:AddMessage(TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD_NOTICE, YELLOW_FONT_COLOR:GetRGB());
		end);
	end);

	ChatEdit_RegisterForStickyFocus(self);
end

function DressUpModelFrameLinkButtonMixin:OnHide()
	ChatEdit_UnregisterForStickyFocus(self);
end

function DressUpModelFrameLinkButtonMixin:OnClick()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LINK_TRANSMOG_OUTFIT, true);
	HelpTip:Hide(self, LINK_TRANSMOG_OUTFIT_HELPTIP);
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
		self.OutfitDropdown:SetShown(inPlayerMode);
		if not inPlayerMode then
			self:SetShownOutfitDetailsPanel(false);
		else
			self:SetShownOutfitDetailsPanel(GetCVarBool("showOutfitDetails"));
		end

		self.SetSelectionPanel:SetShown(inPlayerMode and self.SetSelectionPanel.setID);
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

	if self.SetSelectionPanel:IsShown() then
		self.SetSelectionPanel:Hide();
	end
end

function DressUpModelFrameMixin:OnDressModel(itemModifiedAppearanceID, invSlot, removed)
	if self.OutfitDropdown then
		if not self.gotDressed then
			self.gotDressed = true;
			C_Timer.After(0, function()
				self.gotDressed = nil;
				self.OutfitDropdown:UpdateSaveButton();
				self.OutfitDetailsPanel:OnAppearanceChange();
			end);
		end
	end

	if self.SetSelectionPanel then
		self.SetSelectionPanel:UpdateTransmogSlot(itemModifiedAppearanceID, invSlot, removed);
	end
end

function DressUpModelFrameMixin:InitSetSelectionPanel(setID, setLink)
	local setItems = C_Transmog.GetAllSetAppearancesByID(setID);
	if self.SetSelectionPanel then
		self.SetSelectionPanel:SetData(setID, setLink, setItems);
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

		self.SetSelectionPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", -7, -1);

		self.OutfitDropdown:SetPoint("TOP", -37, -31);
		self.OutfitDropdown:SetWidth(130);
	else
		self:SetSize(450, 545);
		self.OutfitDetailsPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", -9, -29);

		self.SetSelectionPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", -7, -30);

		self.OutfitDropdown:SetPoint("TOP", -39, -31);
		self.OutfitDropdown:SetWidth(203);
	end
	UpdateUIPanelPositions(self);
end

function DressUpModelFrameMixin:SetShownOutfitDetailsPanel(show)
	if self.SetSelectionPanel:IsShown() then
		self.OutfitDetailsPanel:Hide();
		return;
	end

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

function TransmogAndMountDressupFrameMixin:OnDressModel(itemModifiedAppearanceID, invSlot, removed)
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

--------------------------------------------------
------- TRANSMOG SET DRESS UP FRAME MIXINS -------
DressUpFrameSetSelectionLabelMixin = {};

function DressUpFrameSetSelectionLabelMixin:OnEnter()
	if self:IsTruncated() then
		local coloredSetName = self:GetParent().fullColoredSetName or "";

		if coloredSetName == "" then
			return;
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(coloredSetName);
		GameTooltip:Show();
	end
end

function DressUpFrameSetSelectionLabelMixin:OnLeave()
	GameTooltip:Hide();
end

DressUpFrameTransmogSetMixin = {};

local function ConvertInvTypeToSelectionKey(invType, invSlot)
	if invType == "INVTYPE_SHIELD" or invType == "INVTYPE_WEAPONOFFHAND" or invType == "INVTYPE_HOLDABLE" then
		return "SELECTIONTYPE_OFFHAND";
	end

	if invType == "INVTYPE_2HWEAPON" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_RANGEDRIGHT" then
		return "SELECTIONTYPE_TWOHAND";
	end
	
	if invType == "INVTYPE_WEAPONMAINHAND" then
		return "SELECTIONTYPE_MAINHAND";
	end

	if invType == "INVTYPE_WEAPON" then
		return (invSlot) == INVSLOT_OFFHAND and "SELECTIONTYPE_OFFHAND" or "SELECTIONTYPE_MAINHAND";
	end

	return string.gsub(invType, "INVTYPE", "SELECTIONTYPE");
end

local function DeselectItemByType(selectionList, selectionType)
	if selectionList[selectionType] then
		selectionList[selectionType].selected = false;
		selectionList[selectionType] = nil;
	end
end

local function SelectItem(selectionList, selectionType, itemToSelect)
	if selectionType == "SELECTIONTYPE_TWOHAND" then
		DeselectItemByType(selectionList, "SELECTIONTYPE_OFFHAND");
		DeselectItemByType(selectionList, "SELECTIONTYPE_MAINHAND");
	elseif selectionType == "SELECTIONTYPE_MAINHAND" or selectionType == "SELECTIONTYPE_OFFHAND" then
		DeselectItemByType(selectionList, "SELECTIONTYPE_TWOHAND");
	end

	DeselectItemByType(selectionList, selectionType)
	selectionList[selectionType] = itemToSelect;
	itemToSelect.selected = true;
end

function DressUpFrameTransmogSetMixin:OnLoad()
	local DefaultPad = 0;
	local DefaultSpacing = 1;
	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
	view:SetElementInitializer("DressUpFrameTransmogSetButtonTemplate", function(button, elementData)
		button:InitItem(elementData);
		button:SetScript("OnClick", function(button, buttonName, down)
			self:OnItemSelected(button, elementData);
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local leftX, leftY = 13, -80;
	local rightX, rightY = -10, 8;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", leftX, leftY),
		CreateAnchor("BOTTOMRIGHT", rightX - 22, rightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", leftX, leftY),
		CreateAnchor("BOTTOMRIGHT", rightX, rightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function DressUpFrameTransmogSetMixin:OnShow()
	if self.setID == 0 then
		self:Hide();
		return;
	end

	local parent = self:GetParent();
	parent.OutfitDetailsPanel:Hide();
	parent.ToggleOutfitDetailsButton:Hide();
end

function DressUpFrameTransmogSetMixin:OnHide()
	local parent = self:GetParent();
	if parent.mode == "player" then
		parent.OutfitDetailsPanel:Show();
		parent.ToggleOutfitDetailsButton:Show();
	end

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.setID = 0;
	self.setItems = {};
	self.selectedItems = {};
end

function DressUpFrameTransmogSetMixin:SetData(setID, setLink, setItems)
	self.setID = setID;
	self.setItems = setItems;

	self.cachedSlotUpdates = {};

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.continuableContainer = ContinuableContainer:Create();
	for _, setItem in ipairs(self.setItems) do
		self.continuableContainer:AddContinuable(Item:CreateFromItemID(setItem.itemID));
	end

	self.continuableContainer:ContinueOnLoad(function()
		local name = C_Item.GetItemNameByID(setLink);
		local quality = C_Item.GetItemQualityByID(setLink);
		self.fullColoredSetName = ITEM_QUALITY_COLORS[quality].color:WrapTextInColorCode(name);
		self.SetName:SetText(self.fullColoredSetName);

		self:Init();
	end);
end

function DressUpFrameTransmogSetMixin:UpdateTransmogSlot(itemModifiedAppearanceID, invSlot, removed)
	if not self.setID then
		return;
	end

	local itemID = C_Transmog.GetItemIDForSource(itemModifiedAppearanceID);
	if not itemID then
		return;
	end

	if self.continuableContainer:AreAnyLoadsOutstanding() then
		tinsert(self.cachedSlotUpdates, {itemModifiedAppearanceID, invSlot, removed});
		return;
	end

	local invTypeNum = C_Item.GetItemInventoryTypeByID(itemID);
	local invType = C_Item.GetItemInventorySlotKey(invTypeNum);
	if removed then
		if self.selectedItems then
			local selectionType = ConvertInvTypeToSelectionKey(invType, invSlot);

			-- Special cases for hand items
			if selectionType == "SELECTIONTYPE_TWOHAND" then
				DeselectItemByType(self.selectedItems, "SELECTIONTYPE_OFFHAND");
				DeselectItemByType(self.selectedItems, "SELECTIONTYPE_MAINHAND");
			elseif selectionType == "SELECTIONTYPE_MAINHAND" or selectionType == "SELECTIONTYPE_OFFHAND" then
				DeselectItemByType(self.selectedItems, "SELECTIONTYPE_TWOHAND");
			end

			-- Needed for if the player ctrl click previews another one hander that is put into the offhand slot. 
			-- I.e. on a rogue when the preview a new dagger outside of the set with this frame open
			if selectionType == "SELECTIONTYPE_MAINHAND" and invSlot == INVSLOT_OFFHAND then
				DeselectItemByType(self.selectedItems, "SELECTIONTYPE_OFFHAND");
			else
				DeselectItemByType(self.selectedItems, selectionType);
			end

			self:RefreshItems();
		end
	else
		if self.setID == 0 then
			return;
		end

		local dataProvider = self.ScrollBox:GetDataProvider();
		if dataProvider then
			local findPredicate = function(elementData)
				return elementData.itemModifiedAppearanceID == itemModifiedAppearanceID;
			end;

			local selectionType = ConvertInvTypeToSelectionKey(invType, invSlot);
			local elementData = dataProvider:FindElementDataByPredicate(findPredicate);

			if self.selectedItems then
				if elementData then
					SelectItem(self.selectedItems, elementData.selectionType, elementData);
				else
					DeselectItemByType(self.selectedItems, selectionType);
				end

				local isTwoHandWeapon = selectionType == "SELECTIONTYPE_TWOHAND";
					local actor = self.modelScene:GetPlayerActor();
					-- Special cases for hand items
					if isTwoHandWeapon and invSlot == INVSLOT_MAINHAND then
						DeselectItemByType(self.selectedItems, "SELECTIONTYPE_MAINHAND");
						DeselectItemByType(self.selectedItems, "SELECTIONTYPE_OFFHAND");
						
						if actor then
							actor:UndressSlot(INVSLOT_OFFHAND);
						end
					elseif isTwoHandWeapon and invSlot == INVSLOT_OFFHAND then
						DeselectItemByType(self.selectedItems, "SELECTIONTYPE_OFFHAND");
					elseif selectionType == "SELECTIONTYPE_MAINHAND" or selectionType == "SELECTIONTYPE_OFFHAND" then
						local twoHandWasEquipped = self.selectedItems["SELECTIONTYPE_TWOHAND"];
						DeselectItemByType(self.selectedItems, "SELECTIONTYPE_TWOHAND");

						if twoHandWasEquipped and actor then
							if selectionType == "SELECTIONTYPE_MAINHAND" and not self.selectedItems["SELECTIONTYPE_OFFHAND"] then
								actor:UndressSlot(INVSLOT_OFFHAND);
							elseif selectionType == "SELECTIONTYPE_OFFHAND" and not self.selectedItems["SELECTIONTYPE_MAINHAND"] then
								actor:UndressSlot(INVSLOT_MAINHAND);
							end
						end
					end
			end
		end

		self:RefreshItems();
	end
end

function DressUpFrameTransmogSetMixin:Init()
	if self.setID == 0 or not self.setItems then
		self:Hide();
		return;
	end

	self.modelScene = self:GetParent().ModelScene;
	
	self:Show();

	self.selectedItems = {};
	local dataProvider = CreateDataProvider();
	for _, setItem in ipairs(self.setItems) do
		if setItem.itemID then
			self:CreateSetItemFrame(setItem, dataProvider);
		end
	end

	self:RefreshItems();
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	for _, cachedUpdate in ipairs(self.cachedSlotUpdates) do
		self:UpdateTransmogSlot(cachedUpdate[1], cachedUpdate[2], cachedUpdate[3]);
	end

	self.cachedSlotUpdates = {};
end

function DressUpFrameTransmogSetMixin:CreateSetItemFrame(setItem, dataProvider)
	local tooltipLineTypes = { Enum.TooltipDataLineType.EquipSlot, };

	local result = TooltipUtil.FindLinesFromGetter(tooltipLineTypes, "GetItemByID", setItem.itemID);
	
	setItem.name = C_Item.GetItemNameByID(setItem.itemID);
	setItem.quality = C_Item.GetItemQualityByID(setItem.itemID);

	-- These values might not be properly loaded at the first time this is called. 
	if setItem.name and setItem.quality and result and #result ~= 0 then
		local itemIcon = C_Item.GetItemIconByID(setItem.itemID);
		local selectionType = ConvertInvTypeToSelectionKey(setItem.invType, setItem.invSlot);

		local _, canCollect = C_TransmogCollection.PlayerCanCollectSource(setItem.itemModifiedAppearanceID);
		local elementData = {
			 selected = false,
			 itemName = setItem.name, 
			 itemSlot = result[1],
			 itemUsable = canCollect,
			 itemSlotID = setItem.invSlot,
			 itemIcon = itemIcon,
			 itemQuality = setItem.quality,
			 itemID = setItem.itemID,
			 itemModifiedAppearanceID = setItem.itemModifiedAppearanceID,
			 selectionType = selectionType,
		};

		dataProvider:Insert(elementData);

		local shouldUpdate = not self.selectedItems[selectionType];
		if selectionType == "SELECTIONTYPE_TWOHAND" then 
			shouldUpdate = not self.selectedItems["SELECTIONTYPE_TWOHAND"] and not self.selectedItems["SELECTIONTYPE_MAINHAND"] and not self.selectedItems["SELECTIONTYPE_OFFHAND"];
		end

		if shouldUpdate then
			SelectItem(self.selectedItems, elementData.selectionType, elementData);
		end
	end
end

function DressUpFrameTransmogSetMixin:OnItemSelected(element, elementData)
	self:UpdateSelectedAppearance(elementData);
end

function DressUpFrameTransmogSetMixin:RefreshItems()
	self.ScrollBox:ForEachFrame(function(element, elementData)
		element:Refresh();
	end);
end

function DressUpFrameTransmogSetMixin:UpdateSelectedAppearance(elementData)
	local actor = self.modelScene:GetPlayerActor();
	if not actor then
		return;
	end

	if elementData.selected then
		DeselectItemByType(self.selectedItems, elementData.selectionType);

		-- Manually dressing and undressing these slots to avoid slot switching
		if elementData.selectionType == "SELECTIONTYPE_TWOHAND" then
			actor:DressPlayerSlot(INVSLOT_MAINHAND);
			actor:DressPlayerSlot(INVSLOT_OFFHAND);
		elseif elementData.selectionType == "SELECTIONTYPE_MAINHAND" then
			actor:DressPlayerSlot(INVSLOT_MAINHAND);
		elseif elementData.selectionType == "SELECTIONTYPE_OFFHAND" then
			actor:DressPlayerSlot(INVSLOT_OFFHAND);
		else
			actor:DressPlayerSlot(elementData.itemSlotID + 1);
		end
	else
		SelectItem(self.selectedItems, elementData.selectionType, elementData);

		local isTwoHandWeapon = elementData.selectionType == "SELECTIONTYPE_TWOHAND";
		local isOffHandWeapon = elementData.selectionType == "SELECTIONTYPE_OFFHAND";
		local isMainHandWeapon = elementData.selectionType == "SELECTIONTYPE_MAINHAND";
		if isTwoHandWeapon or isOffHandWeapon or isMainHandWeapon then
			if isMainHandWeapon and not self.selectedItems["SELECTIONTYPE_OFFHAND"] then
				actor:DressPlayerSlot(INVSLOT_OFFHAND);
			elseif isOffHandWeapon then
				if self.selectedItems["SELECTIONTYPE_TWOHAND"] or not self.selectedItems["SELECTIONTYPE_MAINHAND"] then
					actor:DressPlayerSlot(INVSLOT_MAINHAND);
				end
			end
			
			if isTwoHandWeapon then
				actor:DressPlayerSlot(INVSLOT_OFFHAND);
			end

			actor:ResetNextHandSlot();
			actor:TryOn(elementData.itemModifiedAppearanceID, isOffHandWeapon and "SECONDARYHANDSLOT" or "MAINHANDSLOT");
		else
			actor:TryOn(elementData.itemModifiedAppearanceID);
		end
	end

	self:RefreshItems();
end

----------------------------------------------------------------------------------
-- DressUpFrameTransmogSetButtonMixin
----------------------------------------------------------------------------------
DressUpFrameTransmogSetButtonMixin = {}

function DressUpFrameTransmogSetButtonMixin:InitItem(elementData)
	self:Show();
	self.elementData = elementData;
	self:SetSelected(self.elementData.selected);

	local itemSlot = elementData.itemSlot;
	local leftText = itemSlot.leftText or "";
	self.ItemSlot:SetText(leftText);

	-- Allows for the maximum amount of text to be shown in an items name
	local slotWidthCap = self:GetWidth() / 2 - 20;
	local textWidth = self.ItemSlot:GetUnboundedStringWidth();
	self.ItemSlot:SetWidth(math.min(textWidth, slotWidthCap));

	self.Icon:SetTexture(elementData.itemIcon);
	local borderColor = elementData.itemUsable and DressUpOutfitDetailsSlot_GetQualityColorName(elementData.itemQuality) or "error";
	self.IconBorder:SetAtlas("dressingroom-itemborder-"..borderColor);
end

function DressUpFrameTransmogSetButtonMixin:Refresh()
	self.SelectedTexture:SetShown(self.elementData.selected);

	local textColor = ITEM_QUALITY_COLORS[self.elementData.itemQuality].color;
	if not self.elementData.itemUsable then
		textColor = RED_FONT_COLOR;
	end

	self.ItemName:SetText(textColor:WrapTextInColorCode(self.elementData.itemName));
end

function DressUpFrameTransmogSetButtonMixin:SetSelected(selected)
	self.elementData.selected = selected;
	self:Refresh();
end

function DressUpFrameTransmogSetButtonMixin:OnEnter()
	self.HighlightTexture:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, -20);
	GameTooltip:SetItemByItemModifiedAppearanceID(self.elementData.itemModifiedAppearanceID);
	GameTooltip:Show();
end

function DressUpFrameTransmogSetButtonMixin:OnLeave()
	self.HighlightTexture:Hide();
	GameTooltip:Hide();
end