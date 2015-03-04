-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function Social_SetShown(shown)
	SocialPostFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function Social_IsShown()
	return SocialPostFrame:GetAttribute("isshown");
end

function Social_SetText(text)
	SocialPostFrame:SetAttribute("settext", text);
end

function Social_GetText()
	return SocialPostFrame:GetAttribute("gettext");
end

function Social_SetScreenshowView()
	SocialPostFrame:SetAttribute("viewmode", "screenshot");
end

function Social_SetDefaultView()
	SocialPostFrame:SetAttribute("viewmode", "default");
end

function Social_ToggleShow(text)
	if (text == "") then
		Social_SetShown(not Social_IsShown());
	else
		Social_SetShown(true);
	end
	if (Social_IsShown()) then
		Social_SetDefaultView();
		Social_SetText(text);
	end
end

function Social_ShowScreenshot(index)
	SocialPostFrame:SetAttribute("screenshotview", index);
end

function Social_ShowAchievement(achievementID, earned)
	SocialPostFrame:SetAttribute("earned", earned);
	SocialPostFrame:SetAttribute("achievementview", achievementID);
end

function Social_ShowItem(itemID, creationContext, earned)
	SocialPostFrame:SetAttribute("creationcontext", creationContext);
	SocialPostFrame:SetAttribute("earned", earned);
	SocialPostFrame:SetAttribute("itemview", itemID);
end

function Social_InsertLink(link)
	SocialPostFrame:SetAttribute("insertlink", link);
end
