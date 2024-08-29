
function ModelPreviewFrame_OnLoad(self)
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetSize(415, 565);
	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 40);

	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self:SetTitle(PREVIEW);

	self.Display.ModelScene:SetResetCallback(ModelPreviewFrame_OnModelSceneReset);
	self.Display.ModelScene.ControlFrame:SetModelScene(self.Display.ModelScene);
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function ModelPreviewFrame_OnModelSceneReset()
	if ModelPreviewFrame.displayInfoEntries then
		ModelPreviewFrame_ShowModels(ModelPreviewFrame.displayInfoEntries, false, true);
	else
		ModelPreviewFrame_RefreshCurrentDisplay();
	end
end

function ModelPreviewFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	local camera = self.Display.ModelScene:GetActiveCamera();
	if camera then
		camera:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL, true);
		camera:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_PAN_VERTICAL, true);
	end
end

function ModelPreviewFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	local camera = self.Display.ModelScene:GetActiveCamera();
	if camera then
		camera:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
		camera:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
	end
end

function ModelPreviewFrame_TryHide()
	if ( ModelPreviewFrame:IsShown() ) then
		ModelPreviewFrame:Hide();
		return true;
	end
	return false;
end

function ModelPreviewFrame_SetStyle(self, style)
	self.style = style;
	if style == "carousel" then
		self.Display.ModelScene.CarouselLeftButton:Show();
		self.Display.ModelScene.CarouselRightButton:Show();
		self.Display.CarouselText:Show();
	else
		self.Display.ModelScene.CarouselLeftButton:Hide();
		self.Display.ModelScene.CarouselRightButton:Hide();
		self.Display.CarouselText:Hide();
	end
end

function ModelPreviewFrame_RefreshCurrentDisplay()
	local display = ModelPreviewFrame.Display;
	ModelPreviewFrame_ShowModel(display.displayID, display.modelSceneID, display.allowZoom, true);
end

function ModelPreviewFrame_BuildCarousel(self)
	self.carouselEntries = {};

	for _, entry in ipairs(self.displayInfoEntries) do
		if entry.displayID and entry.displayID > 0 then
			tinsert(self.carouselEntries, entry);
		else
			if entry.displayTransmogItemsIndividually then
				for i, myIndividualTransmogID in ipairs(entry.itemModifiedAppearanceIDs) do
					local newEntry = CopyTable(entry, false);
					newEntry.itemModifiedAppearanceIDs = {entry.itemModifiedAppearanceIDs[i]};
					tinsert(self.carouselEntries, newEntry);
				end
			else
				tinsert(self.carouselEntries, entry);
			end
		end
	end
end

function ModelPreviewFrame_ShowModels(displayInfoEntries, allowZoom, forceUpdate)
	local self = ModelPreviewFrame;
	self.displayInfoEntries = displayInfoEntries;
	ModelPreviewFrame_BuildCarousel(self);

	if #self.carouselEntries > 1 then
		ModelPreviewFrame_SetStyle(self, "carousel");
	else
		ModelPreviewFrame_SetStyle(self, nil);
	end
	ModelPreviewFrame_SetCarouselIndex(self, 1, allowZoom, forceUpdate);
end

function ModelPreviewFrame_ShowModel(displayID, modelSceneID, allowZoom, forceUpdate)
	local self = ModelPreviewFrame;
	local displayInfoEntry = self.carouselEntries[self.carouselIndex];
	local itemModifiedAppearanceIDs = displayInfoEntry.itemModifiedAppearanceIDs;

	ModelPreviewFrame_SetStyle(self, nil);
	ModelPreviewFrame_ShowModelInternal(displayID, modelSceneID, allowZoom, forceUpdate, itemModifiedAppearanceIDs);
end

function ModelPreviewFrame_ShowModelInternal(displayID, modelSceneID, allowZoom, forceUpdate, itemModifiedAppearanceIDs)
	local display = ModelPreviewFrame.Display;
	display.displayID = displayID;
	display.modelSceneID = modelSceneID;
	display.allowZoom = allowZoom;
	display.ModelScene:ClearScene();
	display.ModelScene:SetFromModelSceneID(modelSceneID, forceUpdate);

	if displayID and displayID > 0 then
		local actor = display.ModelScene:GetActorByTag("item");
		SetupItemPreviewActor(actor, displayID);
	else
		local _, _cameraIDs, _actorIDs, flags = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
		
		local useNativeForm = true;
		local sheatheWeapons = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
		local hideWeapons = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
		local autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;

		local playerRaceName;
		if IsOnGlueScreen() then
			local characterGuid = GetCharacterGUID(GetCharacterSelection());
			if characterGuid then
				local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
				playerRaceName = basicCharacterInfo.raceFilename and basicCharacterInfo.raceFilename:lower();
			end
		else
			local _, raceFilename = UnitRace("player");
			playerRaceName = raceFilename:lower();
		end

		local overrideActorName;
		if playerRaceName == "dracthyr" then
			overrideActorName = "dracthyr-alt";
			useNativeForm = false;
		end

		SetupPlayerForModelScene(display.ModelScene, overrideActorName, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm);
	end
	ModelPreviewFrame:Show();
end

function ModelPreviewFrame_OnEvent(self, event, ...)
	if ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if ( ModelPreviewFrame:IsVisible() ) then
			ModelPreviewFrame_RefreshCurrentDisplay();
		end
	end
end

function ModelPreviewFrame_SetCarouselIndex(self, index, allowZoom, forceUpdate)
	self.carouselIndex = index;
	self.Display.CarouselText:SetText(MODEL_PREVIEW_FRAME_CAROUSEL_TEXT_FORMAT:format(self.carouselIndex, #self.carouselEntries));

	local displayInfoEntry = self.carouselEntries[self.carouselIndex];
	ModelPreviewFrame_ShowModelInternal(displayInfoEntry.creatureDisplayInfoID, displayInfoEntry.modelSceneID, allowZoom, forceUpdate, displayInfoEntry.itemModifiedAppearanceIDs);
	self.Display.Name:SetText(displayInfoEntry.title);
end

function ModelPreviewFrame_MoveCarousel(self, backward)
	local newCarouselIndex = self.carouselIndex;
	if backward then
		newCarouselIndex = newCarouselIndex - 1;
		if newCarouselIndex <= 0 then
			newCarouselIndex = #self.carouselEntries;
		end
	else
		newCarouselIndex = newCarouselIndex + 1;
		if newCarouselIndex > #self.carouselEntries then
			newCarouselIndex = 1;
		end
	end

	local display = self.Display;
	ModelPreviewFrame_SetCarouselIndex(self, newCarouselIndex, display.allowZoom, true);
end

function CarouselLeftButton_OnClick(self)
	local parentPreviewFrame = self:GetParent():GetParent():GetParent();
	ModelPreviewFrame_MoveCarousel(parentPreviewFrame, true);
end

function CarouselRightButton_OnClick(self)
	local parentPreviewFrame = self:GetParent():GetParent():GetParent();
	ModelPreviewFrame_MoveCarousel(parentPreviewFrame, false);
end