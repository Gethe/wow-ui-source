
PlayerFrameBottomManagedFramesContainerMixin = {};

function PlayerFrameBottomManagedFramesContainerMixin:Layout()
	LayoutMixin.Layout(self);
	PlayerFrame_AdjustAttachments();
end

--
-- Functions for having the cast bar underneath the player frame.
--

local function AnchorCastBarToPlayerFrame()
	local playerFrameScale = PlayerFrame:GetScale();
	local castBarScale = PlayerCastingBarFrame:GetScale();

	local xOffset = -24 / castBarScale;
	local yOffset = 12 * playerFrameScale;
	if PlayerFrameBottomManagedFramesContainer:IsShown() then
		yOffset = yOffset - (PlayerFrameBottomManagedFramesContainer:GetHeight() * playerFrameScale);
	end
	yOffset = yOffset / castBarScale / playerFrameScale;

	PlayerCastingBarFrame:ClearAllPoints();
	PlayerCastingBarFrame:SetPoint("TOPRIGHT", PlayerFrame, "BOTTOMRIGHT", xOffset, yOffset);
end

function PlayerFrame_AttachCastBar()
	-- pet
	PetCastingBarFrame:SetLook("UNITFRAME");
	PetCastingBarFrame:SetWidth(150);
	PetCastingBarFrame:SetHeight(10);

	-- player
	PlayerCastingBarFrame.ignoreFramePositionManager = true;
	UIParentBottomManagedFrameContainer:RemoveManagedFrame(PlayerCastingBarFrame);
	PlayerCastingBarFrame.attachedToPlayerFrame = true;
	PlayerCastingBarFrame:SetLook("UNITFRAME");
	PlayerCastingBarFrame:SetFixedFrameStrata(false); -- Inherit parent strata while locked
	PlayerCastingBarFrame:SetParent(PlayerFrame);
	AnchorCastBarToPlayerFrame();
end

function PlayerFrame_DetachCastBar()
	-- pet
	PetCastingBarFrame:SetLook("CLASSIC");
	PetCastingBarFrame:SetWidth(195);
	PetCastingBarFrame:SetHeight(13);

	-- player
	PlayerCastingBarFrame.ignoreFramePositionManager = nil;
	PlayerCastingBarFrame.attachedToPlayerFrame = false;
	PlayerCastingBarFrame:SetLook("CLASSIC");
	PlayerCastingBarFrame:SetFrameStrata("HIGH"); -- Maintain HIGH strata while unlocked
	PlayerCastingBarFrame:SetFixedFrameStrata(true);
	-- Will be re-anchored via edit mode
end

function PlayerFrame_AdjustAttachments()
	if (PlayerCastingBarFrame.attachedToPlayerFrame) then
		AnchorCastBarToPlayerFrame();
	end
end
