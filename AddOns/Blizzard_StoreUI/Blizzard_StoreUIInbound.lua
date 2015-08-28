--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
function StoreFrame_SetShown(shown)
	StoreFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function StoreFrame_IsShown()
	return StoreFrame:GetAttribute("isshown");
end

function StoreFrame_EscapePressed()
	StoreFrame:SetAttribute("action", "EscapePressed");
	return StoreFrame:GetAttribute("escaperesult");
end

function StoreFrame_PreviewFrameIsShown(isShown)
	StoreFrame:SetAttribute("previewframeshown", isShown);
end

function StoreFrame_CheckForFree(event)
	StoreFrame:SetAttribute("checkforfree", event);
end

function StoreFrame_SetTokenCategory()
	StoreFrame:SetAttribute("settokencategory");
end

function StoreFrame_SetGamesCategory()
	StoreFrame:SetAttribute("setgamescategory");
end

if (InGlue()) then
	function StoreFrame_GetVASErrorMessage(guid, errorList)
		local data = {};
		data.guid = guid;
		data.errors = errorList;
		data.realmName = GetServerName();
		StoreFrame:SetAttribute("getvaserrormessage", data);
		return StoreFrame:GetAttribute("vaserrormessageresult");
	end
end