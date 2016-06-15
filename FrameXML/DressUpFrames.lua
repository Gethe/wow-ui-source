function DressUpItemLink(link)
	if ( not link or not IsDressableItem(link) ) then
		return false;
	end
	return DressUpVisual(link);
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
		if ( not DressUpFrame:IsShown() or DressUpFrame.mode ~= "player") then
			DressUpFrame.mode = "player";
			DressUpFrame.ResetButton:Show();

			local race, fileName = UnitRace("player");
			SetDressUpBackground(DressUpFrame, fileName);

			ShowUIPanel(DressUpFrame);
			DressUpModel:SetUnit("player");
		end
		DressUpModel:TryOn(...);
	end
	return true;
end

function DressUpBattlePet(creatureID, displayID)
	if ( not displayID and not creatureID ) then
		return false;
	end

	--Figure out which frame we're going to use
	local frame, model;
	if ( SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() ) then
		frame, model = SideDressUpFrame, SideDressUpModel;
	else
		frame, model = DressUpFrame, DressUpModel;
	end

	--Show the frame
	if ( not frame:IsShown() or frame.mode ~= "battlepet" ) then
		SetDressUpBackground(frame, "Pet");
		ShowUIPanel(frame);
	end

	--Set up the model on the frame
	frame.mode = "battlepet";
	frame.ResetButton:Hide();
	if ( displayID and displayID ~= 0 ) then
		model:SetDisplayInfo(displayID);
	else
		model:SetCreature(creatureID);
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

function SetDressUpBackground(frame, fileName)
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
end

function DressUpFrame_OnDressModel(self)
	-- only want 1 update per frame
	if ( not self.gotDressed ) then
		self.gotDressed = true;
		C_Timer.After(0, function() self.gotDressed = nil; DressUpFrameOutfitDropDown:UpdateSaveButton(); end);
	end
end

DressUpOutfitMixin = { };

function DressUpOutfitMixin:GetSlotSourceID(slot, transmogType)
	local slotID = GetInventorySlotInfo(slot);
	local appearanceSourceID, illusionSourceID = DressUpModel:GetSlotTransmogSources(slotID);
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
	local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(outfitID);
	if ( not appearanceSources ) then
		return true;
	end

	local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
				DressUpModel:TryOn(appearanceSources[i]);
			end
		end
	end

	DressUpModel:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
	DressUpModel:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);
end

function SideDressUpFrame_OnShow(self)
	SetUIPanelAttribute(self.parentFrame, "width", self.openWidth);
	UpdateUIPanelPositions(self.parentFrame);
	PlaySound("igCharacterInfoOpen");
end

function SideDressUpFrame_OnHide(self)
	SetUIPanelAttribute(self.parentFrame, "width", self.closedWidth);
	UpdateUIPanelPositions();
	PlaySound("igCharacterInfoClose");
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