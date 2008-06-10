
INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectHonorFrame" };

UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0 };

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if ( CanInspect(unit) ) then
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

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 2);
	PanelTemplates_SetTab(this, 1);
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

	-- Clear the player being inspected
	ClearInspectPlayer();
end

function InspectFrame_OnUpdate()
	if ( not UnitExists("target") ) then
		HideUIPanel(InspectFrame);
	end
end

function ToggleInspect(tab)
	local subFrame = getglobal(tab);
	if ( subFrame ) then
		PanelTemplates_SetTab(InspectFrame, subFrame:GetID());
		if ( InspectFrame:IsVisible() ) then
			if ( subFrame:IsVisible() ) then
				HideUIPanel(InspectFrame);	
			else
				PlaySound("igCharacterInfoTab");
				InspectFrame_ShowSubFrame(tab);
			end
		else
			ShowUIPanel(InspectFrame);
			InspectFrame_ShowSubFrame(tab);
		end
	end
end

function InspectFrame_ShowSubFrame(frameName)
	for index, value in INSPECTFRAME_SUBFRAMES do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();	
		end	
	end 
end

function InspectFrameTab_OnClick()
	if ( this:GetName() == "InspectFrameTab1" ) then
		ToggleInspect("InspectPaperDollFrame");
	elseif ( this:GetName() == "InspectFrameTab2" ) then
		ToggleInspect("InspectHonorFrame");
	end
	PlaySound("igCharacterInfoTab");
end