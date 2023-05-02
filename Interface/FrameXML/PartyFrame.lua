MAX_PARTY_MEMBERS = 4;

PartyFrameMixin={};

function PartyFrameMixin:OnLoad()
	local function PartyMemberFrameReset(framePool, frame)
		frame.layoutIndex = nil;
		FramePool_HideAndClearAnchors(framePool, frame);
	end

	self.PartyMemberFramePool = CreateFramePool("BUTTON", self, "PartyMemberFrameTemplate", PartyMemberFrameReset);
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function PartyFrameMixin:OnShow()
	self:InitializePartyMemberFrames();
	self:UpdatePartyFrames();
end

function PartyFrameMixin:OnEvent(event, ...)
	self:Layout();
end

function PartyFrameMixin:ShouldShow()
	return ShouldShowPartyFrames() and not EditModeManagerFrame:UseRaidStylePartyFrames();
end

function PartyFrameMixin:InitializePartyMemberFrames()
	local memberFramesToSetup = {};
	
	self.PartyMemberFramePool:ReleaseAll();
	for i = 1, MAX_PARTY_MEMBERS do 	
		 local memberFrame = self.PartyMemberFramePool:Acquire();

		 -- Set for debugging purposes.
		 memberFrame:SetParentKey("MemberFrame"..i);

		 memberFrame:SetPoint("TOPLEFT");
		 memberFrame.layoutIndex = i;
		 memberFramesToSetup[i] = memberFrame;
		 memberFrame:SetShown(self:ShouldShow());
	end
	self:Layout();
	for _, frame in ipairs(memberFramesToSetup) do 
		frame:Setup();
	end
end

function PartyFrameMixin:UpdateMemberFrames()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		memberFrame:UpdateMember();
	end

	self:Layout();
end

function PartyFrameMixin:UpdatePartyMemberBackground()
	if not self.Background then
		return;
	end

	if not self:ShouldShow() or not EditModeManagerFrame:ShouldShowPartyFrameBackground() then
		self.Background:Hide();
		return;
	end

	local numMembers = EditModeManagerFrame:ArePartyFramesForcedShown() and MAX_PARTY_MEMBERS or GetNumSubgroupMembers();
	if numMembers > 0 then
		for memberFrame in self.PartyMemberFramePool:EnumerateActive() do 
			if memberFrame.layoutIndex == numMembers then
				if memberFrame.PetFrame:IsShown() then
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

function PartyFrameMixin:HidePartyFrames()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		memberFrame:Hide();
	end
end

function PartyFrameMixin:UpdatePaddingAndLayout()
	local showPartyFrames = self:ShouldShow();
	if showPartyFrames then
		self.leftPadding = nil;
		self.rightPadding = nil;
	else
		local useHorizontalGroups = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(true);

		if useHorizontalGroups then
			if CompactPartyFrame.borderFrame:IsShown() then
				self.leftPadding = 6;
				self.rightPadding = nil;
			else
				self.leftPadding = 2;
				self.rightPadding = 2;
			end
		else
			self.leftPadding = 2;
			self.rightPadding = 2;
		end
	end

	self:Layout();
end

function PartyFrameMixin:UpdatePartyFrames()
	local showPartyFrames = self:ShouldShow();
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		if showPartyFrames then
			memberFrame:Show();
			memberFrame:UpdateMember();
		else
			memberFrame:Hide();
		end
	end

	self:UpdatePartyMemberBackground();
	self:UpdatePaddingAndLayout();
end

PartyMemberBuffTooltipMixin = {};
function PartyMemberBuffTooltipMixin:OnLoad()
	self.PartyMemberBuffPool = CreateFramePool("BUTTON", self.BuffContainer, "PartyBuffFrameTemplate");
	self.PartyMemberDebuffPool = CreateFramePool("BUTTON", self.DebuffContainer, "PartyDebuffFrameTemplate");
end

function PartyMemberBuffTooltipMixin:UpdateGridLayout(frames, numFrames, anchor)
	local stride = math.min(numFrames, MAX_PARTY_TOOLTIP_BUFFS_PER_ROW);
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, 2, 2);
   
	GridLayoutUtil.ApplyGridLayout(frames, anchor, layout);
end

function PartyMemberBuffTooltipMixin:UpdateTooltip(frame)
	if frame.layoutIndex ~= nil then 
		self:SetID(frame.layoutIndex);
	else
		self:SetID(frame:GetID() ~= 0 and frame:GetID() or 1); -- Pet frame doesn't use layout index
	end

	local numBuffs = 0;
	local frameNum = 1;
	self.PartyMemberBuffPool:ReleaseAll();

	for frame in self.PartyMemberBuffPool:EnumerateActive() do 
		frame:Hide()
	end
	local buffFrames = {};

	frame.buffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_BUFFS then
			return true;
		end

		if aura.icon then
			local buffFrame = self.PartyMemberBuffPool:Acquire();
			buffFrame:Setup(frame.unit, frameNum);
			buffFrame.Icon:SetTexture(aura.icon);
			buffFrame:Show();
			buffFrames[frameNum] = buffFrame;

			frameNum = frameNum + 1;
			numBuffs = numBuffs + 1;
		end

		return false;
	end);

	local numDebuffs = 0;
	frameNum = 1;
	self.PartyMemberDebuffPool:ReleaseAll();
	local debuffFrames = {};
	frame.debuffs:Iterate(function(auraInstanceID, aura)
		if frameNum > MAX_PARTY_TOOLTIP_DEBUFFS then
			return true;
		end

		if aura.icon then
			local debuffFrame = self.PartyMemberDebuffPool:Acquire();
			debuffFrame:Setup(frame.unit, frameNum);
			frame:SetDebuff(debuffFrame, aura, frameNum);
			debuffFrame.Icon:SetTexture(aura.icon);
			local color = aura.dispelName and DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
			debuffFrame.Border:SetVertexColor(color.r, color.g, color.b);
			debuffFrame:Show();
			debuffFrames[frameNum] = debuffFrame;

			frameNum = frameNum + 1;
			numDebuffs = numDebuffs + 1;
		end

		return false;
	end);

	-- Size the tooltip
	local rows = ceil(numBuffs / MAX_PARTY_TOOLTIP_BUFFS_PER_ROW) + ceil(numDebuffs / MAX_PARTY_TOOLTIP_BUFFS_PER_ROW);
	local columns = min(MAX_PARTY_TOOLTIP_BUFFS_PER_ROW, max(numBuffs, numDebuffs));
	if ( (rows > 0) and (columns > 0) ) then
		self:SetWidth( (columns * 17) + 15 );
		self:SetHeight( (rows * 17) + 15 );
		self:Show();
	else
		self:Hide();
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", 8, -8);
	self:UpdateGridLayout(buffFrames, numBuffs, anchor);

	if ( numBuffs ~= 0 ) then
		anchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", 8, -8-17*(rows-1));
	end

	self:UpdateGridLayout(debuffFrames, numDebuffs, anchor);
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
	if ( ArenaEnemyBackground and ArenaEnemyBackground.SetOpacity  ) then
		ArenaEnemyBackground:SetOpacity();
	end
end

function PartyMemberBackgroundMixin:SaveOpacity()
	PARTYBACKGROUND_OPACITY = OpacityFrameSlider:GetValue();
	SetCVar("partyBackgroundOpacity", PARTYBACKGROUND_OPACITY);
end