function ContainerFrame_OnEvent(self, event, ...)
	ContainerFrameBase_OnEvent(self, event, ...);
end

function ContainerFrame_OnLoad(self)
	ContainerFrameBase_OnLoad(self)
end

function ContainerFrame_OnShow(self)
	ContainerFrameBase_OnShow(self);
end

ContainerFrameDerivedMixin = CreateFromMixins(ContainerFrameMixin);
ContainerFrameCombinedBagsDerivedMixin = CreateFromMixins(ContainerFrameCombinedBagsMixin);
ContainerFrameBackpackDerivedMixin = CreateFromMixins(ContainerFrameBackpackMixin);

function GetInitialContainerFrameOffsetX()
	return EditModeUtil:GetRightActionBarWidth() + 10;
end

function UpdateContainerFrameAnchors()
	local containerScale = GetContainerScale();
	local screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	local xOffset = GetInitialContainerFrameOffsetX() / containerScale;
	local yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	local freeScreenHeight = screenHeight - yOffset;
	local previousBag;
	local firstBagInMostRecentColumn;
	for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
		frame:SetScale(containerScale);
		frame:ClearAllPoints();
		if index == 1 then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset);
			firstBagInMostRecentColumn = frame;
		elseif (freeScreenHeight < frame:GetHeight()) or previousBag:IsCombinedBagContainer() then
			-- Start a new column
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", firstBagInMostRecentColumn, "BOTTOMLEFT", -11, 0);
			firstBagInMostRecentColumn = frame;
			else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", previousBag, "TOPRIGHT", 0, CONTAINER_SPACING);
		end

		previousBag = frame;
		freeScreenHeight = freeScreenHeight - frame:GetHeight();
	end
end

ContainerFrameItemButtonDerivedMixin = CreateFromMixins(ContainerFrameItemButtonMixin);
function ContainerFrameItemButtonDerivedMixin:OnDragStop(button) end