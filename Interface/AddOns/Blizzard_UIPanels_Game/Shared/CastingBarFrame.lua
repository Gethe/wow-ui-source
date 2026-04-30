
PlayerCastingBarMixin = {};

function PlayerCastingBarMixin:OnLoad()
	local showTradeSkills = true;
	local showShieldNo = false;
	CastingBarMixin.OnLoad(self, "player", showTradeSkills, showShieldNo);
	self.Icon:Hide();
end

function PlayerCastingBarMixin:OnShow()
	CastingBarMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self); 
end

function PlayerCastingBarMixin:IsAttachedToPlayerFrame()
	return self.attachedToPlayerFrame;
end

-- Alternate Player Casting Bar for use over frames whose content triggers contextual player casts
OverlayPlayerCastingBarMixin = {};

function OverlayPlayerCastingBarMixin:OnLoad()
	local showTradeSkills = true;
	local showShieldNo = false;
	CastingBarMixin.OnLoad(self, "player", showTradeSkills, showShieldNo);
	self.Icon:Hide();
	self.showCastbar = false;
end

--[[
--	Call to use this casting bar over the specified frame INSTEAD of showing the default PlayerCastingBar.
--	Will display any currently active Player cast, and any future Player casts until EndReplacingPlayerBar is called.
--
--	overrideInfo:
--		overrideBarType = [CastingBarType] -- Use a specific bar type rather than have it determined by the type of spell being cast, defines textures used (Default: nil)
--		overrideLook 	= ["CLASSIC", "UNIT", "OVERLAY"] -- Use a specific bar look, defines component sizing and anchoring (Default: "OVERLAY")
--		overrideAnchor 	= [AnchorUtilAnchorInstance] -- Specify a point to anchor the cast bar to, should be created via CreateAnchor (Default: Center of parentFrame)
--		overrideStrata	= [FRAMESTRATA] -- Specify a frame strata to set to (Default: "HIGH")
--		hideBarText		= [BOOLEAN] -- Disable showing text on the cast bar (Default: false)
--]]
function OverlayPlayerCastingBarMixin:StartReplacingPlayerBarAt(parentFrame, overrideInfo)
	-- Disable real Player Cast Bar
	PlayerCastingBarFrame:SetAndUpdateShowCastbar(false);

	overrideInfo = overrideInfo or {};
	self.overrideBarType = overrideInfo.overrideBarType;

	self:SetParent(parentFrame);
	self:SetFrameStrata(overrideInfo.overrideStrata or "HIGH");
	self:SetFrameLevel(parentFrame:GetFrameLevel() + 10);
	self:ClearAllPoints();

	if overrideInfo.overrideAnchor then
		overrideInfo.overrideAnchor:SetPoint(self);
	else
		self:SetPoint("CENTER", parentFrame);
	end

	-- Run through override look adjusting sizing and shown components
	local overrideLook = overrideInfo.overrideLook or "OVERLAY";
	self:SetLook(overrideLook);

	-- Hide text components if needed, avoid using Show/SetShown and overriding SetLook having already hidden either
	if overrideInfo.hideBarText then
		self.Text:Hide();
		self.TextBorder:Hide();
	end

	-- SetAndUpdateShowCastbar will show self on next Player Cast OR now if a Player Cast is active
	self:SetAndUpdateShowCastbar(true);
end

--[[
--	Call to resume using only the default PlayerCastingBar.
--	PlayerCastingBar will immediately pick up displaying any already-active Player casts.
--]]
function OverlayPlayerCastingBarMixin:EndReplacingPlayerBar()
	-- Hide self
	self:SetAndUpdateShowCastbar(false);
	self:SetParent(UIParent);
	self.overrideBarType = nil;

	-- Re-enable real Player Cast Bar
	PlayerCastingBarFrame:SetAndUpdateShowCastbar(true);
end

-- Override template mixin for overriden bar type
function OverlayPlayerCastingBarMixin:GetEffectiveType(isChannel, notInterruptible, isTradeSkill, isEmpowered)
	return self.overrideBarType or CastingBarMixin.GetEffectiveType(self, isChannel, notInterruptible, isTradeSkill, isEmpowered);
end

function OverlayPlayerCastingBarMixin:OnShow()
	CastingBarMixin.OnShow(self);
	EventRegistry:TriggerEvent("OverlayPlayerCastBar.OnShow");
end

function OverlayPlayerCastingBarMixin:OnHide()
	CastingBarMixin.OnHide(self);
	EventRegistry:TriggerEvent("OverlayPlayerCastBar.OnHide");
end
