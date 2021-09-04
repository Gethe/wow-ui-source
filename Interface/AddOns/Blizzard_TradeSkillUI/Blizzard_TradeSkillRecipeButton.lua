TRADE_SKILL_SKILLUP_TEXT_WIDTH = 30;
TRADE_SKILL_SUB_SKILL_BAR_WIDTH = 60;
TRADE_SKILL_TEXT_WIDTH = 270;

TradeSkillRecipeButtonMixin = {};

function TradeSkillRecipeButtonMixin:SetUp(tradeSkillInfo)
	self.tradeSkillInfo = tradeSkillInfo;

	local textWidth = TRADE_SKILL_TEXT_WIDTH;
	if tradeSkillInfo.numIndents > 0 then
		textWidth = textWidth - 20;
		self:GetNormalTexture():SetPoint("LEFT", 23, 0);
		self:GetDisabledTexture():SetPoint("LEFT", 23, 0);
		self:GetHighlightTexture():SetPoint("LEFT", 23, 0);
	else
		self:GetNormalTexture():SetPoint("LEFT", 3, 0);
		self:GetDisabledTexture():SetPoint("LEFT", 3, 0);
		self:GetHighlightTexture():SetPoint("LEFT", 3, 0);
	end

	if tradeSkillInfo.type == "header" or tradeSkillInfo.type == "subheader" then
		self:SetUpHeader(textWidth, tradeSkillInfo);
	else
		self:SetUpRecipe(textWidth, tradeSkillInfo);
	end

	self:Show();
end

function TradeSkillRecipeButtonMixin:Clear()
	self.isHeader = nil;
	self.tradeSkillInfo = nil;
	self:Hide();
end

function TradeSkillRecipeButtonMixin:SetUpHeader(textWidth, tradeSkillInfo)
	self.isHeader = true;
	self.SkillUps:Hide();
	self.LockedIcon:Hide();
	self.StarsFrame:Hide();
	self:SetAlpha(1.0);

	self:SetBaseColor(TradeSkillTypeColor[tradeSkillInfo.type]);

	if tradeSkillInfo.hasProgressBar and not (C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember()) then
		self.SubSkillRankBar:Show();
		self.SubSkillRankBar:SetMinMaxValues(tradeSkillInfo.skillLineStartingRank, tradeSkillInfo.skillLineMaxLevel);
		self.SubSkillRankBar:SetValue(tradeSkillInfo.skillLineCurrentLevel);
		self.SubSkillRankBar.currentRank = tradeSkillInfo.skillLineCurrentLevel;
		self.SubSkillRankBar.maxRank = tradeSkillInfo.skillLineMaxLevel;

		textWidth = textWidth - TRADE_SKILL_SUB_SKILL_BAR_WIDTH;
	else
		self.SubSkillRankBar:Hide();
		self.SubSkillRankBar.currentRank = nil;
		self.SubSkillRankBar.maxRank = nil;
	end

	self.Text:SetWidth(textWidth);
	self:SetText(tradeSkillInfo.name);
	self.Count:SetText("");

	if (C_TradeSkillUI.IsEmptySkillLineCategory(tradeSkillInfo.categoryID)) then
		self:SetNormalTexture("");
		self.Highlight:SetTexture("")
	else
		if tradeSkillInfo.collapsed then
			self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
		end
		self.Highlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
	end

	self.SelectedTexture:Hide();
	self:UnlockHighlight()
	self.isSelected = false;
end

TradeSkillTypePrefix = {
	optimal			= " [+++] ",
	medium			= " [++] ",
	easy			= " [+] ",
	trivial			= " ",
	header			= " ",
	subheader		= " ",
	nodifficulty	= " ",
}

function TradeSkillRecipeButtonMixin:SetUpRecipe(textWidth, tradeSkillInfo)
	self.isHeader = false;

	local isTradeSkillGuild = C_TradeSkillUI.IsTradeSkillGuild();
	local isNPCCrafting = C_TradeSkillUI.IsNPCCrafting();

	self.SubSkillRankBar:Hide();

	local usedWidth;
	if not isTradeSkillGuild and not isNPCCrafting and tradeSkillInfo.numSkillUps > 1 and tradeSkillInfo.difficulty == "optimal" and not tradeSkillInfo.disabled then
		self.SkillUps:Show();
		self.SkillUps.Text:SetText(tradeSkillInfo.numSkillUps);
		usedWidth = TRADE_SKILL_SKILLUP_TEXT_WIDTH;
	else
		self.SkillUps:Hide();
		usedWidth = 0;
	end

	-- display a lock icon when the recipe is shown, but unavailable
	if tradeSkillInfo.disabled then
		self.LockedIcon:Show();
		usedWidth = TRADE_SKILL_SKILLUP_TEXT_WIDTH;
	else
		self.LockedIcon:Hide();
	end

	if tradeSkillInfo.learned then
		self:SetAlpha(1.0);
	else
		self:SetAlpha(0.65);
	end

	if isTradeSkillGuild then
		self:SetBaseColor(TradeSkillTypeColor.easy);
	elseif isNPCCrafting then
		self:SetBaseColor(TradeSkillTypeColor.nodifficulty);
	else
		self:SetBaseColor(TradeSkillTypeColor[tradeSkillInfo.difficulty]);
	end

	local skillNamePrefix = ENABLE_COLORBLIND_MODE == "1" and TradeSkillTypePrefix[tradeSkillInfo.difficulty] or " ";

	self:SetNormalTexture("");
	self.Highlight:SetTexture("");

	local totalRanks, currentRank = TradeSkillFrame_CalculateRankInfoFromRankLinks(tradeSkillInfo);
	if totalRanks > 1 then
		usedWidth = usedWidth + self.StarsFrame:GetWidth();
		self.StarsFrame:Show();
		for i, starFrame in ipairs(self.StarsFrame.Stars) do
			starFrame.EarnedStar:SetShown(i <= currentRank);
		end
		if self.SkillUps:IsShown() then
			self.SkillUps:SetPoint("RIGHT", self.StarsFrame, "LEFT", -2, 0);
			usedWidth = usedWidth + 11;
		end
	else
		self.StarsFrame:Hide();
		if self.SkillUps:IsShown() then
			self.SkillUps:SetPoint("RIGHT", self, "RIGHT", 3, 0);
		end
	end

	self.Text:SetWidth(0);
	self.Text:SetFormattedText("%s%s", skillNamePrefix, tradeSkillInfo.name);
	if tradeSkillInfo.numAvailable == 0 then
		self.Count:SetText("");
		textWidth = textWidth - usedWidth;
	else
		self.Count:SetFormattedText("[%d]", tradeSkillInfo.numAvailable);

		local nameWidth = self.Text:GetWidth();
		local countWidth = self.Count:GetWidth();

		if nameWidth + 2 + countWidth > textWidth - usedWidth then
			textWidth = textWidth - 2 - countWidth - usedWidth;
		else
			textWidth = 0;
		end
	end

	self.Text:SetWidth(textWidth);
end

function TradeSkillRecipeButtonMixin:SetBaseColor(color)
	self:SetNormalFontObject(color.font);
	self.Text:SetVertexColor(color.r, color.g, color.b);
	self.Count:SetVertexColor(color.r, color.g, color.b);
	self.SkillUps.Text:SetVertexColor(color.r, color.g, color.b);
	self.SkillUps.Icon:SetVertexColor(color.r, color.g, color.b);
	self.SelectedTexture:SetVertexColor(color.r, color.g, color.b)

	self.r = color.r;
	self.g = color.g;
	self.b = color.b;
	self.font = color.font;
end

function TradeSkillRecipeButtonMixin:SetSelected(selected)
	if selected then
		self.SelectedTexture:Show();

		self.Text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.Count:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

		self.SkillUps.Text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.SkillUps.Icon:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self:LockHighlight();
		self.isSelected = true;
	else
		self.SelectedTexture:Hide();
		self:UnlockHighlight();
		self.isSelected = false;
	end
end

function TradeSkillRecipeButtonMixin:OnMouseEnter()
	self.Count:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.SkillUps.Icon:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.SkillUps.Text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	self.Text:SetFontObject(GameFontHighlightLeft);
	self.Text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	if self.SubSkillRankBar.currentRank and self.SubSkillRankBar.maxRank then
		self.SubSkillRankBar.Rank:SetFormattedText("%d/%d", self.SubSkillRankBar.currentRank, self.SubSkillRankBar.maxRank);
	end
end


function TradeSkillRecipeButtonMixin:OnMouseLeave()
	if not self.isSelected then
		self.Count:SetVertexColor(self.r, self.g, self.b);
		self.SkillUps.Icon:SetVertexColor(self.r, self.g, self.b);
		self.SkillUps.Text:SetVertexColor(self.r, self.g, self.b);

		self.Text:SetFontObject(self.font);
		self.Text:SetVertexColor(self.r, self.g, self.b);
	end
	self.SubSkillRankBar.Rank:SetText("");
end

function TradeSkillRecipeButtonMixin:OnLockIconMouseEnter()
	if self.tradeSkillInfo.disabled and self.tradeSkillInfo.disabledReason then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(self.tradeSkillInfo.disabledReason, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end
