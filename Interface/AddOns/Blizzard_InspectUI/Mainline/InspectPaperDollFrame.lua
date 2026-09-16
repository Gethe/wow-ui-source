InspectPaperDollFrameMixin = {};

function InspectPaperDollFrameMixin:OnLoad()
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("INSPECT_READY");

	self:RegisterForTransitions();
end

function InspectPaperDollFrameMixin:OnEvent(event, unit)
	if (InspectFrame:IsShown()) then
		if ( unit and unit == InspectFrame.unit ) then
			if ( event == "UNIT_MODEL_CHANGED" ) then
				InspectModelFrame:RefreshUnit();
			elseif ( event == "UNIT_LEVEL" ) then
				self:SetLevel();
			end
			return;
		end
		if (event == "INSPECT_READY" and InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
			self:SetLevel();
			self:UpdateButtons();
		end
	end
end

function InspectPaperDollFrameMixin:SetLevel()
	if (not InspectFrame.unit) then
		return;
	end

	local unit, level, effectiveLevel, sex = InspectFrame.unit, UnitLevel(InspectFrame.unit), UnitEffectiveLevel(InspectFrame.unit), UnitSex(InspectFrame.unit);
	local specID = C_SpecializationInfo.GetInspectSpecialization(InspectFrame.unit);

	local classDisplayName, class = UnitClass(InspectFrame.unit);
	local classColorString = RAID_CLASS_COLORS[class].colorStr;
	local specName, _;

	if (specID) then
		_, specName = GetSpecializationInfoByID(specID, sex);
	end

	if ( level == -1 or effectiveLevel == -1 ) then
		level = "??";
	elseif ( effectiveLevel ~= level ) then
		level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level);
	end

	if (specName and specName ~= "" and specName ~= classDisplayName) then
		InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, classColorString, specName, classDisplayName);
	else
		InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, classColorString, classDisplayName);
	end
end

function InspectPaperDollFrameMixin:UpdateButtons()
	for k,slotName in pairs(INSPECTPAPERDOLLFRAME_SLOTS) do
		InspectPaperDollItemSlotButton_Update(_G[slotName]);
	end

	if InspectPaperDollItemsFrame.InspectTalents then 
		InspectPaperDollItemsFrame.InspectTalents:SetEnabled(C_Traits.HasValidInspectData());
	elseif InspectPaperDollFrame.InspectTalents then
		InspectPaperDollFrame.InspectTalents:SetEnabled(C_Traits.HasValidInspectData());
	end
end

local factionLogoTextures = {
	["Alliance"]	= "Interface\\Timer\\Alliance-Logo",
	["Horde"]		= "Interface\\Timer\\Horde-Logo",
	["Neutral"]		= "Interface\\Timer\\Panda-Logo",
};

function InspectPaperDollFrameMixin:OnShow()
	InspectModelFrame:Show();
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	local modelCanDraw = InspectModelFrame:SetUnit(InspectFrame.unit);
	self:SetLevel();
	self:UpdateButtons();

	-- If the paperdoll model is not available to draw (out of range), then draw the faction logo
	if(modelCanDraw ~= true) then
		local factionGroup = UnitFactionGroup(InspectFrame.unit);
		if ( factionGroup ) then
			InspectFaction:SetTexture(factionLogoTextures[factionGroup]);
			InspectFaction:Show();
			InspectModelFrame:Hide();
		else
			InspectFaction:Hide();
		end
	else
		InspectFaction:Hide();
	end

	SetPaperDollBackground(InspectModelFrame, InspectFrame.unit);
	InspectModelFrameBackgroundTopLeft:SetDesaturated(true);
	InspectModelFrameBackgroundTopRight:SetDesaturated(true);
	InspectModelFrameBackgroundBotLeft:SetDesaturated(true);
	InspectModelFrameBackgroundBotRight:SetDesaturated(true);
end

local ROTATION_RAD = 3.14159;
local PER_TICK_ZOOM = 3;

function InspectPaperDollFrameMixin:RotateAndZoomCharacter(inX, inY)
	self.rotationSpeed = inX;
	self.zoomSpeed = inY;

	if inX ~= 0 or inY ~= 0 then
		self.stickUpdateFrame:SetScript("OnUpdate", self.stickUpdateFrame.Update);
	else
		self.stickUpdateFrame:SetScript("OnUpdate", nil);
	end
end

function InspectPaperDollFrameMixin:UpdateForSticks(delta)
	InspectModelFrame:ApplyRotation(InspectModelFrame.rotation + ROTATION_RAD * self.rotationSpeed * delta, false);
	InspectModelFrame:OnMouseWheel(PER_TICK_ZOOM * self.zoomSpeed * delta);
end

function InspectPaperDollFrameMixin:ResetCharacter()
	InspectModelFrame:ResetModel();
end

function InspectPaperDollFrameMixin:FocusGamepad()
	GamepadMode.ActivateBindingGroup(self.paperDollBindings);
	self.frameFooter:ShowAndActivateBindings();
end

function InspectPaperDollFrameMixin:UnfocusGamepad()
	GamepadMode.DeactivateBindingGroup(self.paperDollBindings);
	self.frameFooter:HideAndDeactivateBindings();
end

function InspectPaperDollFrameMixin:SetupGamepad()
	-- Character Viewer Actions
	self.zoomSpeed = 0;
	self.rotationSpeed = 0;

	-- Making separte frame to handle the stick updates as trying to use our update causes doll blanking problems.
	self.stickUpdateFrame = CreateFrame("Frame", nil, self);
	self.stickUpdateFrame.Update = function(_, delta)
		self:UpdateForSticks(delta);
	end

	self.paperDollBindings = GamepadMode.CreateBindingGroup("PaperDollBindings");
	self.paperDollBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.RotateAndZoomCharacter, self));

	local paperDollZoom = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_VERTICAL, nil, FRAME_ACTION_ZOOM);
	local paperDollRotate = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_HORIZONTAL, nil, ACTION_LABEL_ROTATE);
	local paperDollReset = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, GenerateClosure(self.ResetCharacter, self), RESET);

	self.frameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "InspectPaperDollFrameFooter");
	self.frameFooter:AddPromptedBinding(paperDollZoom);
	self.frameFooter:AddPromptedBinding(paperDollRotate);
	self.frameFooter:AddPromptedBinding(paperDollReset);
	self.frameFooter:Finalize();
	self.frameFooter.inputLegend:ClearAllPoints();
	self.frameFooter.inputLegend:SetPoint("TOP", InspectModelFrame, 0, 0);
end

function InspectPaperDollFrameMixin:InitializeGamepad()
	self.InspectTalents:Hide();
end

function InspectPaperDollFrameMixin:UninitializeGamepad()
	self.InspectTalents:Show();
	GamepadMode.DeactivateBindingGroup(self.paperDollBindings);
end

function InspectPaperDollFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function InspectPaperDollItemSlotButton_OnLoad(self)

	if self.BorderFrame then
		local level = self:GetFrameLevel();
		self.BorderFrame:SetFrameLevel(level - 1);
	end

	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	local slotName = self:GetName();
	local id;
	local textureName;
	local checkRelic;
	id, textureName, checkRelic = C_PaperDollInfo.GetInventorySlotInfo(strsub(slotName,8));
	self:SetID(id);
	local texture = _G[slotName.."IconTexture"];
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
end

function InspectPaperDollItemSlotButton_OnEvent(self, event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		local unit = ...;
		if ( unit == InspectFrame.unit ) then
			InspectPaperDollItemSlotButton_Update(self);
		end
		return;
	end
end

function InspectPaperDollItemSlotButton_OnClick(self, button)
	local itemLink = GetInventoryItemLink(InspectFrame.unit, self:GetID());
	if itemLink and IsModifiedClick("EXPANDITEM") then
		local _, _, classID = UnitClass(InspectFrame.unit);
		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) then
			local azeritePowerIDs = C_PaperDollInfo.GetInspectAzeriteItemEmpoweredChoices(InspectFrame.unit, self:GetID());
			OpenAzeriteEmpoweredItemUIFromLink(itemLink, classID, azeritePowerIDs);
			return;
		end
	end

	HandleModifiedItemClick(GetInventoryItemLink(InspectFrame.unit, self:GetID()));
end

function InspectPaperDollItemSlotButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, self:GetID()) ) then
		local text = _G[strupper(strsub(self:GetName(), 8))];
		if ( self.checkRelic and UnitHasRelicSlot(InspectFrame.unit) ) then
			text = _G["RELICSLOT"];
		end
		GameTooltip:SetText(text);
	end
	CursorUpdate(self);
end

function InspectPaperDollItemSlotButton_Update(button)
	local unit = InspectFrame.unit;
	local textureName = GetInventoryItemTexture(unit, button:GetID());
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()));
		button.hasItem = 1;

		local quality = GetInventoryItemQuality(unit, button:GetID());
		SetItemButtonQuality(button, quality, GetInventoryItemID(unit, button:GetID()));

	else
		textureName = button.backgroundTextureName;
		if ( button.checkRelic and UnitHasRelicSlot(unit) ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, 0);
		button.IconBorder:Hide();
		button.hasItem = nil;
	end
	if ( GameTooltip:IsOwned(button) ) then
		GameTooltip:Hide();
	end

	if button.SocketDisplay then
		button.SocketDisplay:SetItem(GetInventoryItemLink(unit, button:GetID()));
	end
end

function InspectPaperDollViewButton_OnLoad(self)
	self:SetWidth(30 + self:GetFontString():GetStringWidth());
end

function InspectPaperDollViewButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	DressUpItemTransmogInfoList(C_TransmogCollection.GetInspectItemTransmogInfoList());
end

InspectPaperDollFrameTalentsButtonMixin = {};

function InspectPaperDollFrameTalentsButtonMixin:OnClick()
	if C_Traits.HasValidInspectData() then
		PlayerSpellsFrame_LoadUI();

		local inspectUnit = InspectFrame.unit;
		PlayerSpellsUtil.OpenToClassTalentsTab(inspectUnit);
	end
end

function InspectPaperDollFrameTalentsButtonMixin:OnEnter()
	local hasValidInspectData = C_Traits.HasValidInspectData();
	self:SetEnabled(hasValidInspectData);
	if not hasValidInspectData then
		GameTooltip:SetOwner(self);
		GameTooltip_AddErrorLine(GameTooltip, UNAVAILABLE);
		GameTooltip:Show();
	end
end

function InspectPaperDollFrameTalentsButtonMixin:OnLeave()
	GameTooltip_Hide();
end

LevelTextMixin = {}

function LevelTextMixin:OnEnter()
	if ( InspectLevelText:IsTruncated() ) then
		GameTooltip:SetOwner(InspectLevelText, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, InspectLevelText:GetText(), false);
		GameTooltip:Show();
	end
end

function LevelTextMixin:OnLeave()
	GameTooltip:Hide();
end
