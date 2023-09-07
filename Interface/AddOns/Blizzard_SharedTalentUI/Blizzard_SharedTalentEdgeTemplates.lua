
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
	local endVisualState = self:GetEndButton():GetVisualState();
	local startVisualState = self:GetStartButton():GetVisualState();
	local isStartRefundInvalid = (startVisualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	local isEndRefundInvalid = (endVisualState == TalentButtonUtil.BaseVisualState.RefundInvalid);

	-- The edge only shows in red if the start is satisfied (or "Maxed") and the end button is RefundInvalid.
	local isRefundInvalidFromEndButton = isEndRefundInvalid and (startVisualState == TalentButtonUtil.BaseVisualState.Maxed);
	if isRefundInvalidFromEndButton or isStartRefundInvalid then
		self:SetLineColor(RED_FONT_COLOR:GetRGBA());
		return;
	end

	local isEndButtonGated = endVisualState == TalentButtonUtil.BaseVisualState.Gated;
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

	local startButton = self:GetStartButton();
	local isStartButtonGhosted = startButton:IsGhosted();
	local isStartButtonCascadeRepurchaseable = startButton:IsCascadeRepurchasable();

	local endButton = self:GetEndButton();
	local isEndButtonGhosted = endButton:IsGhosted();

	local startVisualState = startButton:GetVisualState();
	local endButtonVisualState = endButton:GetVisualState();
	local isEndRefundInvalid = (endButtonVisualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	
	-- The edge only shows in red if the start is satisfied (or "Maxed") and the end button is RefundInvalid.
	local isRefundInvalidFromEndButton = isEndRefundInvalid and (startVisualState == TalentButtonUtil.BaseVisualState.Maxed);
	local isStartRefundInvalid = (startVisualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	local isRefundInvalidState = isStartRefundInvalid or isRefundInvalidFromEndButton;

	local isLineGhosted = not isRefundInvalidState and ((isStartButtonGhosted or isStartButtonCascadeRepurchaseable) and isEndButtonGhosted);
	self.GhostLine:SetShown(isLineGhosted);
	self.GhostArrowHead:SetShown(isLineGhosted);

	-- Other types and styles are not supported by this template.
	if edgeInfo.visualStyle == Enum.TraitEdgeVisualStyle.Straight then
		if isRefundInvalidState then
			self.Line:SetAtlas("talents-arrow-line-red", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-red");
		elseif edgeInfo.isActive then
			self.Line:SetAtlas("talents-arrow-line-yellow", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-yellow");
		elseif endButtonVisualState == TalentButtonUtil.BaseVisualState.Gated then
			self.Line:SetAtlas("talents-arrow-line-locked", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-locked");
		else
			self.Line:SetAtlas("talents-arrow-line-gray", TextureKitConstants.IgnoreAtlasSize);
			self.ArrowHead:SetAtlas("talents-arrow-head-gray");
		end
	end
end
