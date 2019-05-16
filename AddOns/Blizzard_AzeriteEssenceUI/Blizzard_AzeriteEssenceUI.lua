UIPanelWindows["AzeriteEssenceUI"] = { area = "left", pushable = 1 };

AzeriteEssenceUIMixin = CreateFromMixins(CallbackRegistryBaseMixin);

AzeriteEssenceUIMixin:GenerateCallbackEvents(
{
	"OnShow",
	"OnHide",
});

local ESSENCE_BUTTON_HEIGHT = 41;
local ESSENCE_HEADER_HEIGHT = 21;
local ESSENCE_BUTTON_OFFSET = 1;
local ESSENCE_LIST_PADDING = 3;

local LOCKED_FONT_COLOR = CreateColor(0.5, 0.447, 0.4);
local CONNECTED_LINE_COLOR = CreateColor(.055, .796, .804);
local DISCONNECTED_LINE_COLOR = CreateColor(.055, .796, .804);
local LOCKED_LINE_COLOR = CreateColor(.486, .486, .486);

local HEART_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(256, 1962885);				-- Offhand_1H_HeartofAzeroth_D_01.m2
local LEARN_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);				-- 	8FX_Azerite_AbsorbCurrency_Small_ImpactBase.m2
local UNLOCK_SLOT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(269, 1983548);		-- 	8FX_Azerite_Generic_NovaHigh_Base.m2
local UNLOCK_STAMINA_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(270, 1983548);	-- 	8FX_Azerite_Generic_NovaHigh_Base.m2

local AZERITE_ESSENCE_FRAME_EVENTS = {
	"UI_MODEL_SCENE_INFO_UPDATED",
	"AZERITE_ESSENCE_CHANGED",
	"AZERITE_ESSENCE_ACTIVATED",
	"AZERITE_ESSENCE_ACTIVATION_FAILED",
	"AZERITE_ESSENCE_UPDATE",
	"AZERITE_ESSENCE_FORGE_OPEN",
	"AZERITE_ESSENCE_FORGE_CLOSE",
	"AZERITE_ESSENCE_MILESTONE_UNLOCKED",
	"AZERITE_ITEM_POWER_LEVEL_CHANGED",
};

local MILESTONE_LOCATIONS = {
	[1] = { left = 237, top = -235 },
	[2] = { left = 100, top = -203 },
	[3] = { left = 117, top = -310 },
	[4] = { left = 242, top = -376 },
	[5] = { left = 362, top = -301 },
	[6] = { left = 356, top = -160 },	
	[7] = { left = 232, top = -94 },
};

local LOCKED_RUNE_ATLASES = { "heartofazeroth-slot-minor-unlearned-bottomleft", "heartofazeroth-slot-minor-unlearned-topright" };

function AzeriteEssenceUIMixin:OnLoad()
	CallbackRegistryBaseMixin.OnLoad(self);

	self.TopTileStreaks:Hide();	
	self:SetupModelScene();
	self:SetupMilestones();
	self:RefreshPowerLevel();
end

function AzeriteEssenceUIMixin:SetupMilestones()
	self.Milestones = { };
	self.Lines = { };

	local previousMilestoneFrame;
	local lockedRuneCount = 0;

	local milestones = C_AzeriteEssence.GetMilestones();

	for i, milestoneInfo in ipairs(milestones) do
		local template;
		if milestoneInfo.slot == Enum.AzeriteEssence.MainSlot then
			template = "AzeriteMilestoneMajorSlotTemplate";
		elseif milestoneInfo.slot then
			template = "AzeriteMilestoneMinorSlotTemplate";
		else
			template = "AzeriteMilestoneStaminaTemplate";
		end
		
		local milestoneFrame = CreateFrame("FRAME", nil, self, template);
		milestoneFrame:SetPoint("CENTER", self.OrbBackground, "TOPLEFT", MILESTONE_LOCATIONS[i].left, MILESTONE_LOCATIONS[i].top);
		milestoneFrame:SetFrameLevel(1500);
		milestoneFrame.milestoneID = milestoneInfo.ID;
		milestoneFrame.slot = milestoneInfo.slot;
		if milestoneFrame.LockedState then
			lockedRuneCount = lockedRuneCount + 1;
			local runeAtlas = LOCKED_RUNE_ATLASES[lockedRuneCount];
			if runeAtlas then
				milestoneFrame.LockedState.Rune:SetAtlas(runeAtlas);
			end
		end

		if previousMilestoneFrame then
			local lineContainer = CreateFrame("FRAME", nil, self, "AzeriteEssenceDependencyLineTemplate");
			lineContainer:SetConnectedColor(CONNECTED_LINE_COLOR);
			lineContainer:SetDisconnectedColor(DISCONNECTED_LINE_COLOR);
			lineContainer:SetThickness(6);
			lineContainer.Background:Hide();

			local fromCenter = CreateVector2D(previousMilestoneFrame:GetCenter());
			fromCenter:ScaleBy(previousMilestoneFrame:GetEffectiveScale());

			local toCenter = CreateVector2D(milestoneFrame:GetCenter());
			toCenter:ScaleBy(milestoneFrame:GetEffectiveScale());

			toCenter:Subtract(fromCenter);

			lineContainer:CalculateTiling(toCenter:GetLength());

			lineContainer:SetEndPoints(previousMilestoneFrame, milestoneFrame);
			lineContainer:SetScrollAnimationProgressOffset(0);

			lineContainer:SetState(PowerDependencyLineMixin.LINE_STATE_CONNECTED);
			
			lineContainer.fromButton = previousMilestoneFrame;
			lineContainer.toButton = milestoneFrame;
			tinsert(self.Lines, lineContainer);
		end

		tinsert(self.Milestones, milestoneFrame);
		previousMilestoneFrame = milestoneFrame;
	end
end

function AzeriteEssenceUIMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self:SetupModelScene();
	elseif event == "AZERITE_ESSENCE_CHANGED" then
		local essenceID = ...;
		self:RefreshSlots();
		self.EssenceList:Update();
		self.EssenceList:OnEssenceChanged(essenceID);
		AzeriteEssenceLearnAnimFrame:PlayAnim();
	elseif event == "AZERITE_ESSENCE_ACTIVATED" or event == "AZERITE_ESSENCE_ACTIVATION_FAILED" or event == "AZERITE_ESSENCE_UPDATE" then
		self:ClearNewlyActivatedEssence();
		self:RefreshSlots();
		self.EssenceList:Update();
	elseif event == "AZERITE_ESSENCE_FORGE_OPEN" or event == "AZERITE_ESSENCE_FORGE_CLOSE" then
		self:RefreshMilestones();
	elseif event == "AZERITE_ESSENCE_MILESTONE_UNLOCKED" then
		self:RefreshMilestones();
		local milestoneID = ...;
		local milestoneFrame = self:GetMilestoneFrame(milestoneID);
		if milestoneFrame then
			milestoneFrame:OnUnlocked();
		end
	elseif event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		self:RefreshPowerLevel();
		self:RefreshMilestones();
	end
end

function AzeriteEssenceUIMixin:OnShow()
	-- portrait and title
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if itemLocation then
		local item = Item:CreateFromItemLocation(itemLocation);
		item:ContinueOnItemLoad(function()
			self:SetPortraitToAsset(item:GetItemIcon());
			self:SetTitle(item:GetItemName());
		end);
	end

	FrameUtil.RegisterFrameForEvents(self, AZERITE_ESSENCE_FRAME_EVENTS);

	self:RefreshPowerLevel();
	self:RefreshMilestones();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);		-- temp?

	self:TriggerEvent(AzeriteEssenceUIMixin.Event.OnShow);
end

function AzeriteEssenceUIMixin:OnHide()
	if C_AzeriteEssence:IsAtForge() then
		C_AzeriteEssence:CloseForge();
		CloseAllBags(self);
	end

	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	FrameUtil.UnregisterFrameForEvents(self, AZERITE_ESSENCE_FRAME_EVENTS);

	self:ClearNewlyActivatedEssence();

	-- clean up anims
	self.ActivationGlow.Anim:Stop();
	self.ActivationGlow:SetAlpha(0);
	AzeriteEssenceLearnAnimFrame:StopAnim();
	
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);	-- temp?

	self:TriggerEvent(AzeriteEssenceUIMixin.Event.OnHide);
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

function AzeriteEssenceUIMixin:OnEssenceActivated(essenceID, slotFrame)
	self:SetNewlyActivatedEssence(essenceID, slotFrame.milestoneID);

	self.ActivationGlow.Anim:Stop();
	self.ActivationGlow.Anim:Play();
	-- temp sounds
	if slotFrame.slot == Enum.AzeriteEssence.MainSlot then
		PlaySound(13827);
	else
		PlaySound(13829);
	end

	self:RefreshSlots();
	C_AzeriteEssence.ClearPendingActivationEssence();
end

function AzeriteEssenceUIMixin:RefreshPowerLevel()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if azeriteItemLocation then
		local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);
		self.PowerLevelBadgeFrame.Label:SetText(level);
		self.PowerLevelBadgeFrame:Show();
		self.powerLevel = level;
	else
		self.PowerLevelBadgeFrame:Hide();
		self.powerLevel = 0;
	end
end

function AzeriteEssenceUIMixin:OnEnterPowerLevelBadgeFrame()
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if itemLocation then
		local item = Item:CreateFromItemLocation(itemLocation);
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			GameTooltip:SetOwner(self.PowerLevelBadgeFrame, "ANCHOR_RIGHT", -7, -6);
			GameTooltip_SetTitle(GameTooltip, item:GetItemName(), item:GetItemQualityColor().color);
			GameTooltip_AddColoredLine(GameTooltip, string.format(HEART_OF_AZEROTH_LEVEL, self.powerLevel), WHITE_FONT_COLOR);
			GameTooltip:Show();
		end);
	end
end

function AzeriteEssenceUIMixin:OnLeavePowerLevelBadgeFrame()
	GameTooltip:Hide();
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteEssenceUIMixin:RefreshMilestones()
	for i, milestoneFrame in ipairs(self.Milestones) do
		milestoneFrame:Refresh();
	end

	for i, lineContainer in ipairs(self.Lines) do
		if lineContainer.toButton.unlocked then
			lineContainer:SetState(PowerDependencyLineMixin.LINE_STATE_CONNECTED);
			lineContainer:SetAlpha(0.15);
		else
			if lineContainer.fromButton.unlocked and lineContainer.toButton.canUnlock then
				lineContainer:SetDisconnectedColor(DISCONNECTED_LINE_COLOR);
				lineContainer:SetState(PowerDependencyLineMixin.LINE_STATE_DISCONNECTED);
				lineContainer:SetAlpha(0.08);
			else
				lineContainer:SetDisconnectedColor(LOCKED_LINE_COLOR);
				lineContainer:SetState(PowerDependencyLineMixin.LINE_STATE_DISCONNECTED);
				lineContainer:SetAlpha(0.08);
			end
		end
	end
end

function AzeriteEssenceUIMixin:RefreshSlots()
	for i, slotButton in ipairs(self.Slots) do
		slotButton:Refresh();
	end
end

function AzeriteEssenceUIMixin:GetSlotFrame(slot)
	for _, slotFrame in ipairs(self.Slots) do
		if slotFrame.slot == slot then
			return slotFrame;
		end
	end
	return nil;
end

function AzeriteEssenceUIMixin:GetMilestoneFrame(milestoneID)
	for _, milestoneFrame in ipairs(self.Milestones) do	
		if milestoneFrame.milestoneID == milestoneID then
			return milestoneFrame;
		end
	end
	return nil;
end

function AzeriteEssenceUIMixin:SetupModelScene()
	local forceUpdate = true;
	StaticModelInfo.SetupModelScene(self.ItemModelScene, HEART_MODEL_SCENE_INFO, forceUpdate);
end

function AzeriteEssenceUIMixin:SetNewlyActivatedEssence(essenceID, milestoneID)
	self.newlyActivatedEssenceID = essenceID;
	self.newlyActivatedEssenceMilestoneID = milestoneID;
end

function AzeriteEssenceUIMixin:GetNewlyActivatedEssence()
	return self.newlyActivatedEssenceID, self.newlyActivatedEssenceMilestoneID;
end

function AzeriteEssenceUIMixin:HasNewlyActivatedEssence()
	return self.newlyActivatedEssenceID ~= nil;
end

function AzeriteEssenceUIMixin:ClearNewlyActivatedEssence()
	self.newlyActivatedEssenceID = nil;
	self.newlyActivatedEssenceMilestoneID = nil;
end

function AzeriteEssenceUIMixin:GetSlotEssences()
	local slotEssences = { };
	for i, slotFrame in ipairs(self.Slots) do
		local essenceID = self:GetEffectiveEssence(slotFrame.milestoneID);
		if essenceID then
			slotEssences[essenceID] = slotFrame.slot;
		end
	end
	return slotEssences;
end	

function AzeriteEssenceUIMixin:GetEffectiveEssence(milestoneID)
	if not milestoneID then
		return nil;
	end

	local newlyActivatedEssenceID, newlyActivatedEssenceMilestoneID = self:GetNewlyActivatedEssence();
	if milestoneID == newlyActivatedEssenceMilestoneID then
		return newlyActivatedEssenceID;
	end
	
	local essenceID = C_AzeriteEssence.GetMilestoneEssence(milestoneID);
	if essenceID == newlyActivatedEssenceID then
		return nil;
	else
		return essenceID;
	end
end

AzeriteEssenceDependencyLineMixin = CreateFromMixins(PowerDependencyLineMixin);

function AzeriteEssenceDependencyLineMixin:SetDisconnected()
	self.FillScroll1:SetVertexColor(self.disconnectedColor:GetRGB());
	self.FillScroll2:SetVertexColor(self.disconnectedColor:GetRGB());
	PowerDependencyLineMixin.SetDisconnected(self);
end

AzeriteEssenceListMixin  = { };

function AzeriteEssenceListMixin:OnLoad()
	self.ScrollBar.doNotHide = true;
	self.update = function() self:Refresh(); end
	self.dynamic = function(...) return self:CalculateScrollOffset(...); end
	HybridScrollFrame_CreateButtons(self, "AzeriteEssenceButtonTemplate", 4, -ESSENCE_LIST_PADDING, "TOPLEFT", "TOPLEFT", 0, -ESSENCE_BUTTON_OFFSET, "TOP", "BOTTOM");
	self.HeaderButton:SetParent(self.ScrollChild);

	self:RegisterEvent("VARIABLES_LOADED");
	self.collapsed = GetCVarBool("otherRolesAzeriteEssencesHidden");
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
	elseif event == "VARIABLES_LOADED" then
		self.collapsed = GetCVarBool("otherRolesAzeriteEssencesHidden");
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
		StaticModelInfo.SetupModelScene(scene, LEARN_MODEL_SCENE_INFO, forceUpdate);
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
	SetCVar("otherRolesAzeriteEssencesHidden", self.collapsed);
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

function AzeriteEssenceListMixin:OnEssenceChanged(essenceID)
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

	local slotEssences = self:GetParent():GetSlotEssences();
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
					local essenceSlot = slotEssences[essenceInfo.ID];
					if essenceSlot then
						if essenceSlot == Enum.AzeriteEssence.MainSlot then
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

function AzeriteEssenceButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetAzeriteEssence(self.essenceID, self.rank);
	GameTooltip:Show();
end

function AzeriteEssenceButtonMixin:OnClick(mouseButton)
	if mouseButton == "LeftButton" then
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_AzeriteEssence.GetEssenceHyperlink(self.essenceID, self.rank));
		end
		if ( not linkedToChat ) then
			self:GetParent():GetParent():SetPendingEssence(self.essenceID);
		end
	elseif mouseButton == "RightButton" then
		C_AzeriteEssence.ClearPendingActivationEssence();		
	end
end

AzeriteMilestoneBaseMixin = { };

function AzeriteMilestoneBaseMixin:OnLoad()
	if self.isDraggable then
		self:RegisterForDrag("LeftButton");
	end
	self.SwirlContainer:SetScale(self.swirlScale);
end

function AzeriteMilestoneBaseMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self.unlockEffect = nil;
	end
end

function AzeriteMilestoneBaseMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteMilestoneBaseMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self.unlockEffect = nil;
end

function AzeriteMilestoneBaseMixin:OnMouseUp()
	-- override this
end

function AzeriteMilestoneBaseMixin:OnEnter()
	-- override this
end

function AzeriteMilestoneBaseMixin:OnLeave()
	if self.UnlockedState then
		self.UnlockedState.HighlightRing:Hide();
	end
	GameTooltip:Hide();
end

function AzeriteMilestoneBaseMixin:OnUnlocked()
	if not self.unlockEffect then
		local forceUpdate = true;
		local sceneInfo = self.slot and UNLOCK_SLOT_MODEL_SCENE_INFO or UNLOCK_STAMINA_MODEL_SCENE_INFO;
		self.unlockEffect = StaticModelInfo.SetupModelScene(self.UnlockModelScene, sceneInfo, forceUpdate);
	end
	
	if self.unlockEffect then
		self.UnlockModelScene:Show();
		self.unlockEffect:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, 
			function()
				self.unlockEffect:SetAnimation(0, 0, 0, 0);
				C_Timer.After(5, 
					function()
						self.UnlockModelScene:Hide();
					end
				);
				C_Timer.After(.4,
					function()
						self.SwirlContainer:Show();
						self.SwirlContainer.SelectedAnim:Play();
					end
				);
			end
		);
		if GameTooltip:GetOwner() == self then
			self:OnEnter();
		end
	end
end

AzeriteMilestoneSlotMixin = CreateFromMixins(AzeriteMilestoneBaseMixin);

function AzeriteMilestoneSlotMixin:OnDragStart()
	local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);
	if spellID then
		PickupSpell(spellID);
	end
end

function AzeriteMilestoneSlotMixin:ShowStateFrame(stateFrame)
	if not self.StateFrames then
		return;
	end
	for i, frame in ipairs(self.StateFrames) do
		frame:SetShown(frame == stateFrame);
	end
end

function AzeriteMilestoneSlotMixin:Refresh()
	local milestoneInfo = C_AzeriteEssence.GetMilestoneInfo(self.milestoneID);

	self.unlocked = milestoneInfo.unlocked;
	self.canUnlock = milestoneInfo.canUnlock;

	if milestoneInfo.unlocked then
		self:ShowStateFrame(self.UnlockedState);
		local essenceID = self:GetParent():GetEffectiveEssence(self.milestoneID);
		local icon;
		if essenceID then
			local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
			icon = essenceInfo and essenceInfo.icon or nil;
		end

		local stateFrame = self.UnlockedState;
		if icon then
			stateFrame.Icon:SetTexture(icon);
			stateFrame.Icon:Show();
			stateFrame.EmptyIcon:Hide();
			stateFrame.EmptyGlow:Hide();
		else
			stateFrame.Icon:Hide();
			stateFrame.EmptyIcon:Show();
			stateFrame.EmptyGlow:Show();
			stateFrame.EmptyGlow.Anim:Stop();
			stateFrame.EmptyGlow.Anim:Play();
		end
	else
		if milestoneInfo.canUnlock then
			self:ShowStateFrame(self.AvailableState);
			if C_AzeriteEssence.IsAtForge() then
				self.AvailableState.GlowAnim:Stop();
				self.AvailableState.ForgeGlowAnim:Play();
			else
				self.AvailableState.ForgeGlowAnim:Stop();
				self.AvailableState.GlowAnim:Play();
			end
		else
			self:ShowStateFrame(self.LockedState);
			self.LockedState.UnlockLevelText:SetText(milestoneInfo.requiredLevel);
		end
	end
end

function AzeriteMilestoneSlotMixin:OnMouseUp(button)
	if button == "LeftButton" then
		if C_AzeriteEssence.HasPendingActivationEssence() then
			if self.unlocked then
				if self:GetParent():HasNewlyActivatedEssence() then
					UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_RIGHT_NOW, RED_FONT_COLOR:GetRGBA());
				else
					-- check for animation only, let it go either way for error messages
					local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
					if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.milestoneID) then
						self:GetParent():OnEssenceActivated(pendingEssenceID, self);
						if GameTooltip:GetOwner() == self then
							GameTooltip:Hide();
						end
					end
					C_AzeriteEssence.ActivateEssence(pendingEssenceID, self.milestoneID);
				end
			end
		elseif self.canUnlock then
			C_AzeriteEssence.UnlockMilestone(self.milestoneID);
		end
	end
end

function AzeriteMilestoneSlotMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local essenceID = C_AzeriteEssence.GetMilestoneEssence(self.milestoneID);
	if essenceID then
		GameTooltip:SetAzeriteEssenceSlot(self.slot);
		GameTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM);

		if C_AzeriteEssence.HasPendingActivationEssence() then
			local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
			if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.milestoneID) then
				self.UnlockedState.HighlightRing:Show();
			end
		end
	else
		local wrapText = true;
		local isMainSlot = self.slot == Enum.AzeriteEssence.MainSlot;
		if not self.unlocked then
			assert(not isMainSlot);
			GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_PASSIVE_SLOT);
			if self.canUnlock then
				if C_AzeriteEssence.IsAtForge() then
					GameTooltip_AddColoredLine(GameTooltip, AZERITE_CLICK_TO_SELECT, GREEN_FONT_COLOR, wrapText);
				else
					GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_UNLOCK_SLOT, RED_FONT_COLOR, wrapText);
				end
			else
				local milestoneInfo = C_AzeriteEssence.GetMilestoneInfo(self.milestoneID);
				GameTooltip_AddColoredLine(GameTooltip, string.format(AZERITE_ESSENCE_LOCKED_SLOT_LEVEL, milestoneInfo.requiredLevel), DISABLED_FONT_COLOR, wrapText);
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

AzeriteMilestoneStaminaMixin = CreateFromMixins(AzeriteMilestoneBaseMixin);

function AzeriteMilestoneStaminaMixin:Refresh()
	local milestoneInfo = C_AzeriteEssence.GetMilestoneInfo(self.milestoneID);

	self.unlocked = milestoneInfo.unlocked;
	self.canUnlock = milestoneInfo.canUnlock;

	if milestoneInfo.unlocked then
		self.Icon:SetAtlas("heartofazeroth-node-on");
	else
		self.Icon:SetAtlas("heartofazeroth-node-off");
	end
	if milestoneInfo.canUnlock then
		if C_AzeriteEssence.IsAtForge() then
			self.GlowAnim:Stop();
			self.ForgeGlowAnim:Play();
		else
			self.ForgeGlowAnim:Stop();
			self.GlowAnim:Play();
		end
	else
		self.GlowAnim:Stop();
		self.ForgeGlowAnim:Stop();
	end
end

function AzeriteMilestoneStaminaMixin:OnEnter()
	local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);
	if not spellID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local spell = Spell:CreateFromSpellID(spellID);
	spell:ContinueWithCancelOnSpellLoad(function()
		if GameTooltip:GetOwner() == self then
			local wrapText = true;
			GameTooltip_SetTitle(GameTooltip, spell:GetSpellName());
			GameTooltip_AddColoredLine(GameTooltip, spell:GetSpellDescription(), NORMAL_FONT_COLOR, wrapText);
			if self.canUnlock then
				if C_AzeriteEssence.IsAtForge() then
					GameTooltip_AddColoredLine(GameTooltip, AZERITE_CLICK_TO_SELECT, GREEN_FONT_COLOR, wrapText);
				else
					GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_UNLOCK_MILESTONE, RED_FONT_COLOR, wrapText);
				end
			elseif not self.unlocked then
				local milestoneInfo = C_AzeriteEssence.GetMilestoneInfo(self.milestoneID);
				GameTooltip_AddColoredLine(GameTooltip, string.format(AZERITE_ESSENCE_LOCKED_MILESTONE_LEVEL, milestoneInfo.requiredLevel), DISABLED_FONT_COLOR, wrapText);
			end
			GameTooltip:Show();
		end
	end);
end

function AzeriteMilestoneStaminaMixin:OnMouseUp(mouseButton)
	if mouseButton == "LeftButton" then
		if self.canUnlock and C_AzeriteEssence.IsAtForge() then
			C_AzeriteEssence.UnlockMilestone(self.milestoneID);
		end
	end
end

AzeriteEssenceLearnAnimFrameMixin = { };

function AzeriteEssenceLearnAnimFrameMixin:OnLoad()
	self:SetPoint("CENTER", AzeriteEssenceUI:GetSlotFrame(Enum.AzeriteEssence.MainSlot));
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