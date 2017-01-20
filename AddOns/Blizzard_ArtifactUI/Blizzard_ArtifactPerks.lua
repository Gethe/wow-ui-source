ArtifactPerksMixin = {}

function ArtifactPerksMixin:OnLoad()	
	self.powerButtonPool = CreateFramePool("BUTTON", self, "ArtifactPowerButtonTemplate");
end

function ArtifactPerksMixin:OnShow()	
	self.modelTransformElapsed = 0;
	self:RegisterEvent("CURSOR_UPDATE");
end

function ArtifactPerksMixin:OnHide()	
	self:UnregisterEvent("CURSOR_UPDATE");
end

function ArtifactPerksMixin:OnEvent(event, ...)
	if event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	end
end

function ArtifactPerksMixin:OnAppearanceChanging()
	self.isAppearanceChanging = true;
end

function ArtifactPerksMixin:RefreshModel()
	local itemID, altItemID, _, _, _, _, _, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetArtifactInfo();
	local _, _, _, _, _, _, uiCameraID, altHandUICameraID, _, _, _, modelAlpha, modelDesaturation = C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID);

	self.Model.uiCameraID = uiCameraID;
	self.Model.desaturation = modelDesaturation;
	if itemAppearanceID then
		self.Model:SetItemAppearance(itemAppearanceID);
	else
		self.Model:SetItem(itemID, appearanceModID);
	end

	self.Model.BackgroundFront:SetAlpha(1.0 - (modelAlpha or 1.0));

	self.Model:SetModelDrawLayer(altOnTop and "BORDER" or "ARTWORK");
	self.AltModel:SetModelDrawLayer(altOnTop and "ARTWORK" or "BORDER");

	if altItemID and altHandUICameraID then
		self.AltModel.uiCameraID = altHandUICameraID;
		self.AltModel.desaturation = modelDesaturation;
		if altItemAppearanceID then
			self.AltModel:SetItemAppearance(altItemAppearanceID);
		else
			self.AltModel:SetItem(altItemID, appearanceModID);
		end

		self.AltModel:Show();
	else
		self.AltModel:Hide();
	end
end

function ArtifactsModelTemplate_OnModelLoaded(self)
	local CUSTOM_ANIMATION_SEQUENCE = 213;
	local animationSequence = self:HasAnimation(CUSTOM_ANIMATION_SEQUENCE) and CUSTOM_ANIMATION_SEQUENCE or 0;

	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
	self:SetLight(true, false, 0, 0, 0, .7, 1.0, 1.0, 1.0);
	self:SetViewTranslation(-88, 0);
	self:SetViewInsets(88, 88, 0, 0);
				
	self:SetDesaturation(self.desaturation or .5);

	self:SetAnimation(animationSequence, 0);
end

function ArtifactPerksMixin:RefreshBackground()
	local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
	if artifactArtInfo and artifactArtInfo.textureKit then
		self.textureKit = artifactArtInfo.textureKit;

		local bgAtlas = ("%s-BG"):format(artifactArtInfo.textureKit);
		self.BackgroundBack:SetAtlas(bgAtlas);
		self.Model.BackgroundFront:SetAtlas(bgAtlas);

		local crestAtlas = ("%s-BG-Rune"):format(artifactArtInfo.textureKit);
		self.Tier2Crest:SetAtlas(crestAtlas, true);
	else
		self.textureKit = nil;
	end
end

function ArtifactPerksMixin:OnUpdate(elapsed)
	self:TryRefresh();
end

function ArtifactPerksMixin:AreAllGoldMedalsPurchasedByTier(tier)
	return self.areAllGoldMedalsPurchasedByTier[tier] == nil or self.areAllGoldMedalsPurchasedByTier[tier];
end

function ArtifactPerksMixin:AreAllPowersPurchasedByTier(tier)
	return self.areAllPowersPurchasedByTier[tier] == nil or self.areAllPowersPurchasedByTier[tier];
end

function ArtifactPerksMixin:GetStartingPowerButtonByTier(tier)
	return self.startingPowerButtonsByTier[tier];
end

function ArtifactPerksMixin:GetFinalPowerButtonByTier(tier)
	return self.finalPowerButtonsByTier[tier];
end

function ArtifactPerksMixin:RefreshPowers(newItem)
	self.powerButtonPool:ReleaseAll();

	if newItem or not self.powerIDToPowerButton then
		self.powerIDToPowerButton = {};
	end

	local currentTier = C_ArtifactUI.GetArtifactTier();
	self.startingPowerButtonsByTier = {};
	self.finalPowerButtonsByTier = {};
	self.areAllPowersPurchasedByTier = {};
	self.areAllGoldMedalsPurchasedByTier = {};

	local powers = C_ArtifactUI.GetPowers();

	for i, powerID in ipairs(powers) do
		local powerButton = self.powerIDToPowerButton[powerID];

		if not powerButton then
			powerButton = self.powerButtonPool:Acquire();
			self.powerIDToPowerButton[powerID] = powerButton;

			powerButton:ClearOldData();
		end

		powerButton:SetupButton(powerID, self.BackgroundBack, self.textureKit);
		powerButton.links = {};
		powerButton.owner = self;

		if powerButton:IsStart() then
			self.startingPowerButtonsByTier[powerButton:GetTier()] = powerButton;
		elseif powerButton:IsFinal() then
			self.finalPowerButtonsByTier[powerButton:GetTier()] = powerButton;
		elseif not powerButton:IsCompletelyPurchased() then
			self.areAllPowersPurchasedByTier[powerButton:GetTier()] = false;
			if powerButton:IsGoldMedal() then
				self.areAllGoldMedalsPurchasedByTier[powerButton:GetTier()] = false;
			end
		end

		local meetsTier = currentTier >= powerButton:GetTier();
		powerButton:SetShown(meetsTier);
		powerButton:SetLinksEnabled(meetsTier and not powerButton:IsFinal());
	end

	self:RefreshPowerTiers();
	self:RefreshDependencies(powers);
	self:RefreshRelics();
end

function ArtifactPerksMixin:RefreshFinalPowerForTier(tier, isUnlocked)
	local finalTierButton = self:GetFinalPowerButtonByTier(tier);
	if finalTierButton then
		if isUnlocked then
			if self.wasFinalPowerButtonUnlockedByTier[tier] == false then
				self.wasFinalPowerButtonUnlockedByTier[tier] = true;
				finalTierButton:PlayUnlockAnimation();
			end
		else
			finalTierButton:Hide();
			self.wasFinalPowerButtonUnlockedByTier[tier] = false;
		end
	end
end

function ArtifactPerksMixin:RefreshPowerTiers()
	self:RefreshFinalPowerForTier(1, self:AreAllGoldMedalsPurchasedByTier(1));
	self:RefreshFinalPowerForTier(2, self:AreAllPowersPurchasedByTier(2));

	if C_ArtifactUI.GetArtifactTier() >= 2 then
		local finalTier2Button = self:GetFinalPowerButtonByTier(2);
		if finalTier2Button then
			self.Tier2Crest:ClearAllPoints();
			self.Tier2Crest:SetPoint("CENTER", finalTier2Button, "CENTER");
			self.Tier2Crest:Show();

			local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();

			self.Tier2ModelScene:Show();
			self.Tier2ModelScene:SetFromModelSceneID(artifactArtInfo.uiModelSceneID, true);
		
			local effect = self.Tier2ModelScene:GetActorByTag("effect");
			if ( effect ) then
				effect:SetModelByCreatureDisplayID(11686);
				effect:ApplySpellVisualKit(artifactArtInfo.spellVisualKitID);
			end
		else
			self.Tier2Crest:Hide();
			self.Tier2ModelScene:Hide();
		end
	else
		self.Tier2Crest:Hide();
		self.Tier2ModelScene:Hide();
	end
end

function ArtifactPerksMixin:GetOrCreateDependencyLine(lineIndex)
	local lineContainer = self.DependencyLines and self.DependencyLines[lineIndex];
	if lineContainer then
		lineContainer:Show();
		return lineContainer;
	end

	lineContainer = CreateFrame("FRAME", nil, self, "ArtifactDependencyLineTemplate");

	return lineContainer;
end

function ArtifactPerksMixin:GetOrCreateCurvedDependencyLine(lineIndex)
	local lineContainer = self.CurvedDependencyLines and self.CurvedDependencyLines[lineIndex];
	if lineContainer then
		lineContainer:Show();
		return lineContainer;
	end

	lineContainer = CreateFrame("FRAME", nil, self, "ArtifactCurvedDependencyLineTemplate");

	return lineContainer;
end

function ArtifactPerksMixin:HideUnusedWidgets(widgetTable, numUsed, customHideFunc)
	if widgetTable then
		for i = numUsed + 1, #widgetTable do
			widgetTable[i]:Hide();
			if customHideFunc then
				customHideFunc(widgetTable[i]);
			end
		end
	end
end

function ArtifactPerksMixin:TryRefresh()
	if self.perksDirty then
		if self.newItem then
			self.numRevealsPlaying = nil;
			self:HideAllLines();
			self:RefreshBackground();
		end

		if self.newItem or self.isAppearanceChanging then
			self:RefreshModel();
		end

		self.queuePlayingReveal = false;
		local hasBoughtAnyPowers = C_ArtifactUI.GetTotalPurchasedRanks() > 0;
		if self.newItem then
			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
			self.wasFinalPowerButtonUnlockedByTier = {};
		elseif self.hasBoughtAnyPowers ~= hasBoughtAnyPowers then
			self:HideAllLines();

			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
			if hasBoughtAnyPowers then
				self.queuePlayingReveal = true;
			end
		end

		self:RefreshPowers(self.newItem);
		
		self.TitleContainer:SetPointsRemaining(C_ArtifactUI.GetPointsRemaining());

		self.perksDirty = false;
		self.newItem = nil;
		self.isAppearanceChanging = nil;
		if self.queuePlayingReveal then
			self:PlayReveal();
		end
	end
end

function ArtifactPerksMixin:Refresh(newItem)
	self.perksDirty = true;
	self.newItem = self.newItem or newItem;
end

ArtifactLineMixin = {};

ArtifactLineMixin.LINE_STATE_CONNECTED = 1;
ArtifactLineMixin.LINE_STATE_DISCONNECTED = 2;
ArtifactLineMixin.LINE_STATE_LOCKED = 3;

ArtifactLineMixin.LINE_FADE_ANIM_TYPE_CONNECTED = 1;
ArtifactLineMixin.LINE_FADE_ANIM_TYPE_UNLOCKED = 2;
ArtifactLineMixin.LINE_FADE_ANIM_TYPE_LOCKED = 3;

function ArtifactLineMixin:SetState(lineState)
	if lineState == self.LINE_STATE_CONNECTED then
		self:SetConnected();
	elseif lineState == self.LINE_STATE_DISCONNECTED then
		self:SetDisconnected();
	elseif lineState == self.LINE_STATE_LOCKED then
		self:SetLocked();
	end
end

function ArtifactLineMixin:SetConnected()
	self.Fill:SetVertexColor(self.connectedColor:GetRGB());
	self.FillScroll1:SetVertexColor(self.connectedColor:GetRGB());
	if self.FillScroll2 then
		self.FillScroll2:SetVertexColor(self.connectedColor:GetRGB());
	end

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_CONNECTED);
end

function ArtifactLineMixin:SetDisconnected()
	self.Fill:SetVertexColor(self.disconnectedColor:GetRGB());

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_UNLOCKED);
end

function ArtifactLineMixin:SetLocked()
	self.Fill:SetVertexColor(self.connectedColor:GetRGB());

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_LOCKED);
end

function ArtifactLineMixin:PlayLineFadeAnim(lineAnimType)
	self.FadeAnim:Finish();

	self.FadeAnim.Background:SetFromAlpha(self.Background:GetAlpha());
	self.FadeAnim.Fill:SetFromAlpha(self.Fill:GetAlpha());
	self.FadeAnim.FillScroll1:SetFromAlpha(self.FillScroll1:GetAlpha());
	if self.FillScroll2 then
		self.FadeAnim.FillScroll2:SetFromAlpha(self.FillScroll2:GetAlpha());
	end

	if lineAnimType == self.LINE_FADE_ANIM_TYPE_CONNECTED then
		self.ScrollAnim:Play(false, self.scrollElapsedOffset);

		self.FadeAnim.Background:SetToAlpha(0.0);
		self.FadeAnim.Fill:SetToAlpha(1.0);
		self.FadeAnim.FillScroll1:SetToAlpha(1.0);
		if self.FillScroll2 then
			self.FadeAnim.FillScroll2:SetToAlpha(1.0);
		end
	elseif lineAnimType == self.LINE_FADE_ANIM_TYPE_UNLOCKED then
		self.ScrollAnim:Stop();

		self.FadeAnim.Background:SetToAlpha(1.0);
		self.FadeAnim.Fill:SetToAlpha(1.0);
		self.FadeAnim.FillScroll1:SetToAlpha(0.0);
		if self.FillScroll2 then
			self.FadeAnim.FillScroll2:SetToAlpha(0.0);
		end

	elseif lineAnimType == self.LINE_FADE_ANIM_TYPE_LOCKED then
		self.ScrollAnim:Stop();

		self.FadeAnim.Background:SetToAlpha(0.85);
		self.FadeAnim.Fill:SetToAlpha(0.0);
		self.FadeAnim.FillScroll1:SetToAlpha(0.0);
		if self.FillScroll2 then
			self.FadeAnim.FillScroll2:SetToAlpha(0.0);
		end
	end
	self.animType = lineAnimType;
	self.FadeAnim:Play();
end

function ArtifactLineMixin:SetEndPoints(fromButton, toButton)
	if self.IsCurved then
		self.Fill:SetSize(2, 2);
		self.Fill:ClearAllPoints();
		self.Fill:SetPoint("CENTER", fromButton);

		self.Background:SetSize(2, 2);
		self.Background:ClearAllPoints();
		self.Background:SetPoint("CENTER", fromButton);

		self.FillScroll1:SetSize(2, 2);
		self.FillScroll1:ClearAllPoints();
		self.FillScroll1:SetPoint("CENTER", fromButton);
	else
		self.Fill:SetStartPoint("CENTER", fromButton);
		self.Fill:SetEndPoint("CENTER", toButton);

		self.Background:SetStartPoint("CENTER", fromButton);
		self.Background:SetEndPoint("CENTER", toButton);

		self.FillScroll1:SetStartPoint("CENTER", fromButton);
		self.FillScroll1:SetEndPoint("CENTER", toButton);

		self.FillScroll2:SetStartPoint("CENTER", fromButton);
		self.FillScroll2:SetEndPoint("CENTER", toButton);
	end
end

function ArtifactLineMixin:SetConnectedColor(color)
	self.connectedColor = color;
end

function ArtifactLineMixin:SetDisconnectedColor(color)
	self.disconnectedColor = color;
end

do
	local function OnLineRevealFinished(animGroup)
		local lineContainer = animGroup:GetParent();
		if lineContainer.animType then
			lineContainer:PlayLineFadeAnim(lineContainer.animType);
		end
	end

	function ArtifactLineMixin:BeginReveal(delay, duration)
		if not self.RevealAnim then
			return;
		end
		self.FadeAnim:Stop();
		self.ScrollAnim:Stop();

		self.Background:SetAlpha(0.0);
		self.Fill:SetAlpha(0.0);
		self.FillScroll1:SetAlpha(0.0);
		self.FillScroll2:SetAlpha(0.0);

		self.RevealAnim.Start1:SetEndDelay(delay);
		self.RevealAnim.Start2:SetEndDelay(delay);

		self.RevealAnim.LineScale:SetDuration(duration);

		self.RevealAnim:SetScript("OnFinished", OnLineRevealFinished);
		self.RevealAnim:Play();
	end
end

function ArtifactLineMixin:IsRevealing()
	return self.RevealAnim and self.RevealAnim:IsPlaying();
end

function ArtifactLineMixin:GetRevealDelay()
	return self.RevealAnim and self.RevealAnim.Start1:GetEndDelay() or 0.0;
end

function ArtifactLineMixin:SetScrollAnimationProgressOffset(progress)
	self.scrollElapsedOffset = progress * self.ScrollAnim:GetDuration();
end

function ArtifactLineMixin:CalculateTiling(length)
	local TEXTURE_WIDTH = 128;
	local tileAmount = length / TEXTURE_WIDTH;
	self.Fill:SetTexCoord(0, tileAmount, 0, 1);
	self.Background:SetTexCoord(0, tileAmount, 0, 1);
	self.FillScroll1:SetTexCoord(0, tileAmount, 0, 1);
	if self.FillScroll2 then
		self.FillScroll2:SetTexCoord(0, tileAmount, 0, 1);
	end
end

function ArtifactLineMixin:SetVertexOffset(vertexIndex, x, y)
	self.Fill:SetVertexOffset(vertexIndex, x, y);
	self.Background:SetVertexOffset(vertexIndex, x, y);
	self.FillScroll1:SetVertexOffset(vertexIndex, x, y);
	if self.FillScroll2 then
		self.FillScroll2:SetVertexOffset(vertexIndex, x, y);
	end
end

function ArtifactLineMixin:OnReleased()
	self.animType = nil;
	self.ScrollAnim:Stop();
	self.FadeAnim:Stop();
	if self.RevealAnim then
		self.RevealAnim:Stop();
	end

	self.Background:SetAlpha(0.0);
	self.Fill:SetAlpha(0.0);
	self.FillScroll1:SetAlpha(0.0);
	if self.FillScroll2 then
		self.FillScroll2:SetAlpha(0.0);
	end
end

local function OnUnusedLineHidden(lineContainer)
	lineContainer:OnReleased();
end

function ArtifactPerksMixin:GenerateCurvedLine(startButton, endButton, state, artifactArtInfo)
	local finalTier2Power = self:GetFinalPowerButtonByTier(2);
	if not finalTier2Power then
		return;
	end

	local spline = CreateCatmullRomSpline(2);

	local finalPosition = CreateVector2D(finalTier2Power:GetCenter());
	local startPosition = CreateVector2D(startButton:GetCenter());
	local endPosition = CreateVector2D(endButton:GetCenter());

	local angleOffset = math.atan2(finalPosition.y - startPosition.y, startPosition.x - finalPosition.x);

	local totalAngle = Vector2D_CalculateAngleBetween(endPosition.x - finalPosition.x, endPosition.y - finalPosition.y, startPosition.x - finalPosition.x, startPosition.y - finalPosition.y);
	if totalAngle <= 0 then
		return;
	end

	local lengthToEdge = Vector2D_GetLength(Vector2D_Subtract(finalPosition.x, finalPosition.y, endPosition.x, endPosition.y));

	-- Catmullrom splines are not quadratic so they cannot perfectly fit a circle, add enough points so that the sampling will produce something close enough to a circle
	-- Keeping this as a spline for now in case we need to connect something non-circular
	local NUM_SLICES = 10;
	for angle = 0, totalAngle, totalAngle / NUM_SLICES do
		local x = math.cos(angle + angleOffset) * lengthToEdge;
		local y = math.sin(angle + angleOffset) * lengthToEdge;
		spline:AddPoint(x, y);
	end

	local NUM_SEGEMENTS = 20;
	local previousEndPoint;
	local previousLineContainer;
	for i = 1, NUM_SEGEMENTS do
		self.numUsedCurvedLines = self.numUsedCurvedLines + 1;
		local lineContainer = self:GetOrCreateCurvedDependencyLine(self.numUsedCurvedLines);
		lineContainer:SetConnectedColor(artifactArtInfo.barConnectedColor);
		lineContainer:SetDisconnectedColor(artifactArtInfo.barDisconnectedColor);
		lineContainer:SetEndPoints(finalTier2Power);
		lineContainer:SetScrollAnimationProgressOffset((i - 1) / NUM_SEGEMENTS);
		lineContainer:SetState(state);

		local fromPoint = previousEndPoint or CreateVector2D(spline:CalculatePointOnGlobalCurve(0.0));
		local toPoint = CreateVector2D(spline:CalculatePointOnGlobalCurve(i / NUM_SEGEMENTS));

		local delta = toPoint:Clone();
		delta:Subtract(fromPoint);

		local length = delta:GetLength();
		lineContainer:CalculateTiling(length);

		local thickness = CreateVector2D(-delta.y, delta.x);
		thickness:DivideBy(length);

		local THICKNESS = 10;
		thickness:ScaleBy(THICKNESS);

		if previousLineContainer then
			-- We're in the middle or the last piece, connect the start of this to the end of the last

			-- Making these meet by dividing the tangent (miter) would look better, but seems good enough for this scale
			previousLineContainer:SetVertexOffset(UPPER_RIGHT_VERTEX, fromPoint.x + thickness.x - 1, -1 - (fromPoint.y + thickness.y));
			previousLineContainer:SetVertexOffset(LOWER_RIGHT_VERTEX, fromPoint.x - thickness.x - 1, 1 - (fromPoint.y - thickness.y));

			lineContainer:SetVertexOffset(UPPER_LEFT_VERTEX, fromPoint.x + thickness.x + 1, -1 - (fromPoint.y + thickness.y));
			lineContainer:SetVertexOffset(LOWER_LEFT_VERTEX, fromPoint.x - thickness.x + 1, 1 - (fromPoint.y - thickness.y));

			if i == NUM_SEGEMENTS then
				-- Last piece, just go ahead and just connect the line to the end now
				lineContainer:SetVertexOffset(UPPER_RIGHT_VERTEX, toPoint.x + thickness.x - 1, -1 - (toPoint.y + thickness.y));
				lineContainer:SetVertexOffset(LOWER_RIGHT_VERTEX, toPoint.x - thickness.x - 1, 1 - (toPoint.y - thickness.y));
			end
		else
			-- First piece, just connect the start
			lineContainer:SetVertexOffset(UPPER_LEFT_VERTEX, fromPoint.x + thickness.x + 1, -1 - (fromPoint.y + thickness.y));
			lineContainer:SetVertexOffset(LOWER_LEFT_VERTEX, fromPoint.x - thickness.x + 1, 1 - (fromPoint.y - thickness.y));
		end

		previousLineContainer = lineContainer;
		previousEndPoint = toPoint;
	end
end

function ArtifactPerksMixin:RefreshDependencies(powers)
	self.numUsedLines = 0;
	self.numUsedCurvedLines = 0;

	if ArtifactUI_CanViewArtifact() then
		local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
		local lastTier2Power = nil;

		for i, fromPowerID in ipairs(powers) do
			local fromButton = self.powerIDToPowerButton[fromPowerID];
			local fromLinks = C_ArtifactUI.GetPowerLinks(fromPowerID);
			if fromLinks then
				for j, toPowerID in ipairs(fromLinks) do
					local toButton = self.powerIDToPowerButton[toPowerID];
					if self:GetFinalPowerButtonByTier(2) == toButton then
						lastTier2Power = fromButton;
					end
					if not fromButton.links[toPowerID] and fromButton:AreLinksEnabled() then
						if toButton and not toButton.links[fromPowerID] and toButton:AreLinksEnabled() then
							if (not fromButton:GetLinearIndex() or not toButton:GetLinearIndex()) or fromButton:GetLinearIndex() < toButton:GetLinearIndex() then
								local state;
								if self.hasBoughtAnyPowers or ((toButton:IsStart() or toButton:ArePrereqsMet()) and (fromButton:IsStart() or fromButton:ArePrereqsMet())) then
									local hasSpentAny = fromButton.hasSpentAny and toButton.hasSpentAny;
									if hasSpentAny or (fromButton:IsActiveForLinks() and (toButton.couldSpendPoints or toButton:IsCompletelyPurchased())) or (toButton:IsActiveForLinks() and (fromButton.couldSpendPoints or fromButton:IsCompletelyPurchased())) then
										if (fromButton:IsActiveForLinks() and toButton.hasSpentAny) or (toButton:IsActiveForLinks() and fromButton.hasSpentAny) then
											state = ArtifactLineMixin.LINE_STATE_CONNECTED;
										else
											state = ArtifactLineMixin.LINE_STATE_DISCONNECTED;
										end
									else
										state = ArtifactLineMixin.LINE_STATE_LOCKED;
									end
								end

								if fromButton:GetTier() == 2 and toButton:GetTier() == 2 then
									self:GenerateCurvedLine(fromButton, toButton, state, artifactArtInfo);
								else
									self.numUsedLines = self.numUsedLines + 1;
									local lineContainer = self:GetOrCreateDependencyLine(self.numUsedLines);
									lineContainer:SetConnectedColor(artifactArtInfo.barConnectedColor);
									lineContainer:SetDisconnectedColor(artifactArtInfo.barDisconnectedColor);

									local fromCenter = CreateVector2D(fromButton:GetCenter());
									fromCenter:ScaleBy(fromButton:GetEffectiveScale());

									local toCenter = CreateVector2D(toButton:GetCenter());
									toCenter:ScaleBy(toButton:GetEffectiveScale());

									toCenter:Subtract(fromCenter);

									lineContainer:CalculateTiling(toCenter:GetLength());

									lineContainer:SetEndPoints(fromButton, toButton);
									lineContainer:SetScrollAnimationProgressOffset(0);
				
									lineContainer:SetState(state);
								end

								fromButton.links[toPowerID] = true;
								toButton.links[fromPowerID] = true;
							end
						end
					end
				end
			end
		end

		-- Artificially link the starting and last power if they're both purchased to complete the circle
		if lastTier2Power and lastTier2Power:IsCompletelyPurchased() then
			local startingTier2Power = self:GetStartingPowerButtonByTier(2);
			if startingTier2Power and startingTier2Power:IsCompletelyPurchased() and not startingTier2Power.links[lastTier2Power:GetPowerID()] then
				self:GenerateCurvedLine(lastTier2Power, startingTier2Power, ArtifactLineMixin.LINE_STATE_CONNECTED, artifactArtInfo);

				lastTier2Power.links[startingTier2Power:GetPowerID()] = true;
				startingTier2Power.links[lastTier2Power:GetPowerID()] = true;
			end
		end
	end

	self:HideUnusedWidgets(self.DependencyLines, self.numUsedLines, OnUnusedLineHidden);
	self:HideUnusedWidgets(self.CurvedDependencyLines, self.numUsedCurvedLines, OnUnusedLineHidden);
end

local function RelicRefreshHelper(self, relicSlotIndex, powersAffected, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		powersAffected[powerID] = true;
		self:AddRelicToPower(powerID, relicSlotIndex);
	end
end

function ArtifactPerksMixin:RefreshRelics()
	local powersAffected = {};
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		RelicRefreshHelper(self, relicSlotIndex, powersAffected, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
	end

	for powerID, button in pairs(self.powerIDToPowerButton) do
		if not powersAffected[powerID] then
			button:RemoveRelicType();
		end
	end
end

function ArtifactPerksMixin:AddRelicToPower(powerID, relicSlotIndex)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		local relicType = C_ArtifactUI.GetRelicSlotType(relicSlotIndex);
		local relicName, relicIcon, _, relicLink = C_ArtifactUI.GetRelicInfo(relicSlotIndex);
		button:ApplyRelicType(relicType, relicLink, self.newItem);
	end
end

local function RelicHighlightHelper(self, highlightEnabled, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled);
	end
end

local function RelicMouseOverHighlightHelper(self, highlightEnabled, tempRelicType, tempRelicLink, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled, tempRelicType, tempRelicLink);
	end
end

function ArtifactPerksMixin:OnRelicSlotMouseEnter(relicSlotIndex)
	RelicHighlightHelper(self, true, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
end

function ArtifactPerksMixin:OnRelicSlotMouseLeave(relicSlotIndex)
	RelicHighlightHelper(self, false, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));

	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:ShowHighlightForRelicItemID(itemID)
	local couldFitInAnySlot = false;
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		if C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex) then
			couldFitInAnySlot = true;
			break;
		end
	end

	if couldFitInAnySlot then
		local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfoByItemID(itemID);
		RelicMouseOverHighlightHelper(self, true, relicType, relicLink, C_ArtifactUI.GetPowersAffectedByRelicItemID(itemID));
	end
end

function ArtifactPerksMixin:HideHighlightForRelicItemID(itemID)
	RelicMouseOverHighlightHelper(self, false, nil, nil, C_ArtifactUI.GetPowersAffectedByRelicItemID(itemID));
end

function ArtifactPerksMixin:RefreshCursorHighlights()
	local type, itemID = GetCursorInfo();
	if type == "item" and IsArtifactRelicItem(itemID) then
		self:HideHighlightForRelicItemID(itemID);
	end
end

function ArtifactPerksMixin:OnCursorUpdate()
	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:SetRelicPowerHighlightEnabled(powerID, highlight, tempRelicType, tempRelicLink)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		if highlight and tempRelicType and tempRelicLink then
			button:ApplyTemporaryRelicType(tempRelicType, tempRelicLink);
		else
			button:RemoveTemporaryRelicType();
		end
		button:SetRelicHighlightEnabled(highlight);
	end
end

function ArtifactPerksMixin:HideAllLines()
	self:HideUnusedWidgets(self.DependencyLines, 0, OnUnusedLineHidden);
end

ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE = .005;
ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE = .0019;

local function QueueReveal(self, powerButton, distance)
	if powerButton:IsStart() or powerButton:QueueRevealAnimation(distance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE) then
		for linkedPowerID, linkedLineContainer in pairs(powerButton.links) do
			local linkedPowerButton = self.powerIDToPowerButton[linkedPowerID];
			
			if linkedPowerButton.hasSpentAny then
				QueueReveal(self, linkedPowerButton, distance);
			else 
				local distanceToLink = powerButton:CalculateDistanceTo(linkedPowerButton);
				local totalDistance = distance + distanceToLink;

				QueueReveal(self, linkedPowerButton, totalDistance);

				local delay = powerButton:IsStart() and .1 or totalDistance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE;
				if not linkedLineContainer:IsRevealing() or delay < linkedLineContainer:GetRevealDelay() then
					linkedLineContainer:BeginReveal(delay, distanceToLink * ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE);
				end
			end
		end
	end
end

local function OnRevealFinished(powerButton)
	powerButton.owner:OnRevealAnimationFinished(powerButton);
end

function ArtifactPerksMixin:PlayReveal()
	if self:GetStartingPowerButtonByTier(1) and not self.numRevealsPlaying then
		self.numRevealsPlaying = 0;

		QueueReveal(self, self:GetStartingPowerButtonByTier(1), 0);

		for powerID, powerButton in pairs(self.powerIDToPowerButton) do
			if powerButton:IsShown() and powerButton:PlayRevealAnimation(OnRevealFinished) then
				powerButton:SetLocked(true);
				self.numRevealsPlaying = self.numRevealsPlaying + 1;
			end
		end

		PlaySound("UI_70_Artifact_Forge_Trait_FirstTrait");
	end
end

function ArtifactPerksMixin:OnRevealAnimationFinished(powerButton)
	if self.numRevealsPlaying then
		self.numRevealsPlaying = self.numRevealsPlaying - 1;
		if self.numRevealsPlaying == 0 then
			self.numRevealsPlaying = nil;
			for powerID, powerButton in pairs(self.powerIDToPowerButton) do
				powerButton:SetLocked(false);
			end
		end
	end
end

------------------------------------------------------------------
--   ArtifactTitleTemplate
------------------------------------------------------------------


ArtifactTitleTemplateMixin = {}

function ArtifactTitleTemplateMixin:RefreshTitle()
	self.PointsRemainingLabel:SnapToTarget();

	local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
	self.ArtifactName:SetText(artifactArtInfo.titleName);
	self.ArtifactName:SetVertexColor(artifactArtInfo.titleColor:GetRGB());

	if artifactArtInfo.textureKit then
		local headerAtlas = ("%s-Header"):format(artifactArtInfo.textureKit);
		self.Background:SetAtlas(headerAtlas, true);
		self.Background:Show();
	else
		self.Background:Hide();
	end
end

function ArtifactTitleTemplateMixin:OnShow()
	self:RefreshTitle();
	self:EvaluateRelics();

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("CURSOR_UPDATE");
end

function ArtifactTitleTemplateMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_UPDATE");
	self:UnregisterEvent("CURSOR_UPDATE");
	StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
end

function ArtifactTitleTemplateMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		local newItem = ...;
		if newItem then
			self:RefreshTitle();
		end
		self:EvaluateRelics();
		self:RefreshRelicTooltips();
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	end
end

function ArtifactTitleTemplateMixin:OnCursorUpdate()
	if not CursorHasItem() then
		StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
	end

	self:RefreshCursorRelicHighlights();
end

function ArtifactTitleTemplateMixin:RefreshCursorRelicHighlights()
	local type, itemID = GetCursorInfo();
	self:RefreshRelicHighlights(itemID);
end

function ArtifactTitleTemplateMixin:RefreshRelicHighlights(itemID)
	for relicSlotIndex in ipairs(self.RelicSlots) do
		self:SetRelicSlotHighlighted(relicSlotIndex, itemID and C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex));
	end
end

function ArtifactTitleTemplateMixin:SetRelicSlotHighlighted(relicSlotIndex, highlighted)
	local relicSlot = self.RelicSlots[relicSlotIndex];
	if relicSlot:IsShown() then
		if highlighted then
			relicSlot:LockHighlight();
			relicSlot.CanSlotAnim:Play();
			relicSlot.HighlightTexture:Show();
		else
			relicSlot:UnlockHighlight();
			relicSlot.CanSlotAnim:Stop();
			relicSlot.HighlightTexture:Hide();
		end
	end
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseEnter(relicSlot)
	if relicSlot.lockedReason then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(LOCKED_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			if relicSlot.lockedReason == "" then
				GameTooltip:AddLine(LOCKED_RELIC_TOOLTIP_BODY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			else
				GameTooltip:AddLine(relicSlot.lockedReason, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
		end
	elseif relicSlot.relicLink then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		GameTooltip:SetHyperlink(relicSlot.relicLink);
	elseif relicSlot.relicType then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(EMPTY_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			GameTooltip:AddLine(EMPTY_RELIC_TOOLTIP_BODY:format(slotName), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			GameTooltip:Show();
		end
	end
	self:GetParent():OnRelicSlotMouseEnter(relicSlot.relicSlotIndex);
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseLeave(relicSlot)
	GameTooltip_Hide();
	self:GetParent():OnRelicSlotMouseLeave(relicSlot.relicSlotIndex);
end

StaticPopupDialogs["CONFIRM_RELIC_REPLACE"] = {
	text = CONFIRM_ACCEPT_RELIC,
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, relicSlotIndex)
		C_ArtifactUI.ApplyCursorRelicToSlot(relicSlotIndex);
		ArtifactFrame.PerksTab.TitleContainer.RelicSlots[relicSlotIndex].GlowAnim:Play();
		PlaySound("UI_70_Artifact_Forge_Relic_Place");
	end,
	OnCancel = function()
		ClearCursor();
	end,

	showAlert = true,
	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

function ArtifactTitleTemplateMixin:OnRelicSlotClicked(relicSlot)
	for i = 1, #self.RelicSlots do
		if self.RelicSlots[i] == relicSlot then
			if C_ArtifactUI.CanApplyCursorRelicToSlot(i) then
				local itemName = C_ArtifactUI.GetRelicInfo(i);
				if itemName then
					StaticPopup_Show("CONFIRM_RELIC_REPLACE", nil, nil, i);
				else
					C_ArtifactUI.ApplyCursorRelicToSlot(i);
					self.RelicSlots[i].GlowAnim:Play();
					PlaySound("UI_70_Artifact_Forge_Relic_Place");
				end
			else
				local _, itemID = GetCursorInfo();
				if itemID and IsArtifactRelicItem(itemID) then
					UIErrorsFrame:AddMessage(RELIC_SLOT_INVALID, 1.0, 0.1, 0.1, 1.0);
				else
					if IsModifiedClick() then
						local _, _, _, itemLink = C_ArtifactUI.GetRelicInfo(i);
						HandleModifiedItemClick(itemLink);
					end
				end
			end
			break;
		end
	end
end

function ArtifactTitleTemplateMixin:RefreshRelicTooltips()
	for i = 1, #self.RelicSlots do
		if GameTooltip:IsOwned(self.RelicSlots[i]) then
			self.RelicSlots[i]:GetScript("OnEnter")(self.RelicSlots[i]);
			break;
		end
	end
end

function ArtifactTitleTemplateMixin:EvaluateRelics()
	local numRelicSlots = ArtifactUI_CanViewArtifact() and C_ArtifactUI.GetNumRelicSlots() or 0;

	self:SetExpandedState(numRelicSlots > 0);

	for i = 1, numRelicSlots do
		local relicSlot = self.RelicSlots[i];

		local relicType = C_ArtifactUI.GetRelicSlotType(i);

		local relicAtlasName = ("Relic-%s-Slot"):format(relicType);
		relicSlot:GetNormalTexture():SetAtlas(relicAtlasName, true);
		relicSlot:GetHighlightTexture():SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder1:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder2:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder3:SetAtlas(relicAtlasName, true);
		local lockedReason = C_ArtifactUI.GetRelicLockedReason(i);
		if lockedReason then
			relicSlot:GetNormalTexture():SetAlpha(.5);
			relicSlot:Disable();
			relicSlot.LockedIcon:Show();
			relicSlot.Icon:SetMask(nil);
			relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
			relicSlot.Glass:Hide();
			relicSlot.relicLink = nil;
		else
			local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfo(i);

			relicSlot:GetNormalTexture():SetAlpha(1);
			relicSlot:Enable();
			relicSlot.LockedIcon:Hide();
			if relicIcon then
				relicSlot.Icon:SetSize(34, 34);
				relicSlot.Icon:SetMask(nil);
				relicSlot.Icon:SetTexCoord(0, 1, 0, 1); -- Masks may overwrite our tex coords (even ones set by an atlas), force it back to using the full item icon texture
				relicSlot.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				relicSlot.Icon:SetTexture(relicIcon);
				relicSlot.Glass:Show();

				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH, true);
				ArtifactRelicHelpBox:Hide();
			else
				relicSlot.Icon:SetMask(nil);
				relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
				relicSlot.Glass:Hide();
			end
			relicSlot.relicLink = relicLink;
		end

		
		relicSlot.relicType = relicType;
		relicSlot.relicSlotIndex = i;
		relicSlot.lockedReason = lockedReason;
		
		relicSlot:ClearAllPoints();
		local PADDING = 0;
		if i == 1 then
			local offsetX = -(numRelicSlots - 1) * (relicSlot:GetWidth() + PADDING) * .5;
			relicSlot:SetPoint("CENTER", self, "CENTER", offsetX, -6);
		else
			relicSlot:SetPoint("LEFT", self.RelicSlots[i - 1], "RIGHT", PADDING, 0);
		end

		relicSlot:Show();
	end

	for i = numRelicSlots + 1, #self.RelicSlots do
		self.RelicSlots[i]:Hide();
	end
end

function ArtifactTitleTemplateMixin:SetPointsRemaining(value)
	self.PointsRemainingLabel:SetAnimatedValue(value);
end

function ArtifactTitleTemplateMixin:OnUpdate(elapsed)
	self.PointsRemainingLabel:UpdateAnimatedValue(elapsed);
end

function ArtifactTitleTemplateMixin:SetExpandedState(expanded)
	if self.expanded ~= expanded then
		self.expanded = expanded;

		self:SetHeight(self.expanded and 140 or 90);
	end
end