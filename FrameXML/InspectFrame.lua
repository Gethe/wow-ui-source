
function InspectUnit(unit)
	HideUIPanel(InspectFrame);
	if ( UnitExists(unit) and UnitIsPlayer(unit) ) then
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		ShowUIPanel(InspectFrame);
	end
end

function InspectFrame_OnLoad()
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this.unit = nil;
end

function InspectFrame_OnEvent(event)
	if ( not this:IsVisible() ) then
		return;
	end
	if ( event == "PLAYER_TARGET_CHANGED" or event == "PARTY_MEMBERS_CHANGED" ) then
		InspectUnit(this.unit);
		return;
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == this.unit ) then
			SetPortraitTexture(InspectFramePortrait, arg1);
		end
		return;
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == this.unit ) then
			InspectNameText:SetText(UnitName(arg1));
		end
		return;
	end
end

function InspectFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
	SetPortraitTexture(InspectFramePortrait, this.unit);
	InspectNameText:SetText(UnitName(this.unit));
end

function InspectFrame_OnHide()
	this.unit = nil;
	PlaySound("igCharacterInfoClose");
end

function InspectFrame_OnUpdate()
	if ( not CheckInteractDistance(this.unit, 1) ) then
		HideUIPanel(InspectFrame);
	end
end
