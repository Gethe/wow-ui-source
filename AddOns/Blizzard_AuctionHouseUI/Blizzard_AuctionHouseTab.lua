
local MIN_TAB_WIDTH = 70;
local TAB_PADDING = 20;


AuctionHouseFrameTabMixin = {};

function AuctionHouseFrameTabMixin:OnShow()
	local absoluteSize = nil;
	PanelTemplates_TabResize(self, TAB_PADDING, absoluteSize, MIN_TAB_WIDTH);
end


AuctionHouseFrameTopTabMixin = CreateFromMixins(AuctionHouseFrameTabMixin);

function AuctionHouseFrameTopTabMixin:OnLoad()
	self.LeftDisabled:SetPoint("BOTTOMLEFT");
	self.Text:ClearAllPoints();
	self.deselectedTextY = -6;
	self.selectedTextY = -2;
end

function AuctionHouseFrameTopTabMixin:OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end


AuctionHouseFrameDisplayModeTabMixin = {};

function AuctionHouseFrameDisplayModeTabMixin:OnClick()
	CallMethodOnNearestAncestor(self, "SetDisplayMode", self.displayMode);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end