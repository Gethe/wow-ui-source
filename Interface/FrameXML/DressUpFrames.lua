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
			local speciesID, _, _, _, _, displayID, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByPetID(battlePetID);
			if ( speciesID == tonumber(speciesIDString)) then
				return DressUpBattlePet(creatureID, displayID);
			else
				local _, _, _, creatureID, _, _, _, _, _, _, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(tonumber(speciesIDString));
				return DressUpBattlePet(creatureID, displayID);
			end
		end
	end
	return false
end

function DressUpBattlePet(creatureID, displayID)
	if ( not displayID and not creatureID ) then
		return false;
	end

	--Figure out which frame we're going to use
	local frame, model, fileName, atlasPostfix;
	if ( SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() ) then
		frame, model, fileName = SideDressUpFrame, SideDressUpModel, "Pet";
	else
		frame, model, atlasPostfix = DressUpFrame, DressUpModel, "warrior"; --default to warrior BG when viewing full Pet/Mounts for now
	end

	--Show the frame
	if ( not frame:IsShown() or frame.mode ~= "battlepet" ) then
		SetDressUpBackground(frame, fileName, atlasPostfix);
		ShowUIPanel(frame);
	end

	--Set up the model on the frame
	frame.mode = "battlepet";
	frame.ResetButton:Hide();
	if ( displayID and displayID ~= 0 ) then
		model:SetPosition(0,0,0);
		model:SetDisplayInfo(displayID);
	else
		model:SetPosition(0,0,0);
		model:SetCreature(creatureID);
	end
	return true;
end

function DressUpMountLink(link)
	if( link ) then 
		local _, _, _, linkType, spellID = strsplit(":|H", link);
		if linkType == "spell" then
			local mountID = C_MountJournal.GetMountFromSpell(tonumber(spellID));
			if ( mountID ) then
				local creatureDisplayID = C_MountJournal.GetMountInfoExtraByID(mountID);
				return DressUpMount(creatureDisplayID);
			end
		end
	end
	return false
end

function DressUpMount(creatureDisplayID)
	if ( not creatureDisplayID or creatureDisplayID == 0 ) then
		return false;
	end

	--Figure out which frame we're going to use
	local frame, model, fileName, atlasPostfix;
	if ( SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() ) then
		frame, model, fileName = SideDressUpFrame, SideDressUpModel, "Pet";
	else
		frame, model, atlasPostfix = DressUpFrame, DressUpModel, "warrior"; --default to warrior BG when viewing full Pet/Mounts for now
	end

	--Show the frame
	if ( not frame:IsShown() or frame.mode ~= "mount" ) then
		SetDressUpBackground(frame, fileName, atlasPostfix);
		ShowUIPanel(frame);
	end

	--Set up the model on the frame
	frame.mode = "mount";
	frame.ResetButton:Hide();
	model:SetPosition(0,0,0);
	model:SetDisplayInfo(creatureDisplayID);

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