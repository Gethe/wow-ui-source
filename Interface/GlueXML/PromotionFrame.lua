local DELAYED_PROMO_INFO;

function PromotionFrame_OnLoad(self)
	self:RegisterEvent("DISPLAY_PROMOTION");
	self:RegisterEvent("ACCOUNT_DATA_INITIALIZED");
end

function PromotionFrame_OnEvent(self, event, ...)
	if ( event == "DISPLAY_PROMOTION" ) then
		if ( CharacterSelect:IsVisible() ) then
			PromotionFrame_ReceivePromotion(self, ...);
		else
			DELAYED_PROMO_INFO = {...};
		end
	elseif ( event == "ACCOUNT_DATA_INITIALIZED" ) then
		self.receivingMsg = true;
		if ( CharacterSelect:IsVisible() ) then
			PromotionFrame_AwaitingPromotion();
		end
	end
end

function PromotionFrame_AwaitingPromotion()
	local self = PromotionFrame;
	if ( DELAYED_PROMO_INFO ) then
		--We received this info earlier, just display it
		PromotionFrame_ReceivePromotion(PromotionFrame, unpack(DELAYED_PROMO_INFO));
		DELAYED_PROMO_INFO = nil;
	end
end

function PromotionFrame_ReceivePromotion(self, ...)
	local showPanel, promotionID, texture, logoTexture, acceptTexture, skipTexture = ...;
	if ( not HasShownTrialPopUp() ) then
		if ( showPanel and promotionID ) then
			self.promotionID = promotionID;
			self.Artwork:SetTexture(texture);
			self.Logo:SetTexture(logoTexture);
			PromotionFrameButton_SetTextures(self.UpgradeButton, acceptTexture);
			PromotionFrameButton_SetTextures(self.PlayButton, skipTexture);
			SetTrialPopUp();
			self:Show();
		elseif ( showPanel ) then
			--No special promotion, just show the default one
			SetTrialPopUp();
			StarterEditionPopUp:Show();
		end
	end
	PromotionAwaitingFrame:Hide();
	self.receivingMsg = false;
end

function PromotionFrameButton_SetTextures(button, texture)
	button:SetNormalTexture(texture);
	button:SetPushedTexture(texture);
	button:SetHighlightTexture(texture);
end

function PromotionFrame_Hide()
	PromotionFrame:Hide();
	StarterEditionPopUp:Hide();
	PromotionAwaitingFrame:Hide();
	PromotionFrame.receivingMsg = false;
end

function PromotionFrame_LaunchUpgradeURL()
	VisitPromotionURL(PromotionFrame.promotionID);
end

--Promotion awaiting frame timeout.
--We want to make sure that we don't lock the player out just because we're waiting
--on the promotion message from the server. If we go 10 seconds without getting it,
--we'll just remove the waiting frame.
function PromotionAwaitingFrame_OnShow(self)
	self.timeToAutoClose = 10;
end

function PromotionAwaitingFrame_OnUpdate(self, elapsed)
	if ( elapsed > 1 ) then
		elapsed = 0.1; --Fix a bug with a 4 second elapsed time that I don't have time to track down.
	end
	self.timeToAutoClose = self.timeToAutoClose - elapsed;
	if ( self.timeToAutoClose < 0 ) then
		self:Hide();
		PromotionFrame.receivingMsg = false;
	end
end

function StarterEditionPopUp_OnShow(self)
	local featureTable = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC);
	if featureTable then
		self.Logo:SetTexture(featureTable.logo);
	end
	
	local features = AccountUpgradePanel_GetBrownBoxFeatures();
	for i, feature in ipairs(features) do
		local frame = _G["StarterEditionPopUpFeature"..i];
		if ( not frame ) then
			frame = CreateFrame("FRAME", "StarterEditionPopUpFeature"..i, StarterEditionPopUp, "UpgradeFrameFeatureLargeTemplate");
			frame:SetPoint("TOPLEFT", _G["StarterEditionPopUpFeature"..(i-1)], "BOTTOMLEFT", 0, 0);
		end

		frame.icon:SetTexture(feature.icon);
		frame.text:SetText(feature.text);
	end
	
	local index = #features+1;
	local frame =  _G["StarterEditionPopUpFeature"..index];
	while ( frame ) do
		frame:Hide();
		index = index + 1;
		frame = _G["StarterEditionPopUpFeature"..index];
	end
end