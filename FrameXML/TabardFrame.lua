
function TabardFrame_OnLoad()
	this:RegisterEvent("OPEN_TABARD_FRAME");
	this:RegisterEvent("CLOSE_TABARD_FRAME");
	this:RegisterEvent("TABARD_CANSAVE_CHANGED");
	TabardFrameCostFrame:SetBackdropBorderColor(0.4, 0.4, 0.4);
	TabardFrameCostFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	MoneyFrame_Update("TabardFrameCostMoneyFrame",GetTabardCreationCost());

	local backgroundAlpha = 0.40;
	TabardFrameEmblemTopRight:SetAlpha(backgroundAlpha);
	TabardFrameEmblemTopLeft:SetAlpha(backgroundAlpha);
	TabardFrameEmblemBottomRight:SetAlpha(backgroundAlpha);
	TabardFrameEmblemBottomLeft:SetAlpha(backgroundAlpha);
end

function TabardCharacterModelFrame_OnLoad()
	this.rotation = 0;
	TabardModel:SetRotation(this.rotation);
end

function TabardFrame_OnEvent(event, unit)
	if ( event == "OPEN_TABARD_FRAME" ) then
		TabardModel:SetUnit("player");
		SetPortraitTexture(TabardFramePortrait,"npc");
		TabardFrameNameText:SetText(UnitName("npc"));
		TabardModel:InitializeTabardColors();
		TabardFrame_Update();
		ShowUIPanel(TabardFrame);
		if ( not TabardFrame:IsVisible() ) then
			CloseTabardCreation();
		end
	elseif ( event == "CLOSE_TABARD_FRAME" ) then
		HideUIPanel(TabardFrame);
	elseif ( event == "TABARD_CANSAVE_CHANGED" ) then
		TabardFrame_Update();
	end
end

function TabardCharacterModelRotateLeftButton_OnClick()
	TabardModel.rotation = TabardModel.rotation - .03;
	TabardModel:SetRotation(TabardModel.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function TabardCharacterModelRotateRightButton_OnClick()
	TabardModel.rotation = TabardModel.rotation + .03;
	TabardModel:SetRotation(TabardModel.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function TabardCharacterModelFrame_OnUpdate(elapsedTime)
	if ( TabardCharacterModelRotateRightButton:GetButtonState() == "PUSHED" ) then
		this.rotation = this.rotation + (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND);
		if ( this.rotation < 0 ) then
			this.rotation = this.rotation + (2 * PI);
		end
		this:SetRotation(this.rotation);
	end
	if ( TabardCharacterModelRotateLeftButton:GetButtonState() == "PUSHED" ) then
		this.rotation = this.rotation - (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND);
		if ( this.rotation > (2 * PI) ) then
			this.rotation = this.rotation - (2 * PI);
		end
		this:SetRotation(this.rotation);
	end
end

function TabardCustomization_Left(id)
	PlaySound("gsCharacterCreationLook");
	TabardModel:CycleVariation(id,-1);
	TabardFrame_Update();
end

function TabardCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	TabardModel:CycleVariation(id,1);
	TabardFrame_Update();
end

function TabardFrame_Update()
	TabardModel:GetUpperEmblemTexture("TabardFrameEmblemTopLeft");
	TabardModel:GetUpperEmblemTexture("TabardFrameEmblemTopRight");
	TabardModel:GetLowerEmblemTexture("TabardFrameEmblemBottomLeft");
	TabardModel:GetLowerEmblemTexture("TabardFrameEmblemBottomRight");

	if ( TabardModel:CanSave() ) then
		TabardFrameGreetingText:SetText(TABARDVENDORGREETING);
		TabardFrameAcceptButton:Enable();
	else
		if ( IsGuildLeader() ) then
			TabardFrameGreetingText:SetText(TABARDVENDORALREADYSETGREETING);
		else
			TabardFrameGreetingText:SetText(TABARDVENDORNOGUILDGREETING);
		end
		TabardFrameAcceptButton:Disable();
	end
end