
function GlueMenuFrame_Show()
	GlueMenuFrame:Show();
end
function GlueMenuFrame_Hide()
	GlueMenuFrame:Hide();
end

function GlueMenuFrame_OnShow(self)
	GlueParent_AddModalFrame(self);
end

function GlueMenuFrame_OnHide(self)
	GlueParent_RemoveModalFrame(self);
end