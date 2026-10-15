local LIST_ROW_SPACING = 40;
local LIST_SAFE_WIDTH = 300;
local MAW_BUFF_MAX_DISPLAY = 44;

TieredEntranceTraitsContainerMixin = {};

function TieredEntranceTraitsContainerMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		self:SetMawAuras();
		self:UpdateAlignment();
	end
end

function TieredEntranceTraitsContainerMixin:OnLoad()
	if C_GameRules.IsWoWHack() then 
		EventRegistry:RegisterCallback("PlayerChoiceTaleboundOptionTemplate.OnShow", self.ShowList, self);
		EventRegistry:RegisterCallback("PlayerChoiceTaleboundOptionTemplate.OnHide", self.HideList, self);
		EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", self.HideList, self);

		-- Show when the outfitter frame is opened
		EventRegistry:RegisterCallback("OutfitterFrame.Opened", self.ShowList, self);
		EventRegistry:RegisterCallback("OutfitterFrame.Closed", self.HideList, self);
	end
end


function TieredEntranceTraitsContainerMixin:OnShow()
	if C_GameRules.IsWoWHack() then 
		self:RegisterUnitEvent("UNIT_AURA", "player");
		self:SetMawAuras();
		self:UpdateAlignment();
	end
end

function TieredEntranceTraitsContainerMixin:OnHide()
	self.List:Hide();
	self.Arrow:Hide();
	EventRegistry:TriggerEvent("TieredEntranceTraits.TraitsListHidden");
	if C_GameRules.IsWoWHack() then
		self:UnregisterEvent("UNIT_AURA");
	end
end

function TieredEntranceTraitsContainerMixin:ShowList()
	if self.List:IsShown() then
		return;
	end

	if self.needSet then
		self.needSet = nil;
		if self.traitTreeID then
			self.List:SetTraitTree(self.traitTreeID, self.numTraits);
		else
			self.List:SetSpells(self.spells);
		end
	end
	self:UpdateAlignment();
	self.List:Show();
	self.Arrow:Show();
	EventRegistry:TriggerEvent("TieredEntranceTraits.TraitsListShown");
end

function TieredEntranceTraitsContainerMixin:HideList()
	if not self.List:IsShown() then
		return;
	end

	self.List:Hide();
	self.Arrow:Hide();
	EventRegistry:TriggerEvent("TieredEntranceTraits.TraitsListHidden");
end

function TieredEntranceTraitsContainerMixin:OnClick()
	if self.List:IsShown() then
		self:HideList();
	else
		self:ShowList();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function TieredEntranceTraitsContainerMixin:SetTraitTree(traitTreeID)
	if C_GameRules.IsWoWHack() then
		return;	
	end

	local numTraits = 0;
	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	if configID then
		local nodeIDs = C_Traits.GetTreeNodes(traitTreeID);
		for _, nodeID in ipairs(nodeIDs) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
			if nodeInfo and nodeInfo.ranksPurchased > 0 then
				numTraits = numTraits + 1;
			end
		end
	end
	local spells = nil;
	self:Update(numTraits, traitTreeID, spells);
end

function TieredEntranceTraitsContainerMixin:SetSpells(spells)
	local numTraits = spells and #spells or 0;
	local traitTreeID = nil;
	self:Update(numTraits, traitTreeID, spells);
end

function TieredEntranceTraitsContainerMixin:SetMawAuras()
	local spells = {};
	for i = 1, MAW_BUFF_MAX_DISPLAY do
		local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "MAW");
		if auraData and auraData.spellId then
			table.insert(spells, auraData.spellId);
		end
	end
	self:SetSpells(spells);
	return #spells;
end

function TieredEntranceTraitsContainerMixin:SetTextureKit(textureKit)
	self.textureKit = textureKit;
	-- convert these to use string.format()
	local buttonUpAtlas = string.format("%s-challenge-button-up", textureKit);
	local buttonPressedAtlas = string.format("%s-challenge-button-pressed", textureKit);
	self.NormalTexture:SetAtlas(buttonUpAtlas, TextureKitConstants.UseAtlasSize);
	self.PushedTexture:SetAtlas(buttonPressedAtlas, TextureKitConstants.UseAtlasSize);
	self.HighlightTexture:SetAtlas(buttonUpAtlas, TextureKitConstants.UseAtlasSize);
	self.ThemeOverlay:SetAtlas(string.format("%s-challenge-button-up-add", textureKit), TextureKitConstants.UseAtlasSize);
	self.DisabledTexture:SetAtlas(buttonUpAtlas, TextureKitConstants.UseAtlasSize);
	self.List.Background:SetAtlas(string.format("%s-challenge-flyout", textureKit), TextureKitConstants.UseAtlasSize);
	self.List.textureKit = textureKit;

	-- Reset so UpdateAlignment re-runs and updates the arrow atlases with the new texture kit
	self.isOnLeftSide = nil;
	if self:IsShown() then
		self:UpdateAlignment();
	end
end

function TieredEntranceTraitsContainerMixin:Update(numTraits, traitTreeID, spells)
	self.traitTreeID = traitTreeID;
	self.numTraits = numTraits;
	self.spells = spells;
	self.needSet = true;

	if self.List and self.List:IsShown() then
		self.needSet = nil;
		if traitTreeID then
			self.List:SetTraitTree(traitTreeID, numTraits);
		else
			self.List:SetSpells(spells);
		end
	end

	self:SetFormattedText(SCENARIO_CHALLENGES_BUTTON, numTraits);
	-- if no traits just disable the button
	if numTraits == 0 then
		self:SetEnabled(false);
		self.ThemeOverlay:Hide();
	else
		self:SetEnabled(true);
		local displayInfo = C_ScenarioInfo.GetDisplayInfo();
		if displayInfo and displayInfo.themeColor then
			self.ThemeOverlay:Show();
			self.ThemeOverlay:SetVertexColor(displayInfo.themeColor:GetRGB());
		else
			self.ThemeOverlay:Hide();
		end
	end
end

function TieredEntranceTraitsContainerMixin:SetPressed(pressed)
	AlphaHighlightButtonMixin.SetPressed(self, pressed);
	local textureKit = self.textureKit or "themed-scenario";
	if self.pressed then
		self.ThemeOverlay:SetAtlas(string.format("%s-challenge-button-pressed-add", textureKit), TextureKitConstants.UseAtlasSize);
	else
		self.ThemeOverlay:SetAtlas(string.format("%s-challenge-button-up-add", textureKit), TextureKitConstants.UseAtlasSize);
	end
end

function TieredEntranceTraitsContainerMixin:UpdateAlignment()
	local left = self:GetLeft();
	if not left then
		return;
	end

	local isOnLeftSide = left < LIST_SAFE_WIDTH;
	-- initially self.isOnLeftSide is nil so this will always run the first time
	if isOnLeftSide == self.isOnLeftSide then
		return;
	end

	self.isOnLeftSide = isOnLeftSide;

	self.List:ClearAllPoints();
	self.Arrow:ClearAllPoints();

	local textureKit = self.textureKit or "themed-scenario";
	if isOnLeftSide then
		self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 17, 1);
		self.Arrow:SetAtlas(string.format("%s-challenge-flyout-forwardarrow", textureKit), TextureKitConstants.UseAtlasSize);
		self.Arrow:SetPoint("LEFT", self, "RIGHT", -5, 0);
	else
		self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -17, 0);
		self.Arrow:SetAtlas(string.format("%s-challenge-flyout-backarrow", textureKit), TextureKitConstants.UseAtlasSize);
		self.Arrow:SetPoint("RIGHT", self, "LEFT", 5, 0);
	end
end

TieredEntranceTraitsListMixin = {};

function TieredEntranceTraitsListMixin:OnLoad()
	self.framePool = CreateFramePool("FRAME", self, "TieredEntranceTraitSpellTemplate");

	TalentFrameBaseMixin.OnLoad(self);
	self.ButtonsParent:SetPropagateMouseMotion(true);
	self.buttonsMethod = GenerateClosure(self.OrderButtons, self);
end

function TieredEntranceTraitsListMixin:OrderButtons()
	local orderedButtons = {};
	for talentButton in self:EnumerateAllTalentButtons() do
		if talentButton.visualState == TalentButtonUtil.BaseVisualState.Normal or talentButton.visualState == TalentButtonUtil.BaseVisualState.Maxed then
			local nodeInfo = talentButton:GetNodeInfo();
			if nodeInfo then
				if nodeInfo.activeRank then
					tinsert(orderedButtons, talentButton);
				else
					talentButton:Hide();
				end
			end
		else
			talentButton:Hide();
		end
	end

	return orderedButtons;
end

function TieredEntranceTraitsListMixin:GetTemplateForTalentType(_nodeInfo, _talentType, _useLarge)
	return "TalentButtonScenarioChallengeCircleTemplate";
end

function TieredEntranceTraitsListMixin:CalculateHeight(numTraits)
	local numRows = math.ceil(numTraits / self.stride);
	local height = numRows * LIST_ROW_SPACING + (numRows - 1) * self.paddingY + self.topPadding + self.bottomPadding;
	return height;
end

function TieredEntranceTraitsListMixin:SetTraitTree(traitTreeID, numTraits)
	local height = self:CalculateHeight(numTraits)
	self:SetHeight(height);

	local systemID = C_Traits.GetSystemIDByTreeID(traitTreeID);
	self:SetConfigIDBySystemID(systemID);
end

function TieredEntranceTraitsListMixin:SetSpells(spells)
	-- resize the panel
	local height = self:CalculateHeight(#spells)
	self:SetHeight(height);

	-- get frames
	self.framePool:ReleaseAll();
	local frames = { };
	for i, spellID in ipairs(spells) do
		local iconTexture = C_Spell.GetSpellTexture(spellID);
		if iconTexture then
			local frame = self.framePool:Acquire();
			frame.Icon:SetTexture(iconTexture);
			frame.spellID = spellID;
			local circleAtlas = string.format("%s-challenge-gold-circle", self.textureKit or "themed-scenario");
			frame.GoldCircle:SetAtlas(circleAtlas, TextureKitConstants.UseAtlasSize);
			frame:Show();
			table.insert(frames, frame);
		end
	end

	-- layout
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, self.stride, self.paddingX, self.paddingY);
	local anchor = CreateAnchor("TOPLEFT", self, "TOPLEFT", 27, -20);
	AnchorUtil.GridLayout(frames, anchor, layout);
end

TieredEntranceTraitSpellMixin = { };

function TieredEntranceTraitSpellMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
end
