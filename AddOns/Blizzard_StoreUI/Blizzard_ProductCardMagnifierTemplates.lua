--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	Import("C_StoreGlue");
end

setfenv(1, tbl);
--------------------------------------------------

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


