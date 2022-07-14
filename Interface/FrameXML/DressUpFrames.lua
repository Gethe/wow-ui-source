function DressUpLink(link)
	return link and (DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link));
end

function DressUpItemLink(link)
	if( link ) then 
		if ( C_Item.IsDressableItemByID(link) ) then
			return DressUpVisual(link);
		end
	end
	return false;
end

function DressUpItemLocation(itemLocation)
	if( itemLocation and itemLocation:IsValid() ) then 
		local itemTransmogInfo = C_Item.GetCurrentItemTransmogInfo(itemLocation);
		-- non-equippable items won't have an appearanceID
		if itemTransmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
			return DressUpItemTransmogInfo(itemTransmogInfo);
		end
	end
	return false;
end

function DressUpTransmogLink(link)
	if ( not link or not (strsub(link, 1, 16) == "transmogillusion" or strsub(link, 1, 18) == "transmogappearance") ) then
		return false;
	end
	return DressUpVisual(link);
end

local function ShouldAcceptDressUp(frame)
	local parentFrame = frame.parentFrame;
	if parentFrame == nil then
		return;
	end

	if parentFrame.ShouldAcceptDressUp then
		return parentFrame:ShouldAcceptDressUp();
	end

	return parentFrame:IsShown();
end

local function GetFrameAndSetBackground(raceFilename, classFilename)
	local frame;
	if ShouldAcceptDressUp(SideDressUpFrame) then
		frame = SideDressUpFrame;
		if not raceFilename then
			raceFilename = select(2, UnitRace("player"));
		end
	elseif ShouldAcceptDressUp(TransmogAndMountDressupFrame) then
		frame = TransmogAndMountDressupFrame;
		if not raceFilename then
			raceFilename = select(2, UnitRace("player"));
		end
	else
		frame = DressUpFrame;
		if not classFilename then
			classFilename = select(2, UnitClass("player"));
		end
	end

	SetDressUpBackground(frame, raceFilename, classFilename);

	return frame;
end

function DressUpVisual(...)
	local frame = GetFrameAndSetBackground();
	DressUpFrame_Show(frame);

	local playerActor = frame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return false;
	end

	local result = playerActor:TryOn(...);
	if ( result ~= Enum.ItemTryOnReason.Success ) then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_EQUIPPABLE);
	end
	return true;
end

-- For ctrl-clicking in the Appearances collection
function DressUpCollectionAppearance(appearanceID, transmogLocation, categoryID)
	local frame = GetFrameAndSetBackground();
	DressUpFrame_Show(frame);

	local playerActor = frame.ModelScene:GetPlayerActor();
	if not playerActor then
		return false;
	end

	local itemTransmogInfo;
	-- if the equipped item has an active secondary appearance then only change the correct appearance
	-- at the transmogrifier check the checkbox state
	if C_Transmog.CanHaveSecondaryAppearanceForSlotID(transmogLocation.slotID) then
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(transmogLocation.slotID);
		if (C_Transmog.IsAtTransmogNPC() and WardrobeTransmogFrame:HasActiveSecondaryAppearance()) or TransmogUtil.IsSecondaryTransmoggedForItemLocation(itemLocation) then
			itemTransmogInfo = playerActor:GetItemTransmogInfo(transmogLocation.slotID);
			if transmogLocation:IsSecondary() then
				itemTransmogInfo.secondaryAppearanceID = appearanceID;
			else
				-- if the item on the actor doesn't already have a secondary, copy over one to the other (items previewed via other means do not have secondaries set)
				if itemTransmogInfo.secondaryAppearanceID == Constants.Transmog.NoTransmogID then
					itemTransmogInfo.secondaryAppearanceID = itemTransmogInfo.appearanceID;
				end
				itemTransmogInfo.appearanceID = appearanceID;
			end
		end
	end

	if not itemTransmogInfo then
		itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(appearanceID);
	end

	local weaponSlotID = nil;
	local ignoreChildItems = true;
	if categoryID then
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
		-- weapons that can go in either hand need the slot specified
		weaponSlotID = (canMainHand and canOffHand) and transmogLocation.slotID or nil;
		-- configure the secondary for mainhands
		if transmogLocation.slotID == INVSLOT_MAINHAND then
			local isLegionArtifact = TransmogUtil.IsCategoryLegionArtifact(categoryID);
			itemTransmogInfo:ConfigureSecondaryForMainHand(isLegionArtifact);
			-- we only want child items if the appearance is from Legion Artifact category
			if isLegionArtifact then
				ignoreChildItems = false;
			end
		end
	end

	local result = playerActor:SetItemTransmogInfo(itemTransmogInfo, weaponSlotID, ignoreChildItems);
	if result ~= Enum.ItemTryOnReason.Success then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_EQUIPPABLE);
	end
	return true;
end

function DressUpTransmogSet(itemModifiedAppearanceIDs, forcedFrame)
	local frame = forcedFrame or GetFrameAndSetBackground();
	DressUpFrame_Show(frame);
	DressUpFrame_ApplyAppearances(frame, itemModifiedAppearanceIDs);
end

function DressUpBattlePetLink(link)
	if( link ) then 
		local _, _, _, linkType, linkID, _, _, _, _, _, battlePetID, battlePetDisplayID = strsplit(":|H", link);
		if ( linkType == "item") then
			local _, _, _, creatureID, _, _, _, _, _, _, _, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tonumber(linkID));
			if (creatureID and displayID) then
				return DressUpBattlePet(creatureID, displayID, speciesID);
			end
		elseif ( linkType == "battlepet" ) then
			local speciesID, _, _, _, _, displayID, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByPetID(battlePetID);
			if ( speciesID == tonumber(linkID)) then
				return DressUpBattlePet(creatureID, displayID, speciesID);
			else
				speciesID = tonumber(linkID);
				local _, _, _, creatureID, _, _, _, _, _, _, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
				displayID = (battlePetDisplayID and battlePetDisplayID ~= "0") and battlePetDisplayID or displayID;
				return DressUpBattlePet(creatureID, displayID, speciesID);
			end
		end
	end
	return false
end

function DressUpBattlePet(creatureID, displayID, speciesID)
	if ( not displayID and not creatureID ) then
		return false;
	end
	
	local frame = GetFrameAndSetBackground("Pet", "warrior");	--default to warrior BG when viewing full Pet/Mounts for now

	--Show the frame
	frame:SetMode("battlepet");if ( not frame:IsShown() or frame:GetMode() ~= "battlepet" ) then
		frame:SetMode("battlepet");
		ShowUIPanel(frame);
	end

	local _, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID);

	frame.ModelScene:ClearScene();
	frame.ModelScene:SetViewInsets(0, 0, 50, 0);
	frame.ModelScene:TransitionToModelSceneID(loadoutModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

	local battlePetActor = frame.ModelScene:GetActorByTag("pet");
	if ( battlePetActor ) then
		battlePetActor:SetModelByCreatureDisplayID(displayID);
		battlePetActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
	end
	return true;
end

function DressUpMountLink(link)
	if( link ) then
		local mountID = 0;

		local _, _, _, linkType, linkID = strsplit(":|H", link);
		if linkType == "item" then
			mountID = C_MountJournal.GetMountFromItem(tonumber(linkID));
		elseif linkType == "spell" then
			mountID = C_MountJournal.GetMountFromSpell(tonumber(linkID));
		end

		if ( mountID ) then
			return DressUpMount(mountID);
		end
	end
	return false
end

function DressUpMount(mountID, forcedFrame)
	if ( not mountID or mountID == 0 ) then
		return false;
	end

	local frame = forcedFrame or GetFrameAndSetBackground("Pet", "warrior");	--default to warrior BG when viewing full Pet/Mounts for now

	--Show the frame
	if ( not frame:IsShown() or frame:GetMode() ~= "mount" ) then
		frame:SetMode("mount");
		ShowUIPanel(frame);
	end

	local creatureDisplayID, _, _, isSelfMount, _, modelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID);
	frame.ModelScene:ClearScene();
	frame.ModelScene:SetViewInsets(0, 0, 0, 0);
	local forceEvenIfSame = true;
	frame.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceEvenIfSame);
	
	local mountActor = frame.ModelScene:GetActorByTag("unwrapped");
	if mountActor then
		mountActor:SetModelByCreatureDisplayID(creatureDisplayID);

		-- mount self idle animation
		if (isSelfMount) then
			mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
			mountActor:SetAnimation(618); -- MountSelfIdle
		else
			mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_ANIM);
			mountActor:SetAnimation(0);
		end
		frame.ModelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview);
	end
	return true;
end

function DressUpTexturePath(raceFileName)
	-- HACK
	if ( not raceFileName ) then
		raceFileName = "Orc";
	end
	-- END HACK

	return "Interface\\DressUpFrame\\DressUpBackground-"..raceFileName;
end

function SetDressUpBackground(frame, raceFilename, classFilename)
	local texture = DressUpTexturePath(raceFilename);
	
	if ( frame.BGTopLeft ) then
		frame.BGTopLeft:SetTexture(texture..1);
	end
	if ( frame.BGTopRight ) then
		frame.BGTopRight:SetTexture(texture..2);
	end
	if ( frame.BGBottomLeft ) then
		frame.BGBottomLeft:SetTexture(texture..3);
	end
	if ( frame.BGBottomRight ) then
		frame.BGBottomRight:SetTexture(texture..4);
	end
	
	if ( frame.ModelBackground and classFilename ) then
		frame.ModelBackground:SetAtlas("dressingroom-background-"..classFilename);
	end
end

function DressUpFrame_Show(frame)
	if ( not frame:IsShown() or frame:GetMode() ~= "player") then
		frame:SetMode("player");

		-- If there's not enough space as-is, try minimizing.
		if not CanShowRightUIPanel(frame) and frame.MaximizeMinimizeFrame and not frame.MaximizeMinimizeFrame:IsMinimized() then
			local isAutomaticAction = true;
			frame.MaximizeMinimizeFrame:Minimize(isAutomaticAction);

			-- Restore the frame to its original state if we still can't fit.
			if not CanShowRightUIPanel(frame) then
				frame.MaximizeMinimizeFrame:Maximize(isAutomaticAction);
			end
		end

		ShowUIPanel(frame);

		frame.ModelScene:ClearScene();
		frame.ModelScene:SetViewInsets(0, 0, 0, 0);
		frame.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
		
		local sheatheWeapons = false;
		local autoDress = true;
		local hideWeapons = false;
		local itemModifiedAppearanceIDs = nil;
		SetupPlayerForModelScene(frame.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons);
	end
end

function DressUpFrame_ApplyAppearances(frame, itemModifiedAppearanceIDs)
	local sheatheWeapons = false;
	local autoDress = true;
	local hideWeapons = false;
	SetupPlayerForModelScene(frame.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons);
end

function DressUpItemTransmogInfo(itemTransmogInfo)
	local frame = GetFrameAndSetBackground();
	DressUpFrame_Show(frame);

	local playerActor = frame.ModelScene:GetPlayerActor();
	if not playerActor or not itemTransmogInfo then
		return false;
	end

	playerActor:SetItemTransmogInfo(itemTransmogInfo);
	return true;
end

function DressUpItemTransmogInfoList(itemTransmogInfoList, showOutfitDetails)
	local frame = GetFrameAndSetBackground();
	DressUpFrame_Show(frame);

	local playerActor = frame.ModelScene:GetPlayerActor();
	if not playerActor or not itemTransmogInfoList then
		return false;
	end

	for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
		local ignoreChildItems = slotID ~= INVSLOT_MAINHAND;
		playerActor:SetItemTransmogInfo(itemTransmogInfo, slotID, ignoreChildItems);
	end

	if showOutfitDetails then
		frame:ForceOutfitDetailsOn();
	end
end

DressUpOutfitMixin = { };

function DressUpOutfitMixin:GetItemTransmogInfoList()
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if playerActor then
		return playerActor:GetItemTransmogInfoList();
	end
	return nil;
end

function DressUpOutfitMixin:LoadOutfit(outfitID)
	if outfitID then
		DressUpItemTransmogInfoList(C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID));
	end
end

function SetUpSideDressUpFrame(parentFrame, closedWidth, openWidth, point, relativePoint, offsetX, offsetY)
	local self = SideDressUpFrame;
	if ( self.parentFrame ) then
		if ( self.parentFrame == parentFrame ) then
			return;
		end
		if ( self:IsShown() ) then
			HideUIPanel(self);
		end
	end	
	self.parentFrame = parentFrame;
	self.closedWidth = closedWidth;
	self.openWidth = openWidth;	
	relativePoint = relativePoint or point;
	self:SetParent(parentFrame);
	self:SetPoint(point, parentFrame, relativePoint, offsetX, offsetY);
end

function CloseSideDressUpFrame(parentFrame)
	if ( SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame == parentFrame ) then
		HideUIPanel(SideDressUpFrame);
	end
end

function SetUpTransmogAndMountDressupFrame(parentFrame, transmogSetID, mountID,  width, height, point, relativePoint, offsetX, offsetY, removeWeapons)
	local self = TransmogAndMountDressupFrame;
	self.parentFrame = parentFrame;
	self.transmogSetID = transmogSetID;
	self.mountID = mountID; 
	self:SetSize(width, height); 
	TransmogAndMountDressupFrame.removeWeapons = removeWeapons;
	relativePoint = relativePoint or point;

	self:SetParent(parentFrame);
	self:SetPoint(point, parentFrame, relativePoint, offsetX, offsetY);
end

DressUpOutfitDetailsPanelMixin = { };

local CLASS_BACKGROUND_SETTINGS = {
	["DEFAULT"] = { desaturation = 0.5, alpha = 0.25 },
	["DEATHKNIGHT"] = { desaturation = 0.5, alpha = 0.30 },
	["DEMONHUNTER"] = { desaturation = 0.5, alpha = 0.30 },
	["HUNTER"] = { desaturation = 0.5, alpha = 0.45 },
	["MAGE"] = { desaturation = 0.5, alpha = 0.45 },
	["PALADIN"] = { desaturation = 0.5, alpha = 0.21 },
	["ROGUE"] = { desaturation = 0.5, alpha = 0.65 },
	["SHAMAN"] = { desaturation = 0.5, alpha = 0.40 },
	["WARLOCK"] = { desaturation = 0.5, alpha = 0.40 },	
}

function DressUpOutfitDetailsPanelMixin:OnLoad()
	self.slotPool = CreateFramePool("FRAME", self, "DressUpOutfitSlotFrameTemplate");
	local classFilename = select(2, UnitClass("player"));
	self.ClassBackground:SetAtlas("dressingroom-background-"..classFilename);
	local settings = CLASS_BACKGROUND_SETTINGS[classFilename] or CLASS_BACKGROUND_SETTINGS["DEFAULT"];
	self.ClassBackground:SetDesaturation(settings.desaturation);
	self.ClassBackground:SetAlpha(settings.alpha);
	local frameLevel = self:GetParent().NineSlice:GetFrameLevel();
	self:SetFrameLevel(frameLevel + 1);
end

function DressUpOutfitDetailsPanelMixin:OnShow()
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
	self:Refresh();
end

function DressUpOutfitDetailsPanelMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
end

function DressUpOutfitDetailsPanelMixin:OnEvent(event, ...)
	if event == "TRANSMOG_COLLECTION_ITEM_UPDATE" then
		if self.waitingOnItemData then
			self:Refresh();
		elseif self.mousedOverFrame then
			self.mousedOverFrame:RefreshAppearanceTooltip();
		end
	elseif event == "TRANSMOG_SOURCE_COLLECTABILITY_UPDATE" then
		self:MarkDirty();
	end
end

function DressUpOutfitDetailsPanelMixin:OnUpdate()
	self:SetScript("OnUpdate", nil);
	self:Refresh();
end

function DressUpOutfitDetailsPanelMixin:OnKeyDown(key)
	if key == WARDROBE_CYCLE_KEY and self.mousedOverFrame then
		self:SetPropagateKeyboardInput(false);
		self.mousedOverFrame:OnCycleKeyDown();
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function DressUpOutfitDetailsPanelMixin:MarkDirty()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function DressUpOutfitDetailsPanelMixin:MarkWaitingOnItemData()
	self.waitingOnItemData = true;
end

function DressUpOutfitDetailsPanelMixin:OnAppearanceChange()
	if self:IsShown() then
		self:Refresh();
	end
end

function DressUpOutfitDetailsPanelMixin:SetMousedOverFrame(frame)
	self.mousedOverFrame = frame;
end

function DressUpOutfitDetailsPanelMixin:Refresh()
	self.slotPool:ReleaseAll();
	self.lastFrame = nil;
	self.validMainHand = false;
	self.waitingOnItemData = false;

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if not playerActor then
		return;
	end
	local itemTransmogInfoList = playerActor:GetItemTransmogInfoList();
	if not itemTransmogInfoList then
		return;
	end

	-- for Legion Artifacts the offhand is virtual
	local mainHandInfo = itemTransmogInfoList[INVSLOT_MAINHAND];
	if mainHandInfo.secondaryAppearanceID == Constants.Transmog.MainHandTransmogIsPairedWeapon then
		local pairedTransmogID = C_TransmogCollection.GetPairedArtifactAppearance(mainHandInfo.appearanceID);
		if pairedTransmogID then
			itemTransmogInfoList[INVSLOT_OFFHAND].appearanceID = pairedTransmogID;
		end
	end
	
	for _, slotID in ipairs(TransmogSlotOrder) do
		local transmogInfo = itemTransmogInfoList[slotID];
		if transmogInfo then
			-- spacer before weapons
			if slotID == INVSLOT_MAINHAND then
				self:AddSlotFrame(nil, nil, nil);
			end
			-- primary
			self:AddSlotFrame(slotID, transmogInfo, "appearanceID");
			-- secondary
			if transmogInfo.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID and C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) then
				self:AddSlotFrame(slotID, transmogInfo, "secondaryAppearanceID");
			end
			-- illusion
			if transmogInfo.illusionID ~= Constants.Transmog.NoTransmogID then
				self:AddSlotFrame(slotID, transmogInfo, "illusionID");
			end
		end
	end
end

function DressUpOutfitDetailsPanelMixin:AddSlotFrame(slotID, transmogInfo, field)
	-- hide offhand if empty and mainhand has something
	if slotID == INVSLOT_OFFHAND and self.validMainHand and transmogInfo.appearanceID == Constants.Transmog.NoTransmogID then
		return;
	end

	local frame = self.slotPool:Acquire();
	local isValid = false;
	if transmogInfo then
		isValid = frame:SetUp(slotID, transmogInfo, field);
		frame:Show();
	else
		-- spacer
		isValid = true;
		frame:Hide();
	end

	if isValid then
		frame.slotID = slotID;
		if self.lastFrame then
			frame:SetPoint("TOPLEFT", self.lastFrame, "BOTTOMLEFT");
		else
			frame:SetPoint("TOPLEFT", 18, -38);
		end
		self.lastFrame = frame;

		if isValid and slotID == INVSLOT_MAINHAND and transmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
			self.validMainHand = true;
		end
	else
		frame:Hide();
	end
end

DressUpOutfitDetailsSlotMixin = { };

function DressUpOutfitDetailsSlotMixin:OnHide()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
	self.item = nil;
end

local OUTFIT_SLOT_STATE_ERROR = 1;
local OUTFIT_SLOT_STATE_COLLECTED = 2;
local OUTFIT_SLOT_STATE_UNCOLLECTED = 3;

local GRAY_FONT_ALPHA = 0.7;

local TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK = "|A:common-icon-checkmark:16:16:0:-1|a "..TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN;

function DressUpOutfitDetailsSlotMixin:OnEnter()
	if not self.transmogID then
		return;
	end

	if self.item and not self.item:IsItemDataCached() then
		self:GetParent():MarkDirty();
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.isHiddenVisual then
		GameTooltip_AddColoredLine(GameTooltip, self.name, NORMAL_FONT_COLOR);
	elseif not self.item then
		-- illusion
		GameTooltip_AddColoredLine(GameTooltip, self.name, NORMAL_FONT_COLOR);
		if self.slotState == OUTFIT_SLOT_STATE_UNCOLLECTED then
			GameTooltip_AddColoredLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, LIGHTBLUE_FONT_COLOR);
		else
			GameTooltip_AddColoredLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK, GREEN_FONT_COLOR);
		end
	elseif self.slotState == OUTFIT_SLOT_STATE_ERROR then
		local hasData, canCollect = C_TransmogCollection.AccountCanCollectSource(self.transmogID);
		-- hasData should be true, there's a check that the item data is cached at the top of the function

		if not canCollect and (self.slotID == INVSLOT_MAINHAND or self.slotID == INVSLOT_OFFHAND) then
			local pairedTransmogID = C_TransmogCollection.GetPairedArtifactAppearance(self.transmogID);
			if pairedTransmogID then
				hasData, canCollect = C_TransmogCollection.AccountCanCollectSource(pairedTransmogID);
				if not hasData then
					self:GetParent():MarkDirty();
					return;
				end
			end
		end

		if canCollect then
			local nameColor = self.item:GetItemQualityColor().color;
			GameTooltip_AddColoredLine(GameTooltip, self.name, nameColor);
			local slotName = TransmogUtil.GetSlotName(self.slotID);
			GameTooltip_AddColoredLine(GameTooltip, _G[slotName], HIGHLIGHT_FONT_COLOR);
			GameTooltip_AddErrorLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNUSABLE);
		else
			local hideVendorPrice = true;
			GameTooltip:SetHyperlink(self.item:GetItemLink(), nil, nil, nil, hideVendorPrice);
			GameTooltip_AddErrorLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNCOLLECTABLE);
		end
	elseif self.slotState == OUTFIT_SLOT_STATE_UNCOLLECTED then
		if C_TransmogCollection.PlayerKnowsSource(self.transmogID) then
			self:GetParent():SetMousedOverFrame(self);
			self:RefreshAppearanceTooltip();
		else
			local nameColor = self.item:GetItemQualityColor().color;
			GameTooltip_AddColoredLine(GameTooltip, self.name, nameColor);
			local slotName = TransmogUtil.GetSlotName(self.slotID);
			GameTooltip_AddColoredLine(GameTooltip, _G[slotName], HIGHLIGHT_FONT_COLOR);
			GameTooltip_AddColoredLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, LIGHTBLUE_FONT_COLOR);
		end
	else
		local nameColor = self.item:GetItemQualityColor().color;
		GameTooltip_AddColoredLine(GameTooltip, self.name, nameColor);
		local slotName = TransmogUtil.GetSlotName(self.slotID);
		GameTooltip_AddColoredLine(GameTooltip, _G[slotName], HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddColoredLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK, GREEN_FONT_COLOR);
	end
	GameTooltip:Show();
end

function DressUpOutfitDetailsSlotMixin:OnLeave()
	self:GetParent():SetMousedOverFrame(nil);
	self.tooltipSourceIndex = nil;
	self.tooltipCycle = nil;
	GameTooltip:Hide();
end

function DressUpOutfitDetailsSlotMixin:OnMouseUp()
	if IsModifiedClick("CHATLINK") and self.transmogID then
		local link;
		if self.item then
			link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID));
		else
			link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID));
		end
		if link then
			if not ChatEdit_InsertLink(link) then
				ChatFrame_OpenChat(link);
			end
		end
	end
end

function DressUpOutfitDetailsSlotMixin:OnCycleKeyDown()
	if not self.tooltipCycle and not self.tooltipSourceIndex then
		return;
	end
	if IsShiftKeyDown() then
		self.tooltipSourceIndex = self.tooltipSourceIndex - 1;
	else
		self.tooltipSourceIndex = self.tooltipSourceIndex + 1;
	end
	self:RefreshAppearanceTooltip();
end

function DressUpOutfitDetailsSlotMixin:RefreshAppearanceTooltip()
	local appearanceInfo = C_TransmogCollection.GetAppearanceInfoBySource(self.transmogID);
	local category = C_TransmogCollection.GetCategoryForItem(self.transmogID);
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(appearanceInfo.appearanceID, category, self.transmogLocation);
	local showUseError = true;	
	local inLegionArtifactCategory = false;
	local slotName = TransmogUtil.GetSlotName(self.slotID);
	local subheaderString = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(_G[slotName]);
	self.tooltipSourceIndex, self.tooltipCycle = CollectionWardrobeUtil.SetAppearanceTooltip(GameTooltip, sources, self.transmogID, self.tooltipSourceIndex, showUseError, inLegionArtifactCategory, subheaderString);
	GameTooltip_AddColoredLine(GameTooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, LIGHTBLUE_FONT_COLOR);
	GameTooltip:Show();
end

function DressUpOutfitDetailsSlotMixin:SetUp(slotID, transmogInfo, field)
	local transmogID = transmogInfo[field];
	local isSecondary = true;
	if field == "appearanceID" then
		return self:SetAppearance(slotID, transmogID, not isSecondary);
	elseif field == "secondaryAppearanceID" then
		return self:SetAppearance(slotID, transmogID, isSecondary);
	elseif field == "illusionID" then
		return self:SetIllusion(slotID, transmogID);
	end
end

function DressUpOutfitDetailsSlotMixin:SetAppearance(slotID, transmogID, isSecondary)
	local modificationType = Enum.TransmogModification.Secondary and isSecondary or Enum.TransmogModification.Main;
	self.transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, modificationType);

	local itemID = C_TransmogCollection.GetSourceItemID(transmogID);
	if not itemID then
		-- no empty slot for secondaries
		if isSecondary then
			return false;
		end
		self.Icon:SetTexture(nil);
		self.IconBorder:SetTexture(nil);
		self.HiddenIcon:Hide();
		local slotName = TransmogUtil.GetSlotName(slotID);
		self.Name:SetFormattedText(TRANSMOG_EMPTY_SLOT_FORMAT, _G[slotName]);
		self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		self.Name:SetAlpha(GRAY_FONT_ALPHA);
		self.transmogID = nil;
	else
		local appearanceInfo = C_TransmogCollection.GetAppearanceInfoBySource(transmogID);
		local hasAllData = false;
		local category = C_TransmogCollection.GetCategoryForItem(transmogID);
		transmogID, hasAllData = CollectionWardrobeUtil.GetPreferredSourceID(transmogID, appearanceInfo, category, self.transmogLocation);
		if not hasAllData then
			self:GetParent():MarkWaitingOnItemData();
		end
		itemID = C_TransmogCollection.GetSourceItemID(transmogID);

		self.item = Item:CreateFromItemID(itemID);
		if not self.item:IsItemDataCached() then
			self.Icon:SetTexture(nil);
			self.IconBorder:SetTexture(nil);
			self.Name:SetText(nil);
		end
		self.itemDataLoadedCancelFunc = self.item:ContinueWithCancelOnItemLoad(GenerateClosure(self.SetItemInfo, self, transmogID, appearanceInfo, isSecondary));
	end

	return true;
end

function DressUpOutfitDetailsSlotMixin:SetItemInfo(transmogID, appearanceInfo, isSecondary)
	local icon = C_TransmogCollection.GetSourceIcon(transmogID);
	local name = self.item:GetItemName();
	local slotState, isHiddenVisual;

	if not appearanceInfo then
		-- either uncollectable, or collectable but hidden until collected
		local hasData, canCollect = C_TransmogCollection.PlayerCanCollectSource(transmogID);
		if canCollect then
			slotState = OUTFIT_SLOT_STATE_UNCOLLECTED;
		else
			slotState = OUTFIT_SLOT_STATE_ERROR;
		end
	elseif appearanceInfo.appearanceIsCollected then
		-- collected
		slotState = OUTFIT_SLOT_COLLECTED;
		isHiddenVisual = C_TransmogCollection.IsAppearanceHiddenVisual(transmogID);	
	else
		-- uncollected
		slotState = OUTFIT_SLOT_STATE_UNCOLLECTED;
	end

	local useSmallIcon = isSecondary;
	self:SetDetails(transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual);
end

function DressUpOutfitDetailsSlotMixin:SetIllusion(slotID, transmogID)
	local illusionInfo = C_TransmogCollection.GetIllusionInfo(transmogID);
	if not illusionInfo then
		return false;
	end

	local name = C_TransmogCollection.GetIllusionStrings(illusionInfo.sourceID);
	local useSmallIcon = true;
	local slotState = illusionInfo.isCollected and OUTFIT_SLOT_STATE_COLLECTED or OUTFIT_SLOT_STATE_UNCOLLECTED;
	local isHiddenVisual = illusionInfo.isHideVisual;
	self:SetDetails(transmogID, illusionInfo.icon, TRANSMOGRIFIED_ENCHANT:format(name), useSmallIcon, slotState, isHiddenVisual);
	
	self.transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Illusion, Enum.TransmogModification.Main);

	return true;
end

local s_qualityToAtlasColorName = {
	[Enum.ItemQuality.Poor] = "gray",
	[Enum.ItemQuality.Common] = "white",
	[Enum.ItemQuality.Uncommon] = "green",
	[Enum.ItemQuality.Rare] = "blue",
	[Enum.ItemQuality.Epic] = "purple",
	[Enum.ItemQuality.Legendary] = "orange",
	[Enum.ItemQuality.Artifact] = "artifact",
	[Enum.ItemQuality.Heirloom] = "account"
};

function DressUpOutfitDetailsSlotMixin:SetDetails(transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
	-- info for tooltip
	self.transmogID = transmogID;
	self.name = name;
	self.slotState = slotState;
	self.isHiddenVisual = isHiddenVisual;

	local nameColor = NORMAL_FONT_COLOR;
	local nameAlpha = 1;
	local borderType;
	if slotState == OUTFIT_SLOT_STATE_ERROR then
		nameColor = RED_FONT_COLOR;
		borderType = "error";
	elseif slotState == OUTFIT_SLOT_STATE_UNCOLLECTED then
		nameColor = GRAY_FONT_COLOR;
		borderType = "uncollected";
		nameAlpha = GRAY_FONT_ALPHA;
	elseif isHiddenVisual then
		borderType = "uncollected";
	else
		-- this is something collected, show in default colors
		if self.item then
			nameColor = self.item:GetItemQualityColor().color;
			local quality = self.item:GetItemQuality();
			local colorName = s_qualityToAtlasColorName[quality];
			borderType = colorName;
		else
			borderType = "illusion";
		end
	end

	self.Name:SetText(name);
	self.Name:SetTextColor(nameColor:GetRGB());
	self.Name:SetAlpha(nameAlpha);

	self.Icon:SetTexture(icon);
	if slotState == OUTFIT_SLOT_STATE_UNCOLLECTED or isHiddenVisual then
		self.Icon:SetAlpha(0.3);
		self.Icon:SetDesaturated(true);
	else
		self.Icon:SetAlpha(1);
		self.Icon:SetDesaturated(false);
	end

	if useSmallIcon then
		borderType = "small-"..borderType;
		self.Icon:SetSize(14, 14);
		if isHiddenVisual then
			self.HiddenIcon:SetSize(24, 20);
		end
	else
		self.Icon:SetSize(20, 20);
		if isHiddenVisual then
			self.HiddenIcon:SetSize(26, 22);
		end
	end
	self.IconBorder:SetAtlas("dressingroom-itemborder-"..borderType);
	self.HiddenIcon:SetShown(isHiddenVisual);
end