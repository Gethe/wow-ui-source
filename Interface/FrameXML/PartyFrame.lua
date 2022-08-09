MAX_PARTY_MEMBERS = 4;

PartyFrameMixin={};

function PartyFrameMixin:OnLoad()
	self.PartyMemberFramePool = CreateFramePool("BUTTON", self, "PartyMemberFrameTemplate");
end

function PartyFrameMixin:OnShow()
	self:InitializePartyMemberFrames();
	self:HidePartyFrame();
	self:ShowPartyFrame();
end

function PartyFrameMixin:InitializePartyMemberFrames()
	local memberFramesToSetup = {};
	
	self.PartyMemberFramePool:ReleaseAll();
	for i = 1, MAX_PARTY_MEMBERS do 	
		 local memberFrame = self.PartyMemberFramePool:Acquire();
		 memberFrame:SetPoint("TOPLEFT");
		 memberFrame.layoutIndex = i;
		 memberFramesToSetup[i] = memberFrame;
		 memberFrame:Show();
	end
	self:Layout();
	for index, frame in ipairs(memberFramesToSetup) do 
		frame:Setup();
	end
end

function PartyFrameMixin:HidePartyFrame()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		memberFrame:Hide();
	end
end

function PartyFrameMixin:UpdatePartyMemberBackground()
	if ( not self.Background ) then
		return;
	end
	local numMembers = GetNumSubgroupMembers();
	if ( numMembers > 0 and CVarCallbackRegistry:GetCVarValueBool("showPartyBackground") and GetDisplayedAllyFrames() == "party" ) then
		for memberFrame in self.PartyMemberFramePool:EnumerateActive() do 
			if memberFrame.layoutIndex == numMembers then
				if (memberFrame.PetFrame:IsShown() ) then
					self.Background:SetPoint("BOTTOMLEFT", memberFrame, "BOTTOMLEFT", -5, -21);
				else
					self.Background:SetPoint("BOTTOMLEFT", memberFrame, "BOTTOMLEFT", -5, -5);
				end
			end
		end
		self.Background:Show();
	else
		self.Background:Hide();
	end
end

function PartyFrameMixin:ShowPartyFrame()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		if ( UnitExists(memberFrame.unit) ) then
			memberFrame:Show();
		end
	end
end

PartyMemberBuffTooltipMixin={};

function PartyMemberBuffTooltipMixin:UpdateTooltip(frame)
	if frame.layoutIndex ~= nil then 
		self:SetID(frame.layoutIndex);
	else
		self:SetID(frame:GetID()); -- Pet frame doesn't use layout index
	end

	local numBuffs = 0;
	local frameNum = 1;
	frame.buffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_BUFFS then
			return true;
		end

		if aura.icon then
			local buff = self.Buff[frameNum];
			buff.Icon:SetTexture(aura.icon);
			buff:Show();

			frameNum = frameNum + 1;
			numBuffs = numBuffs + 1;
		end

		return false;
	end);

	for i = frameNum, MAX_PARTY_TOOLTIP_BUFFS do
		self.Buff[i]:Hide();
	end

	if ( numBuffs == 0 ) then
		self.Debuff[1]:SetPoint("TOP", self.Buff[1], "TOP", 0, 0);
	elseif ( numBuffs <= 8 ) then
		self.Debuff[1]:SetPoint("TOP", self.Buff[1], "BOTTOM", 0, -2);
	else
		self.Debuff[1]:SetPoint("TOP", self.Buff[9], "BOTTOM", 0, -2);
	end

	local numDebuffs = 0;
	frameNum = 1;
	frame.debuffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_DEBUFFS then
			return true;
		end

		if aura.icon then
			local debuff = self.Debuff[frameNum]
			debuff.Icon:SetTexture(aura.icon);
			local color = aura.dispelName and DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
			debuff.Border:SetVertexColor(color.r, color.g, color.b);
			debuff:Show();

			frameNum = frameNum + 1;
			numDebuffs = numDebuffs + 1;
		end

		return false;
	end);

	for i = frameNum, MAX_PARTY_TOOLTIP_DEBUFFS do
		self.Debuff[i]:Hide();
	end

	-- Size the tooltip
	local rows = ceil(numBuffs / 8) + ceil(numDebuffs / 8);
	local columns = min(8, max(numBuffs, numDebuffs));
	if ( (rows > 0) and (columns > 0) ) then
		self:SetWidth( (columns * 17) + 15 );
		self:SetHeight( (rows * 17) + 15 );
		self:Show();
	else
		self:Hide();
	end
end

PartyMemberBackgroundMixin={};

function PartyMemberBackgroundMixin:OnLoad()
	self:RegisterEvent("VARIABLES_LOADED");
end

function PartyMemberBackgroundMixin:OnShow()
	self:SetFrameLevel(1);
end

function PartyMemberBackgroundMixin:OnEvent(event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		self:GetParent():UpdatePartyMemberBackground();
		OpacityFrameSlider:SetValue(tonumber(GetCVar("partyBackgroundOpacity")));
		self:SetOpacity();
	end
end

function PartyMemberBackgroundMixin:OnMouseUp(button)
	if ( button == "RightButton" ) then
		self:ToggleOpacity();
	end
end

function PartyMemberBackgroundMixin:ToggleOpacity(frame)
	if ( not self ) then
		frame = self;
	end
	if ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
		return;
	end
	OpacityFrame:ClearAllPoints();
	if ( frame == ArenaEnemyBackground ) then
		OpacityFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, -7);
	else
		OpacityFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 7);
	end
	OpacityFrame.opacityFunc = PartyMemberBackgroundMixin.SetOpacity;
	OpacityFrame.saveOpacityFunc = PartyMemberBackgroundMixin.SaveOpacity;
	OpacityFrame:Show();
end

function PartyMemberBackgroundMixin:SetOpacity()
	local alpha = 1.0 - OpacityFrameSlider:GetValue();
	PartyFrame.Background:SetAlpha(alpha);
	if ( ArenaEnemyBackground_SetOpacity ) then
		ArenaEnemyBackground_SetOpacity();
	end
end

function PartyMemberBackgroundMixin:SaveOpacity()
	PARTYBACKGROUND_OPACITY = OpacityFrameSlider:GetValue();
	SetCVar("partyBackgroundOpacity", PARTYBACKGROUND_OPACITY);
end