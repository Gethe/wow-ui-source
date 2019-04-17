UIPanelWindows["AzeriteEssenceUI"] = { area = "left", pushable = 1 };

AzeriteEssenceUIMixin  = { };

local ESSENCE_BUTTON_HEIGHT = 41;
local ESSENCE_HEADER_HEIGHT = 21;
local ESSENCE_BUTTON_OFFSET = 1;
local ESSENCE_LIST_PADDING = 3;

local LOCKED_FONT_COLOR = CreateColor(0.5, 0.447, 0.4);

local ITEM_MODEL_SCENE_ID = 256;
local ITEM_MODEL_ID = 1962885;	-- Offhand_1H_HeartofAzeroth_D_01.m2
local EFFECT_MODEL_SCENE_ID = 257;
local EFFECT_MODEL_ID = 1688020;	-- 7DU_ArgusRaid_TitanTrappedSoul01.m2
local LEARN_MODEL_SCENE_ID = 259;
local LEARN_MODEL_ID = 2101299;

function AzeriteEssenceUIMixin:OnLoad()
	self.TopTileStreaks:Hide();
	self:SetupModelScenes();
end

function AzeriteEssenceUIMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self:SetupModelScenes();
	elseif event == "AZERITE_ESSENCE_CHANGED" then
		local essenceID, newRank = ...;	-- Do something with these
		self:RefreshSlots();
		self.ScrollFrame:Update();
		self.ScrollFrame:OnLearnEssence(essenceID);
		AzeriteEssenceLearnAnimFrame:PlayAnim();
	elseif event == "AZERITE_ESSENCE_ACTIVATED" or event == "AZERITE_ESSENCE_ACTIVATION_FAILED" or event == "AZERITE_ESSENCE_UPDATE" then
		self:ClearNewlyActivatedEssence();
		self:RefreshSlots();
		self.ScrollFrame:Update();
	end
end

function AzeriteEssenceUIMixin:OnShow()
	-- portrait and title
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if itemLocation then
		local item = Item:CreateFromItemLocation(itemLocation);
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			self:SetPortraitToAsset(item:GetItemIcon());
			self:SetTitle(item:GetItemName());
		end);
	end

	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("AZERITE_ESSENCE_CHANGED");
	self:RegisterEvent("AZERITE_ESSENCE_ACTIVATED");
	self:RegisterEvent("AZERITE_ESSENCE_ACTIVATION_FAILED");
	self:RegisterEvent("AZERITE_ESSENCE_UPDATE");

	self:Update();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);		-- temp?
end

function AzeriteEssenceUIMixin:OnHide()
	if C_AzeriteEssence:IsAtForge() then
		C_AzeriteEssence:CloseForge();
		CloseAllBags(self);
	end

	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:UnregisterEvent("AZERITE_ESSENCE_CHANGED");
	self:UnregisterEvent("AZERITE_ESSENCE_ACTIVATED");
	self:UnregisterEvent("AZERITE_ESSENCE_ACTIVATION_FAILED");
	self:UnregisterEvent("AZERITE_ESSENCE_UPDATE");

	self:ClearNewlyActivatedEssence();

	-- clean up anims
	self.SlotsFrame.ActivationGlow.Anim:Stop();
	self.SlotsFrame.ActivationGlow:SetAlpha(0);
	AzeriteEssenceLearnAnimFrame:StopAnim();
	
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);	-- temp?
end

function AzeriteEssenceUIMixin:OnMouseUp(mouseButton)
	if mouseButton == "LeftButton" or mouseButton == "RightButton" then
		C_AzeriteEssence.ClearPendingActivationEssence();
	end
end

function AzeriteEssenceUIMixin:TryShow()
	if C_AzeriteEssence.CanOpenUI() then
		ShowUIPanel(AzeriteEssenceUI);
		return true;
	end
	return false;
end

function AzeriteEssenceUIMixin:OnEssenceActivated(slot, essenceID)
	self:SetNewlyActivatedEssence(essenceID, slot);

	self.SlotsFrame.ActivationGlow.Anim:Stop();
	self.SlotsFrame.ActivationGlow.Anim:Play();
	-- temp sounds
	if slot == Enum.AzeriteEssence.MainSlot then
		PlaySound(13827);
	else
		PlaySound(13829);
	end

	self:RefreshSlots();
	C_AzeriteEssence.ClearPendingActivationEssence();
end

function AzeriteEssenceUIMixin:Update()
	self:RefreshSlots();
	self:RefreshPowerLevel();
end

function AzeriteEssenceUIMixin:RefreshPowerLevel()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if azeriteItemLocation then
		local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);
		self.PowerLevelBadgeFrame.Label:SetText(level);
		self.PowerLevelBadgeFrame:Show();
	else
		self.PowerLevelBadgeFrame:Hide();
	end
end

function AzeriteEssenceUIMixin:RefreshSlots()
	for i, slotButton in ipairs(self.SlotsFrame.Slots) do
		slotButton:Refresh();
	end
end

function AzeriteEssenceUIMixin:SetupModelScenes()
	local forceUpdate = true;
	self.ItemModelScene:SetFromModelSceneID(ITEM_MODEL_SCENE_ID, forceUpdate);
	local itemActor = self.ItemModelScene:GetActorByTag("item");
	if itemActor then
		itemActor:SetModelByFileID(ITEM_MODEL_ID);
	end
	--self.EffectModelScene:SetFromModelSceneID(EFFECT_MODEL_SCENE_ID, forceUpdate);
	--local effectActor = self.EffectModelScene:GetActorByTag("effect");
	if effectActor then
		effectActor:SetModelByFileID(EFFECT_MODEL_ID);
	end
end

function AzeriteEssenceUIMixin:SetNewlyActivatedEssence(essenceID, slot)
	self.newlyActivatedEssenceID = essenceID;
	self.newlyActivatedEssenceSlot = slot;
end

function AzeriteEssenceUIMixin:GetNewlyActivatedEssence()
	return self.newlyActivatedEssenceID, self.newlyActivatedEssenceSlot;
end

function AzeriteEssenceUIMixin:HasNewlyActivatedEssence()
	return self.newlyActivatedEssenceID ~= nil;
end

function AzeriteEssenceUIMixin:ClearNewlyActivatedEssence()
	self.newlyActivatedEssenceID = nil;
	self.newlyActivatedEssenceSlot = nil;
end

function AzeriteEssenceUIMixin:GetEffectiveEssence(slot)
	local newlyActivatedEssenceID, newlyActivatedEssenceSlot = self:GetNewlyActivatedEssence();
	if slot == newlyActivatedEssenceSlot then
		return newlyActivatedEssenceID;
	end
	
	local essenceID = C_AzeriteEssence.GetActiveEssence(slot);
	if essenceID == newlyActivatedEssenceID then
		return nil;
	else
		return essenceID;
	end
end

AzeriteEssenceListMixin  = { };

function AzeriteEssenceListMixin:OnLoad()
	self.ScrollBar.doNotHide = true;
	self.update = function() self:Refresh(); end
	self.dynamic = function(...) return self:CalculateScrollOffset(...); end
	HybridScrollFrame_CreateButtons(self, "AzeriteEssenceButtonTemplate", 4, -ESSENCE_LIST_PADDING, "TOPLEFT", "TOPLEFT", 0, -ESSENCE_BUTTON_OFFSET, "TOP", "BOTTOM");
	self.HeaderButton:SetParent(self.ScrollChild);
end

function AzeriteEssenceListMixin:OnShow()
	self:Update();
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("PENDING_AZERITE_ESSENCE_CHANGED");
end

function AzeriteEssenceListMixin:OnHide()
	self:CleanUpLearnEssence();
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:UnregisterEvent("PENDING_AZERITE_ESSENCE_CHANGED");
	C_AzeriteEssence.ClearPendingActivationEssence();
end

function AzeriteEssenceListMixin:OnEvent(event)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(true);
	elseif event == "PENDING_AZERITE_ESSENCE_CHANGED" then
		self:Refresh();
	end
end

function AzeriteEssenceListMixin:Update()
	self:CacheAndSortEssences();
	self:Refresh();
end

function AzeriteEssenceListMixin:SetPendingEssence(essenceID)
	local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
	if essenceInfo and essenceInfo.unlocked and essenceInfo.valid then
		C_AzeriteEssence.SetPendingActivationEssence(essenceID);
	end
end

function AzeriteEssenceListMixin:SetupModelScene(forceUpdate)
	local scene = self.LearnEssenceModelScene;
	if not scene.init or forceUpdate then
		scene.init = true;
		scene:SetFromModelSceneID(LEARN_MODEL_SCENE_ID, forceUpdate);
		local effectActor = scene:GetActorByTag("effect");
		if effectActor then
			effectActor:SetModelByFileID(LEARN_MODEL_ID);
		end
	end
end

local function SortComparison(entry1, entry2)
	if ( entry1.valid ~= entry2.valid ) then
		return entry1.valid;
	end
	if ( entry1.unlocked ~= entry2.unlocked ) then
		return entry1.unlocked;
	end
	if ( entry1.rank ~= entry2.rank ) then
		return entry1.rank > entry2.rank;
	end
	return strcmputf8i(entry1.name, entry2.name) < 0;
end
	
function AzeriteEssenceListMixin:CacheAndSortEssences()
	self.essences = C_AzeriteEssence.GetEssences();
	if not self.essences then
		return;
	end
	
	table.sort(self.essences, SortComparison);

	self.headerIndex = nil;
	for i, essenceInfo in ipairs(self.essences) do
		if not essenceInfo.valid then
			self.headerIndex = i;
			local headerInfo = { name = "Header", isHeader = true };
			tinsert(self.essences, i, headerInfo);
			break;
		end
	end
end

function AzeriteEssenceListMixin:GetNumViewableEssences()
	if not self:ShouldShowInvalidEssences() and self.headerIndex then
		return self.headerIndex;
	else
		return #self:GetCachedEssences();
	end
end

function AzeriteEssenceListMixin:ToggleHeader()
	self.collapsed = not self.collapsed;
	self:Refresh();
end

function AzeriteEssenceListMixin:ForceOpenHeader()
	self.collapsed = false;
end

function AzeriteEssenceListMixin:ShouldShowInvalidEssences()
	return not self.collapsed;
end

function AzeriteEssenceListMixin:HasHeader()
	return self.headerIndex ~= nil;
end

function AzeriteEssenceListMixin:GetHeaderIndex()
	return self.headerIndex;
end

function AzeriteEssenceListMixin:GetCachedEssences()
	return self.essences or {};
end

function AzeriteEssenceListMixin:OnLearnEssence(essenceID)
	if self.learnEssenceButton then
		return;
	end

	-- locate the appropriate button
	local essences = self:GetCachedEssences();
	local headerIndex = self:GetHeaderIndex();
	for index, essenceInfo in ipairs(essences) do
		if essenceInfo.ID == essenceID then
			-- open the header if closed and the essence is invalid
			if headerIndex and index > headerIndex and not self:ShouldShowInvalidEssences() then
				self:ForceOpenHeader();
			end
			-- scroll to the essence
			local getHeightFunc = function(index)
				if index == headerIndex then
					return ESSENCE_HEADER_HEIGHT + ESSENCE_BUTTON_OFFSET;
				else
					return ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET;
				end
			end
			HybridScrollFrame_ScrollToIndex(self, index, getHeightFunc);
			-- find the button
			for i, button in ipairs(self.buttons) do
				if button.essenceID == essenceID then
					self.learnEssenceButton = button;
					break;
				end
			end
			break;
		end
	end

	if self.learnEssenceButton then
		-- disable the scrollbar
		ScrollBar_Disable(self.scrollBar);
		-- set up scene
		local scene = self.LearnEssenceModelScene;
		self:SetupModelScene();
		scene:SetPoint("CENTER", self.learnEssenceButton);
		scene:Show();
		-- play glow
		self.learnEssenceButton.Glow.Anim:Play();
		self.learnEssenceButton.Glow2.Anim:Play();
		self.learnEssenceButton.Glow3.Anim:Play();
		-- timer so the effect only plays once
		C_Timer.After(2.969, function() self:CleanUpLearnEssence(); end);
	end
end

function AzeriteEssenceListMixin:CleanUpLearnEssence()
	if not self.learnEssenceButton then
		return;
	end

	self.learnEssenceButton.Glow.Anim:Stop();
	self.learnEssenceButton.Glow2.Anim:Stop();
	self.learnEssenceButton.Glow3.Anim:Stop();
	self.learnEssenceButton.Glow:SetAlpha(0);
	self.learnEssenceButton.Glow2:SetAlpha(0);
	self.learnEssenceButton.Glow3:SetAlpha(0);
	self.learnEssenceButton = nil;

	self.LearnEssenceModelScene:Hide();
	ScrollBar_Enable(self.scrollBar);
end

function AzeriteEssenceListMixin:CalculateScrollOffset(offset)
	local usedHeight = 0;
	local essences = self:GetCachedEssences();
	for i = 1, self:GetNumViewableEssences() do
		local essence = essences[i];
		local height;
		if essence.isHeader then
			height = ESSENCE_HEADER_HEIGHT + ESSENCE_BUTTON_OFFSET;
		else
			height = ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET;
		end
		if ( usedHeight + height >= offset ) then
			return i - 1, offset - usedHeight;
		else
			usedHeight = usedHeight + height;
		end
	end
	return 0, 0;
end

function AzeriteEssenceListMixin:Refresh()
	local essences = self:GetCachedEssences();
	local numEssences = self:GetNumViewableEssences();

	local activeEssences = { };
	for k, slot in pairs(Enum.AzeriteEssence) do
		local essenceID = self:GetParent():GetEffectiveEssence(slot);
		if essenceID then
			activeEssences[essenceID] = slot;
		end
	end
	
	local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();

	self.HeaderButton:Hide();
	local offset = HybridScrollFrame_GetOffset(self);

	local totalHeight = numEssences * (ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET) + ESSENCE_LIST_PADDING * 2;
	if self:HasHeader() then
		totalHeight = totalHeight + ESSENCE_HEADER_HEIGHT - ESSENCE_BUTTON_HEIGHT;
	end

	for i, button in ipairs(self.buttons) do
		local index = offset + i;
		if index <= numEssences then
			local essenceInfo = essences[index];
			if essenceInfo.isHeader then
				button:SetHeight(ESSENCE_HEADER_HEIGHT);
				button:Hide();
				self.HeaderButton:SetPoint("BOTTOM", button, 0, 0);
				self.HeaderButton:Show();
				if self:ShouldShowInvalidEssences() then
					self.HeaderButton.ExpandedIcon:Show();
					self.HeaderButton.CollapsedIcon:Hide();
				else
					self.HeaderButton.ExpandedIcon:Hide();
					self.HeaderButton.CollapsedIcon:Show();
				end
			else
				button:SetHeight(ESSENCE_BUTTON_HEIGHT);
				button.Icon:SetTexture(essenceInfo.icon);
				button.Name:SetText(essenceInfo.name);
				local activatedMarker;
				if essenceInfo.unlocked then
					local color = ITEM_QUALITY_COLORS[essenceInfo.rank + 1];	-- min shown quality is uncommon
					button.Name:SetTextColor(color.r, color.g, color.b);
					button.Icon:SetDesaturated(not essenceInfo.valid);
					button.Icon:SetVertexColor(1, 1, 1);
					button.IconCover:Hide();
					button.Background:SetAtlas("heartofazeroth-list-item");
					local activeSlot = activeEssences[essenceInfo.ID];
					if activeSlot then
						if activeSlot == Enum.AzeriteEssence.MainSlot then
							activatedMarker = button.ActivatedMarkerMain;
						else
							activatedMarker = button.ActivatedMarkerPassive;
						end
					end
				else
					button.Name:SetTextColor(LOCKED_FONT_COLOR:GetRGB());
					button.Icon:SetDesaturated(true);
					button.Icon:SetVertexColor(LOCKED_FONT_COLOR:GetRGB());
					button.IconCover:Show();
					button.Background:SetAtlas("heartofazeroth-list-item-uncollected");
				end
				button.PendingGlow:SetShown(essenceInfo.ID == pendingEssenceID);
				button.essenceID = essenceInfo.ID;
				button.rank = essenceInfo.rank;
				button:Show();

				for _, marker in ipairs(button.ActivatedMarkers) do
					marker:SetShown(marker == activatedMarker);
				end
			end
		else
			button:Hide();
		end
	end

	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
	self:UpdateMouseOverTooltip();
end

function AzeriteEssenceListMixin:UpdateMouseOverTooltip()
	for i, button in ipairs(self.buttons) do
		-- need to check shown for when mousing over button covered by header
		if button:IsMouseOver() and button:IsShown() then
			button:OnEnter();
			return;
		end
	end
end

AzeriteEssenceButtonMixin  = { };

function AzeriteEssenceButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function AzeriteEssenceButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetAzeriteEssence(self.essenceID, self.rank);
	GameTooltip:Show();
end

function AzeriteEssenceButtonMixin:OnClick(mouseButton)
	if mouseButton == "LeftButton" then
		self:GetParent():GetParent():SetPendingEssence(self.essenceID);
	elseif mouseButton == "RightButton" then
		C_AzeriteEssence.ClearPendingActivationEssence();		
	end
end

AzeriteEssenceSlotMixin = { };

function AzeriteEssenceSlotMixin:Refresh()
	local locked, unlockLevel = C_AzeriteEssence.GetSlotInfo(self.slot);
	
	if self.UnlockedRegions then
		for i, region in ipairs(self.UnlockedRegions) do
			region:SetShown(not locked);
		end
	end

	if self.LockedRegions then
		for i, region in ipairs(self.LockedRegions) do
			region:SetShown(locked);
		end
	end
	
	if locked then
		self.UnlockLevelText:SetText(unlockLevel);
		self.EmptyGlow:Hide();
	else
		local essenceID = self:GetParent():GetParent():GetEffectiveEssence(self.slot);
		local icon;
		if essenceID then
			local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
			icon = essenceInfo and essenceInfo.icon or nil;
		end

		if icon then
			self.Icon:SetTexture(icon);
			self.Icon:Show();
			self.EmptyIcon:Hide();
			self.EmptyGlow:Hide();
		else
			self.Icon:Hide();
			self.EmptyIcon:Show();
			self.EmptyGlow:Show();
			self.EmptyGlow.Anim:Stop();
			self.EmptyGlow.Anim:Play();
		end
	end
end

function AzeriteEssenceSlotMixin:OnMouseUp(button)
	if button == "LeftButton" then
		if C_AzeriteEssence.HasPendingActivationEssence() then
			local locked, unlockLevel = C_AzeriteEssence.GetSlotInfo(self.slot);
			if not locked then
				if self:GetParent():GetParent():HasNewlyActivatedEssence() then
					UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_RIGHT_NOW, RED_FONT_COLOR:GetRGBA());
				else
					-- check for animation only, let it go either way for error messages
					local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
					if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.slot) then
						self:GetParent():GetParent():OnEssenceActivated(self.slot, pendingEssenceID);
						if GameTooltip:GetOwner() == self then
							GameTooltip:Hide();
						end
					end
					C_AzeriteEssence.ActivateEssence(pendingEssenceID, self.slot);
				end
			end
		end
	end
end

function AzeriteEssenceSlotMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local essenceID = C_AzeriteEssence.GetActiveEssence(self.slot);
	if essenceID then
		GameTooltip:SetAzeriteEssenceSlot(self.slot);
		GameTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM);

		if C_AzeriteEssence.HasPendingActivationEssence() then
			local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
			if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.slot) then
				self.HighlightRing:Show();
			end
		end
	else
		local wrapText = true;
		local isMainSlot = self.slot == Enum.AzeriteEssence.MainSlot;
		local locked, unlockLevel, unlockDescription = C_AzeriteEssence.GetSlotInfo(self.slot);
		if locked then
			if isMainSlot then
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_MAIN_SLOT);
				if unlockDescription then
					GameTooltip_AddColoredLine(GameTooltip, unlockDescription, DISABLED_FONT_COLOR, wrapText);
				end
			else
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_PASSIVE_SLOT);
				GameTooltip_AddColoredLine(GameTooltip, string.format(AZERITE_ESSENCE_LOCKED_SLOT_LEVEL, unlockLevel), DISABLED_FONT_COLOR, wrapText);
			end
		else
			if isMainSlot then
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_EMPTY_MAIN_SLOT);
				GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_EMPTY_MAIN_SLOT_DESC, NORMAL_FONT_COLOR, wrapText);
			else
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_EMPTY_PASSIVE_SLOT);
				GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_EMPTY_PASSIVE_SLOT_DESC, NORMAL_FONT_COLOR, wrapText);
			end
		end
	end
	GameTooltip:Show();
end

function AzeriteEssenceSlotMixin:OnLeave()
	self.HighlightRing:Hide();
	GameTooltip:Hide();
end

function AzeriteEssenceSlotMixin:OnDragStart()
	local spellID = C_AzeriteEssence.GetActionSpell();
	PickupSpell(spellID);
end

AzeriteEssenceLearnAnimFrameMixin = { };

function AzeriteEssenceLearnAnimFrameMixin:OnLoad()
	self:SetPoint("CENTER", AzeriteEssenceUI.SlotsFrame.MajorSlot);
end

function AzeriteEssenceLearnAnimFrameMixin:PlayAnim()
	if not AzeriteEssenceUI:IsShown() then
		return;
	end

	self.Anim:Stop();
	for i, texture in ipairs(self.Textures) do
		texture:SetAlpha(0);
	end
	self:Show();
	self.Anim:Play();
end

function AzeriteEssenceLearnAnimFrameMixin:StopAnim()
	self:Hide();
end
