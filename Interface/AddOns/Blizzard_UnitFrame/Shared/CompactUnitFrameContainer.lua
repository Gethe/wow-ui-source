
--	Minimum Setup:
--		1. Create an XML template inheriting CompactUnitFrameContainerTemplate.
--		2. Create a mixin derived from CompactUnitFrameContainerMixin and override GetUnitToken.
--		3. Register the events that should trigger a refresh (i.e in OnLoad).
--
--	(Optional) Custom Layout:
--		CompactUnitFrameContainerTemplate inherits GridLayoutFrame, so child frames are
--		arranged automatically. Control the grid via XML KeyValues (see LayoutFrame.xml)
--
--	(Optional) CompactUnitFrame Config (CompactUnitFrameUtil.GenerateNewConfig):
--		Override GetConfig() to return a config table from CompactUnitFrameUtil.GenerateNewConfig.
--
--	(Optional) Other Method Overrides:
--		GetMaxMembers()				- Number of member slots to iterate (DEFAULT_MAX_CONTAINER_MEMBERS is 5).
--										checks UnitExists for the token returned by GetUnitToken(index).
--		OnUnitFrameCreated(frame)	- Called once per frame the first time it is acquired from the pool.
--										Use for one-time setup like attaching a cast bar.
-- 		Check below for other new methods.

local DEFAULT_MAX_CONTAINER_MEMBERS = 5;

CompactUnitFrameContainerMixin = {};

function CompactUnitFrameContainerMixin:OnLoad()
	self.unitFramePool = CreateFramePool("BUTTON", self, "ContainedCompactUnitFrameTemplate");
end

function CompactUnitFrameContainerMixin:OnShow()
	-- Overriding this explicitly so that the base function is more visible.
	BaseLayoutMixin.OnShow(self);
end

function CompactUnitFrameContainerMixin:OnEvent(_event)
	self:RefreshMembers();
end

function CompactUnitFrameContainerMixin:ShouldMemberShow(index)
	-- TODO:: Edit mode functionality.
	local unitToken = self:GetUnitToken(index);
	return unitToken and UnitExists(unitToken);
end

function CompactUnitFrameContainerMixin:RefreshMembers()
	self.unitFramePool:ReleaseAll();

	for i = 1, self:GetMaxMembers() do
		if self:ShouldMemberShow(i) then
			local unitFrame, isNewFrame = self.unitFramePool:Acquire();

			if isNewFrame then
				self:OnUnitFrameCreated(unitFrame);
			end

			unitFrame.layoutIndex = i;
			unitFrame:Show();

			local unitToken = self:GetUnitToken(i);
			CompactUnitFrame_SetUnit(unitFrame, unitToken);

			local compactUnitFrameConfig = self:GetConfig();
			CompactUnitFrame_SetUpFrame(unitFrame, CompactUnitFrameUtil.ApplyConfig, compactUnitFrameConfig);
		end
	end

	self:MarkDirty();
	self:UpdateVisibility();
end

function CompactUnitFrameContainerMixin:ShouldShow()
	for i = 1, self:GetMaxMembers() do
		if self:ShouldMemberShow(i) then
			return true;
		end
	end

	return false;
end

function CompactUnitFrameContainerMixin:GetNumActive()
	return self.unitFramePool:GetNumActive();
end

function CompactUnitFrameContainerMixin:UpdateVisibility()
	-- TODO:: Edit mode functionality.
	self:SetShown(self:ShouldShow());
end

function CompactUnitFrameContainerMixin:GetUnitToken(_index)
	-- Override in your derived Mixin. This is required.
	assertsafe(false);
	return nil;
end

function CompactUnitFrameContainerMixin:OnUnitFrameCreated(_unitFrame)
	-- Override in your derived Mixin. This lets you do one-time set up like adding a cast bar.
end

function CompactUnitFrameContainerMixin:GetMaxMembers()
	-- Override in your derived Mixin.

	return DEFAULT_MAX_CONTAINER_MEMBERS;
end

function CompactUnitFrameContainerMixin:GetConfig()
	-- Override in your derived Mixin.
	-- The returned config should come from CompactUnitFrameUtil.GenerateNewConfig.

	-- nil is valid. That means use the default.
	return nil;
end
