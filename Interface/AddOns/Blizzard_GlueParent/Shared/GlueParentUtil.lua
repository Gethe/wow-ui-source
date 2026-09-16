local modalFrames = { };

function GlueParent_AddModalFrame(frame)
	local index = tIndexOf(modalFrames, frame);
	if index then
		return;
	end

	table.insert(modalFrames, frame);

	if #modalFrames == 1 then
		GlueParent.BlockingFrame:Show();
	end
end

function GlueParent_RemoveModalFrame(frame)
	local index = tIndexOf(modalFrames, frame);
	if not index then
		return;
	end

	table.remove(modalFrames, index);

	if #modalFrames == 0 then
		GlueParent.BlockingFrame:Hide();
	end
end

function GlueParentBlockingFrame_OnKeyDown(self, key)
	if key == "ESCAPE" then
		local frame = modalFrames[#modalFrames];
		if not frame.disableHideOnEscape then
			local continueHide = true;
			if frame.onCloseCallback then
				continueHide = frame.onCloseCallback(self);
			end
			if continueHide then
				frame:Hide();
			end
		end
	elseif key == "PRINTSCREEN" then
		Screenshot();
	end
end

function GlueParent_CheckPhotosensitivity()
	local lastPhotosensitivityExpansionShown = (tonumber(GetCVar("showPhotosensitivityWarning")) or -1);
	if LE_EXPANSION_LEVEL_CURRENT > lastPhotosensitivityExpansionShown then
		SetCVar("showPhotosensitivityWarning", LE_EXPANSION_LEVEL_CURRENT);
		GlueParent_OpenSecondaryScreen("photosensitivity");
		
		return true;
	end

	return false;
end

function GlueParent_CheckScreenNarrator()
	if not GetCVarBool("showScreenNarrationDialog") then
		return false;
	end

	-- Always set the var to false even if the below check prevents the popup from showing.
	SetCVar("showScreenNarrationDialog", false);

	-- If screen narration has already been disabled don't display the popup. This can only happen
	-- if the default value is conditionally changed for different versions or builds.
	if not CVarCallbackRegistry:GetCVarValueBool("accessibilityScreenNarrationEnabled") then
		return false;
	end

	StaticPopup_Show("SCREEN_NARRATOR_CHOICE");
	return true;
end

function GetLogoReleaseType()
	if(GetCNLogoReleaseType) then
		return GetCNLogoReleaseType();
	end

	return GetGameReleaseType();
end

function GetDisplayedExpansionLogo(expansionLevel, releaseType)
	releaseType = releaseType or GetLogoReleaseType();

	local isTrial = expansionLevel == nil;

	if isTrial then
		return [[Interface\Glues\Common\Glues-WoW-FreeTrial]];
	elseif expansionLevel <= GetMinimumExpansionLevel() then
		local expansionInfo = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC, releaseType);
		if expansionInfo then
			return expansionInfo.logo;
		end
	else
		local expansionInfo = GetExpansionDisplayInfo(expansionLevel, releaseType);
		if expansionInfo then
			return expansionInfo.logo;
		end
	end

	return nil;
end

function SetExpansionLogo(texture, expansionLevel, releaseType)
	releaseType = releaseType or GetLogoReleaseType();

	local logo = GetDisplayedExpansionLogo(expansionLevel, releaseType);
	if logo then
		texture:SetTexture(logo);
		texture:Show();
	else
		texture:Hide();
	end
end
