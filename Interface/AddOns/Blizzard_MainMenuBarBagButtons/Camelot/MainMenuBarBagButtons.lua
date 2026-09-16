function BaseBagSlotButtonMixin:GetSlotAtlases()
	return "ui-hud-actionbar-iconframe-bags", "ui-hud-actionbar-iconframe-bags", "ui-hud-actionbar-iconframe-bags"; 
end

function CharacterReagentBagMixin:GetSlotAtlases()
	return "UI-HUD-ActionBar-IconFrame", "UI-HUD-ActionBar-IconFrame", "UI-HUD-ActionBar-IconFrame";
end

function BaseBagSlotButtonMixin:UpdateTextures()
	local size = ContainerFrame_GetContainerNumSlots(self:GetBagID());
	local bagSlotAtlas, bagSlotEmptyAtlas, bagSlotHighlight = self:GetSlotAtlases();
	local atlas = (size and size > 0) and bagSlotAtlas or bagSlotEmptyAtlas;
	local textureWidth = self.normalAndPushedTextureWidth or 46;
	local textureHeight = self.normalAndPushedTextureHeight or 46;

	if (self.bagIcon) then
		self.icon:SetTexture(self.bagIcon);
		self.icon:Show();
	elseif (self.bagAtlas) then
		self.icon:SetAtlas(self.bagAtlas);
		self.icon:Show();
	end

	local normalTexture = self:GetNormalTexture();
	normalTexture:SetPoint("TOPLEFT", self, "TOPLEFT");
	normalTexture:SetSize(textureWidth, textureHeight);
	normalTexture:SetAtlas(atlas);

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:SetPoint("TOPLEFT", self, "TOPLEFT");
	pushedTexture:SetSize(textureWidth, textureHeight);
	pushedTexture:SetAtlas(atlas);

	local highlight = self:GetHighlightTexture();
	highlight:SetAllPoints(self);
	highlight:SetBlendMode("ADD");
	highlight:SetAlpha(.4);
	highlight:SetAtlas(bagSlotHighlight);

	self.SlotHighlightTexture:SetAtlas(bagSlotHighlight);
end

function PutKeyInKeyRing()
	local texture;
	local emptyKeyRingSlot;
	for i=1, GetKeyRingSize() do
		texture = C_Container.GetContainerItemInfo(KEYRING_CONTAINER, i);
		if ( not texture ) then
			emptyKeyRingSlot = i;
			break;
		end
	end
	if ( emptyKeyRingSlot ) then
		C_Container.PickupContainerItem(KEYRING_CONTAINER, emptyKeyRingSlot);
	else
		UIErrorsFrame:AddMessage(NO_EMPTY_KEYRING_SLOTS, 1.0, 0.1, 0.1, 1.0);
	end
end

function GetKeyRingSize()
	local numKeyringSlots = C_Container.GetContainerNumSlots(KEYRING_CONTAINER);
	local maxSlotNumberFilled = 0;
	local numItems = 0;
	for i=1, numKeyringSlots do
		local texture = C_Container.GetContainerItemInfo(KEYRING_CONTAINER, i);
		-- Update max slot
		if ( texture and i > maxSlotNumberFilled) then
			maxSlotNumberFilled = i;
		end
		-- Count how many items you have
		if ( texture ) then
			numItems = numItems + 1;
		end
	end

	-- Round to the nearest 4 rows that will hold the keys
	local modulo = maxSlotNumberFilled % 4;
	local size;
	if ( (modulo == 0) and (numItems < maxSlotNumberFilled) ) then
		size = maxSlotNumberFilled;
	else
		-- Only expand if the number of keys in the keyring exceed or equal the max slot filled
		size = maxSlotNumberFilled + (4 - modulo);
	end	
	size = min(size, numKeyringSlots);

	return size;
end

KeyRingMixin = {};

function KeyRingMixin:BagSlotOnShow()
	-- Only here to prevent base object behavior
end

function KeyRingMixin:BagSlotOnHide()
	-- Only here to prevent base object behavior
end

function KeyRingMixin:SetBarExpanded(isExpanded)
	-- Remains shown regardless of expand state
end

function KeyRingMixin:BagSlotOnDragStart(button)
	-- prevent pick up
end

function KeyRingMixin:OnLoadInternal()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	if(not C_ActionBar.ShouldShowKeyring()) then
		KeyRingButton:Hide();
		KeyRingButton:Disable();
	end

	self:UpdateTextures();
	self.Count:ClearAllPoints();
	self.Count:SetPoint("CENTER", 0, -10);

	self:SetID(KEYRING_CONTAINER);
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.initialWidth = self:GetWidth();
	self.initialHeight = self:GetHeight();
end

function KeyRingMixin:TriggerTutorial()
	if(HasKey()) then
		if(not GetCVarBool("showKeyring")) then
			-- Show Tutorial and flash keyring
			TriggerTutorial(50); --TUTORIAL_KEYRING
			SetButtonPulse(self, 60, 1);
			SetCVar("showKeyring", 1);
		end
	end
end

function KeyRingMixin:OnBagUpdate()
	if (C_ActionBar.ShouldShowKeyring()) then
		if(GetCVarBool("showKeyring")) then
			self.bagAtlas = "UI-HUD-ActionBar-Keyring-Small";
		else
			self.bagAtlas = "UI-HUD-ActionBar-IconFrame-Slot-Small";
		end
		self:UpdateTextures();
	end
end

function KeyRingMixin:BagSlotOnEvent(event, ...)
	if event == "ITEM_PUSH" then
		local bagSlot, iconFileID = ...;
		if self:GetID() == bagSlot then
			self.AnimIcon:SetTexture(iconFileID);
			self.FlyIn:Play(true);
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateBagMatchesSearch();
		self:TriggerTutorial();
		self:OnBagUpdate();
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:UpdateBagMatchesSearch();
	elseif event == "BAG_UPDATE" then
		local bag = ...;
		self:TriggerTutorial();
		self:OnBagUpdate();
	end
end

function KeyRingMixin:BagSlotOnClick()
	if (CursorHasItem()) then
		PutKeyInKeyRing();
	else
		ToggleBag(KEYRING_CONTAINER);
	end
end

function KeyRingMixin:BagSlotOnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(KEYRING, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine();
end

function KeyRingMixin:BagSlotOnLeave()
	GameTooltip:Hide();
end

function KeyRingMixin:BagSlotOnReceiveDrag()
	if (CursorHasItem()) then
		PutKeyInKeyRing();
	end
end

function KeyRingMixin:UpdateOrientation(isHorizontal)
	if isHorizontal then
		self:SetSize(self.initialWidth, self.initialHeight);
		self:GetNormalTexture():SetRotation(0);
		self:GetHighlightTexture():SetRotation(0);
		self:GetPushedTexture():SetRotation(0);
	else
		-- Swap width/height for vertical bags bar since the bar is horizontal by default
		self:SetSize(self.initialHeight, self.initialWidth);
		self:GetNormalTexture():SetRotation(math.pi/2);
		self:GetHighlightTexture():SetRotation(math.pi/2);
		self:GetPushedTexture():SetRotation(math.pi/2);
	end
end

function KeyRingMixin:GetSlotAtlases()
	return "UI-HUD-ActionBar-IconFrame-Small", "UI-HUD-ActionBar-IconFrame-Small", "UI-HUD-ActionBar-IconFrame-Small";
end
