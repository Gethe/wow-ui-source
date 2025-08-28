
function JumpToCollectionsTab(tabIndex)

	if not tabIndex then
		return
	end

	local currentTab = nil

	if CollectionsJournal then
		currentTab = PanelTemplates_GetSelectedTab(CollectionsJournal)
	end

	local isClosed = not CollectionsJournal or not CollectionsJournal:IsVisible()
	local isOpenAndWrongTab = CollectionsJournal and CollectionsJournal:IsVisible() and currentTab ~= tabIndex

	if ( isClosed or isOpenAndWrongTab ) then
		ToggleCollectionsJournal(tabIndex)
	end
end

function DressUpLink(link, forcedFrame)
	return link and (DressUpItemLink(link, forcedFrame) or DressUpBattlePetLink(link, forcedFrame) or DressUpMountLink(link, forcedFrame));
end

function DressUpItemLink(link)
	if( link ) then 
		if ( C_Item.IsDressableItem(link) ) then
			return DressUpVisual(link);
		end
	end
		return false;
end

function DressUpTransmogLink(link)
	if not link then
		return false;
	end

	local linkType = LinkUtil.ExtractLink(link);
	if linkType ~= LinkTypes.TransmogIllusion and linkType ~= LinkTypes.TransmogAppearance then
		return false;
	end

	return DressUpVisual(link);
end

function DressUpVisual(...)
	if ( SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() ) then
		if ( not SideDressUpFrame:IsShown() or SideDressUpFrame.mode ~= "player" ) then
			SideDressUpFrame.mode = "player";
			SideDressUpFrame.ResetButton:Show();

			local race, fileName = UnitRace("player");
			SetDressUpBackground(SideDressUpFrame, fileName);

			ShowUIPanel(SideDressUpFrame);
			SideDressUpModel:SetUnit("player");
		end
		SideDressUpModel:TryOn(...);
	else
		DressUpFrame_Show();
		DressUpModelFrame:TryOn(...);
	end
	return true;
end

function DressUpBattlePetLink(link)
	if( link ) then 
		
		local _, _, _, linkType, speciesIDString, _, _, _, _, _, battlePetID = strsplit(":|H", link);
		if ( linkType == "battlepet" ) then
			local speciesID = tonumber(speciesIDString)
			local _, _, _, creatureID, _, _, _, _, _, _, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);

			DressUpBattlePet(speciesID)
		end
	end
	return false
end

function DressUpBattlePet(speciesID)
	if ( not speciesID ) then
		return false
	end
	
	JumpToCollectionsTab(COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
	if PetJournal then
		PetJournal_SelectSpecies(PetJournal, speciesID);
	end
	return true
end

function DressUpMountLink(link, forcedFrame)
	if( link ) then
		local mountID = 0;

		local _, _, _, linkType, linkID = strsplit(":|H", link);
		if linkType == "item" then
			mountID = C_MountJournal.GetMountFromItem(tonumber(linkID));
		elseif linkType == "spell" then
			mountID = C_MountJournal.GetMountFromSpell(tonumber(linkID));
		elseif linkType == "mount" then
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

	JumpToCollectionsTab(COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
	MountJournal_SetSelected(mountID, 0)

	return true;
end

function DressUpTexturePath(raceFileName)
	-- HACK!!! (from 1.12.0)
	if ( raceFileName == "Gnome" or raceFileName == "GNOME" ) then
		raceFileName = "Dwarf";
	elseif ( raceFileName == "Troll" or raceFileName == "TROLL" ) then
		raceFileName = "Orc";
	end
	if ( not raceFileName ) then
		raceFileName = "Orc";
	end
	-- END HACK

	return "Interface\\DressUpFrame\\DressUpBackground-"..raceFileName;
end

function SetDressUpBackground(frame, fileName, atlasPostfix)
	local texture = DressUpTexturePath(fileName);
	
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
	
	if ( frame.ModelBackground and atlasPostfix ) then
		frame.ModelBackground:SetAtlas("dressingroom-background-"..atlasPostfix);
	end
end

function DressUpFrame_OnDressModel(self)
	-- only want 1 update per frame
	if ( not self.gotDressed ) then
		self.gotDressed = true;
		C_Timer.After(0, function() self.gotDressed = nil; end);
	end
end

function DressUpFrame_Show()
	if ( not DressUpFrame:IsShown() or DressUpFrame.mode ~= "player") then
		DressUpFrame.mode = "player";
		DressUpFrame.ResetButton:Show();

		local race, fileName = UnitRace("player");
		SetDressUpBackground(DressUpFrame, fileName);

		ShowUIPanel(DressUpFrame);
		DressUpModelFrame:SetPosition(0,0,0);
		DressUpModelFrame:SetUnit("player");
	end
end

function DressUpSources(appearanceSources, mainHandEnchant, offHandEnchant)
	if ( not appearanceSources ) then
		return true;
	end

	DressUpFrame_Show();
	local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
				DressUpModelFrame:TryOn(appearanceSources[i]);
			end
		end
	end

	DressUpModelFrame:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
	DressUpModelFrame:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);
end

function SideDressUpFrame_OnShow(self)
	SetUIPanelAttribute(self.parentFrame, "width", self.openWidth);
	UpdateUIPanelPositions(self.parentFrame);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function SideDressUpFrame_OnHide(self)
	SetUIPanelAttribute(self.parentFrame, "width", self.closedWidth);
	UpdateUIPanelPositions();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
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