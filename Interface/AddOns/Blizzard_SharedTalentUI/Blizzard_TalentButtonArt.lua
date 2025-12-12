
TalentButtonArtMixin = {};

-- Split out for easier adjustment.
local RefundInvalidOverlayAlpha = 0.3;

TalentButtonArtMixin.ArtSet = {
	Square = {
		iconMask = nil,
		shadow = "talents-node-square-shadow",
		normal = "talents-node-square-yellow",
		disabled = "talents-node-square-gray",
		selectable = "talents-node-square-green",
		maxed = "talents-node-square-yellow",
		locked = "talents-node-square-locked",
		refundInvalid = "talents-node-square-red",
		displayError = "talents-node-square-red",
		glow = "talents-node-square-greenglow",
		ghost = "talents-node-square-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	Circle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-circle-shadow",
		normal = "talents-node-circle-yellow",
		disabled = "talents-node-circle-gray",
		selectable = "talents-node-circle-green",
		maxed = "talents-node-circle-yellow",
		refundInvalid = "talents-node-circle-red",
		displayError = "talents-node-circle-red",
		locked = "talents-node-circle-locked",
		glow = "talents-node-circle-greenglow",
		ghost = "talents-node-circle-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	Choice = {
		iconMask = "talents-node-choice-mask",
		shadow = "talents-node-choice-shadow",
		normal = "talents-node-choice-yellow",
		disabled = "talents-node-choice-gray",
		selectable = "talents-node-choice-green",
		maxed = "talents-node-choice-yellow",
		refundInvalid = "talents-node-choice-red",
		displayError = "talents-node-choice-red",
		locked = "talents-node-choice-locked",
		glow = "talents-node-choice-greenglow",
		ghost = "talents-node-choice-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LargeSquare = {
		iconMask = "talents-node-choiceflyout-mask",
		shadow = "talents-node-choiceflyout-square-shadow",
		normal = "talents-node-choiceflyout-square-yellow",
		disabled = "talents-node-choiceflyout-square-gray",
		selectable = "talents-node-choiceflyout-square-green",
		maxed = "talents-node-choiceflyout-square-yellow",
		refundInvalid = "talents-node-choiceflyout-square-red",
		displayError = "talents-node-choiceflyout-square-red",
		locked = "talents-node-choiceflyout-square-locked",
		glow = "talents-node-choiceflyout-square-greenglow",
		ghost = "talents-node-choiceflyout-square-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
	},

	LargeCircle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-choiceflyout-circle-shadow",
		normal = "talents-node-choiceflyout-circle-gray",
		disabled = "talents-node-choiceflyout-circle-gray",
		selectable = "talents-node-choiceflyout-circle-green",
		maxed = "talents-node-choiceflyout-circle-yellow",
		refundInvalid = "talents-node-choiceflyout-circle-red",
		displayError = "talents-node-choiceflyout-circle-red",
		locked = "talents-node-choiceflyout-circle-locked",
		glow = "talents-node-choiceflyout-circle-greenglow",
		ghost = "talents-node-choiceflyout-circle-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
	},

	LegionSmallCircle = {
		iconMask = "talents-node-circle-mask",
		shadow = "lemixartifact-node-circle-shadow",
		normal = "lemixartifact-node-stats-disabled",
		disabled = "lemixartifact-node-stats-disabled",
		selectable = "lemixartifact-node-stats-green",
		maxed = "lemixartifact-node-stats-yellow",
		refundInvalid = "talents-node-choiceflyout-circle-red", 
		displayError = "talents-node-choiceflyout-circle-red", 
		locked = "lemixartifact-node-stats-locked",
		glow = "talents-node-circle-greenglow", 
		ghost = "talents-node-circle-ghost", 
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LegionSquare = {
		iconMask = nil,
		shadow = "lemixartifact-node-square-shadow",
		normal = "lemixartifact-node-square-yellow",
		disabled = "lemixartifact-node-square-disabled",
		selectable = "lemixartifact-node-square-green",
		maxed = "lemixartifact-node-square-yellow",
		locked = "lemixartifact-node-square-locked",
		refundInvalid = "talents-node-square-red", 
		displayError = "talents-node-square-red", 
		glow = "talents-node-square-greenglow", 
		ghost = "talents-node-square-ghost", 
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LegionCircle = {
		iconMask = "talents-node-circle-mask", 
		shadow = "lemixartifact-node-circle-shadow",
		normal = "lemixartifact-node-circle-yellow",
		disabled = "lemixartifact-node-circle-disabled",
		selectable = "lemixartifact-node-circle-green",
		maxed = "lemixartifact-node-circle-yellow",
		refundInvalid = "talents-node-circle-red", 
		displayError = "talents-node-circle-red", 
		locked = "lemixartifact-node-circle-locked",
		glow = "talents-node-circle-greenglow", 
		ghost = "lemixartifact-node-circle-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LegionChoice = {
		iconMask = "talents-node-choice-mask",
		shadow = "lemixartifact-node-choice-shadow",
		normal = "lemixartifact-node-choice-yellow",
		disabled = "lemixartifact-node-choice-disabled",
		selectable = "lemixartifact-node-choice-slash-green",
		maxed = "lemixartifact-node-choice-yellow",
		refundInvalid = "talents-node-choice-red", 
		displayError = "talents-node-choice-red", 
		locked = "lemixartifact-node-choice-locked",
		glow = "talents-node-choice-greenglow", 
		ghost = "talents-node-choice-ghost", 
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LegionInfiniteCircle = {
		iconMask = "talents-node-circle-mask", 
		shadow = "lemixartifact-node-circle-shadow",
		normal = "lemixartifact-node-infinite",
		disabled = "lemixartifact-node-infinite-disabled",
		selectable = "lemixartifact-node-infinite", -- Infinite Node always appears yellow
		maxed = "lemixartifact-node-infinite",
		refundInvalid = "talents-node-circle-red", 
		displayError = "talents-node-circle-red", 
		locked = "lemixartifact-node-infinite-disabled",
		glow = "talents-node-circle-greenglow", 
		ghost = "lemixartifact-node-circle-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},
	CapstoneCircle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-circle-shadow",
		normal = "talents-node-apex-large-gray",
		disabled = "talents-node-apex-large-gray",
		selectable = "talents-node-apex-large-green",
		maxed = "talents-node-apex-large-yellow",
		refundInvalid = "talents-node-apex-large-red",
		displayError = "talents-node-apex-large-red",
		locked = "talents-node-apex-large-locked",
		glow = "talents-node-apex-large-glow",
		ghost = "talents-node-choiceflyout-circle-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
		progressBarBase = "talents-node-apex-bar-base",
		progressBarHalf = "talents-node-apex-bar-half",
		progressBarFull = "talents-node-apex-bar-full",
	},

	CapstoneSquare = {
		iconMask = nil,
		shadow = "talents-node-square-shadow",
		normal = "talents-node-apex-active-large-gray",
		disabled = "talents-node-apex-active-large-gray",
		selectable = "talents-node-apex-active-large-green",
		maxed = "talents-node-apex-active-large-yellow",
		refundInvalid = "talents-node-apex-active-large-red",
		displayError = "talents-node-apex-active-large-red",
		locked = "talents-node-apex-active-large-locked",
		glow = "talents-node-apex-active-large-glow",
		ghost = "talents-node-choiceflyout-square-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
		progressBarBase = "talents-node-apex-active-bar-base",
		progressBarHalf = "talents-node-apex-active-bar-half",
		progressBarFull = "talents-node-apex-active-bar-full",
	},

	CapstonePipCircle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-circle-shadow",
		normal = "talents-node-apex-small-gray",
		disabled = "talents-node-apex-small-gray",
		selectable = "talents-node-apex-small-gray",
		maxed = "talents-node-apex-small-gray",
		refundInvalid = "talents-node-apex-small-gray",
		displayError = "talents-node-apex-small-gray",
		locked = "talents-node-apex-small-locked",
		glow = "talents-node-circle-greenglow",
		ghost = "talents-node-circle-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

};

function TalentButtonArtMixin:OnLoad()
	self:ApplySize(self:GetSize());

	if not self.artSet.iconMask then
		self.IconMask:Hide();
		self.DisabledOverlayMask:Hide();
	else
		self.IconMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
		self.DisabledOverlayMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
	end

	self.Glow:SetAtlas(self.artSet.glow, TextureKitConstants.UseAtlasSize);
	self.Ghost:SetAtlas(self.artSet.ghost, TextureKitConstants.UseAtlasSize);
	self.Shadow:SetAtlas(self.artSet.shadow, TextureKitConstants.UseAtlasSize);

	self.SpendText:SetFontObject(self.artSet.spendFont);
	if self.spendTextShadows then
		for _, shadow in ipairs(self.spendTextShadows) do
			shadow:SetFontObject(self.artSet.spendFont);
		end
	end
end

function TalentButtonArtMixin:ApplyVisualState(visualState)
	local color = TalentButtonUtil.GetColorForBaseVisualState(visualState);
	local r, g, b = color:GetRGB();
	MixinUtil.CallMethodSafe(self.SpendText, "SetTextColor", r, g, b);

	local isRefundInvalid = (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	local isDisplayError = (visualState == TalentButtonUtil.BaseVisualState.DisplayError);
	local iconVertexColor = (isRefundInvalid or isDisplayError) and DIM_RED_FONT_COLOR or WHITE_FONT_COLOR;
	self.Icon:SetVertexColor(iconVertexColor:GetRGBA());

	local isGated = (visualState == TalentButtonUtil.BaseVisualState.Gated);
	MixinUtil.CallMethodSafe(self.DisabledOverlay, "SetAlpha", (isGated and 0.7) or (isRefundInvalid and RefundInvalidOverlayAlpha) or 0.25)

	local isLocked = (visualState == TalentButtonUtil.BaseVisualState.Locked);
	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Disabled);
	local isDimmed = isGated or isLocked or isDisabled;
	self.Icon:SetDesaturated(not isRefundInvalid and isDimmed);
	MixinUtil.CallMethodSafe(self.DisabledOverlay, "SetShown", isRefundInvalid or isDimmed);

	if self.SelectableIcon then
		local isSelectable = (visualState == TalentButtonUtil.BaseVisualState.Selectable);
		self.SelectableIcon:SetShown(isSelectable and CVarCallbackRegistry:GetCVarValueBool("colorblindMode"));
	end

	self:UpdateStateBorder(visualState);
end

function TalentButtonArtMixin:UpdateNonStateVisuals()
	self.Ghost:SetShown(self.isGhosted);
	self:UpdateSearchIcon();
	self:UpdateGlow();
end

function TalentButtonArtMixin:UpdateStateBorder(visualState)
	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Gated)
					or (visualState == TalentButtonUtil.BaseVisualState.Locked)
					or (visualState == TalentButtonUtil.BaseVisualState.Disabled);

	local function SetAtlas(atlas)
		self.StateBorder:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

		if self.StateBorderHover then
			self.StateBorderHover:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
			self.StateBorderHover:SetAlpha(TalentButtonUtil.GetHoverAlphaForVisualStyle(visualState));
		end
	end

	if (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid) then
		SetAtlas(self.artSet.refundInvalid);
	elseif (visualState == TalentButtonUtil.BaseVisualState.DisplayError) then
		SetAtlas(self.artSet.displayError);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Gated) then
		SetAtlas(self.artSet.locked);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Selectable) then
		SetAtlas(self.artSet.selectable);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Maxed) then
		SetAtlas(self.artSet.maxed);
	elseif not isDisabled then
		SetAtlas(self.artSet.normal);
	else
		SetAtlas(self.artSet.disabled);
	end
end

function TalentButtonArtMixin:SetAndApplySize(width, height)
	local scalar = self.buttonSizeScaleOverride or 1.0;
	width = width * scalar;
	height = height * scalar;

	self:SetSize(width, height);
	self:ApplySize(width, height);
end

function TalentButtonArtMixin:ApplySize(width, height)
	local sizingAdjustment = self.sizingAdjustment;
	if sizingAdjustment == nil then
		return;
	end

	for _, sizingAdjustmentInfo in ipairs(sizingAdjustment) do
		local region = self[sizingAdjustmentInfo.region];
		if region then
			local sizeAdjustment = sizingAdjustmentInfo.adjust;
			local anchorX = sizingAdjustmentInfo.anchorX;
			local anchorY = sizingAdjustmentInfo.anchorY;

			if sizeAdjustment then
				region:SetSize(width + sizeAdjustment, height + sizeAdjustment);
			end
			if anchorX or anchorY then
				local point, relativeTo, relativePoint, x, y = region:GetPoint();
				region:SetPoint(point, relativeTo, relativePoint, anchorX or x, anchorY or y);
			end

			region:SetScale((sizingAdjustmentInfo.scale or self.scaleOverride) or 1);
		end
	end
end

function TalentButtonArtMixin:GetCircleEdgeDiameterOffset(unused_angle)
	return TalentButtonUtil.CircleEdgeDiameterOffset;
end

function TalentButtonArtMixin:GetSquareEdgeDiameterOffset(angle)
	local quarterRotation = math.pi / 2;
	local eighthRotation = quarterRotation / 2;
	local progress = math.abs(((eighthRotation + angle) % quarterRotation) - eighthRotation);
	return Lerp(TalentButtonUtil.SquareEdgeMinDiameterOffset, TalentButtonUtil.SquareEdgeMaxDiameterOffset, progress);
end

function TalentButtonArtMixin:GetChoiceEdgeDiameterOffset(angle)
	local eighthRotation = math.pi / 4;
	local sixteenthRotation = eighthRotation / 2;
	local progress = math.abs(((sixteenthRotation + angle) % eighthRotation) - sixteenthRotation);
	return Lerp(TalentButtonUtil.ChoiceEdgeMinDiameterOffset, TalentButtonUtil.ChoiceEdgeMaxDiameterOffset, progress);
end

function TalentButtonArtMixin:UpdateSearchIcon()
	if not self.SearchIcon then
		return;
	end

	self.SearchIcon:SetMatchType(self.matchType);
	if self.matchType then
		self.SearchIcon:SetFrameLevel(self:GetFrameLevel() + 50);
	end
end

function TalentButtonArtMixin:UpdateGlow()
	if self.Glow then
		self.Glow:SetShown(self.shouldGlow);
	end
end

function TalentButtonArtMixin:OnEnterVisuals()
	if self.StateBorderHover then
		self.StateBorderHover:Show();
	end
end

function TalentButtonArtMixin:OnLeaveVisuals()
	if self.StateBorderHover then
		self.StateBorderHover:Hide();
	end
end

function TalentButtonArtMixin:UpdateColorBlindVisuals(isColorBlindModeActive)
	local visualState = self:GetVisualState();
	if self.SelectableIcon then
		self.SelectableIcon:SetShown(visualState == TalentButtonUtil.BaseVisualState.Selectable and isColorBlindModeActive);
	end
end

function TalentButtonArtMixin:PlayPurchaseInProgressEffect(fxModelScene, fxIDs)
	self.purchaseInProgressEffects = self:InternalPlayAnimEffects(self.purchaseInProgressEffects, fxModelScene, fxIDs);
end

function TalentButtonArtMixin:StopPurchaseInProgressEffect()
	self:InternalStopAnimEffects(self.purchaseInProgressEffects);
	self.purchaseInProgressEffects = nil;
end

function TalentButtonArtMixin:PlayPurchaseCompleteEffect(fxModelScene, fxIDs)
	self.purchaseCompleteEffects = self:InternalPlayAnimEffects(self.purchaseCompleteEffects, fxModelScene, fxIDs);
end

function TalentButtonArtMixin:StopPurchaseCompleteEffect()
	self:InternalStopAnimEffects(self.purchaseCompleteEffects);
	self.purchaseCompleteEffects = nil;
end

function TalentButtonArtMixin:InternalPlayAnimEffects(animEffectControllers, fxModelScene, fxIDs)
	if animEffectControllers then
		self:InternalStopAnimEffects();
		animEffectControllers = nil;
	end

	if fxIDs and self:ShouldBeVisible() then
		-- If no custom multiplier specified, fall back on the difference between the node and scene's scale,
		-- so if node is in a differently scaled parent the effects will visually scale accordingly
		local scaleMultiplier = self.animEffectScaleMultiplier or (self:GetEffectiveScale() / fxModelScene:GetEffectiveScale());

		animEffectControllers = {};
		for _, fxID in ipairs(fxIDs) do
			table.insert(animEffectControllers, fxModelScene:AddEffect(fxID, self, self, nil, nil, scaleMultiplier));
		end
	end

	return animEffectControllers;
end

function TalentButtonArtMixin:InternalStopAnimEffects(animEffectControllers)
	if not animEffectControllers then
		return;
	end

	for _, fxController in ipairs(animEffectControllers) do
		if fxController and fxController.CancelEffect then
			fxController:CancelEffect();
		end
	end
end

function TalentButtonArtMixin:ResetActiveVisuals()
	self:StopPurchaseInProgressEffect();
	self:StopPurchaseCompleteEffect();
end

-- This Mixin is not used directly here but included for derived mixins to inherit from.
TalentButtonSplitIconMixin = {};

function TalentButtonSplitIconMixin:ApplyVisualState(visualState)
	TalentButtonArtMixin.ApplyVisualState(self, visualState);

	local desaturation = self.Icon:GetDesaturation();
	MixinUtil.CallMethodSafe(self.Icon2, "SetDesaturation", desaturation);
end

function TalentButtonSplitIconMixin:SetSplitIconShown(isSplitShown)
	MixinUtil.CallMethodSafe(self.IconSplitMask, "SetShown", isSplitShown);
	MixinUtil.CallMethodSafe(self.Icon2, "SetShown", isSplitShown);
end
