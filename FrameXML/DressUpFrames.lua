function DressUpItemLink(link)
	if( link ) then 
		if ( IsDressableItem(link) ) then
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

local function GetFrameAndSetBackground(raceFilename, classFilename)
	local frame;
	if SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() then
		frame = SideDressUpFrame;
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

function DressUpTransmogSet(itemModifiedAppearanceIDs)
	local frame = GetFrameAndSetBackground();
	DressUpFrame_Show(frame);
	DressUpFrame_ApplyAppearances(frame, itemModifiedAppearanceIDs);
end

function DressUpBattlePetLink(link)
	if( link ) then 
		
		local _, _, _, linkType, linkID, _, _, _, _, _, battlePetID = strsplit(":|H", link);
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
				local _, _, _, creatureID, _, _, _, _, _, _, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(tonumber(linkID));
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

function DressUpMount(mountID)
	if ( not mountID or mountID == 0 ) then
		return false;
	end

	local frame = GetFrameAndSetBackground("Pet", "warrior");	--default to warrior BG when viewing full Pet/Mounts for now

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

		local playerActor = frame.ModelScene:GetPlayerActor();
		if (playerActor) then
			if disablePlayerMountPreview or isSelfMount then
				playerActor:ClearModel();
			else
				local sheatheWeapons = true;
				if (playerActor:SetModelByUnit("player", sheatheWeapons)) then
					local calcMountScale = mountActor:CalculateMountScale(playerActor);
					local inverseScale = 1 / calcMountScale; 
					playerActor:SetRequestedScale( inverseScale );
					mountActor:AttachToMount(playerActor, animID, spellVisualKitID);
				end
			end
		end
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

function DressUpFrame_OnDressModel(self)
	-- only want 1 update per frame
	if ( not self.gotDressed ) then
		self.gotDressed = true;
		C_Timer.After(0, function() self.gotDressed = nil; DressUpFrameOutfitDropDown:UpdateSaveButton(); end);
	end
end

function DressUpFrame_Show(frame)
	if ( not frame:IsShown() or frame.mode ~= "player") then
		frame.mode = "player";
		frame.ResetButton:Show();

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

function DressUpSources(appearanceSources, mainHandEnchant, offHandEnchant)
	if ( not appearanceSources ) then
		return true;
	end

	local raceFilename = nil;
	local classFilename = select(2, UnitClass("player"));
	SetDressUpBackground(DressUpFrame, raceFilename, classFilename);
	DressUpFrame_Show(DressUpFrame);

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return true;
	end

	local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
				playerActor:TryOn(appearanceSources[i]);
			end
		end
	end

	playerActor:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
	playerActor:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);
end

DressUpOutfitMixin = { };

function DressUpOutfitMixin:GetSlotSourceID(slot, transmogType)
	local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
	if (not playerActor) then
		return;
	end

	local slotID = GetInventorySlotInfo(slot);
	local appearanceSourceID, illusionSourceID = playerActor:GetSlotTransmogSources(slotID);
	if ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		return appearanceSourceID;
	elseif ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		return illusionSourceID;
	end
end

function DressUpOutfitMixin:LoadOutfit(outfitID)
	if ( not outfitID ) then
		return;
	end
	DressUpSources(C_TransmogCollection.GetOutfitSources(outfitID))
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