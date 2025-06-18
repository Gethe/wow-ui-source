function GlueMenuFrame_OnShow(self)
	GlueParent_AddModalFrame(self);
end

function GlueMenuFrame_OnHide(self)
	GlueParent_RemoveModalFrame(self);
end

function GlueMenuFrameOptionsButton_OnShow(self)
	local version = GetBuildInfo();
	self.New:SetShown(version == "4.4.1" and not C_BattleNet.AreHighResTexturesInstalled());
end