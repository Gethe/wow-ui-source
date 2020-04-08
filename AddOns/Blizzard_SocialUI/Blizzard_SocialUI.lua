local SOCIAL_DEFAULT_FRAME_WIDTH = 388;
local SOCIAL_DEFAULT_FRAME_HEIGHT = 190;
local SOCIAL_IMAGE_FRAME_MAX_WIDTH = 640;
local SOCIAL_IMAGE_FRAME_MAX_HEIGHT = 400;
local SOCIAL_SCREENSHOT_TOOLTIP_MAX_WIDTH = 236;
local SOCIAL_SCREENSHOT_TOOLTIP_MAX_HEIGHT = 146;
local SOCIAL_IMAGE_FRAME_ASPECT_RATIO = SOCIAL_IMAGE_FRAME_MAX_WIDTH / SOCIAL_IMAGE_FRAME_MAX_HEIGHT;
local SOCIAL_SCREENSHOT_CROP_MIN_WIDTH = 100;
local SOCIAL_SCREENSHOT_CROP_MIN_HEIGHT = 100;
local SOCIAL_IMAGE_PADDING_HEIGHT = 50;
local SOCIAL_IMAGE_PADDING_WIDTH = 26;
local SOCIAL_IMAGE_TYPE_ACHIEVEMENT = 1;
local SOCIAL_IMAGE_TYPE_SCREENSHOT = 2;
local SOCIAL_IMAGE_TYPE_ITEM = 3;
local SOCIAL_OFFSCREEN_SNAPSHOT_ID = 0;
local SOCIAL_OFFSCREEN_STATE_HIDE = 0;
local SOCIAL_OFFSCREEN_STATE_SHOW_ACHIEVEMENT = 1;
local SOCIAL_OFFSCREEN_STATE_SHOW_ITEM = 2;

--------------------------------------------------------------------------------
-- SocialFrame Events
--------------------------------------------------------------------------------

function SocialPostFrame_OnLoad(self)
	self.SocialMessageFrame.EditBox:SetCountInvisibleLetters(false);
	
	self:RegisterEvent("TWITTER_POST_RESULT");
	self:RegisterEvent("SOCIAL_ITEM_RECEIVED");
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("SCREENSHOT_SUCCEEDED");
end

function SocialPostFrame_OnEvent(self, event, ...)
	if (event == "TWITTER_POST_RESULT") then
		local result = ...;
		if (result == LE_TWITTER_RESULT_SUCCESS) then
			DEFAULT_CHAT_FRAME:AddMessage(SOCIAL_TWITTER_TWEET_SENT, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		elseif (result == LE_TWITTER_RESULT_NOT_LINKED) then
			DEFAULT_CHAT_FRAME:AddMessage(SOCIAL_TWITTER_TWEET_NOT_LINKED, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		elseif (result == LE_TWITTER_RESULT_FAIL) then
			DEFAULT_CHAT_FRAME:AddMessage(SOCIAL_TWITTER_TWEET_FAILED, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		end
	elseif (event == "SOCIAL_ITEM_RECEIVED") then
		SocialItemButton_Update();
	elseif (event == "ACHIEVEMENT_EARNED") then
		local id, alreadyEarned = ...;
		local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(id);
		if (completed and wasEarnedByMe) then
			SocialAchievementButton_Update();
		end
	elseif (event == "SCREENSHOT_SUCCEEDED") then
		SocialScreenshotButton_Update();
		if (SocialPostFrame.ImageFrame.type == SOCIAL_IMAGE_TYPE_SCREENSHOT) then
			SocialScreenshotImage_Set(C_Social.GetLastScreenshotIndex());
		end
	end
end

function SocialPostFrame_OnShow(self)
	SocialPostFrame_SetDefaultView();
	self.SocialMessageFrame.EditBox:SetFocus();
	
	SocialScreenshotButton_Update();
	SocialAchievementButton_Update();
	SocialItemButton_Update();
	SocialPostButton_Update();
	self:SetAttribute("isshown", true);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function SocialPostFrame_OnHide(self)
	self:SetAttribute("isshown", false);
	OffScreenFrame:Flush();
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function SocialPostFrame_OnAttributeChanged(self, name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if (not C_Social.IsSocialEnabled()) then
		return;
	end
	if (name == "action") then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		end
	elseif (name == "settext") then
		self.SocialMessageFrame.EditBox:SetText(value);
		-- When an addon sets the text, disable the tweet button for a second to prevent them from
		-- changing the text on mouse down of the Tweet button, before OnClick() registers
		self.PostButton:Disable();
		self.PostButton.tempEnabled = false;
		self.addonSetText = true;
		self.Timer = C_Timer.NewTimer(1, function() self.addonSetText = false; SocialPostButton_Update(); end);
	elseif (name == "viewmode") then
		if (value == "screenshot") then
			SocialPostFrame_ShowScreenshot(1);
		else
			SocialPostFrame_SetDefaultView();
		end
	elseif (name == "achievementview") then
		SocialPostFrame_ShowAchievement(value, self:GetAttribute("earned"));
	elseif (name == "itemview") then
		SocialPostFrame_ShowItem(value, self:GetAttribute("earned"));
	elseif (name == "screenshotview") then
		SocialPostFrame_ShowScreenshot(value);
	elseif (name == "insertlink") then
		SocialPostFrame_InsertLink(value);
	end
end


--------------------------------------------------------------------------------
-- Functions to show the window in various states. 
--------------------------------------------------------------------------------

function SocialPostFrame_ShowAchievement(achievementID, earned)
	SocialPostFrame:Show();
	SocialPrefillAchievementText(achievementID, earned);
end

function SocialPostFrame_ShowItem(itemLink, earned)
	SocialPostFrame:Show();
	SocialPrefillItemText(itemLink, earned);
end

function SocialPostFrame_ShowScreenshot(index)
	SocialPostFrame:Show();
	SocialPrefillScreenshotText(index);
end

function SocialPostFrame_InsertLink(link)
	local itemID = GetItemInfoFromHyperlink(link);
	if (itemID) then
		SocialPostFrame_ShowItem(link, false);
		return true;
	else
		local achieveID = GetAchievementInfoFromHyperlink(link);
		if (achieveID) then
			SocialPostFrame_ShowAchievement(achieveID, false);
			return true;
		end
	end
	return false;
end


--------------------------------------------------------------------------------
-- Shared input handlers
--------------------------------------------------------------------------------

function SocialMessageFrame_OnLoad(self)
	self.EditBox:SetFontObject("GameFontHighlight");
	self.EditBox.Instructions:SetFontObject("GameFontHighlight");
	self.EditBox:SetScript("OnTextChanged", MessageBoxEdit_OnTextChanged);
	InputScrollFrame_OnLoad(self);
end

function MessageBoxEdit_OnTextChanged(self)
	SocialPostButton_Update();
	InputScrollFrame_OnTextChanged(self);
	SocialPostFrame:SetAttribute("gettext", self:GetText());
end

function SocialPostButton_Update()
	local maxTweetLength = C_Social.GetMaxTweetLength();
	local text = SocialPostFrame.SocialMessageFrame.EditBox:GetDisplayText();
	local tweetLength = C_Social.GetTweetLength(text);
	
	local charsLeft = maxTweetLength - tweetLength;
	SocialPostFrame.PostButton.CharsLeftString:SetText(tostring(charsLeft));
	if (charsLeft < 0) then
		SocialPostFrame.PostButton.CharsLeftString:SetFontObject("GameFontRedLarge");
		SocialPostFrame.PostButton:Disable();
		SocialPostFrame.PostButton.tempEnabled = false;
	else
		SocialPostFrame.PostButton.CharsLeftString:SetFontObject("GameFontNormalLarge");
		if (tweetLength == 0 and not SocialPostFrame.ImageFrame:IsShown()) then
			SocialPostFrame.PostButton:Disable();
		elseif (not SocialPostFrame.addonSetText) then
			SocialPostFrame.PostButton:Enable();
			SocialPostFrame.PostButton.tempEnabled = true;
		end
	end
	
	local button = SocialPostFrame.PostButton;
	local timeToPost = C_Social.TwitterGetMSTillCanPost();
	if (timeToPost > 0) then
		button:Disable();
		button.tempEnabled = false;
		button.tooltip = SOCIAL_TWITTER_THROTTLE_TOOLTIP;
		local recheckTime = timeToPost / 1000;
		button.Timer = C_Timer.NewTimer(recheckTime, function() button.tooltip = nil; SocialPostButton_Update(); end);
		return;
	end
	
	if (SocialPostFrame.ImageFrame.TextureFrame.CropFrame:IsShown()) then
		button:Disable();
	end
end

function SocialPostButton_OnClick(self)
	-- In order to prevent addons from doing something malicious like changing the text just as the user
	-- clicks the Tweet button, make sure we don't call any functions that they can do a secure hook on
	-- between the beginning of this function and the call to tweet the message.
	local text = self:GetParent().SocialMessageFrame.EditBox:GetDisplayText();
	local rawText = self:GetParent().SocialMessageFrame.EditBox:GetText();
	local usedCustomText = (not SocialPostFrame.lastPrefilledText) or (SocialPostFrame.lastPrefilledText ~= rawText);
	if ((SocialPostFrame.ImageFrame:IsShown() or (text and text ~= "")) and self.tempEnabled) then
		if (SocialPostFrame.ImageFrame:IsShown()) then
			if (SocialPostFrame.ImageFrame.type == SOCIAL_IMAGE_TYPE_ACHIEVEMENT) then
				local width, height = OffScreenFrame.Achievement:GetSize();
				C_Social.TwitterPostAchievement(text, width, height, SOCIAL_OFFSCREEN_SNAPSHOT_ID, OffScreenFrame, SocialPostFrame.lastAchievementID, usedCustomText);
			elseif (SocialPostFrame.ImageFrame.type == SOCIAL_IMAGE_TYPE_ITEM) then
				local width, height = OffScreenFrame.ItemTooltip:GetSize();
				C_Social.TwitterPostItem(text, width, height, SOCIAL_OFFSCREEN_SNAPSHOT_ID, OffScreenFrame, SocialPostFrame.lastItemID, usedCustomText);
			elseif (SocialPostFrame.ImageFrame.type == SOCIAL_IMAGE_TYPE_SCREENSHOT) then
				C_Social.TwitterPostScreenshot(text, SocialPostFrame.screenshotIndex, SocialPostFrame.ImageFrame.TextureFrame.Texture, usedCustomText);
			end
		else
			C_Social.TwitterPostMessage(text);
		end
		SocialPostFrame:Hide();
		SocialPostFrame.SocialMessageFrame.EditBox:SetText("");
		UIErrorsFrame:AddMessage(SOCIAL_TWITTER_TWEET_SENDING , 1.0, 1.0, 0.0, 1.0);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function SocialPostButton_OnEnter(self)
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function SocialPostButton_OnLeave(self)
	GameTooltip_Hide();
end

function SharedButton_OnMouseDown(self)
	if (self:IsEnabled()) then
		self.Border:SetAtlas("WoWShare-AddButton-Down", true);
		self.Icon:SetPoint("CENTER", -1, -1);
		self.Plus:SetPoint("CENTER", -1, -1);
	end
end

function SharedButton_OnMouseUp(self)
	if (self:IsEnabled()) then
		self.Border:SetAtlas("WoWShare-AddButton-Up", true);
		self.Icon:SetPoint("CENTER", 0, 0);
		self.Plus:SetPoint("CENTER", 0, 0);
	end
end

--------------------------------------------------------------------------------
-- Image view functions
--------------------------------------------------------------------------------

function SocialPostFrame_SetImageView(width, height, imageType)
	local texture = SocialPostFrame.ImageFrame.TextureFrame.Texture;
	local _, _, _, tlX, tlY = texture:GetPoint(1);
	local _, _, _, brX, brY = texture:GetPoint(2);
	width = width + tlX - brX;
	height = height - tlY + brY;

	-- Show the image frame for screenshots, achievements or items
	local frameHeight = height + SOCIAL_IMAGE_PADDING_HEIGHT; -- Extra room for buttons, padding
	local frame = SocialPostFrame.ImageFrame;
	frame.type = imageType;
	frame.TextureFrame.defaultWidth = width;
	frame.TextureFrame.defaultHeight = height;
	frame.TextureFrame:SetSize(width, height);
	frame.TextureFrame.Texture:SetTexCoord(0, 1, 0, 1);
	frame:SetSize(width, frameHeight);
	frame:Show();
	
	local windowWidth = max(SOCIAL_DEFAULT_FRAME_WIDTH, width + SOCIAL_IMAGE_PADDING_WIDTH);
	local windowHeight = SOCIAL_DEFAULT_FRAME_HEIGHT + frameHeight;
	SocialPostFrame:SetSize(windowWidth, windowHeight);
end

function SocialPostFrame_SetDefaultView()
	SocialPostFrame.ImageFrame:Hide();
	SocialPostFrame:SetSize(SOCIAL_DEFAULT_FRAME_WIDTH, SOCIAL_DEFAULT_FRAME_HEIGHT);
end

function SetRemoveButtonText(text)
	SocialPostFrame.ImageFrame.RemoveImageButton:SetText(text);
	local textWidth = SocialPostFrame.ImageFrame.RemoveImageButton:GetTextWidth();
	SocialPostFrame.ImageFrame.RemoveImageButton:SetWidth(textWidth + 30);
end

--------------------------------------------------------------------------------
-- Screenshot Button Handlers
--------------------------------------------------------------------------------

function CalculateScreenshotSize(ssWidth, ssHeight, maxWidth, maxHeight)
	local aspectRatio = ssWidth / ssHeight;
	local frameWidth, frameHeight;
	if (aspectRatio > SOCIAL_IMAGE_FRAME_ASPECT_RATIO) then -- If wider, use maxWidth
		frameWidth = min(maxWidth, ssWidth);
		frameHeight = frameWidth / aspectRatio;
	else
		frameHeight = min(maxHeight, ssHeight);
		frameWidth = frameHeight * aspectRatio;
	end
	return frameWidth, frameHeight;
end

function SocialPostFrame_SetScreenshotView(index, width, height)
	-- Calculate how much space we need to fit the screenshot
	local ssWidth, ssHeight = CalculateScreenshotSize(width, height, SOCIAL_IMAGE_FRAME_MAX_WIDTH, SOCIAL_IMAGE_FRAME_MAX_HEIGHT);
	SocialPostFrame_SetImageView(ssWidth, ssHeight, SOCIAL_IMAGE_TYPE_SCREENSHOT);
	
	SocialScreenshotImage_Set(index);
	SocialScreenshotCrop_SetEnabled(false);
	SocialScreenshotCrop_ResetCropBox();
	SocialTextureFrame_ResetImageSize();
	SetRemoveButtonText(SOCIAL_SCREENSHOT_REMOVE_BUTTON);
end

function SocialScreenshotButton_ShowTooltip(button, width, height)
	-- Calculate how much space we need to fit the screenshot
	local ssWidth, ssHeight = CalculateScreenshotSize(width, height, SOCIAL_SCREENSHOT_TOOLTIP_MAX_WIDTH, SOCIAL_SCREENSHOT_TOOLTIP_MAX_HEIGHT);
	local tooltipTitleWidth = SocialScreenshotTooltip.Title:GetWidth();
	if ( tooltipTitleWidth > ssWidth ) then
		ssHeight = ssHeight * tooltipTitleWidth / ssWidth;
		ssWidth = tooltipTitleWidth;
	end
	SocialScreenshotTooltip:SetSize(ssWidth + 20, ssHeight + 44);
	SocialScreenshotTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 5, -12);
	SocialScreenshotTooltip:Show();
end

function SocialRemoveImageButton_OnClick(self)
	SocialPostFrame_SetDefaultView();
	SocialPostButton_Update();
end

function SocialScreenshotButton_Update()
	local self = SocialPostFrame.ScreenshotButton;
	local index = C_Social.GetLastScreenshotIndex();
	if (index > 0 and C_Social.GetScreenshotInfoByIndex(index)) then
		C_Social.SetTextureToScreenshot(self.Icon, index);
		C_Social.SetTextureToScreenshot(SocialScreenshotTooltip.Image, index);
		self:Enable();
	else
		self.Icon:SetAtlas("WoWShare-ScreenshotIcon", true);
		self:Disable();
	end
end

function SocialScreenshotImage_Set(index)
	C_Social.SetTextureToScreenshot(SocialPostFrame.ImageFrame.TextureFrame.Texture, index);
	SocialPostFrame.screenshotIndex = index;
end

function SocialPrefillScreenshotText(index)
	-- Populate editbox with social prefill text and expand to screenshot view
	local width, height = C_Social.GetScreenshotInfoByIndex(index);
	if width then
		local text = SOCIAL_SCREENSHOT_PREFILL_TEXT;
		local prefillTextLength = strlen(SOCIAL_SCREENSHOT_PREFILL_TEXT);
		SocialPostFrame.SocialMessageFrame.EditBox:SetText(text);
		SocialPostFrame.SocialMessageFrame.EditBox:HighlightText(0, prefillTextLength);
		SocialPostFrame.SocialMessageFrame.EditBox:SetCursorPosition(prefillTextLength);
		SocialPostFrame.lastPrefilledText = text;
		SocialPostFrame_SetScreenshotView(index, width, height);
	else
		SocialPostFrame_SetDefaultView();
		SocialPostFrame.SocialMessageFrame.EditBox:SetText("");
		SocialScreenshotButton_Update();
	end
end

function SocialScreenshotButton_OnClick(self)
	local alreadyShown = SocialPostFrame.ImageFrame:IsShown();
	SocialPrefillScreenshotText(C_Social.GetLastScreenshotIndex());
	if (alreadyShown) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	end
end

function SocialScreenshotButton_OnEnter(self)
	local index = C_Social.GetLastScreenshotIndex();
	local width, height = C_Social.GetScreenshotInfoByIndex(index);
	if width then
		SocialScreenshotButton_ShowTooltip(self, width, height);
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -38, -12);
		GameTooltip:SetText(SOCIAL_SCREENSHOT_PREFILL_NONE);
	end
end

function SocialScreenshotButton_OnLeave(self)
	GameTooltip_Hide();
	SocialScreenshotTooltip:Hide();
end

function SocialPostFrame_AddOffscreenFrameImage(offscreenSubFrame, imageType, removeImageText)
	local width, height = offscreenSubFrame:GetSize();
	local frameWidth = width;
	local frameHeight = height;
	local aspectRatio = frameWidth / frameHeight;
	local frame = SocialPostFrame.ImageFrame;
	if (height > SOCIAL_IMAGE_FRAME_MAX_HEIGHT) then
		frameHeight = SOCIAL_IMAGE_FRAME_MAX_HEIGHT;
		frameWidth = frameHeight * aspectRatio;
	end
	if (frameWidth > SOCIAL_IMAGE_FRAME_MAX_WIDTH) then
		frameWidth = SOCIAL_IMAGE_FRAME_MAX_WIDTH;
	end
	
	SocialPostFrame_SetImageView(frameWidth, frameHeight, imageType);
	if (height > SOCIAL_IMAGE_FRAME_MAX_HEIGHT) then
		frame.TextureFrame:SetSize(frameHeight * aspectRatio, frameHeight);
	end
	
	SocialScreenshotCrop_SetEnabled(false);
	
	OffScreenFrame:ApplySnapshot(frame.TextureFrame.Texture, SOCIAL_OFFSCREEN_SNAPSHOT_ID);
	local texCoordX = width / OffScreenFrame:GetWidth();
	local texCoordY = height / OffScreenFrame:GetHeight();
	frame.TextureFrame.Texture:SetTexCoord(0, texCoordX, 0, texCoordY);
	
	frame.CropCancelButton:Hide();
	frame.CropSaveButton:Hide();
	frame.CropScreenshotButton:Hide();
	SetRemoveButtonText(removeImageText);
end

--------------------------------------------------------------------------------
-- Achievement Button Handlers
--------------------------------------------------------------------------------

function SocialAchievementButton_Update()
	-- Show icon of last received achievement, or default achievement icon
	local self = SocialPostFrame.AchievementButton;
	local id, name, description, icon = C_Social.GetLastAchievement();
	if (id) then
		self.Icon:SetTexture(icon);
		self:Enable();
	else
		self.Icon:SetAtlas("WoWShare-AchievementIcon", true);
		self:Disable();
	end
end

function SocialPrefillAchievementText(achievementID, earned, name)
	if (name == nil) then
		local ignored;
		ignored, name = GetAchievementInfo(achievementID);
	end
	
	-- Populate editbox with achievement prefill text
	local achievementNameColored = format("%s[%s]|r", NORMAL_FONT_COLOR_CODE, name);
	local prefillText;
	if (earned) then
		prefillText = format(SOCIAL_ACHIEVEMENT_PREFILL_TEXT_EARNED, achievementNameColored);
	else
		prefillText = format(SOCIAL_ACHIEVEMENT_PREFILL_TEXT_GENERIC, achievementNameColored);
	end

	local prefillTextLength = strlen(prefillText);
	SocialPostFrame.SocialMessageFrame.EditBox:SetText(prefillText);
	SocialPostFrame.SocialMessageFrame.EditBox:HighlightText(0, prefillTextLength);
	SocialPostFrame.SocialMessageFrame.EditBox:SetCursorPosition(prefillTextLength);
	SocialPostFrame.lastAchievementID = achievementID;
	SocialPostFrame.lastPrefilledText = prefillText;

	-- Show image frame with achievement image rendered off screen
	SocialRenderAchievement(achievementID);
end

local function UpdateOffScreenFrame(self, state)
	self:SetShown(state ~= SOCIAL_OFFSCREEN_STATE_HIDE);
	self.Achievement:SetShown(state == SOCIAL_OFFSCREEN_STATE_SHOW_ACHIEVEMENT);
	self.ItemTooltip:SetShown(state == SOCIAL_OFFSCREEN_STATE_SHOW_ITEM);
end

local function TakeOffscreenSnapshot(offscreenSubFrame, imageType, removeImageText)
	offscreenSubFrame.frameCount = 1;
	offscreenSubFrame:SetScript("OnUpdate", function(self)
		if (self.frameCount < 2) then
			self.frameCount = self.frameCount + 1;
		else
			SOCIAL_OFFSCREEN_SNAPSHOT_ID = OffScreenFrame:TakeSnapshot();
			UpdateOffScreenFrame(OffScreenFrame, SOCIAL_OFFSCREEN_STATE_HIDE);
			SocialPostFrame_AddOffscreenFrameImage(offscreenSubFrame, imageType, removeImageText);
			offscreenSubFrame:SetScript("OnUpdate", nil);
		end
	end);
end

function SocialRenderAchievement(achievementID)
	local button = OffScreenFrame.Achievement;
	AchievementFrameAchievements_SetupButton(button);

	-- Set button to collapsed state so that AchievementButton_DisplayAchievement() expands
	-- the frame and renders all the objectives
	AchievementButton_Collapse(button);
	AchievementButton_DisplayAchievement (button, achievementID, nil, achievementID, true);
	button.tracked:Hide();
	button.plusMinus:Hide();
	button.check:Hide();

	UpdateOffScreenFrame(OffScreenFrame, SOCIAL_OFFSCREEN_STATE_SHOW_ACHIEVEMENT);
	TakeOffscreenSnapshot(button, SOCIAL_IMAGE_TYPE_ACHIEVEMENT, SOCIAL_ACHIEVEMENT_REMOVE_BUTTON);
end

function SocialAchievementButton_OnClick(self)
	local id, name, description, icon = C_Social.GetLastAchievement();
	if (id) then
		local alreadyShown = SocialPostFrame.ImageFrame:IsShown();
		SocialPrefillAchievementText(id, true, name);
		if (alreadyShown) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
		end
	end
end

function SocialAchievementButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -38, -12);
	local id, name, description, icon = C_Social.GetLastAchievement();
	if (id) then
		GameTooltip:SetText(SOCIAL_ACHIEVEMENT_PREFILL_TOOLTIP, 1, 1, 1);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(name);
		GameTooltip:AddLine(description, 1, 1, 1);
	else
		GameTooltip:SetText(SOCIAL_ACHIEVEMENT_PREFILL_NONE);
	end
	GameTooltip:Show();
end

function SocialAchievementButton_OnLeave(self)
	GameTooltip_Hide();
end

--------------------------------------------------------------------------------
-- Item Button Handlers
--------------------------------------------------------------------------------

function SocialItemButton_Update()
	-- Show icon of last received item, or default item icon
	local self = SocialPostFrame.ItemButton;
	local id, _, icon, quality = C_Social.GetLastItem();
	if (id) then
		self.Icon:SetTexture(icon);
		local r, g, b = GetItemQualityColor(quality);
		self.QualityBorder:SetVertexColor(r, g, b);
		self.QualityBorder:Show();
		self:Enable();
	else
		self.Icon:SetAtlas("WoWShare-ItemIcon", true);
		self.QualityBorder:Hide();
		self:Disable();
	end
end

function SocialPrefillItemText(itemLink, earned)
	local itemID = GetItemInfoFromHyperlink(itemLink);
	local name = GetItemInfo(itemLink);
	
	local prefillText;
	if (earned) then
		prefillText = SOCIAL_ITEM_PREFILL_TEXT_EARNED;
	else
		prefillText = SOCIAL_ITEM_PREFILL_TEXT_GENERIC;
	end
	
	-- Populate editbox with item prefill text
	local itemName = format("[%s]", name);
	local text = format(SOCIAL_ITEM_PREFILL_TEXT_ALL, prefillText, itemName);
	
	local prefillTextLength = strlen(prefillText);
	SocialPostFrame.SocialMessageFrame.EditBox:SetText(text);
	SocialPostFrame.SocialMessageFrame.EditBox:HighlightText(0, prefillTextLength);
	SocialPostFrame.SocialMessageFrame.EditBox:SetCursorPosition(prefillTextLength);
	SocialPostFrame.lastItemID = itemID;
	SocialPostFrame.lastPrefilledText = prefillText;
	
	SocialRenderItem(itemID);
end

function SocialItemButton_OnClick(self)
	local id, _, _, _, _, itemLink = C_Social.GetLastItem();
	if (id) then
		SocialPrefillItemText(itemLink, true);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

function SocialItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -38, -12);
	local _, name, _, quality, level = C_Social.GetLastItem();
	if (name) then
		GameTooltip:SetText(SOCIAL_ITEM_PREFILL_TOOLTIP, 1, 1, 1);
		GameTooltip:AddLine(" ");
		local r, g, b, colorString = GetItemQualityColor(quality);
		GameTooltip:AddLine(format("|c%s%s|r", colorString, name));
		GameTooltip:AddLine(format(ITEM_LEVEL, level));
	else
		GameTooltip:SetText(SOCIAL_ITEM_PREFILL_NONE);
	end
	GameTooltip:Show();
end

function SocialItemButton_OnLeave(self)
	GameTooltip_Hide();
end

function SocialRenderItem(itemID)
	local tooltip = OffScreenFrame.ItemTooltip;
	tooltip:SetOwner(OffScreenFrame, "ANCHOR_PRESERVE");
	tooltip:SetOwnedItemByID(itemID);

	UpdateOffScreenFrame(OffScreenFrame, SOCIAL_OFFSCREEN_STATE_SHOW_ITEM);
	TakeOffscreenSnapshot(tooltip, SOCIAL_IMAGE_TYPE_ITEM, SOCIAL_ITEM_REMOVE_BUTTON);
end

--------------------------------------------------------------------------------
-- Cropping Functions
--------------------------------------------------------------------------------

function SocialScreenshotCrop_ResetCropBox()
	local self = SocialPostFrame.ImageFrame.TextureFrame.CropFrame;
	
	-- Set initial crop size to 75%
	local parentWidth, parentHeight = self:GetParent():GetSize();
	self.currentWidth = parentWidth * 0.75;
	self.currentHeight = self.currentWidth / 2;
	self.currentPosX = (parentWidth - self.currentWidth) / 2;
	self.currentPosY = -(parentHeight - self.currentHeight) / 2;
	
	self:SetSize(self.currentWidth, self.currentHeight);
	self:SetPoint("TOPLEFT", self.currentPosX, self.currentPosY);
	SocialScreenshotCrop_UpdateDarkRects();
end

function SocialTextureFrame_ResetImageSize()
	local textureFrame = SocialPostFrame.ImageFrame.TextureFrame;
	textureFrame.Texture:SetTexCoord(0, 1, 0, 1);
	textureFrame:SetSize(textureFrame.defaultWidth, textureFrame.defaultHeight);
end

function SocialCropScreenshotButton_OnClick(self)
	SocialTextureFrame_ResetImageSize();
	SocialScreenshotCrop_SetEnabled(true);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

function SocialCropCancelButton_OnClick(self)
	SocialScreenshotCrop_ResetCropBox();
	SocialTextureFrame_ResetImageSize();
	SocialScreenshotCrop_SetEnabled(false);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

function SocialCropSaveButton_OnClick(self)
	local textureFrame = self:GetParent().TextureFrame;
	local frameWidth, frameHeight = textureFrame:GetSize();
	local frameAspectRatio = frameWidth / frameHeight;
	
	local _, _, _, cropX, cropY = textureFrame.CropFrame:GetPoint(0);
	local cropWidth, cropHeight = textureFrame.CropFrame:GetSize();
	local cropAspectRatio = cropWidth / cropHeight;
	
	if (frameAspectRatio > cropAspectRatio) then -- cropped image is not as wide
		textureFrame:SetSize(frameHeight * cropAspectRatio, frameHeight);
	else
		textureFrame:SetSize(frameWidth, frameWidth / cropAspectRatio);
	end
	
	local texMinX = cropX / frameWidth;
	local texMaxX = texMinX + cropWidth / frameWidth;
	local texMinY = -cropY / frameHeight;
	local texMaxY = texMinY + cropHeight / frameHeight;
	
	SocialScreenshotCrop_SetEnabled(false);
	textureFrame.Texture:SetTexCoord(texMinX, texMaxX, texMinY, texMaxY);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

function SocialScreenshotCrop_SetEnabled(enable)
	local frame = SocialPostFrame.ImageFrame;
	frame.TextureFrame.DarkLeft:SetShown(enable);
	frame.TextureFrame.DarkRight:SetShown(enable);
	frame.TextureFrame.DarkTop:SetShown(enable);
	frame.TextureFrame.DarkBottom:SetShown(enable);
	frame.TextureFrame.CropFrame:SetShown(enable);
	frame.CropCancelButton:SetShown(enable);
	frame.CropSaveButton:SetShown(enable);
	frame.CropScreenshotButton:SetShown(not enable);
	SocialPostButton_Update();
end

function SocialScreenshotCrop_UpdateDarkRects()
	local self = SocialPostFrame.ImageFrame.TextureFrame;
	local frameWidth, frameHeight = self:GetSize();
	local _, _, _, cropX, cropY = self.CropFrame:GetPoint(0);
	local cropWidth, cropHeight = self.CropFrame:GetSize();
	
	self.DarkLeft:SetSize(cropX + 0.01, frameHeight);
	self.DarkRight:SetSize(frameWidth - cropX - cropWidth + 0.01, frameHeight);
	self.DarkTop:SetSize(cropWidth, -cropY + 0.01);
	self.DarkBottom:SetSize(cropWidth, frameHeight - cropHeight + cropY + 0.01);
end

local function ClampMove(self, x, y)
	local myWidth, myHeight = self:GetSize();
	local pWidth, pHeight = self:GetParent():GetSize();
	local maxX = pWidth - myWidth;
	local minY = -(pHeight - myHeight);
	
	if (x < 0) then
		x = 0;
	elseif (x > maxX) then
		x = maxX;
	end
	
	if (y > 0) then
		y = 0;
	elseif (y < minY) then
		y = minY;
	end
	return x, y;
end

local function ClampResizePosX(x, parent)
	if (x < 0) then
		x = 0;
	elseif (x > parent.currentPosX + parent.currentWidth - SOCIAL_SCREENSHOT_CROP_MIN_WIDTH) then
		x = parent.currentPosX + parent.currentWidth - SOCIAL_SCREENSHOT_CROP_MIN_WIDTH;
	end
	return x;
end

local function ClampResizePosY(y, parent)
	if (y > 0) then
		y = 0;
	elseif (y < parent.currentPosY - parent.currentHeight + SOCIAL_SCREENSHOT_CROP_MIN_HEIGHT) then
		y = parent.currentPosY - parent.currentHeight + SOCIAL_SCREENSHOT_CROP_MIN_HEIGHT;
	end
	return y;
end

local function ClampResizeWidth(width, x, parent)
	local frameWidth, frameHeight = parent:GetParent():GetSize();
	if (width < SOCIAL_SCREENSHOT_CROP_MIN_WIDTH) then
		width = SOCIAL_SCREENSHOT_CROP_MIN_WIDTH;
	elseif (width > frameWidth - x) then
		width = frameWidth - x;
	end
	return width;
end

local function ClampResizeHeight(height, y, parent)
	local frameWidth, frameHeight = parent:GetParent():GetSize();
	if (height < SOCIAL_SCREENSHOT_CROP_MIN_HEIGHT) then
		height = SOCIAL_SCREENSHOT_CROP_MIN_HEIGHT;
	elseif (height > frameHeight + y) then
		height = frameHeight + y;
	end
	return height;
end

function SocialScreenshotCrop_Move_OnEnter(self)
	if (self.resizeType == nil) then
		SetCursor("UI_MOVE_CURSOR");
	end
end

function SocialScreenshotCrop_Move_OnLeave(self)
	if (self.resizeType == nil) then
		ResetCursor();
	end
end

function SocialScreenshotCrop_Move_OnMouseDown(self)
	self.startPosX, self.startPosY = GetScaledCursorPosition();
	self:SetScript("OnUpdate", SocialScreenshotCrop_Move_OnUpdate);
end

function SocialScreenshotCrop_Move_OnMouseUp(self)
	local _;
	_, _, _, self.currentPosX, self.currentPosY = self:GetPoint(0);
	self:SetScript("OnUpdate", nil);
	
	if (not self:IsMouseOver()) then
		ResetCursor();
	end
end

function SocialScreenshotCrop_Move_OnUpdate(self)
	local xPos, yPos = GetScaledCursorPosition();
	local newX = self.currentPosX + (xPos - self.startPosX);
	local newY = self.currentPosY + (yPos - self.startPosY);
	newX, newY = ClampMove(self, newX, newY);
	self:SetPoint("TOPLEFT", newX, newY);
	SocialScreenshotCrop_UpdateDarkRects();
end

function SocialScreenshotCrop_Resize_OnEnter(self)
	SetCursor("UI_RESIZE_CURSOR");
end

function SocialScreenshotCrop_Resize_OnLeave(self)
	if (self:GetParent().resizeType == nil) then
		ResetCursor();
	end
end

function SocialScreenshotCrop_Resize_OnMouseDown(self)
	local parent = self:GetParent();
	parent.startPosX, parent.startPosY = GetScaledCursorPosition();
	parent.resizeType = self.corner;
	self:SetScript("OnUpdate", SocialScreenshotCrop_Resize_OnUpdate);
end

function SocialScreenshotCrop_Resize_OnMouseUp(self)
	local parent = self:GetParent();
	local _;
	_, _, _, parent.currentPosX, parent.currentPosY = parent:GetPoint(0);
	parent.currentWidth, parent.currentHeight = parent:GetSize();
	parent.resizeType = nil;
	self:SetScript("OnUpdate", nil);
	
	if (not self:IsMouseOver()) then
		ResetCursor();
	end
end

function SocialScreenshotCrop_Resize_OnUpdate(self)
	local parent = self:GetParent();
	local mouseX, mouseY = GetScaledCursorPosition();
	local xDiff = mouseX - parent.startPosX;
	local yDiff = mouseY - parent.startPosY;
	
	-- Calculate position of top-left corner of crop box
	local newX = parent.currentPosX;
	local newY = parent.currentPosY;
	if (parent.resizeType == "TOPLEFT" or parent.resizeType == "BOTTOMLEFT") then
		newX = ClampResizePosX(newX + xDiff, parent);
	end
	if (parent.resizeType == "TOPLEFT" or parent.resizeType == "TOPRIGHT") then
		newY = ClampResizePosY(newY + yDiff, parent);
	end
	
	-- Calculate width and height of crop box
	local newWidth = parent.currentWidth;
	local newHeight = parent.currentHeight;
	if (parent.resizeType == "TOPLEFT" or parent.resizeType == "BOTTOMLEFT") then
		newWidth = ClampResizeWidth(newWidth - (newX - parent.currentPosX), newX, parent);
	else
		newWidth = ClampResizeWidth(newWidth + xDiff, newX, parent);
	end
	if (parent.resizeType == "TOPLEFT" or parent.resizeType == "TOPRIGHT") then
		newHeight = ClampResizeHeight(newHeight + (newY - parent.currentPosY), newY, parent);
	else
		newHeight = ClampResizeHeight(newHeight - yDiff, newY, parent);
	end
	
	parent:SetSize(newWidth, newHeight);
	parent:SetPoint("TOPLEFT", newX, newY);
	SocialScreenshotCrop_UpdateDarkRects();
end
