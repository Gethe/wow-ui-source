local MAW_BUFF_MAX_DISPLAY = 44;

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

function MawBuffsContainerMixin:Update()
	local mawBuffs = {};
	local totalCount = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do
		local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("player", i, "MAW");
		if icon then
			if count == 0 then
				count = 1;
			end

			totalCount = totalCount + count;
			table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});
		end
	end

	self:SetText(JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(totalCount));
	self.List:Update(mawBuffs);
	
	if(IsInJailersTower() or self.fromFrameManager) then
		self:Show();
	else
		self:Hide();
	end

	self.buffCount = #mawBuffs;
	if self.buffCount == 0 then
		self.List:Hide();
		self:Disable();
	else
		self:Enable();
	end
	self:UpdateHelptip(); 
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
	self.button:SetPushedTextOffset(8.75, -1);
	self.button:SetButtonState("PUSHED", true);
end

function MawBuffsListMixin:OnHide()
	self.button:SetPushedAtlas("jailerstower-animapowerbutton-normalpressed");
	self.button:SetHighlightAtlas("jailerstower-animapowerbutton-highlight");
	self.button:SetWidth(253);
	self.button:SetButtonState("NORMAL", false);
	self.button:SetPushedTextOffset(1.25, -1);
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

MawBuffsBelowMinimapFrameMixin = { };
function MawBuffsBelowMinimapFrameMixin:OnShow()
	self.Container.fromFrameManager = true;
	self.Container:Update(); 
	UIParent_ManageFramePositions();
end 