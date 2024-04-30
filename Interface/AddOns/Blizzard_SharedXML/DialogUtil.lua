
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);
end
----------------

function ShowAppropriateDialog(popupType, textArg1, textArg2, data, insertedFrame)
	if IsOnGlueScreen() then
		GlueDialog_Show(popupType, textArg1, data);
	else
		StaticPopup_Show(popupType, textArg1, textArg2, data, insertedFrame);
	end
end

function HideAppropriateDialog(popupType)
	if IsOnGlueScreen() then
		GlueDialog_Hide(popupType);
	else
		StaticPopup_Hide(popupType);
	end
end