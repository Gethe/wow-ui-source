CollapseButtonMixin = { };

function CollapseButtonMixin:UpdatePressedState(pressed)
	if pressed then
		self.Icon:AdjustPointsOffset(1, -1);
	else
		self.Icon:AdjustPointsOffset(-1, 1);
	end
end

function CollapseButtonMixin:UpdateCollapsedState(collapsed)
	self.collapsed = collapsed;
	local atlas = collapsed and "questlog-icon-expand" or "questlog-icon-shrink";
	self.Icon:SetAtlas(atlas, true);
	self:SetHighlightAtlas(atlas);
end

ListHeaderVisualMixin = {};

function ListHeaderVisualMixin:GetTitleRegion()
	return self.ButtonText or self.Text;
end

function ListHeaderVisualMixin:AdjustTextOffset(x, y)
	local title = self:GetTitleRegion();
	if title then
		title:AdjustPointsOffset(x, y);
	end
end

function ListHeaderVisualMixin:GetTitleColor(useHighlight)
	local color = self.titleColors and self.titleColors[useHighlight];
	if color then
		return color;
	end

	return useHighlight and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
end

function ListHeaderVisualMixin:SetTitleColor(useHighlight, color)
	if not self.titleColors then
		self.titleColors = {};
	end

	self.titleColors[useHighlight] = color;
end

function ListHeaderVisualMixin:CheckHighlightTitle(isMouseOver)
	if isMouseOver == nil then
		isMouseOver = self:IsMouseMotionFocus();
	end

	local color = self:GetTitleColor(isMouseOver);
	self:GetTitleRegion():SetTextColor(color:GetRGB());
end

function ListHeaderVisualMixin:SetHeaderText(text)
	self:GetTitleRegion():SetText(text);
	self:CheckHighlightTitle(nil);
end

function ListHeaderVisualMixin:IsTruncated()
	return self:GetTitleRegion():IsTruncated();
end

function ListHeaderVisualMixin:GetCollapseButton()
	return self.CollapseButton;
end

ListHeaderMixin = {};

function ListHeaderMixin:OnLoad()
	local isMouseOver = false;
	self:CheckHighlightTitle(isMouseOver);
	self:SetPushedTextOffset(1, -1);
end

function ListHeaderMixin:OnClick(button)
	if self.customClickHandler then
		self.customClickHandler(self, button);
	end
end

function ListHeaderMixin:SetClickHandler(handler)
	self.customClickHandler = handler;
end

function ListHeaderMixin:OnEnter()
	local isMouseOver = true;
	self:CheckHighlightTitle(isMouseOver);
	self:CheckUpdateTooltip(isMouseOver);

	local collapseButton = self:GetCollapseButton();
	if collapseButton then
		collapseButton:LockHighlight();
	end
end

function ListHeaderMixin:OnLeave()
	local isMouseOver = false;
	self:CheckHighlightTitle(isMouseOver);
	self:CheckUpdateTooltip(isMouseOver);

	local collapseButton = self:GetCollapseButton();
	if collapseButton then
		collapseButton:UnlockHighlight();
	end
end

function ListHeaderMixin:CheckUpdateTooltip(isMouseOver)
	local tooltip = GetAppropriateTooltip();

	if self:IsTruncated() and isMouseOver then
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 239, 0);
		tooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip_SetTitle(tooltip, self:GetTitleRegion():GetText(), nil, true);
	else
		tooltip:Hide();
	end
end

function ListHeaderMixin:OnMouseDown()
	self:AdjustTextOffset(1, -1);

	local collapseButton = self:GetCollapseButton();
	if collapseButton then
		local pressed = true;
		collapseButton:UpdatePressedState(pressed);
	end
end

function ListHeaderMixin:OnMouseUp()
	self:AdjustTextOffset(-1, 1);

	local collapseButton = self:GetCollapseButton();
	if collapseButton then
		local pressed = false;
		collapseButton:UpdatePressedState(pressed);
	end
end

function ListHeaderMixin:UpdateCollapsedState(collapsed)
	local collapseButton = self:GetCollapseButton();
	if collapseButton then
		collapseButton:UpdateCollapsedState(collapsed);
	end
end

ListHeaderThreeSliceMixin = CreateFromMixins(ListHeaderVisualMixin);

function ListHeaderThreeSliceMixin:OnLoad()
	-- override if necessary
end

function ListHeaderThreeSliceMixin:GetTitleRegion()
	return self.Name;
end

function ListHeaderThreeSliceMixin:UpdateCollapsedState(collapsed)
	self.Right:SetAtlas(collapsed and "Options_ListExpand_Right" or "Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
	self.HighlightRight:SetAtlas(collapsed and "Options_ListExpand_Right" or "Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
end
