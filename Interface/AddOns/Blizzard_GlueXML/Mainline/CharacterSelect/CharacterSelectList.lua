
CharacterSelectListMixin = {};

function CharacterSelectListMixin:OnLoad()
	self.CreateCharacterButton:SetScript("OnEnter", function()
		if self.CreateCharacterButton:IsEnabled() then
			GlueTooltip:SetOwner(self.CreateCharacterButton, "ANCHOR_TOP");
			GameTooltip_SetTitle(GlueTooltip, CHARACTER_SELECT_NAV_BAR_CREATE_CHARACTER_TOOLTIP:format(CharacterSelectUtil.GetFormattedCurrentRealmName()));
			GlueTooltip:Show();
		end
	end);

	self.CreateCharacterButton:SetScript("OnLeave", function()
		GlueTooltip:Hide();
	end);

	self.CreateCharacterButton:SetScript("OnClick", function()
		local createCharacterCallback = function()
			if not CharacterSelect_ShowTimerunningChoiceWhenActive() then
				CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal);
			end
		end;

		if GetCVar("showCreateCharacterRealmConfirmDialog") == "1" then
			local formattedText = string.format(StaticPopupDialogs["CREATE_CHARACTER_REALM_CONFIRMATION"].text, CharacterSelectUtil.GetFormattedCurrentRealmName());
			GlueDialog_Show("CREATE_CHARACTER_REALM_CONFIRMATION", formattedText, createCharacterCallback);
		else
			createCharacterCallback();
		end
	end);

	self.DeleteCharacterButton:SetScript("OnClick", GenerateFlatClosure(CharacterSelect_Delete));

	self.UndeleteButton:SetOnClickHandler(CharacterSelect_StartCharacterUndelete);

	self.BackToActiveButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		CharacterSelect_EndCharacterUndelete();
	end);

	self:RegisterEvent("UPDATE_REALM_NAME_FOR_GUID");
	self:RegisterEvent("CHARACTER_LIST_UPDATE");

	self:EvaluateIntroHelptip();

	-- This event handler can only be added after the CharacterSelectUI's OnLoad has run.
	RunNextFrame(function ()
		self:AddDynamicEventMethod(CharacterSelect.CharacterSelectUI, CharacterSelectUIMixin.Event.ExpansionTrialStateUpdated, CharacterSelectListMixin.OnExpansionTrialStateUpdated);
	end);
end

function CharacterSelectListMixin:OnEvent(event, ...)
	if event == "UPDATE_REALM_NAME_FOR_GUID" then
		local guid, realmName = ...;
		CharacterSelectListUtil.ForEachCharacterDo(function(frame)
			if frame:GetCharacterGUID() == guid then
				frame.characterInfo.realmName = realmName;
			end
		end);

		-- Update VAS tokens, in case not having a realm had the token disabled.
		CharacterServicesMaster_UpdateServiceButton();
	elseif event == "CHARACTER_LIST_UPDATE" then
		CharacterLoginUtil.EvaluateNewAlliedRaces();
		self:EvaluateCreateCharacterNewState();
	end
end

-- Multiple things can trigger the 'new' text on the create character button, ensure that we show it if any pass.
function CharacterSelectListMixin:EvaluateCreateCharacterNewState()
	local isNew = self.isExpansionTrial or CharacterLoginUtil.HasNewAlliedRaces();
	self.CreateCharacterButton.NewFeatureFrame:SetShown(isNew);
end

function CharacterSelectListMixin:OnExpansionTrialStateUpdated(isExpansionTrial)
	self.isExpansionTrial = isExpansionTrial;
	self:EvaluateCreateCharacterNewState();
end

function CharacterSelectListMixin:Init()
	self:InitScrollBox();
	self:InitDragBehavior();
end

function CharacterSelectListMixin:InitScrollBox()
	local function GroupInitializer(group, elementData)
		group:Init(elementData);
	end;

	local function CharacterInitializer(frame, elementData)
		if elementData.characterID > 0 then
			local inGroup = false;
			frame:SetData(elementData, inGroup);
		end
	end;

	local view = CreateScrollBoxListLinearView();

	view:SetElementFactory(function(factory, elementData)
		if elementData.isGroup then
			factory("CharacterSelectListGroupTemplate", GroupInitializer);
			return;
		elseif elementData.isDivider then
			factory("CharacterSelectListDividerTemplate");
			return;
		else
			factory("CharacterSelectListCharacterTemplate", CharacterInitializer);
		end
	end);

	local function CalculateHeight(elementData)
		if elementData.isGroup then
			return elementData.collapsed and elementData.heightCollapsed or elementData.heightExpanded;
		end

		return elementData.height;
	end;

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		return CalculateHeight(elementData);
	end);

	-- Scroll box extends far to the left and then counterpositioned to make space
	-- for services, service arrows, and locks.
	local left = 82;
	local pad = 0;
	local spacing = 2;
	view:SetPadding(pad, pad, left, pad, spacing);

	-- Manually set pan extent, otherwise scrolling will be referencing the size of the first element in the
	-- list as its basis, which currently is the camp group which is larger than we want.
	view:SetPanExtent(CharacterSelectListUtil.CharacterHeight);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function CharacterSelectListMixin:InitDragBehavior()
	local function CursorInitializer(frame, elementData)
		local characterID = elementData.characterID;
		local containingElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
			return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
		end);

		local inGroup = containingElementData.isGroup ~= nil;

		frame:SetData(elementData, inGroup);
		frame:SetSelectedState(false);
		frame:SetScript("OnEnter", nil);
		frame:SetScript("OnLeave", nil);

		frame.InnerContent:SetDragState(true);

		local statusText = frame.InnerContent.Text.Status;
		statusText:SetScript("OnEnter", nil);
		statusText:SetScript("OnLeave", nil);
		statusText:SetScript("OnMouseUp", nil);
	end

	-- Be aware of what the various DragIntersectionArea cases translate to here.
	-- Inside == swap the elements, Above/Below == insert next to the element.
	local dragBehavior = ScrollUtil.AddLinearDragBehavior(self.ScrollBox);
	dragBehavior:SetReorderable(true);
	dragBehavior:SetDragRelativeToCursor(true);
	dragBehavior:SetAreaIntersectMargin(function(destinationElementData, sourceElementData, contextData)
		if contextData.destinationData.parentElementData == nil and not destinationElementData.isGroup and not destinationElementData.isDivider then
			return destinationElementData.height * 0.5;
		end

		return 15;
	end);


	dragBehavior:SetCursorFactory(function(elementData)
		return "CharacterSelectListCharacterTemplate", CursorInitializer;
	end);

	dragBehavior:SetDropEnter(function(factory, candidate)
		local candidateArea = candidate.area;
		local candidateFrame = candidate.frame;
		local leftX = 0;
		local rightX = 7;
		if candidateArea == DragIntersectionArea.Above then
			local y = -1;
			local frame = factory("CharacterSelectListDragIndicatorTemplate");
			frame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", leftX, y);
			frame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", rightX, y);
		elseif candidateArea == DragIntersectionArea.Below then
			local y = 1;
			local frame = factory("CharacterSelectListDragIndicatorTemplate");
			frame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", leftX, y);
			frame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", rightX, y);
		elseif candidateArea == DragIntersectionArea.Inside then
			if candidateFrame:GetElementData().characterID then
				candidateFrame.InnerContent:SetAlpha(.4);
				candidateFrame:SetDropState(true);
			end
		end
	end);

	dragBehavior:SetDropLeave(function(candidate)
		if candidate.frame:GetElementData().characterID then
			candidate.frame.InnerContent:SetAlpha(1);
			candidate.frame:SetDropState(false);
		end
	end);

	dragBehavior:SetNotifyDragStart(function(sourceFrame, dragging)
		sourceFrame:SetAlpha(dragging and .4 or 1);
		sourceFrame:SetMouseMotionEnabled(not dragging);
	end);

	dragBehavior:SetNotifyDropCandidates(function(candidateFrame, dragging, sourceElementData)
		candidateFrame:SetMouseMotionEnabled(not dragging);

		local candidateFrameElementData = candidateFrame:GetElementData();
		if candidateFrameElementData.isEmpty then
			candidateFrame:SetDragState(dragging);
		end
	end);

	-- Determines if this is this a valid drop case.
	dragBehavior:SetDropPredicate(function(sourceElementData, contextData)
		-- You cannot drop something above or below a group.

		-- You cannot drop something directly above or inside a divider.
		if contextData.elementData.isDivider and (contextData.area == DragIntersectionArea.Above or contextData.area == DragIntersectionArea.Inside) then
			return false;
		end

		-- You cannot swap with an element that is not in a group.
		if contextData.area == DragIntersectionArea.Inside and contextData.parentElementData == nil then
			return false;
		end

		-- You cannot insert into grouped elements, if the source element was not already contained within the same group.
		if contextData.parentElementData ~= nil
			and (contextData.area == DragIntersectionArea.Above or contextData.area == DragIntersectionArea.Below)
			and not CharacterSelectListUtil.ContainsCharacterID(sourceElementData.characterID, contextData.parentElementData) then
			return false;
		end

		return true;
	end);

	-- Determines if this is this a valid drag case.
	dragBehavior:SetDragPredicate(function(frame, elementData)
		-- Cannot drag groups or divider elements.
		if elementData.isGroup or elementData.isDivider then
			return false;
		end

		-- Cannot drag empty characters that are in groups.
		if elementData.isEmpty then
			return false;
		end

		return true;
	end);

	dragBehavior:SetPostDrop(function(contextData)
		local dataProvider = contextData.dataProvider;

		-- Pre drop information.
		local sourceData = contextData.sourceData;
		local destinationData = contextData.destinationData;

		-- Character moved from a group to out of one.  Ensure we place an empty character in the correct slot index.
		if sourceData.parentElementData and not destinationData.parentElementData then
			local characterData = {
				characterID = 0,
				isEmpty = true,
				height = CharacterSelectListUtil.CharacterHeight
			}

			table.insert(sourceData.parentElementData.characterData, sourceData.elementDataIndex, characterData);
		end

		-- If any empty group characters were updated, make sure that reflects in the new dataProvider.
		for index, elementData in dataProvider:EnumerateEntireRange() do
			if elementData.isEmpty then
				-- Empty character slots that were swapped out of a group entirely are removed.
				dataProvider:RemoveIndex(index);
			end
		end

		-- Cache selected character ID, so we can make sure we are still selecting it if it moves once we update the character order.
		local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);

		-- dataProvider has the new order of everything post move, update our backing data with this new ordering.
		CharacterSelectListUtil.UpdateCharacterOrderFromDataProvider(dataProvider);

		-- Ensure we are still selecting the same character now that things have updated.
		CharacterSelectListUtil.UpdateSelectedIndex(selectedCharacterID);
	end);

	-- Trigger any animations related to the reorder.
	dragBehavior:SetFinalizeDrop(function(contextData)
		local newSourceData = contextData.newSourceData;
		local newDestinationData = contextData.newDestinationData;

		-- Visually refresh character rendering now that things have moved.
		local noCreate = true;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);

		-- Ensure we update character display, as no update event will happen as we are not actually changing the selected character.
		local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
		CharacterSelect.CharacterSelectUI:SetCharacterDisplay(selectedCharacterID);

		local function AnimatePulseAnimForCharacter(frame)
			frame:AnimatePulse();
		end;

		local function AnimateGlowAnimForCharacter(frame)
			frame:AnimateGlow();
		end;

		local function AnimateGlowMoveAnimForCharacter(frame)
			frame:AnimateGlowMove();
		end;

		-- Swaps in general play different animations than inserts.
		if contextData.isSwap then
			if newDestinationData.elementData.isEmpty and not newDestinationData.parentElementData and newSourceData.parentElementData then
				-- If we are swapping into an empty character slot from an ungrouped character (empty character slot is removed).
				CharacterSelectListUtil.ForCharacterDo(newSourceData.elementData.characterID, AnimatePulseAnimForCharacter);

				local sourceGuid = GetCharacterGUID(newSourceData.elementData.characterID);
				local groupFrame = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
					return CharacterSelectListUtil.GetCharacterPositionData(sourceGuid, elementData) ~= nil;
				end);

				if groupFrame then
					groupFrame:AnimatePulse();
				end
			elseif newDestinationData.elementData.isEmpty and newDestinationData.parentElementData and newSourceData.parentElementData
				and newDestinationData.parentElementData.groupID == newSourceData.parentElementData.groupID then
				-- We are swapping a grouped character with an empty slot within the same group.
				CharacterSelectListUtil.ForCharacterDo(newSourceData.elementData.characterID, AnimateGlowAnimForCharacter);

				local originalGroupID = contextData.sourceData.parentElementData.groupID;
				local groupFrame = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
					return elementData.isGroup and elementData.groupID == originalGroupID;
				end);

				if groupFrame then
					groupFrame.groupButtons[contextData.sourceData.elementDataIndex]:AnimateGlowFade();
				end
			else
				CharacterSelectListUtil.ForCharacterDo(newSourceData.elementData.characterID, AnimateGlowMoveAnimForCharacter);
				CharacterSelectListUtil.ForCharacterDo(newDestinationData.elementData.characterID, AnimateGlowMoveAnimForCharacter);
			end
		else
			CharacterSelectListUtil.ForCharacterDo(newSourceData.elementData.characterID, AnimateGlowAnimForCharacter);

			-- If a new empty slot was made from this move.
			local sourceData = contextData.sourceData;
			if sourceData.parentElementData and not newSourceData.parentElementData then
				local originalGroupID = sourceData.parentElementData.groupID;
				local groupFrame = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
					return elementData.isGroup and elementData.groupID == originalGroupID;
				end);

				if groupFrame then
					groupFrame.groupButtons[sourceData.elementDataIndex]:AnimateGlowFade();
				end
			end
		end
	end);

	dragBehavior:SetGetChildrenFrames(function(frame)
		-- Only group frames have groupButtons set, non groups must return nil.
		return frame.groupButtons;
	end);

	dragBehavior:SetGetChildrenElementData(function(elementData)
		-- Only group elementData has characterData set, non groups must return nil.
		return elementData.characterData;
	end);

	-- Assigning an empty data provider to prevent any scroll box related access errors due to race conditions.
	-- When the actual character data arrives, this data provider will be discarded.
	self.ScrollBox:SetDataProvider(CreateDataProvider());
end

function CharacterSelectListMixin:UpdateUndeleteState()
	local isUndeleting = CharacterSelectUtil.IsUndeleting();

	self.CreateCharacterButton:SetShown(not isUndeleting);
	self.DeleteCharacterButton:SetShown(not isUndeleting);
	self.UndeleteButton:SetShown(not isUndeleting);
	self.UndeleteLabel:SetShown(isUndeleting);
	self.UndeleteRealmLabel:SetShown(isUndeleting);
	self.UndeleteRealmBackdrop:SetShown(isUndeleting);
	self.BackToActiveButton:SetShown(isUndeleting);
	self.SearchBox:SetShown(not isUndeleting);
	self.SearchBox:SetText("");

	if isUndeleting then
		HelpTip:Hide(self, CHARACTER_SELECT_WARBAND_INTRO_HELPTIP);

		self.UndeleteRealmLabel:SetText(CHARACTER_SELECT_UNDELETE_REALM_LABEL:format(CharacterSelectUtil.GetFormattedCurrentRealmName()));
		local helpTipInfo = {
			text = CHARACTER_SELECT_UNDELETE_REALM_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
		};
		HelpTip:Show(self, helpTipInfo, self.UndeleteRealmLabel);
	else
		HelpTip:Hide(self, CHARACTER_SELECT_UNDELETE_REALM_HELPTIP);

		self:EvaluateIntroHelptip();
	end
end

function CharacterSelectListMixin:SetCharacterCreateEnabled(enabled, disabledTooltip)
	self.CreateCharacterButton:SetEnabled(enabled);
end

function CharacterSelectListMixin:SetDeleteEnabled(isEnabled, disabledTooltip)
	self.DeleteCharacterButton:SetEnabled(isEnabled);
	self.DeleteCharacterButton:SetDisabledTooltip(disabledTooltip);
end

function CharacterSelectListMixin:UpdateCharacterMatchingGUID(guid)
	local characterID;
	local frame = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		characterID = CharacterSelectListUtil.GetCharacterPositionData(guid, elementData);
		return characterID ~= nil;
	end);

	if frame then
		CharacterSelectListUtil.UpdateCharacter(frame, characterID);
	end
end

function CharacterSelectListMixin:UpdateCharacterSelection()
	local dataProvider = CharacterSelectListUtil.GenerateCharactersDataProvider();
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self.ScrollBox.dragBehavior:SetDragEnabled(CharacterSelectListUtil.CanReorder());

	CharacterSelect_UpdateButtonState();
end

function CharacterSelectListMixin:ClearCharacterSelection()
	self.ScrollBox:SetDataProvider(CreateDataProvider());
end

function CharacterSelectListMixin:ScrollToCharacter(characterGUID)
	local elementData = self.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.GetCharacterPositionData(characterGUID, elementData) ~= nil;
	end);

	if elementData then
		CharacterSelectListUtil.ScrollToElement(elementData, ScrollBoxConstants.AlignCenter);
	else
		self.ScrollBox:ScrollToEnd();
	end
end

function CharacterSelectListMixin:SetScrollEnabled(enabled)
	self.ScrollBox:SetScrollAllowed(enabled);
end

function CharacterSelectListMixin:EvaluateIntroHelptip()
	if IsCharacterSelectListModeRealmless() then
		local helpTipInfo = {
			text = CHARACTER_SELECT_WARBAND_INTRO_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeTop,
			cvar = "seenCharacterSelectWarbandHelpTip",
			cvarValue = "1",
			checkCVars = true,
			offsetY = -153
		};
		HelpTip:Show(self, helpTipInfo, self);
	end
end