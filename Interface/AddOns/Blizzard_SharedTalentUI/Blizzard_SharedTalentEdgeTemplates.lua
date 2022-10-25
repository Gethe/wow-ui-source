
TalentEdgeBaseMixin = {};

function TalentEdgeBaseMixin:Init(startButton, endButton, edgeInfo)
	self.startButton = startButton;
	self.endButton = endButton;
	self.edgeInfo = edgeInfo;
end

function TalentEdgeBaseMixin:GetStartButton()
	return self.startButton;
end

function TalentEdgeBaseMixin:GetEndButton()
	return self.endButton;
end

function TalentEdgeBaseMixin:GetEdgeInfo()
	return self.edgeInfo;
end


-- TODO:: Replace the art for this to be a generic edge template.
TalentEdgeStraightMixin = {};

local ActiveEdgeFrameLevel = 100;
function TalentEdgeStraightMixin:Init(startButton, endButton, edgeInfo)
	TalentEdgeBaseMixin.Init(self, startButton, endButton, edgeInfo);

	local function TalentEdgeAttachToButtons(talentEdge)
		talentEdge:SetStartPoint("CENTER", startButton);
		talentEdge:SetEndPoint("CENTER", endButton);
	end

	TalentEdgeAttachToButtons(self.Background);
	TalentEdgeAttachToButtons(self.Fill);
	TalentEdgeAttachToButtons(self.FillScroll1);
	TalentEdgeAttachToButtons(self.FillScroll2);

	self.ScrollAnim:Play();

	local isActive = edgeInfo.isActive;
	self:SetFrameLevel(isActive and ActiveEdgeFrameLevel or 1);

	self:UpdateState();
end

function TalentEdgeStraightMixin:UpdateState()
	local edgeInfo = self:GetEdgeInfo();
	local isEndButtonGated = self:GetEndButton():GetVisualState() == TalentButtonUtil.BaseVisualState.Gated;

	if edgeInfo.type == Enum.TraitEdgeType.MutuallyExclusive then
		self:SetLineColor(isEndButtonGated and DIM_RED_FONT_COLOR or RED_FONT_COLOR);
	elseif edgeInfo.visualStyle == Enum.TraitEdgeVisualStyle.Straight then
		if edgeInfo.isActive then
			self:SetLineColor(YELLOW_FONT_COLOR:GetRGBA());
		elseif isEndButtonGated then
			self:SetLineColor(0.1, 0.1, 0.1);
		else
			self:SetLineColor(GRAY_FONT_COLOR:GetRGBA());
		end
	end
end

function TalentEdgeStraightMixin:SetLineColor(r, g, b, a)
	a = a or 1.0;

	self.Fill:SetVertexColor(r, g, b, a);
	self.FillScroll1:SetVertexColor(r, g, b, a);
	self.FillScroll2:SetVertexColor(r, g, b, a);
end


TalentEdgeArrowMixin = {};

function TalentEdgeArrowMixin:Init(startButton, endButton, edgeInfo)
	TalentEdgeBaseMixin.Init(self, startButton, endButton, edgeInfo);

	local angle = RegionUtil.CalculateAngleBetween(endButton, startButton);
	local diameterOffset = endButton.GetEdgeDiameterOffset and endButton:GetEdgeDiameterOffset(angle) or TalentButtonUtil.CircleEdgeDiameterOffset;
	local xOffset = (endButton:GetWidth() / 2) * math.cos(angle) * diameterOffset;
	local yOffset = (endButton:GetHeight() / 2) * math.sin(angle) * diameterOffset;

	self.Line:SetStartPoint("CENTER", startButton);
	self.Line:SetEndPoint("CENTER", endButton, xOffset, yOffset);

	self.GhostLine:SetStartPoint("CENTER", startButton);
	self.GhostLine:SetEndPoint("CENTER", endButton, xOffset, yOffset);

	self.ArrowHead:SetPoint("CENTER", endButton, xOffset, yOffset);
	self.ArrowHead:SetRotation(angle - (math.pi / 2));

	self.GhostArrowHead:SetPoint("CENTER", endButton, xOffset, yOffset);
	self.GhostArrowHead:SetRotation(angle - (math.pi / 2));

	self:UpdateState();
end

function TalentEdgeArrowMixin:UpdateState()
	local edgeInfo = self:GetEdgeInfo();

	local isStartButtonGhosted = self:GetStartButton():IsGhosted();
	local isEndButtonGhosted = self:GetEndButton():IsGhosted();

	local isLineGhosted = isStartButtonGhosted and isEndButtonGhosted;

	self.GhostLine:SetShown(isLineGhosted);
	self.GhostArrowHead:SetShown(isLineGhosted);

	-- Other types and styles are not supported by this template.
	if edgeInfo.visualStyle == Enum.TraitEdgeVisualStyle.Straight then
		if edgeInfo.isActive then
			self.Line:SetAtlas("talents-arrow-line-yellow", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-yellow", TextureKitConstants.IgnoreAtlasSize);
		elseif (self:GetEndButton():GetVisualState() == TalentButtonUtil.BaseVisualState.Gated) then
			self.Line:SetAtlas("talents-arrow-line-locked", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-locked", TextureKitConstants.IgnoreAtlasSize);
		else
			self.Line:SetAtlas("talents-arrow-line-gray", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-gray", TextureKitConstants.IgnoreAtlasSize);
		end
	end
end
