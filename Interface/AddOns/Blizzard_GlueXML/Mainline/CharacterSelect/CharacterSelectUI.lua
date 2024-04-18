CharacterSelectUIMixin = CreateFromMixins(CallbackRegistryMixin);

CharacterSelectUIMixin:GenerateCallbackEvents({
	"ExpansionTrialStateUpdated",
});

function CharacterSelectUIMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.RotationStartX = nil;
	self.RotationConstant = 0.6;
	self.ClampedHeightTopPercent = 0.8;
	self.ClampedHeightBottomPercent = 0.3;
	self.BottomOffsetYPercent = 0.05;
	self.ListToggle:SetExpandTarget(self.CharacterList);

	self.CharacterHeaderFramePool = CreateFramePool("FRAME", self, "CharacterHeaderFrameTemplate", nil);
	self.CharacterFooterFramePool = CreateFramePool("FRAME", self, "CharacterFooterFrameTemplate", nil);

    SetCharSelectModelFrame(self.ModelFFX:GetName());
    SetCharSelectMapSceneFrame(self.MapScene:GetName());

	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function CharacterSelectUIMixin:OnEvent(event, ...)
	if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		if CharacterSelect.selectedIndex > 0 then
			self.CharacterHeaderFramePool:ReleaseAll();
			self.CharacterFooterFramePool:ReleaseAll();
			self:SetupCharacterOverlayFrames();
		end
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
		self:ShowModelScene();
	end
end

function CharacterSelectUIMixin:OnMouseDown(button)
    if button == "LeftButton" then
        self.RotationStartX = GetCursorPosition();
    end
end

function CharacterSelectUIMixin:OnMouseUp(button)
	if button == "LeftButton" then
        self.RotationStartX = nil
    end
end

function CharacterSelectUIMixin:SetCharacterDisplay(characterID)
	local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
	end);

	if elementData then
		if elementData.isGroup then
			local mapSceneID = 1;

			for index, childElementData in ipairs(elementData.characterData) do
				SetMapSceneCharPos(childElementData.characterID, index-1);
			end

			local loadedMapScene = GetLoadedMapScene();
			local mapSceneLoaded = loadedMapScene and loadedMapScene == mapSceneID;
			if mapSceneLoaded then
				self:ShowModelScene();
			else
				LoadMapScene(mapSceneID);
				self.mapSceneLoading = true;

				SetCharSelectBackground(GetSelectBackgroundModel(characterID));
				self:ShowModelFFX();
			end
		else
			self.mapSceneLoading = false;
			SetCharSelectBackground(GetSelectBackgroundModel(characterID));
			self:ShowModelFFX();
		end
	end
end

function CharacterSelectUIMixin:ShowModelScene()
	self.ModelFFX:Hide();
	self.MapScene:Show();

	CharacterSelectRotateLeft:Hide();
	CharacterSelectRotateRight:Hide();
	MoveCharactersToMapSceneFrame();
	self.CharacterHeaderFramePool:ReleaseAll();
	self.CharacterFooterFramePool:ReleaseAll();

	self:SetupCharacterOverlayFrames();
end

function CharacterSelectUIMixin:ShowModelFFX()
	self.MapScene:Hide();
	self.ModelFFX:Show();

	CharacterSelectRotateLeft:Show();
	CharacterSelectRotateRight:Show();
	MoveCharactersToModelFFXFrame();
	ResetModel(self.ModelFFX);
	self.CharacterHeaderFramePool:ReleaseAll();
	self.CharacterFooterFramePool:ReleaseAll();
end

function CharacterSelectUIMixin:SetupCharacterOverlayFrames()
	if self.MapScene:IsShown() then
		local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
		local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
			return CharacterSelectListUtil.ContainsCharacterID(selectedCharacterID, elementData);
		end);

		if elementData and elementData.isGroup then
			for index, childElementData in ipairs(elementData.characterData) do
				if not childElementData.isEmpty then
					local modelBoundingBox = MapSceneGetBoundingBox(index-1);

					if modelBoundingBox then
						local bottomLeftVector = CreateVector3D(modelBoundingBox.b.x, modelBoundingBox.b.y, modelBoundingBox.b.z);
						local topRightVector = CreateVector3D(modelBoundingBox.t.x, modelBoundingBox.t.y, modelBoundingBox.t.z);

						-- Use the bounding box's center point to determine the x position of various UI, to appear centered to the model.
						local centerPointVector = CreateVector3D(bottomLeftVector:GetXYZ());
						centerPointVector:Subtract(topRightVector);
						centerPointVector:DivideBy(2);
						centerPointVector:Add(topRightVector);

						-- Will need to scale by the current frame dimensions.
						local width = self:GetWidth();
						local height = self:GetHeight();

						local bottomLeft, topRight = MapSceneProject3DBoxTo2D(modelBoundingBox);
						bottomLeft.x = bottomLeft.x * width;
						bottomLeft.y = bottomLeft.y * height;
						topRight.x = topRight.x * width;
						topRight.y = topRight.y * height;

						local centerPoint2D = MapSceneProject3DPointTo2D(centerPointVector);
						centerPoint2D.x = centerPoint2D.x * width;
						centerPoint2D.y = centerPoint2D.y * height;

						-- Any custom nudging of the top and bottom values to get the spacings good across the board.
						local clampedHeightTop = height * self.ClampedHeightTopPercent;
						local clampedHeightBottom = height * self.ClampedHeightBottomPercent;
						local clampedTopY = math.min(topRight.y, clampedHeightTop);
						local bottomOffsetY = (topRight.y - bottomLeft.y) * self.BottomOffsetYPercent;
						local clampedBottomY = math.max(bottomLeft.y + bottomOffsetY, clampedHeightBottom);

						-- Now that positions are calculated, actually set up any UI we need.
						local headerFrame = self.CharacterHeaderFramePool:Acquire();
						headerFrame:ClearAllPoints();

						headerFrame:SetPoint("BOTTOM", self, "BOTTOMLEFT", centerPoint2D.x, clampedTopY);
						headerFrame:Initialize(childElementData.characterID);
						headerFrame:Show();

						if childElementData.characterID == selectedCharacterID then
							local footerFrame = self.CharacterFooterFramePool:Acquire();
							footerFrame:ClearAllPoints();

							footerFrame:SetPoint("TOP", self, "BOTTOMLEFT", centerPoint2D.x, clampedBottomY);
							footerFrame:Show();
						end
					end
				end
			end
		end
	end
end

function CharacterSelectUIMixin:SetStoreEnabled(enabled)
	self.shouldStoreBeEnabled = enabled;
	self.NavBar:SetStoreButtonEnabled(enabled);

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
	self.NavBar:SetMenuButtonEnabled(enabled);
end

function CharacterSelectUIMixin:SetCharacterCreateEnabled(enabled, disabledTooltip)
	self.NavBar:SetCharacterCreateButtonEnabled(enabled, disabledTooltip);
end

function CharacterSelectUIMixin:SetChangeRealmEnabled(enabled)
	self.NavBar:SetRealmsButtonEnabled(enabled);
end


CharacterSelectMapSceneMixin = {};

function CharacterSelectMapSceneMixin:OnLoad()
	self:Hide();
	SetWorldFrameStrata(self);
end

function CharacterSelectMapSceneMixin:OnUpdate()
    UpdateSelectionCustomizationScene();
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
	GlueTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, 0);
	CharacterSelectUtil.SetTooltipForCharacterInfo(self.characterInfo);
	GlueTooltip:Show();
end

function CharacterSelectHeaderMixin:OnLeave()
	GlueTooltip:Hide();
end

function CharacterSelectHeaderMixin:Initialize(characterID)
	self.characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);

	local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	self.SelectedBackdrop:SetShown(characterID == selectedCharacterID);
	local nameFontStyle = characterID == selectedCharacterID and "GlueFontNormalHuge" or "GlueFontNormalLarge";
	local levelFontStyle = characterID == selectedCharacterID and "GlueFontHighlightLarge" or "GlueFontHighlight";
	self.Name:SetFontObject(nameFontStyle);
	self.Level:SetFontObject(levelFontStyle);

	if self.characterInfo then
		self.Name:SetText(self.characterInfo.name);
		self.Level:SetText(CHARACTER_SELECT_HEADER_INFO:format(self.characterInfo.experienceLevel));
	end

	self:SetWidth(math.max(self.Name:GetStringWidth(), self.Level:GetStringWidth()));
end