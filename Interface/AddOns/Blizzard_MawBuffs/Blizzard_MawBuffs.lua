local MAW_BUFF_MAX_DISPLAY = 44;

function ShouldShowMawBuffs()
	local auraData = C_UnitAuras.GetAuraDataByIndex("player", 1, "MAW");
	local hasMawBuff = auraData and auraData.icon;
	return IsInJailersTower() or hasMawBuff or false;
end

MawBuffsContainerMixin = {};

function MawBuffsContainerMixin:OnLoad()
	self:Update();
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
end

function MawBuffsContainerMixin:OnEvent(event, ...)
	local unit = ...;
	if event == "UNIT_AURA" then
		self:Update();
	elseif event == "GLOBAL_MOUSE_DOWN" then
		if self.List:IsShown() then
			if (self:IsMouseOver() or self.List:IsMouseOver() or (PlayerChoiceFrame and PlayerChoiceFrame:IsShown()))  then 
				return; 
			end 

			self:UpdateListState(false);
		end
	end
end

function MawBuffsContainerMixin:OnShow()
	self:UpdateAlignment();
end

function MawBuffsContainerMixin:Update()
	if not ShouldShowMawBuffs() then
		self:Hide();
		self.buffCount = 0;
		return;
	end

	local mawBuffs = {};
	local totalCount = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do
		local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "MAW");
		if auraData and auraData.icon then
			if auraData.applications == 0 then
				auraData.applications = 1;
			end

			totalCount = totalCount + auraData.applications;
			table.insert(mawBuffs, {icon = auraData.icon, count = auraData.applications, slot = i, spellID = auraData.spellId});
		end
	end

	self:SetText(JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(totalCount));
	self.List:Update(mawBuffs);

	self:Show();

	self.buffCount = #mawBuffs;
	if self.buffCount == 0 then
		self.List:Hide();
		self:Disable();
	else
		self:Enable();
	end
	self:UpdateHelptip();
end

function MawBuffsContainerMixin:UpdateAlignment()
	local isOnLeftSide = ObjectiveTrackerFrame and ObjectiveTrackerFrame.isOnLeftSideOfScreen;
	-- initially self.isOnLeftSide is nil so the first time this check will fail, resulting in an update
	if isOnLeftSide == self.isOnLeftSide then
		return;
	end

	self.isOnLeftSide = isOnLeftSide;

	self:ClearAllPoints();
	self.List:ClearAllPoints();

	if isOnLeftSide then
		-- If tracker is on left side of screen make stuff face right
		self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0);
		self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", -15, 1);

		self.NormalTexture:SetTexCoord(1, 0, 1, 0);
		self.PushedTexture:SetTexCoord(1, 0, 1, 0);
		self.HighlightTexture:SetTexCoord(1, 0, 1, 0);
		self.DisabledTexture:SetTexCoord(1, 0, 1, 0);
	else
		-- If tracker is on right side of screen make stuff face left
		self:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", 0, 0);
		self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", 15, 1);

		self.NormalTexture:SetTexCoord(0, 1, 1, 0);
		self.PushedTexture:SetTexCoord(0, 1, 1, 0);
		self.HighlightTexture:SetTexCoord(0, 1, 1, 0);
		self.DisabledTexture:SetTexCoord(0, 1, 1, 0);
	end
end

function MawBuffsContainerMixin:UpdateHelptip()
	if(self.buffCount > 0 and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_9_0_JAILERS_TOWER_BUFFS)) then
		local selectLocationHelpTipInfo = {
			text = JAILERS_TOWER_BUFFS_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_9_0_JAILERS_TOWER_BUFFS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			autoEdgeFlipping = true,
			useParentStrata = true,
		};
		 HelpTip:Show(self, selectLocationHelpTipInfo)
	else 
		HelpTip:Hide(self, JAILERS_TOWER_BUFFS_TUTORIAL);
	end
end 

function MawBuffsContainerMixin:UpdateListState(shouldShow) 
	self:SetEnabled(not shouldShow); 
	self.List:SetShown(shouldShow and self.buffCount > 0); 
end 

function MawBuffsContainerMixin:OnClick()
	self.List:SetShown(not self.List:IsShown());
	HelpTip:Acknowledge(self, JAILERS_TOWER_BUFFS_TUTORIAL);
	PlaySound(SOUNDKIT.UI_MAW_BUFFS_ANIMA_POWERS_BUTTON);
end

function MawBuffsContainerMixin:HighlightBuffAndShow(spellID, maxStacks)
	self.List:HighlightBuffAndShow(spellID, maxStacks)
end 

function MawBuffsContainerMixin:HideBuffHighlight(spellID)
	self.List:HideBuffHighlight(spellID)
end 

MawBuffsListMixin = {};

local BUFF_HEIGHT = 45;
local BUFF_LIST_MIN_HEIGHT = 159;
local BUFF_LIST_PADDING_HEIGHT = 36;
local BUFF_LIST_NUM_COLUMNS = 4;

function MawBuffsListMixin:OnLoad()
	self.button = self:GetParent();
	self:SetFrameLevel(self.button:GetFrameLevel() - 1);
	self.buffPool = CreateFramePool("BUTTON", self, "MawBuffTemplate");
end

function MawBuffsListMixin:OnShow()
	self.button:SetPushedAtlas("jailerstower-animapowerbutton-pressed");
	self.button:SetHighlightAtlas("jailerstower-animapowerbutton-pressed-highlight");
	self.button:SetWidth(268);
	self.button:SetButtonState("NORMAL");
	self.button:SetPushedTextOffset((ObjectiveTrackerFrame and ObjectiveTrackerFrame.isOnLeftSideOfScreen) and -8.75 or 8.75, -1);
	self.button:SetButtonState("PUSHED", true);
end

function MawBuffsListMixin:OnHide()
	self.button:SetPushedAtlas("jailerstower-animapowerbutton-normalpressed");
	self.button:SetHighlightAtlas("jailerstower-animapowerbutton-highlight");
	self.button:SetWidth(253);
	self.button:SetButtonState("NORMAL", false);
	self.button:SetPushedTextOffset((ObjectiveTrackerFrame and ObjectiveTrackerFrame.isOnLeftSideOfScreen) and -1.25 or 1.25, -1);
end

function MawBuffsListMixin:HighlightBuffAndShow(spellID, maxStackCount)
	if(not spellID or not maxStackCount or not self.buffPool) then 
		return;
	end 
	for mawBuff in self.buffPool:EnumerateActive() do
		if(mawBuff.spellID == spellID and mawBuff.count < maxStackCount) then 
			if( not self:IsShown()) then 
				self:Show(); 
			end
			mawBuff.HighlightBorder:Show(); 
			return; 
		end 
	end
end

function MawBuffsListMixin:HideBuffHighlight(spellID)
	if(not spellID or not self.buffPool) then 
		return;
	end 

	for mawBuff in self.buffPool:EnumerateActive() do
		if(mawBuff.spellID == spellID) then 
			mawBuff.HighlightBorder:Hide(); 
		end 
	end
end

function MawBuffsListMixin:Update(mawBuffs)
	self.buffPool:ReleaseAll();

	local lastRowFirstFrame;
	local lastBuffFrame;
	local buffsTotalHeight = 0;
	for index, buffInfo in ipairs(mawBuffs) do
		local buffFrame = self.buffPool:Acquire();

		local column = mod(index, BUFF_LIST_NUM_COLUMNS);
		if column == 1 then
			if lastRowFirstFrame then
				buffFrame:SetPoint("TOPLEFT", lastRowFirstFrame, "BOTTOMLEFT", 0, -3);
				buffsTotalHeight = buffsTotalHeight + BUFF_HEIGHT + 3;
			else
				buffFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 12, -18);
				buffsTotalHeight = BUFF_HEIGHT;
			end
			lastRowFirstFrame = buffFrame;
		else
			buffFrame:SetPoint("TOPLEFT", lastBuffFrame, "TOPRIGHT", 3, 0);
		end

		lastBuffFrame = buffFrame;
		buffFrame:SetBuffInfo(mawBuffs[index]);
	end

	local totalListHeight = math.max(buffsTotalHeight + BUFF_LIST_PADDING_HEIGHT, BUFF_LIST_MIN_HEIGHT);
	self:SetHeight(totalListHeight);
end

MawBuffMixin = {};

function MawBuffMixin:SetBuffInfo(buffInfo)
	self.Icon:SetTexture(buffInfo.icon);
	self.slot = buffInfo.slot;
	self.count = buffInfo.count;
	self.spellID = buffInfo.spellID;

	local rarityAtlas = C_Spell.GetMawPowerBorderAtlasBySpellID(self.spellID);
	local showCount = buffInfo.count > 1;
		
	if (showCount) then
		self.Count:SetText(buffInfo.count);
	end 

	if(rarityAtlas) then
		self.Border:SetAtlas(rarityAtlas, TextureKitConstants.UseAtlasSize);
	end 

	self.Count:SetShown(showCount);
	self.CountRing:SetShown(showCount);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end

	self:Show();
end

function MawBuffMixin:OnEnter()
	self:RefreshTooltip(); 
end 

function MawBuffMixin:RefreshTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetUnitAura("player", self.slot, "MAW");

	GameTooltip:Show();
	self.HighlightBorder:Show(); 
end

function MawBuffMixin:OnClick()
	if (IsModifiedClick("CHATLINK")) then
		ChatEdit_InsertLink(GetMawPowerLinkBySpellID(self.spellID));
		return;
	end
end

function MawBuffMixin:OnLeave()
	GameTooltip_Hide(); 
	self.HighlightBorder:Hide(); 
end