
AuctionHouseLevelRangeEditBoxMixin = {};

function AuctionHouseLevelRangeEditBoxMixin:OnTextChanged()
	self:GetParent():OnLevelRangeChanged();
end


AuctionHouseLevelRangeFrameMixin = {};

function AuctionHouseLevelRangeFrameMixin:OnLoad()
	self.MinLevel.nextEditBox = self.MaxLevel;
	self.MaxLevel.nextEditBox = self.MinLevel;
end

function AuctionHouseLevelRangeFrameMixin:OnHide()
	self:FixLevelRange();
end

function AuctionHouseLevelRangeFrameMixin:SetLevelRangeChangedCallback(levelRangeChangedCallback)
	self.levelRangeChangedCallback = levelRangeChangedCallback;
end

function AuctionHouseLevelRangeFrameMixin:OnLevelRangeChanged()
	if self.levelRangeChangedCallback then
		self.levelRangeChangedCallback();
	end
end

function AuctionHouseLevelRangeFrameMixin:FixLevelRange()
	local minLevel = self.MinLevel:GetNumber();
	local maxLevel = self.MaxLevel:GetNumber();

	if maxLevel ~= 0 and minLevel > maxLevel then
		self.MinLevel:SetNumber(maxLevel);
	end
end

function AuctionHouseLevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("");
	self.MaxLevel:SetText("");
end

function AuctionHouseLevelRangeFrameMixin:GetLevelRange()
	return self.MinLevel:GetNumber(), self.MaxLevel:GetNumber();
end