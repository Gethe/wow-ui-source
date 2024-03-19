local itemSlotButtons = {};
local SPECTATE_AURA = 362731
local PAPERDOLL_FRAME_EVENTS = {
	"PLAYER_LOGIN",
	"PLAYER_EQUIPED_SPELLS_CHANGED",
	"CURSOR_CHANGED",
};

LoadoutFrameMixin = {};
function LoadoutFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
	-- flyout settings
	PaperDollItemsFrame.flyoutSettings = {
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		parent = PaperDollFrame,
		anchorX = 0,
		anchorY = -3,
		verticalAnchorX = 0,
		verticalAnchorY = 0,
	};

	-- trial edition
	local width = CharacterTrialLevelErrorText:GetWidth();
	if ( width > 190 ) then
		CharacterTrialLevelErrorText:SetPoint("TOP", CharacterLevelText, "BOTTOM", -((width-190)/2), 2);
	end
	if( GameLimitedMode_IsActive() ) then
		CharacterTrialLevelErrorText:SetText(CAPPED_LEVEL_TRIAL);
	end

	-- Right click to activate spell
	CharacterSpell1Slot:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(1); end end)
	CharacterSpell2Slot:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(2); end end)
	CharacterSpell3Slot:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(3); end end)
	CharacterSpell4Slot:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(4); end end)
	CharacterUtility1:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(5); end end)
	CharacterUtility2:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then ActionButtonDown(6); end end)
end

function LoadoutFrameMixin:OnEvent(event, ...)
	local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or event == "GX_RESTARTED" or
		event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		CharacterModelFrame:SetUnit("player", false);
		return;
	end

	if ( not self:IsVisible() ) then
		return;
	end

	if ( unit == "player" ) then
		if ( event == "UNIT_DAMAGE" or
				event == "UNIT_ATTACK_SPEED" or
				event == "UNIT_RANGEDDAMAGE" or
				event == "UNIT_ATTACK" or
				event == "UNIT_STATS" or
				event == "UNIT_RANGED_ATTACK_POWER" or
				event == "UNIT_SPELL_HASTE" or
				event == "UNIT_MAXHEALTH" or
				event == "UNIT_AURA" or
				event == "UNIT_RESISTANCES") then
			self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
		end
	end

	if ( event == "PLAYER_EQUIPED_SPELLS_CHANGED") then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	end

	if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		local caster = select(5, CombatLogGetCurrentEventInfo())
		local event = select(2, CombatLogGetCurrentEventInfo())
		local spellID = select(12, CombatLogGetCurrentEventInfo())

        if (spellID == SPECTATE_AURA and caster == UnitName("player")) then
			if (event == "SPELL_AURA_APPLIED") then
				self.LoadoutItemsFrame:Hide()
				self.CharacterAttack:Hide()
				SetCVar("nameplateShowFriends", 1) 
			elseif (event == "SPELL_AURA_REMOVED") then
				self.LoadoutItemsFrame:Show()
				self.CharacterAttack:Show()
				C_Commentator.ResetFoVTarget();
				SetCVar("nameplateShowFriends", 0) 
			end
        end
    end
end

LoadoutSlotButtonMixin = {};
function LoadoutSlotButtonMixin:UpdateHotkeyText()
	local text = _G["LOADOUT_" .. strupper(strsub(self:GetName(), 10))];
	local hotkey = GetBindingKey( self.commandName );
	local keyText = GetBindingText(hotkey, 1);
	self.SpellLabel:SetText(text .. " |cFFFFFFFF(" .. keyText .. ")");
end

function LoadoutSlotButtonMixin:UpdateLock()
	SetItemButtonDesaturated(self, IsInventoryItemLocked(self:GetID()));
end

function LoadoutSlotButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	local slotName = self:GetName();
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,10));
	self:SetID(id);
	local texture = _G[slotName.."IconTexture"];
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
	self.UpdateTooltip = LoadoutSlotButton_OnEnter;
	itemSlotButtons[id] = self;
	self.verticalFlyout = VERTICAL_FLYOUTS[id];
	self:GetNormalTexture():Hide();
	self:GetNormalTexture():SetAlpha(0);
	self.IconBorder:SetSize(52,52)

	local popoutButton = self.popoutButton;
	if ( popoutButton ) then
		if ( self.verticalFlyout ) then
			popoutButton:SetHeight(16);
			popoutButton:SetWidth(38);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("TOP", self, "BOTTOM", 0, 4);
		else
			popoutButton:SetHeight(38);
			popoutButton:SetWidth(16);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("LEFT", self, "RIGHT", -8, 0);
		end
	end
	self:UpdateHotkeyText();
	
	self:RegisterEvent("UPDATE_BINDINGS");
end

function LoadoutSlotButtonMixin:OnClick(button)
	if ( IsModifiedClick() ) then
		self:OnModifiedClick(button);
	else
		MerchantFrame_ResetRefundItem();
		if ( button == "LeftButton" ) then
			local type = GetCursorInfo();
			if ( type == "merchant" and MerchantFrame.extendedCost ) then
				MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
			else
				PickupInventoryItem(self:GetID());
				if ( CursorHasItem() ) then
					MerchantFrame_SetRefundItem(self, 1);
				end
			end
		else
			UseInventoryItem(self:GetID());
		end	
	end
end

function LoadoutSlotButtonMixin:Update()
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = _G[self:GetName().."Cooldown"];
	local hasItem = textureName ~= nil;
	if ( hasItem ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID())
		  or GetInventoryItemEquippedUnusable("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		end
		if ( cooldown ) then
			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
			CooldownFrame_Set(cooldown, start, duration, enable);
		end
	else
		local textureName = self.backgroundTextureName;
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, 0);
		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		if ( cooldown ) then
			cooldown:Hide();
		end
	end

	local quality = GetInventoryItemQuality("player", self:GetID());
	if not quality then quality = 1 end
	local suppressOverlays = self.HasPaperDollAzeriteItemOverlay;
	SetItemButtonQuality(self, quality, GetInventoryItemID("player", self:GetID()), suppressOverlays);

	--[[
	if (not PaperDollEquipmentManagerPane:IsShown()) then
		self.ignored = nil;
	end
	--]]

	if self.ignoreTexture then
		self.ignoreTexture:SetShown(self.ignored);
	end

	if self.HasPaperDollAzeriteItemOverlay then
		self:SetAzeriteItem(hasItem and ItemLocation:CreateFromEquipmentSlot(self:GetID()) or nil);
	end

	PaperDollItemSlotButton_UpdateLock(self);
	self:UpdateLock();
end

function LoadoutSlotButtonMixin:OnShow(isBag)
	FrameUtil.RegisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);
	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	self:Update();
end

function LoadoutSlotButtonMixin:OnEvent(event, ...)
	if ( event == "PLAYER_LOGIN" or event == "PLAYER_EQUIPED_SPELLS_CHANGED" ) then
		self:Update();
	elseif ( event == "CURSOR_CHANGED" ) then
		if ( C_PaperDollInfo.CanCursorCanGoInSlot(self:GetID()) ) then
			self:LockHighlight();
		else
			self:UnlockHighlight();
		end
	elseif ( event == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeyText();
	end
end

function LoadoutSlotButtonMixin:OnModifiedClick(button)
	if ( IsModifiedClick("EXPANDITEM") ) then
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID());
		if C_Item.DoesItemExist(itemLocation) then
			if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
				if C_Item.CanViewItemPowers(itemLocation) then 
					OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation);
				else 
					UIErrorsFrame:AddExternalErrorMessage(AZERITE_PREVIEW_UNAVAILABLE_FOR_CLASS);
				end
				return;
			end

			local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
			if heartItemLocation and heartItemLocation:IsEqualTo(itemLocation) then
				OpenAzeriteEssenceUIFromItemLocation(itemLocation);
				return;
			end

			SocketInventoryItem(self:GetID());
		end
		return;
	end
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID())) ) then
		return;
	end
end

function LoadoutSlotButtonMixin:OnEnter()
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	--EquipmentFlyout_UpdateFlyout(self);
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true);
	if ( not hasItem ) then
		local text = _G["LOADOUT_" .. strupper(strsub(self:GetName(), 10))];
		print()
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			text = RELICSLOT;
		end
		GameTooltip:SetText(text);
		GameTooltip:Show(text);
	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	else
		CursorUpdate(self);
	end
end

function LoadoutSlotButtonMixin:OnLeave()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
	ResetCursor();
end

function LoadoutSlotButtonMixin:OnDragStart()
	self:OnClick("LeftButton");
end

function LoadoutSlotButtonMixin:OnReceiveDrag()
	self:OnClick("LeftButton");
end


CharacterAttackMixin = {};
function CharacterAttackMixin:OnLoad()
	self:RegisterEvent("UPDATE_BINDINGS");
	self:UpdateHotkeyText();
end

function CharacterAttackMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeyText();
	end
end