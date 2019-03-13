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

Import("pairs");
Import("select");

function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

function CreateFromMixins(...)
	return Mixin({}, ...)
end
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
	if #entryInfo.sharedData.cards > 1 then
		StoreFrame_ShowPreviews(entryInfo.sharedData.cards);
	elseif #entryInfo.sharedData.cards > 0 then
		local card = entryInfo.sharedData.cards[1];
		StoreFrame_ShowPreview(card.name, card.creatureDisplayInfoID, card.modelSceneID);
	end
end

function DefaultStoreCardMagnifierMixin:OnShow()
	StoreCardDetail_SetLayerAboveModelScene(self);
end


