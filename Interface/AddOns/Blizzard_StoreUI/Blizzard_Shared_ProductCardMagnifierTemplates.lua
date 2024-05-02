
--------------------------------------------------
-- DEFAULT MAGNIFIER MIXIN
DefaultStoreCardMagnifierMixin = {};
function DefaultStoreCardMagnifierMixin:OnEnter()
	self:GetParent():OnEnter();
end

function DefaultStoreCardMagnifierMixin:OnLeave()
	self:GetParent():OnLeave();
end

function DefaultStoreCardMagnifierMixin:OnClick()
	local card = self:GetParent();
	local entryID = card:GetID();
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
	StoreFrame_ShowPreviews(entryInfo.sharedData.cards);
end

function DefaultStoreCardMagnifierMixin:OnShow()
	StoreCardDetail_SetLayerAboveModelScene(self);
end


