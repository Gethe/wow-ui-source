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

	local slotID = nil;
	if categoryID then
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
		-- weapons that can go in either hand need the slot specified
		slotID = (canMainHand and canOffHand) and transmogLocation.slotID or nil;
		-- legion artifacts might set both weapons
		if TransmogUtil.IsCategoryLegionArtifact(categoryID) then
			itemTransmogInfo.secondaryAppearanceID = Constants.Transmog.MainHandTransmogFromPairedCategory;
		end
	end

	local result = playerActor:SetItemTransmogInfo(itemTransmogInfo, slotID);
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
	if ( not frame:IsShown() or frame.mode ~= "battlepet" ) then
		ShowUIPanel(frame);
	end
	frame.mode = "battlepet";
	frame.ResetButton:Hide();

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
	if ( not frame:IsShown() or frame.mode ~= "mount" ) then
		ShowUIPanel(frame);
	end
	frame.mode = "mount";
	frame.ResetButton:Hide();

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
	if ( not frame:IsShown() or frame.mode ~= "player") then
		frame.mode = "player";

		frame.ResetButton:SetShown(frame ~= TransmogAndMountDressupFrame);

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
		local itemModifiedAppearanceIDs = nil;
		SetupPlayerForModelScene(frame.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress);
	end
end

function DressUpFrame_ApplyAppearances(frame, itemModifiedAppearanceIDs)
	local sheatheWeapons = false;
	local autoDress = true;
	SetupPlayerForModelScene(frame.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress);
end

function DressUpItemTransmogInfoList(itemTransmogInfoList)
	if not itemTransmogInfoList then
		return true;
	end

	local raceFilename = nil;
	local classFilename = select(2, UnitClass("player"));
	SetDressUpBackground(DressUpFrame, raceFilename, classFilename);
	DressUpFrame_Show(DressUpFrame);

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if not playerActor then
		return true;
	end

	for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
		playerActor:SetItemTransmogInfo(itemTransmogInfo, slotID);
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