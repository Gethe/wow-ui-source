RPETutorialInterruptMixin = CreateFromMixins(UIFrameManager_ManagedFrameMixin);

function RPETutorialInterruptMixin:OnLoad()
	UIFrameManager_ManagedFrameMixin.OnLoad(self);
	TutorialMainFrameMixin.OnLoad(self);
end

function RPETutorialInterruptMixin:OnShow()
	local text = self.ContainerFrame.Text;
	-- This will do first time setup, plus handles a bug if the UI is reloaded while the tutorial is up.
	-- Doesn't fix the bug but subsequent shows will display correctly.
	if not ApproximatelyEqual(text:GetStringHeight(), text:GetHeight()) then
		self.ContainerFrame.Icon:Hide();
		text:ClearAllPoints();
		text:SetPoint("CENTER");
		text:SetSize(0, 0);
		local atlasMarkup = CreateAtlasMarkup("ui-castingbar-uninterruptable-full", 138, 17, 0, -13);	-- 30% atlas size
		text:SetText(RPE_SPELL_INTERRUPT.."|n"..atlasMarkup);
		text:SetWidth(text:GetStringWidth());
		text:SetHeight(text:GetStringHeight());
		self.ContainerFrame:MarkDirty();
	end
end
