local CONDUIT_PENDING_INSTALL_FONT_COLOR = CreateColor(0.0, 0.8, 1.0);

local ConduitChargeSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
ConduitChargeSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, true, true);

function ConduitChargeSecondsFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

ConduitChargeMixin = {};

local CONDUIT_CHARGE_STATE_AVAILABLE = 1;
local CONDUIT_CHARGE_STATE_PENDING = 2;
local CONDUIT_CHARGE_STATE_UNAVAILABLE = 3;

function ConduitChargeMixin:SetState(state)
	local useAtlasSize = true;
	if state == CONDUIT_CHARGE_STATE_AVAILABLE then
		self.Icon:SetAtlas("soulbinds_collection_charge_active", useAtlasSize);
		self.PendingOverlay:SetAtlas(nil);
	elseif state == CONDUIT_CHARGE_STATE_PENDING then
		self.Icon:SetAtlas("soulbinds_collection_charge_pending", useAtlasSize);
		self.PendingOverlay:SetAtlas("soulbinds_collection_charge_pending", useAtlasSize);
	elseif state == CONDUIT_CHARGE_STATE_UNAVAILABLE then
		self.Icon:SetAtlas("soulbinds_collection_charge_inactive", useAtlasSize);
		self.PendingOverlay:SetAtlas(nil);
	end
end

function ConduitChargeMixin:OnShow()
	self.PendingOverlay.Anim:Play();
end

ConduitChargesTrayEvents = 
{
	"SOULBIND_CONDUIT_CHARGES_UPDATED",
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"CURRENCY_DISPLAY_UPDATE",
};

ConduitChargesTrayMixin = {};

function ConduitChargesTrayMixin:OnLoad()
	self.pool = CreateFramePool("FRAME", self, "ConduitChargeTemplate");
	self.frames = {};

	local capacity = C_Soulbinds.GetConduitChargesCapacity();
	local function FactoryFunction(index)
		if index > capacity then
			return nil;
		end

		local frame = self.pool:Acquire();
		table.insert(self.frames, frame);
		frame:Show();
		return frame;
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT");
	local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, capacity, -6, 0;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, capacity, anchor, layout);
end

function ConduitChargesTrayMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitChargesTrayEvents);
end

function ConduitChargesTrayMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitChargesTrayEvents);
end

function ConduitChargesTrayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -4);
	GameTooltip_SetTitle(GameTooltip, CONDUIT_CHARGE_HEADER);
	GameTooltip_AddNormalLine(GameTooltip, CONDUIT_CHARGE_DESCRIPTION);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	local time = ConduitChargeSecondsFormatter:Format(C_DateAndTime.GetSecondsUntilDailyReset());
	local text = CONDUIT_CHARGE_REPLENISHMENT_TIME:format(WHITE_FONT_COLOR:WrapTextInColorCode(time));
	GameTooltip_AddNormalLine(GameTooltip, text);

	GameTooltip:Show();
end

function ConduitChargesTrayMixin:OnLeave()
	GameTooltip_Hide();
end

function ConduitChargesTrayMixin:Init()
	self:EvaluateCharges();
end

function ConduitChargesTrayMixin:EvaluateCharges()
	local charges = C_Soulbinds.GetConduitCharges();
	local unused = charges - C_Soulbinds.GetTotalConduitChargesPending();
	for index = 1, unused do
		self.frames[index]:SetState(CONDUIT_CHARGE_STATE_AVAILABLE);
	end

	for index = unused + 1, charges do
		self.frames[index]:SetState(CONDUIT_CHARGE_STATE_PENDING);
	end

	local capacity = C_Soulbinds.GetConduitChargesCapacity();
	for index = charges + 1, capacity do
		self.frames[index]:SetState(CONDUIT_CHARGE_STATE_UNAVAILABLE);
	end
end

function ConduitChargesTrayMixin:SetPendingCount(pendingCount)
	local available = Clamp(pendingCount, 0, C_Soulbinds.GetConduitCharges());
	self.pendingCount = Clamp(available, 0, C_Soulbinds.GetConduitChargesCapacity());
	self:EvaluateCharges();
end

function ConduitChargesTrayMixin:OnEvent(event, ...)
	if event == "SOULBIND_CONDUIT_CHARGES_UPDATED" or event == "SOULBIND_PENDING_CONDUIT_CHANGED" or 
		event == "SOULBIND_CONDUIT_INSTALLED" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:EvaluateCharges();
	end
end

ConduitListCategoryButtonMixin = CreateFromMixins(CallbackRegistryMixin);

ConduitListCategoryButtonMixin:GenerateCallbackEvents(
	{
		"OnExpandedChanged",
	}
);

function ConduitListCategoryButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.expanded = false;
	self:SetExpanded(true);
end

local function GetConduitIconScale(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return 1.0;
	end
end

function ConduitListCategoryButtonMixin:Init(conduitType)
	local name = self.Container.Name;
	name:SetText(Soulbinds.GetConduitName(conduitType));
	name:SetWidth(name:GetStringWidth() + 40);

	local useAtlasSize = false;
	local icon = self.Container.ConduitIcon;
	icon:SetAtlas(Soulbinds.GetConduitEmblemAtlas(conduitType), false);
	icon:SetScale(GetConduitIconScale(conduitType));
	icon:SetPoint("LEFT", name, "RIGHT", -40, -1);
end

function ConduitListCategoryButtonMixin:OnEnter()
	for index, element in ipairs(self.Container.Hovers) do
		element:Show();
	end
end

function ConduitListCategoryButtonMixin:OnLeave()
	for index, element in ipairs(self.Container.Hovers) do
		element:Hide();
	end
	GameTooltip_Hide();
end

function ConduitListCategoryButtonMixin:OnMouseDown()
	self.Container:AdjustPointsOffset(1, -1);
end

function ConduitListCategoryButtonMixin:OnMouseUp()
	self.Container:AdjustPointsOffset(-1, 1);
end

function ConduitListCategoryButtonMixin:OnClick(buttonName)
	self:SetExpanded(not self.expanded);
end

function ConduitListCategoryButtonMixin:SetExpanded(expanded)
	local changed = self.expanded ~= expanded;
	self.expanded = expanded;

	local atlas = expanded and "Soulbinds_Collection_CategoryHeader_Collapse" or "Soulbinds_Collection_CategoryHeader_Expand";
	local useAtlasSize = true;
	self.Container.ExpandableIcon:SetAtlas(atlas, useAtlasSize);

	if changed then
		if expanded then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, nil, SOUNDKIT_ALLOW_DUPLICATES);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF, nil, SOUNDKIT_ALLOW_DUPLICATES);
		end
		self:TriggerEvent(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.expanded);
	end
end

function ConduitListCategoryButtonMixin:IsExpanded()
	return self.expanded;
end

ConduitListConduitButtonMixin = {};

ConduitListConduitButtonMixin.State =
{
	Uninstalled = 1,
	Installed = 2,
	Pending = 3,
}

ConduitListConduitButtonEvents = {
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"CURSOR_CHANGED",
};

function ConduitListConduitButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function ConduitListConduitButtonMixin:Init(conduitData)
	self.conduitData = conduitData;
	self.conduit = SoulbindConduitMixin_Create(conduitData.conduitID, conduitData.conduitRank);

	local itemID = conduitData.conduitItemID;
	local item = Item:CreateFromItemID(itemID);
	local itemCallback = function()
		self.ConduitName:SetSize(150, 30);
		self.ConduitName:SetText(item:GetItemName());
		self.ConduitName:SetHeight(self.ConduitName:GetStringHeight());
		
		local yOffset = self.ConduitName:GetNumLines() > 1 and -6 or 0;
		self.ConduitName:ClearAllPoints();
		self.ConduitName:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 10, yOffset);
		self.ConduitName:SetWidth(150);

		self.ItemLevel:SetPoint("TOPLEFT", self.ConduitName, "BOTTOMLEFT", 0, 0);
		self.ItemLevel:SetText(conduitData.conduitItemLevel);
	end;
	item:ContinueOnItemLoad(itemCallback);

	local icon = item:GetItemIcon();
	self.Icon:SetTexture(icon);
	self.Icon2:SetTexture(icon);
	self.IconPulse:SetTexture(icon);

	local conduitQuality = C_Soulbinds.GetConduitQuality(conduitData.conduitID, conduitData.conduitRank);
	local color = ITEM_QUALITY_COLORS[conduitQuality];
	local r, g, b = color.r, color.g, color.b;
	self.IconOverlay:SetVertexColor(r, g, b);
	self.IconOverlay2:SetVertexColor(r, g, b);
	self.IconOverlayDark:SetVertexColor(0, 0, 0);
	self.ConduitName:SetTextColor(r, g, b);

	local conduitSpecName = conduitData.conduitSpecName;
	if conduitSpecName then
		local specIDs = C_SpecializationInfo.GetSpecIDs(conduitData.conduitSpecSetID);
		self.Spec.Icon:SetTexture(select(4, GetSpecializationInfoByID(specIDs[1])));

		local isCurrentSpec = C_SpecializationInfo.MatchesCurrentSpecSet(conduitData.conduitSpecSetID);
		if isCurrentSpec then
			self.Spec.stateAlpha = 1;
			self.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
			self.ItemLevel:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		else
			self.Spec.stateAlpha = .4;
			self.Spec.stateAtlas = "soulbinds_collection_specborder_secondary";
			self.ItemLevel:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		end
		self.Spec.Icon:SetAlpha(self.Spec.stateAlpha);

		self.Spec:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.Spec, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, conduitSpecName);
			GameTooltip:Show();
		end);
		self.Spec:SetScript("OnLeave", function()
			GameTooltip_Hide();
		end);
		self.Spec:Show();
	else
		self.ItemLevel:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		self.Spec:Hide();
		self.Spec:SetScript("OnEnter", nil);
		self.Spec:SetScript("OnLeave", nil);
		self.Spec.stateAlpha = 1;
		self.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
	end

	self:Update();
end

function ConduitListConduitButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID, conduitID = ...;
		self:Update();
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		local nodeID, conduitData = ...;
		if conduitData.conduitID == self.conduitData.conduitID then
			self:UpdateVisuals(ConduitListConduitButtonMixin.State.Installed);
		end
	elseif event == "SOULBIND_CONDUIT_UNINSTALLED" then
		local nodeID, conduitData = ...;
		if conduitData.conduitID == self.conduitData.conduitID then
			self:UpdateVisuals(ConduitListConduitButtonMixin.State.Uninstalled);
		end
	elseif event == "CURSOR_CHANGED" then
		local conduitData = C_Soulbinds.GetConduitCollectionDataAtCursor();
		local pending = conduitData and conduitData.conduitID == self.conduitData.conduitID;
		self.PendingBackground:SetShown(pending);
	end
end

function ConduitListConduitButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListConduitButtonEvents);
end

function ConduitListConduitButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListConduitButtonEvents);
end

function ConduitListConduitButtonMixin:MatchesID(conduitID)
	return self.conduitData.conduitID == conduitID;
end

function ConduitListConduitButtonMixin:PlayUpdateAnimation()
	SoulbindViewer.ConduitList:PlayLearnAnimation(self);
end

function ConduitListConduitButtonMixin:UpdateVisuals(state)
	local installed = state == ConduitListConduitButtonMixin.State.Installed;
	local pending = state == ConduitListConduitButtonMixin.State.Pending;
	local dark = installed or pending;
	self.ConduitName:SetAlpha(dark and .5 or 1);
	self.ItemLevel:SetAlpha(dark and .2 or 1);
	self.IconOverlayDark:SetShown(dark);
	self.IconDark:SetShown(dark);
	
	local specIconAlpha = dark and .2 or self.Spec.stateAlpha;
	local specIconAtlas = dark and "soulbinds_collection_specborder_tertiary" or self.Spec.stateAtlas;
	local useAtlasSize = true;
	self.Spec.IconOverlay:SetAtlas(specIconAtlas, useAtlasSize);
	self.Spec.Icon:SetAlpha(specIconAlpha);
	self.Pending:SetShown(pending);
end

function ConduitListConduitButtonMixin:Update()
	self:UpdateVisuals(self:GetState());
end

function ConduitListConduitButtonMixin:GetState()
	local soulbindID = Soulbinds.GetOpenSoulbindID();
	local conduitID = self.conduitData.conduitID;
	
	local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID);
	if pendingInstallNodeID > 0 then
		return ConduitListConduitButtonMixin.State.Pending;
	end

	local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID);
	if pendingUninstallNodeID > 0 then
		return ConduitListConduitButtonMixin.State.Uninstalled;
	end

	local installed = C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID);
	if installed then
		return ConduitListConduitButtonMixin.State.Installed;
	end

	return ConduitListConduitButtonMixin.State.Uninstalled;
end

function ConduitListConduitButtonMixin:OnClick(buttonName)
	if buttonName == "LeftButton" then
		local linked = false;
		if IsModifiedClick("CHATLINK") then
			linked = HandleModifiedItemClick(self.conduit:GetHyperlink());
		end

		if not linked then
			self:CreateCursor();
		end
	elseif buttonName == "RightButton" then
		local soulbindID = Soulbinds.GetOpenSoulbindID();
		local conduitID = self.conduitData.conduitID;

		local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID);
		if pendingInstallNodeID > 0 then
			C_Soulbinds.UnmodifyNode(pendingInstallNodeID);
		else
			local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID);
			if pendingUninstallNodeID > 0 then
				C_Soulbinds.UnmodifyNode(pendingUninstallNodeID);
			end
		end

		SoulbindViewer:OnCollectionConduitClick(conduitID);
	end
end

function ConduitListConduitButtonMixin:OnDragStart()
	self:CreateCursor();
end

function ConduitListConduitButtonMixin:CreateCursor()
	SetCursorVirtualItem(self.conduitData.conduitItemID, Enum.UICursorType.ConduitCollectionItem);
end

function ConduitListConduitButtonMixin:OnEnter(conduitData)
	local onConduitLoad = function()
		if self.conduitOnSpellLoadCb then
			self.conduitOnSpellLoadCb = nil;
		end

		GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 178, 0);
		
		local conduitID = self.conduit:GetConduitID();
		GameTooltip:SetConduit(conduitID, self.conduit:GetConduitRank());

		local soulbindID = Soulbinds.GetOpenSoulbindID();
		if C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID) > 0 then
			GameTooltip_AddColoredLine(GameTooltip, CONDUIT_COLLECTION_ITEM_PENDING, CONDUIT_PENDING_INSTALL_FONT_COLOR);
		else
			if C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID) == 0 then
				if C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID) then
					GameTooltip_AddErrorLine(GameTooltip, CONDUIT_COLLECTION_ITEM_SOCKETED);
				end	
			end
		end
		GameTooltip:Show();
	end;

	self.conduitOnSpellLoadCb = self.conduit:ContinueWithCancelOnSpellLoad(onConduitLoad);

	for index, element in ipairs(self.Hovers) do
		element:Show();
	end

	local conduitType = self.conduitData.conduitType;
	local conduitID = self.conduitData.conduitID;
	Soulbinds.SetPreviewConduit(conduitType, conduitID);
	SoulbindViewer:OnCollectionConduitEnter(conduitType, self.conduit:GetConduitID());
end

function ConduitListConduitButtonMixin:OnLeave(collectionData)
	if self.conduitOnSpellLoadCb then
		self.conduitOnSpellLoadCb();
		self.conduitOnSpellLoadCb = nil;
	end

	GameTooltip_Hide();

	for index, element in ipairs(self.Hovers) do
		element:Hide();
	end
	
	Soulbinds.ClearPreviewConduit();
	SoulbindViewer:OnCollectionConduitLeave();
end

function ConduitListConduitButtonMixin:SetConduitPulsePlaying(playing)
	self.IconOverlayPulse.Anim:SetPlaying(playing);
	self.IconPulse.Anim:SetPlaying(playing);
end

ConduitListSectionMixin = CreateFromMixins(CallbackRegistryMixin);

ConduitListSectionMixin:GenerateCallbackEvents(
	{
		"OnCollapsibleChanged",
	}
);

function ConduitListSectionMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.pool = CreateFramePool("BUTTON", self.Container, "ConduitListConduitButtonTemplate");
	self.CategoryButton:RegisterCallback(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.OnExpandedChanged, self);
end

function ConduitListSectionMixin:Init(collection)
	self:BuildConduits(collection);

	self.CategoryButton:Init(self.conduitType);
end

function ConduitListSectionMixin:Update()
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:Update();
	end
end

function ConduitListSectionMixin:SetConduitPulsePlaying(playing)
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:SetConduitPulsePlaying(playing);
	end
end

function ConduitListSectionMixin:FindConduitButton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
end

function ConduitListSectionMixin:AddCollectionData(collectionData)
	local conduitButton = self:FindConduitButton(collectionData.conduitID);
	if conduitButton then
		conduitButton:PlayUpdateAnimation();
		return true, conduitButton;
	end
	return false;
end

function ConduitListSectionMixin:BuildConduits(collection)
	self.pool:ReleaseAll();

	local count = #collection;
	local function FactoryFunction(index)
		if index > count then
			return nil;
		end

		local frame = self.pool:Acquire();
		frame:Init(collection[index]);

		frame:SetPoint("LEFT", 0, 0);
		frame:SetPoint("RIGHT", 0, 0);
		frame:Show();
		return frame;
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Container, "TOPLEFT");
	local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, 0;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);

	self:UpdateLayout();

	return count > 0;
end

function ConduitListSectionMixin:OnExpandedChanged(expanded)
	self.Container:SetShown(expanded);
	self.Spacer:SetShown(expanded);
	self:UpdateLayout();

	self:TriggerEvent(ConduitListSectionMixin.Event.OnCollapsibleChanged);
end

function ConduitListSectionMixin:UpdateLayout()
	self.Container:Layout();
	self:Layout();
end

function ConduitListSectionMixin:IsExpanded()
	return self.CategoryButton:IsExpanded();
end

function ConduitListSectionMixin:SetExpanded(expanded)
	self.CategoryButton:SetExpanded(expanded);
end

ConduitListMixin = {};

local ConduitListEvents =
{
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"SOULBIND_CONDUIT_COLLECTION_REMOVED",
	"SOULBIND_CONDUIT_COLLECTION_CLEARED",
	"PLAYER_SPECIALIZATION_CHANGED",
};

function ConduitListMixin:OnLoad()
	for index, list in ipairs(self:GetLists()) do
		list:RegisterCallback(ConduitListSectionMixin.Event.OnCollapsibleChanged, self.OnCollapsibleChanged, self);
	end

	self.Clip:SetPoint("TOPLEFT", -200, 0);
	self.Clip:SetPoint("BOTTOMRIGHT", 200, 0);
end

function ConduitListMixin:OnEvent(event, ...)
	if event == "SOULBIND_CONDUIT_COLLECTION_UPDATED" then
		local collectionData = ...;
		self:OnCollectionDataUpdated(collectionData);
	elseif event == "SOULBIND_CONDUIT_COLLECTION_REMOVED" then
		self:Init();
	elseif event == "SOULBIND_CONDUIT_COLLECTION_CLEARED" then
		self:Init();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Init();
	end
end

function ConduitListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:GetLists()
	return self.ScrollBox.ScrollTarget.Lists;
end

function ConduitListMixin:SetConduitPreview(preview)
	self.preview = preview;
end

function ConduitListMixin:SetConduitListConduitsPulsePlaying(conduitType, playing)
	local section = self:FindListSection(conduitType);
	if section then
		section:SetConduitPulsePlaying(playing);
	end
end

function ConduitListMixin:FindListSection(conduitType)
	local _, section = FindInTableIf(self:GetLists(), function(section)
		return section.conduitType == conduitType;
	end);
	return section;
end

function ConduitListMixin:Init()
	local anyShown = false;
	local parsed = 0;
	local lists = self:GetLists();

	for index, list in ipairs(lists) do
		list.layoutIndex = index;

		local collection = C_Soulbinds.GetConduitCollection(list.conduitType);

		local continuableContainer = ContinuableContainer:Create();
		local matchesSpecSet = {};
		for index, collectionData in ipairs(collection) do
			local specSetID = collectionData.conduitSpecSetID;
			if not matchesSpecSet[specSetID] then
				matchesSpecSet[specSetID] = C_SpecializationInfo.MatchesCurrentSpecSet(specSetID);
			end

			if not collectionData.conduitSpecName then
				collectionData.sortingCategory = 1;
			elseif matchesSpecSet[specSetID] then
				collectionData.sortingCategory = 2;
			else
				collectionData.sortingCategory = 3;
			end

			collectionData.item = Item:CreateFromItemID(collectionData.conduitItemID);
			continuableContainer:AddContinuable(collectionData.item);
		end

		continuableContainer:ContinueOnLoad(function()
			table.sort(collection, function(lhs, rhs)
				if lhs.sortingCategory == rhs.sortingCategory then
					if (not lhs.conduitSpecName or not rhs.conduitSpecName) or lhs.conduitSpecName == rhs.conduitSpecName then
						if lhs.conduitRank ~= rhs.conduitRank then
							return lhs.conduitRank > rhs.conduitRank;	
						end

						return lhs.item:GetItemName() < rhs.item:GetItemName();
					else
						return lhs.conduitSpecName < rhs.conduitSpecName;
					end
				else
					return lhs.sortingCategory < rhs.sortingCategory;
				end
			end);

			local shown = #collection > 0;
			if shown then
				list:Init(collection);
				anyShown = true;
			end

			list:SetShown(shown);

			parsed = parsed + 1;
			if parsed == #lists then
				self.ScrollBox.ScrollTarget:Layout();
				self.BottomShadowContainer.BottomShadow:SetShown(anyShown);
				self.preview:SetShown(not anyShown);

				if anyShown then
					self.Charges:Init();
				end
				self.Fx:SetShown(anyShown);
				self.Charges:SetShown(anyShown);

				local scrollValue = 0;
				local elementExtent = 41;
				ScrollUtil.Init(self.ScrollBar, self.ScrollBox, scrollValue, elementExtent);
			end
		end);
	end
end

function ConduitListMixin:Update()
	for index, list in ipairs(self:GetLists()) do
		list:Update();
	end
end

function ConduitListMixin:PlayLearnAnimation(button)
	local effects = self.Clip.Effects;
	effects:SetPoint("LEFT", button);
	for index, glow in ipairs(effects.Glows) do
		glow.Anim:Play();
	end

	local modelScene = self.Clip.ModelScene;
	if not modelScene.effect then
		local forceUpdate, stopAnim = true, true;
		local ADD_CONDUIT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);
		modelScene.effect = StaticModelInfo.SetupModelScene(modelScene, ADD_CONDUIT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end
	
	modelScene:SetPoint("CENTER", button);
	local MODEL_SCENE_ACTOR_SETTINGS = {["effect"] = { startDelay=0, duration = 0.769, speed = 1 },};
	modelScene:ShowAndAnimateActors(MODEL_SCENE_ACTOR_SETTINGS);

	PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_LEARNED, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function ConduitListMixin:OnCollectionDataUpdated(collectionData)
	self:Init();
	
	local conduitID = collectionData.conduitID;
	for index, list in ipairs(self:GetLists()) do
		local result, conduitButton = list:AddCollectionData(collectionData);
		if result then
			if not list:IsExpanded() then
				list:SetExpanded(true);
			end

			self.ScrollBox:ScrollTo(conduitButton);
			break;
		end
	end
end

function ConduitListMixin:OnCollapsibleChanged()
	self.ScrollBox.ScrollTarget:Layout();
end
