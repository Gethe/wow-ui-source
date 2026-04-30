local LIST_ROW_SPACING = 40;
local LIST_SAFE_WIDTH = 300;

TieredEntranceTraitsContainerMixin = {};

function TieredEntranceTraitsContainerMixin:OnHide()
	self.List:Hide();
	self.Arrow:Hide();
end

function TieredEntranceTraitsContainerMixin:OnClick()
	local doShow = not self.List:IsShown();
	if doShow then
		if self.needSet then
			self.needSet = nil;
			if self.traitTreeID then
				self.List:SetTraitTree(self.traitTreeID, self.numTraits);
			else
				self.List:SetSpells(self.spells);
			end
		end
		self:UpdateAlignment();
	end
	self.List:SetShown(doShow);
	self.Arrow:SetShown(doShow);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function TieredEntranceTraitsContainerMixin:SetTraitTree(traitTreeID)
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

function TieredEntranceTraitsContainerMixin:Update(numTraits, traitTreeID, spells)
	self.traitTreeID = traitTreeID;
	self.numTraits = numTraits;
	self.spells = spells;
	self.needSet = true;

	self:SetFormattedText(SCENARIO_CHALLENGES_BUTTON, numTraits);
	-- if no traits just disable the button
	if numTraits == 0 then
		self:SetEnabled(false);
		self.ThemeOverlay:Hide();
	else
		self:SetEnabled(true);
		local displayInfo = C_ScenarioInfo.GetDisplayInfo();
		if displayInfo then
			self.ThemeOverlay:Show();
			self.ThemeOverlay:SetVertexColor(displayInfo.themeColor:GetRGB());
		else
			self.ThemeOverlay:Hide();
		end
	end
end

function TieredEntranceTraitsContainerMixin:SetPressed(pressed)
	AlphaHighlightButtonMixin.SetPressed(self, pressed);
	if self.pressed then
		self.ThemeOverlay:SetAtlas("themed-scenario-challenge-button-pressed-add", TextureKitConstants.UseAtlasSize);
	else
		self.ThemeOverlay:SetAtlas("themed-scenario-challenge-button-up-add", TextureKitConstants.UseAtlasSize);
	end
end

function TieredEntranceTraitsContainerMixin:UpdateAlignment()
	local isOnLeftSide = self:GetLeft() < LIST_SAFE_WIDTH;
	-- initially self.isOnLeftSide is nil so this will always run the first time
	if isOnLeftSide == self.isOnLeftSide then
		return;
	end

	self.isOnLeftSide = isOnLeftSide;

	self.List:ClearAllPoints();
	self.Arrow:ClearAllPoints();

	if isOnLeftSide then
		self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 17, 1);
		self.Arrow:SetAtlas("themed-scenario-challenge-flyout-forwardarrow", TextureKitConstants.UseAtlasSize);
		self.Arrow:SetPoint("LEFT", self, "RIGHT", -5, 0);
	else
		self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -17, 0);
		self.Arrow:SetAtlas("themed-scenario-challenge-flyout-backarrow", TextureKitConstants.UseAtlasSize);
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
