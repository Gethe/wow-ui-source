CharacterSelectUIMixin = CreateFromMixins(CallbackRegistryMixin);

CharacterSelectUIMixin:GenerateCallbackEvents({
	"ExpansionTrialStateUpdated",
});

function CharacterSelectUIMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.RotationStartX = nil;
	self.RotationConstant = 0.6;
	self.ClampedHeightTopPercent = 0.8;
	self.ClampedHeightBottomPercent = 0.2;
	self.DoubleClickThreshold = 0.3;
	self.TooltipTimerDuration = 0.5;

	local function OnToggleCallback(isExpanded, isUserInput)
		if isUserInput then
			SetCVar("expandWarbandCharacterList", isExpanded);
		end
	end
	self.VisibilityFramesContainer.ListToggle:SetExpandTarget(self.VisibilityFramesContainer.CharacterList);
	self.VisibilityFramesContainer.ListToggle:SetOnToggleCallback(OnToggleCallback);

	local function MapFadeInOnFinished()
		self.FadeInBackground:Hide();
		self:SetupCharacterOverlayFrames();
	end
	self.MapFadeIn:SetScript("OnFinished", MapFadeInOnFinished);

	self.inVisibilityDoubleClickThreshold = false;
	self.visibilityState = true;
	local function VisibilityToggleOnClick()
		local visibilityState = not self.VisibilityFramesContainer:IsShown();

		self.visibilityState = visibilityState;

		self.VisibilityFramesContainer:SetShown(visibilityState);

		local buttonArtKit = visibilityState and "128-redbutton-visibilityon" or "128-redbutton-visibilityoff";
		self.VisibilityToggleButton:SetButtonArtKit(buttonArtKit);

		self.VisibilityToggleButton:SetShown(visibilityState);

		CharacterSelect_UpdateLogo();
		SetCharacterSelectUIVisibilityState(visibilityState);
	end
	self.VisibilityToggleButton:SetScript("OnClick", VisibilityToggleOnClick);

	self.LoadedOverlayFrameCharacterIDs = {};
	self.CharacterHeaderFramePool = CreateFramePool("BUTTON", self, "CharacterHeaderFrameTemplate", nil);
	self.CharacterFooterFramePool = CreateFramePool("FRAME", self.VisibilityFramesContainer, "CharacterFooterFrameTemplate", nil);
	self.headerFrames = {};
	self.footerFrames = {};

	self.loadedMapManifest = nil;

	self.currentMapSceneHoverGUID = nil;
	self.mouseDownMapSceneHoverGUID = nil;
	self.doubleClickHoverGUID = nil;

    SetCharSelectModelFrame(self.ModelFFX:GetName());
    SetCharSelectMapSceneFrame(self.MapScene:GetName());

	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("MAP_SCENE_CHARACTER_ON_MOUSE_ENTER");
	self:RegisterEvent("MAP_SCENE_CHARACTER_ON_MOUSE_LEAVE");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("CHARACTER_LIST_RESTRICTIONS_RECEIVED");
	self:RegisterEvent("CHARACTER_LIST_MAIL_RECEIVED");
	self:RegisterEvent("ACCOUNT_CONVERSION_DISPLAY_STATE");
	self:RegisterEvent("ACCOUNT_CVARS_LOADED");
end

function CharacterSelectUIMixin:OnEvent(event, ...)
	if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		-- Defer this until the next frame so that any pending map frame projection changes have taken effect.
		RunNextFrame(function()
			if CharacterSelect.selectedIndex > 0 then
				self:SetupCharacterOverlayFrames();
			end
		end);
	elseif event == "MAP_SCENE_CHARACTER_ON_MOUSE_ENTER" then
		local guid = ...;

		self.currentMapSceneHoverGUID = guid;

		-- Trigger any updates on the character model UI
		for headerFrame in self.CharacterHeaderFramePool:EnumerateActive() do
			if headerFrame.basicCharacterInfo and headerFrame.basicCharacterInfo.guid == guid then
				self.tooltipTimer = C_Timer.NewTimer(self.TooltipTimerDuration, function()
					headerFrame:SetTooltipAndShow();
				end);
				break;
			end
		end

		-- Trigger any updates on the character list entry, if visible.
		local isHighlight = true;
		CharacterSelectListUtil.UpdateCharacterHighlight(guid, isHighlight);
	elseif event == "MAP_SCENE_CHARACTER_ON_MOUSE_LEAVE" then
		local guid = ...;

		self.currentMapSceneHoverGUID = nil;

		if self.tooltipTimer then
			self.tooltipTimer:Cancel();
			self.tooltipTimer = nil;
		end
		GlueTooltip:Hide();

		-- Trigger any updates on the character list entry, if visible.
		local isHighlight = false;
		CharacterSelectListUtil.UpdateCharacterHighlight(guid, isHighlight);
	elseif event == "CVAR_UPDATE" then
		local cvarName, cvarValue = ...;
		if cvarName == "debugTargetInfo" then
			CharacterSelectUtil.UpdateShowDebugTooltipInfo(cvarValue == "1");
		end
	elseif event == "CHARACTER_LIST_RESTRICTIONS_RECEIVED" then
		-- Visually refresh character rendering.
		CharacterSelectCharacterFrame:UpdateCharacterSelection();
	elseif event == "CHARACTER_LIST_MAIL_RECEIVED" then
		-- Visually refresh character rendering.
		CharacterSelectCharacterFrame:UpdateCharacterSelection();
	elseif event == "ACCOUNT_CONVERSION_DISPLAY_STATE" then
		local shouldDisplay = ...;

		if shouldDisplay then
			GlueDialog_Show("ACCOUNT_CONVERSION_DISPLAY");
		else
			GlueDialog_Hide("ACCOUNT_CONVERSION_DISPLAY");

			if CharacterSelect.retrievingCharacters then
				-- Show the retrieving character list dialog again once conversion is complete if needed.
				GlueDialog_Show("RETRIEVING_CHARACTER_LIST");
			end
		end
	elseif event == "ACCOUNT_CVARS_LOADED" then
		local isExpanded = GetCVarBool("expandWarbandCharacterList");
		self:ExpandCharacterList(isExpanded);
	end
end

function CharacterSelectUIMixin:OnUpdate()
    if self.RotationStartX then
        local x = GetCursorPosition();
        local diff = (x - self.RotationStartX) * self.RotationConstant;
        self.RotationStartX = GetCursorPosition();
        SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
    end

	if self.mapSceneLoading and IsMapSceneLoaded() then
		self.mapSceneLoading = false;
		self.MapFadeIn:Restart();
	end
end

function CharacterSelectUIMixin:OnMouseDown(button)
    if button == "LeftButton" then
        self.RotationStartX = GetCursorPosition();
    end

	self.mouseDownMapSceneHoverGUID = self.currentMapSceneHoverGUID;
end

function CharacterSelectUIMixin:OnMouseUp(button)
	if button == "LeftButton" then
        self.RotationStartX = nil
    end

	-- Character model selection logic.
	if self.mouseDownMapSceneHoverGUID and self.mouseDownMapSceneHoverGUID == self.currentMapSceneHoverGUID then
		local isCharacterDoubleClick = self.doubleClickHoverGUID and self.doubleClickHoverGUID == self.currentMapSceneHoverGUID;
		if not self.doubleClickHoverGUID then
			C_Timer.After(self.DoubleClickThreshold, function()
				self.doubleClickHoverGUID = nil;
			end);
			self.doubleClickHoverGUID = self.currentMapSceneHoverGUID;
		end

		CharacterSelectListUtil.ClickCharacterFrameByGUID(self.mouseDownMapSceneHoverGUID, isCharacterDoubleClick);
	end
	self.mouseDownMapSceneHoverGUID = nil;

	-- Visibility toggle logic.
	if self:GetVisibilityState() then
		return;
	end

	local isVisibilityDoubleClick = self.inVisibilityDoubleClickThreshold;
	if not self.inVisibilityDoubleClickThreshold then
		C_Timer.After(self.DoubleClickThreshold, function()
			self.inVisibilityDoubleClickThreshold = false;
		end);
		self.inVisibilityDoubleClickThreshold = true;
	end

	if isVisibilityDoubleClick then
		self:ToggleVisibilityButtonState();
		self.inVisibilityDoubleClickThreshold = false;
	end
end

function CharacterSelectUIMixin:ExpandCharacterList(isExpanded)
	local isUserInput = false;
	self.VisibilityFramesContainer.ListToggle:SetExpanded(isExpanded, isUserInput);
end

function CharacterSelectUIMixin:SetCharacterListToggleEnabled(isEnabled)
	self.VisibilityFramesContainer.ListToggle:SetEnabledState(isEnabled);
end

function CharacterSelectUIMixin:SetCharacterDisplay(selectedCharacterID)
	local selectedElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(selectedCharacterID, elementData);
	end);

	if selectedElementData then
		local showModelFFX = true;
		-- See if the map scene assets are present to load.
		if selectedElementData.isGroup then
			-- Only 1 map currently, when multiple are introduced this will update.
			local mapSceneID = 1;

			if self.loadedMapManifest ~= mapSceneID and LoadMapManifest(mapSceneID) then
				self.loadedMapManifest = mapSceneID;
				if not CheckMapManifestLocality() then
					PreloadMapManifest();
				end
			end

			-- Explicitly check as the above load could have failed, and we only want to fire off LoadMapManifest until loaded successfully.
			if self.loadedMapManifest == mapSceneID and CheckMapManifestLocality() then
				showModelFFX = false;

				local loadedMapScene = GetLoadedMapScene();
				local mapSceneLoaded = loadedMapScene and loadedMapScene == mapSceneID;
				-- No need to reload the same map every time.
				if not mapSceneLoaded then
					self.FadeInBackground:Show();
					LoadMapScene(mapSceneID);
					self.mapSceneLoading = true;
				end

				for index, childElementData in ipairs(selectedElementData.characterData) do
					SetMapSceneCharPos(childElementData.characterID, index);
				end

				-- Set up the model scene first, so that valid model info is at the ready for character UI to reference if needed.
				local isSceneChange = self.ModelFFX:IsShown();
				self:ShowModelScene();

				-- We show the overlay frames at the end of MapFadeIn otherwise.
				if mapSceneLoaded then
					self:SetupCharacterOverlayFrames();
				end

				for _, childElementData in ipairs(selectedElementData.characterData) do
					if childElementData.characterID == selectedCharacterID then
						PlayRandomAnimation(childElementData.characterID, Enum.WarbandSceneAnimationEvent.Select, isSceneChange);
					elseif not childElementData.isEmpty then
						local pose = mapSceneLoaded and Enum.WarbandSceneAnimationEvent.Deselect or Enum.WarbandSceneAnimationEvent.StartingPose;
						PlayRandomAnimation(childElementData.characterID, pose, isSceneChange);
					end
				end
			end
		end

		if showModelFFX then
			self.mapSceneLoading = false;
			if self.MapFadeIn:IsPlaying() then
				self.MapFadeIn:Stop();
			end
			self.FadeInBackground:Hide();

			SetCharSelectBackground(GetSelectBackgroundModel(selectedCharacterID));
			self:ShowModelFFX();
		end
	end
end

function CharacterSelectUIMixin:ShowModelScene()
	self.ModelFFX:Hide();
	self.MapScene:Show();

	PlayGlueAmbience(GLUE_AMBIENCE_TRACKS["WARBANDS_MAPSCENE"], 4.0);

	CharacterSelectRotateLeft:Hide();
	CharacterSelectRotateRight:Hide();
	MoveCharactersToMapSceneFrame();
end

function CharacterSelectUIMixin:ShowModelFFX()
	self.MapScene:Hide();
	self.ModelFFX:Show();

	CharacterSelectRotateLeft:Show();
	CharacterSelectRotateRight:Show();
	MoveCharactersToModelFFXFrame();
	ResetModel(self.ModelFFX);
	self:ReleaseCharacterOverlayFrames();
end


function CharacterSelectUIMixin:SetupCharacterOverlayFrames()
	if self.MapScene:IsShown() and not self.FadeInBackground:IsShown() then
		self:ReleaseCharacterOverlayFrames();
		if #self.LoadedOverlayFrameCharacterIDs > 0 then
			for _, characterID in ipairs(self.LoadedOverlayFrameCharacterIDs) do
				self:SetupOverlayFrameForCharacter(characterID);
			end
			self.LoadedOverlayFrameCharacterIDs = {};
		else
			local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
			local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
				return CharacterSelectListUtil.ContainsCharacterID(selectedCharacterID, elementData);
			end);

			if elementData and elementData.isGroup then
				for _, childElementData in ipairs(elementData.characterData) do
					if not childElementData.isEmpty then
						self:SetupOverlayFrameForCharacter(childElementData.characterID);
					end
				end
			end
		end
	end
end

function CharacterSelectUIMixin:ReleaseCharacterOverlayFrames()
	self.CharacterHeaderFramePool:ReleaseAll();
	self.CharacterFooterFramePool:ReleaseAll();
	self.headerFrames = {};
	self.footerFrames = {};
end

function CharacterSelectUIMixin:SetupOverlayFrameForCharacter(characterID)
	local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);

	local positionTop, positionBottom = MapSceneGetCharacterOverlayFramePositions(characterID);
	local topPoint2D = MapSceneProject3DPointTo2D(positionTop);
	local bottomPoint2D = MapSceneProject3DPointTo2D(positionBottom);

	-- Will need to scale by the current frame dimensions.
	local width = self:GetWidth();
	local height = self:GetHeight();

	bottomPoint2D.x = bottomPoint2D.x * width;
	bottomPoint2D.y = bottomPoint2D.y * height;
	topPoint2D.x = topPoint2D.x * width;
	topPoint2D.y = topPoint2D.y * height;

	-- Any custom nudging of the top and bottom values to get the spacings good across the board.
	local clampedHeightTop = height * self.ClampedHeightTopPercent;
	local clampedHeightBottom = height * self.ClampedHeightBottomPercent;
	local clampedTopY = math.min(topPoint2D.y, clampedHeightTop);
	local clampedBottomY = math.max(bottomPoint2D.y, clampedHeightBottom);

	-- Do not create overlay frames if the position is off screen (can happen when initially loading things up, before the MapSceneModelLoaded callback)
	if topPoint2D.x < 0 or topPoint2D.x > width or topPoint2D.y < 0 or topPoint2D.y > height then
		return;
	end

	-- Create and place the overlay frames.
	local characterGuid = GetCharacterGUID(characterID);
	local headersToRelease = {};
	for _, header in ipairs(self.headerFrames) do
		if header.basicCharacterInfo.guid == characterGuid then
			table.insert(headersToRelease, header);
		end
	end

	for _, header in ipairs(headersToRelease) do
		self.CharacterHeaderFramePool:Release(header);
		local index = tIndexOf(self.headerFrames, header);
		table.remove(self.headerFrames, index);
	end

	local headerFrame = self.CharacterHeaderFramePool:Acquire();
	headerFrame:ClearAllPoints();
	headerFrame:SetPoint("BOTTOM", self, "BOTTOMLEFT", topPoint2D.x, clampedTopY);
	headerFrame:Initialize(characterID);
	headerFrame:Show();
	table.insert(self.headerFrames, headerFrame);

	if characterID == selectedCharacterID then
		local footersToRelease = {};
		for _, footer in ipairs(self.footerFrames) do
			if footer.characterGuid == characterGuid then
				table.insert(footersToRelease, footer);
			end
		end

		for _, footer in ipairs(footersToRelease) do
			self.CharacterFooterFramePool:Release(footer);
			local index = tIndexOf(self.footerFrames, footer);
			table.remove(self.footerFrames, index);
		end

		local footerFrame = self.CharacterFooterFramePool:Acquire();
		footerFrame:ClearAllPoints();

		footerFrame:SetPoint("TOP", self, "BOTTOMLEFT", bottomPoint2D.x, clampedBottomY);
		footerFrame.characterGuid = characterGuid;
		footerFrame:Show();
		table.insert(self.footerFrames, footerFrame);
	end
end

function CharacterSelectUIMixin:MapSceneModelLoaded(characterID)
	if self.FadeInBackground:IsShown() then
		table.insert(self.LoadedOverlayFrameCharacterIDs, characterID);
	else
		self:SetupOverlayFrameForCharacter(characterID);
	end
end

function CharacterSelectUIMixin:SetStoreEnabled(enabled)
	self.shouldStoreBeEnabled = enabled;
	self.VisibilityFramesContainer.NavBar:SetStoreButtonEnabled(enabled);

	if GlueMenuFrame:IsShown() then
		GlueMenuFrame:InitButtons();
	end
end

function CharacterSelectUIMixin:UpdateStoreEnabled()
	self:SetStoreEnabled(CharacterSelectUtil.IsStoreAvailable() and not Kiosk.IsEnabled());
end

function CharacterSelectUIMixin:ShouldStoreBeEnabled()
	return self.shouldStoreBeEnabled;
end

function CharacterSelectUIMixin:SetMenuEnabled(enabled)
	self.VisibilityFramesContainer.NavBar:SetMenuButtonEnabled(enabled);
end

function CharacterSelectUIMixin:SetChangeRealmEnabled(enabled)
	self.VisibilityFramesContainer.NavBar:SetRealmsButtonEnabled(enabled);
end

function CharacterSelectUIMixin:GetVisibilityState()
	return self.visibilityState;
end

function CharacterSelectUIMixin:ToggleVisibilityState()
	self.VisibilityToggleButton:Click();
end

function CharacterSelectUIMixin:ToggleVisibilityButtonState()
	self.VisibilityToggleButton:SetShown(not self.VisibilityToggleButton:IsShown());
end

function CharacterSelectUIMixin:ResetVisibilityState()
	if not self:GetVisibilityState() then
		self:ToggleVisibilityState();
	end
end


CharacterSelectMapSceneMixin = {};

function CharacterSelectMapSceneMixin:OnLoad()
	self:Hide();
	SetWorldFrameStrata(self);
end

function CharacterSelectMapSceneMixin:OnUpdate()
    UpdateSelectionCustomizationScene();
end

function CharacterSelectMapSceneMixin:OnModelLoaded(mapSceneIndex)
	local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(selectedCharacterID, elementData);
	end);

	if elementData and elementData.isGroup then
		for index, childElementData in ipairs(elementData.characterData) do
			if index == mapSceneIndex then
				CharacterSelect.CharacterSelectUI:MapSceneModelLoaded(childElementData.characterID);
				break;
			end
		end
	end
end


CharacterSelectModelFFXMixin = {};

function CharacterSelectModelFFXMixin:OnLoad()
	self:SetSequence(0);
	self:SetCamera(0);
	SetWorldFrameStrata(self);
end

function CharacterSelectModelFFXMixin:OnUpdate()
	UpdateSelectionCustomizationScene();
    self:AdvanceTime();
end


CharacterSelectHeaderMixin = {};

function CharacterSelectHeaderMixin:OnEnter()
	if not self.basicCharacterInfo then
		return;
	end

	self.tooltipTimer = C_Timer.NewTimer(CharacterSelectUI.TooltipTimerDuration, function()
		self:SetTooltipAndShow();
	end);

	-- Trigger any updates on the character list entry, if visible.
	local isHighlight = true;
	CharacterSelectListUtil.UpdateCharacterHighlight(self.basicCharacterInfo.guid, isHighlight);

	-- Update character model as needed.
	MapSceneCharacterHighlightStart(self.basicCharacterInfo.guid);
end

function CharacterSelectHeaderMixin:OnLeave()
	if not self.basicCharacterInfo then
		return;
	end

	if self.tooltipTimer then
		self.tooltipTimer:Cancel();
		self.tooltipTimer = nil;
	end
	GlueTooltip:Hide();

	-- Trigger any updates on the character list entry, if visible.
	local isHighlight = false;
	CharacterSelectListUtil.UpdateCharacterHighlight(self.basicCharacterInfo.guid, isHighlight);

	-- Update character model as needed.
	MapSceneCharacterHighlightEnd(self.basicCharacterInfo.guid);
end

function CharacterSelectHeaderMixin:OnClick()
	if not self.basicCharacterInfo then
		return;
	end

	local isDoubleClick = false;
	CharacterSelectListUtil.ClickCharacterFrameByGUID(self.basicCharacterInfo.guid, isDoubleClick);
end

function CharacterSelectHeaderMixin:OnDoubleClick()
	if not self.basicCharacterInfo then
		return;
	end

	local isDoubleClick = true;
	CharacterSelectListUtil.ClickCharacterFrameByGUID(self.basicCharacterInfo.guid, isDoubleClick);

	-- Visibility toggle logic.
	if CharacterSelectUI:GetVisibilityState() then
		return;
	end

	CharacterSelectUI:ToggleVisibilityButtonState();
end

function CharacterSelectHeaderMixin:Initialize(characterID)
	local characterGuid = GetCharacterGUID(characterID);
	if characterGuid then
		self.basicCharacterInfo = GetBasicCharacterInfo(characterGuid);

		local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
		self.SelectedBackdrop:SetShown(characterID == selectedCharacterID);
		local nameFontStyle = characterID == selectedCharacterID and "GlueFontNormalHuge" or "GlueFontNormalLarge";
		local levelFontStyle = characterID == selectedCharacterID and "GlueFontHighlightLarge" or "GlueFontHighlight";
		self.Name:SetFontObject(nameFontStyle);
		self.Level:SetFontObject(levelFontStyle);

		self.Name:SetText(self.basicCharacterInfo.name);
		self.Level:SetText(CHARACTER_SELECT_HEADER_INFO:format(self.basicCharacterInfo.experienceLevel));

		local guid = self.basicCharacterInfo.guid;
		local timerunningSeasonID = guid and GetCharacterTimerunningSeasonID(guid) or nil;
		self.TimerunningIcon:SetShown(timerunningSeasonID ~= nil);

		self:SetWidth(math.max(self.Name:GetStringWidth(), self.Level:GetStringWidth()));
	end
end

function CharacterSelectHeaderMixin:SetTooltipAndShow()
	if not self.basicCharacterInfo or not CharacterSelectUI:GetVisibilityState() then
		return;
	end

	GlueTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, 0);
	CharacterSelectUtil.SetTooltipForCharacterInfo(self.basicCharacterInfo, nil);
	GlueTooltip:Show();
end


CharacterDeletionDialogMixin = {}

function CharacterDeletionDialogMixin:OnLoad()
	self.Background.Button1:SetScript("OnClick", function()
		self:DeleteCharacter();
	end);

	self.Background.Button2:SetScript("OnClick", function()
		self:Hide();
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
	end);

	self.EditBox:SetScript("OnTextChanged", function(editBox)
		self.Background.Button1:SetEnabled(ConfirmationEditBoxMatches(editBox, DELETE_CONFIRM_STRING));
	end);

	self.EditBox:SetScript("OnEnterPressed", function()
		if self.Background.Button1:IsEnabled() then
			self:DeleteCharacter();
		end
	end);

	self.EditBox:SetScript("OnEscapePressed", function()
		self:Hide();
	end);
end

function CharacterDeletionDialogMixin:OnShow()
	self:Raise();

	self.characterGuid = GetCharacterGUID(CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex));
	if not self.characterGuid then
		return;
	end

	local basicInfo = GetBasicCharacterInfo(self.characterGuid);
    self.Background.Text1:SetFormattedText(CONFIRM_CHAR_DELETE, basicInfo.name, basicInfo.experienceLevel, basicInfo.className);
    self.Background:SetHeight(16 + self.Background.Text1:GetHeight() + self.Background.Text2:GetHeight() + 23 + self.EditBox:GetHeight() + 8 + self.Background.Button1:GetHeight() + 16);
    self.Background.Button1:Disable();
end

function CharacterDeletionDialogMixin:OnHide()
	self.EditBox:SetText("");
end

function CharacterDeletionDialogMixin:DeleteCharacter()
	if CharacterSelect_IsRetrievingCharacterList() or CharacterSelectUtil.IsAccountLocked() or not self.characterGuid then
		return;
	end

	DeleteCharacter(self.characterGuid);
	self:Hide();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	GlueDialog_Show("CHAR_DELETE_IN_PROGRESS");
end