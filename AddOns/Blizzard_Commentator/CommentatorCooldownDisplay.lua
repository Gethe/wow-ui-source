
CommentatorCooldownDisplayMixin = {};

function CommentatorCooldownDisplayMixin:OnLoad()
	self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");
	self:RegisterEvent("COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE");

	self:MarkDirty();
end

function CommentatorCooldownDisplayMixin:OnUpdate()
	if self.isDirty then
		self:Refresh();
	end
end

function CommentatorCooldownDisplayMixin:OnEvent(event, ...)
	if event == "COMMENTATOR_PLAYER_UPDATE" or event == "COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE" then
		self:MarkDirty();
	end
end

function CommentatorCooldownDisplayMixin:MarkDirty()
	self.isDirty = true;
end

function CommentatorCooldownDisplayMixin:Refresh()
	self.isDirty = false;

	for teamIndex, teamFrame in ipairs(self.TeamFrames) do
		teamFrame:Refresh(teamIndex);
	end
end

CommentatorCooldownTeamMixin = {};

function CommentatorCooldownTeamMixin:OnLoad()
	self.playerRowPool = CreateFramePool("FRAME", self, "CommentatorCooldownPlayerTemplate");
end

local function RowComparator(left, right)
	local leftRole = left:GetRole();
	local rightRole = right:GetRole();
	if leftRole ~= rightRole then
		if leftRole == "HEALER" then
			return true;
		elseif rightRole == "HEALER" then
			return false;
		end

		if leftRole == "TANK" then
			return true;
		elseif rightRole == "TANK" then
			return false;
		end
	end

	return strcmputf8i(left:GetPlayerName(), right:GetPlayerName()) < 0;
end

function CommentatorCooldownTeamMixin:Refresh(teamIndex)
	if self.teamIndex ~= teamIndex then
		self.teamIndex = teamIndex;
		self:SetTeam(teamIndex);
	end

	local numPlayers = C_Commentator.GetNumPlayers(teamIndex);
	if numPlayers == 0 then
		self:Hide();
		return;
	end

	local activeRows = {};

	self.playerRowPool:ReleaseAll();
	for playerIndex = 1, numPlayers do
		local row = self.playerRowPool:Acquire();
		row:Show();
		row:ClearAllPoints()

		row:SetTeamAndPlayer(teamIndex, playerIndex);

		activeRows[#activeRows + 1] = row;
	end

	table.sort(activeRows, RowComparator);

	for i, row in ipairs(activeRows) do
		local prevRow = activeRows[i - 1];
		row:SetPoint("TOP", prevRow or self, prevRow and "BOTTOM" or "TOP");
	end

	self:SetHeight(#activeRows > 0 and activeRows[1]:GetHeight() * numPlayers or 0);
	self:Show();
end

do
	local ATLASES_FOR_TEAM = {
		{ corner = "tournamentarena-frame-bg-corner-red", side = "tournamentarena-frame-bg-side-red" },
		{ corner = "tournamentarena-frame-bg-corner-blue", side = "tournamentarena-frame-bg-side-blue" },
	}

	function CommentatorCooldownTeamMixin:SetTeam(teamIndex)
		local atlases = ATLASES_FOR_TEAM[teamIndex];
		if atlases then
			for i, corner in ipairs(self.ColoredCorners) do
				corner:SetAtlas(atlases.corner);
			end

			for i, side in ipairs(self.ColoredSides) do
				side:SetAtlas(atlases.side);
			end
		end
	end
end


CommentatorCooldownPlayerMixin = {};

function CommentatorCooldownPlayerMixin:OnLoad()
	local teamIndex, playerIndex = self:GetTeamAndPlayer();
	self.offensiveCooldownPool = CreateCommentatorSpellPool(self.Container, teamIndex, playerIndex, "CommentatorCooldownFrameTemplate");
	self.defensiveCooldownPool = CreateCommentatorSpellPool(self.Container, teamIndex, playerIndex, "CommentatorCooldownFrameTemplate");
end

function CommentatorCooldownPlayerMixin:SetTeamAndPlayer(teamIndex, playerIndex)
	self.teamIndex = teamIndex;
	self.playerIndex = playerIndex;

	local unitToken, playerName, faction, specID = C_Commentator.GetPlayerInfo(teamIndex, playerIndex);
	self:SetPlayerName(playerName);
	self:SetClass(select(2, UnitClass(unitToken)));
	self:SetRole(GetSpecializationRoleByID(specID));

	self.offensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	self.defensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	local offensiveSpells = C_Commentator.GetTrackedSpells(teamIndex, playerIndex, Enum.TrackedSpellCategory.Offensive);
	local defensiveSpells = C_Commentator.GetTrackedSpells(teamIndex, playerIndex, Enum.TrackedSpellCategory.Defensive);
	self:UpdateSpells(offensiveSpells, defensiveSpells);
end

function CommentatorCooldownPlayerMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorCooldownPlayerMixin:Clear()
	self:Hide();
end

function CommentatorCooldownPlayerMixin:SetPlayerName(name)
	self.Name:SetText(name);
end

function CommentatorCooldownPlayerMixin:GetPlayerName()
	return self.Name:GetText();
end

function CommentatorCooldownPlayerMixin:SetClass(class)
	local color = RAID_CLASS_COLORS[class];
	if color then
		self.Name:SetVertexColor(color.r, color.g, color.b, 1.0);
	else
		self.Name:SetVertexColor(0, 1.0, 0, 1.0);
	end
end

function CommentatorCooldownPlayerMixin:SetRole(role)
	if role == nil or role == "DAMAGER" then
		self.RoleIcon:Hide();
	else
		self.RoleIcon:Show();
		if role == "HEALER" then
			self.RoleIcon:SetAtlas("HealerBadge");
		elseif role == "TANK" then
			self.RoleIcon:SetAtlas("TankBadge");
		end
	end
	self.role = role;
end

function CommentatorCooldownPlayerMixin:GetRole()
	return self.role;
end

function CommentatorCooldownPlayerMixin:UpdateSpells(offensiveSpells, defensiveSpells)
	local MAX_TRACKED_SPELLS = 10;
	while #offensiveSpells + #defensiveSpells > MAX_TRACKED_SPELLS do
		if #offensiveSpells > #defensiveSpells then
			offensiveSpells[#offensiveSpells] = nil;
		else
			defensiveSpells[#defensiveSpells] = nil;
		end
	end

	local PADDING = 5;
	self.offensiveCooldownPool:ConstructFrames(offensiveSpells, COMMENTATOR_MAX_OFFENSIVE_SPELLS, self.Container, "LEFT", PADDING);
	self.defensiveCooldownPool:ConstructFrames(defensiveSpells, COMMENTATOR_MAX_DEFENSIVE_SPELLS, self.Container, "RIGHT", PADDING);
end

CommentatorSpellPoolMixin = {};

function CreateCommentatorSpellPool(parent, teamIndex, playerIndex, frameTemplate)
	return CreateAndInitFromMixin(CommentatorSpellPoolMixin, parent, teamIndex, playerIndex, frameTemplate);
end

function CommentatorSpellPoolMixin:Init(parent, teamIndex, playerIndex, frameTemplate)
	self.activeSpells = {};
	self.teamIndex = teamIndex;
	self.playerIndex = playerIndex;
	self.framePool = CreateFramePool("FRAME", parent, frameTemplate);
end

function CommentatorSpellPoolMixin:SetTeamAndPlayer(teamIndex, playerIndex)
	wipe(self.activeSpells);
	self.teamIndex = teamIndex;
	self.playerIndex = playerIndex;
end

function CommentatorSpellPoolMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorSpellPoolMixin:SetSpellActive(trackedSpellID, isActive)
	self.activeSpells[trackedSpellID] = isActive;
	for spellFrame in self.framePool:EnumerateActive() do
		if spellFrame:GetSpellID() == trackedSpellID then
			spellFrame:SetSpellActive(isActive);
			self:UpdateAlignment();
			break;
		end
	end
end

function CommentatorSpellPoolMixin:IsSpellActive(trackedSpellID)
	return self.activeSpells[trackedSpellID] == true;
end

function CommentatorSpellPoolMixin:ConstructFrames(spells, maxSpells, container, point, padding)
	self:Release();

	-- Reserve enough frames for every spell so the order of frames returned by
	-- EnumerateActive remains the same below, and in UpdateAlignment().
	local frameCount = math.min(#spells, maxSpells);
	for index = 1, frameCount do
		self.framePool:Acquire();
	end

	local direction = point == "LEFT" and 1 or -1;
	local spellIndex = 1;
	for frame in self.framePool:EnumerateActive() do
		frame:Initialize(self, spells[spellIndex]);
		frame.aligner = function(alignIndex)
			frame:ClearAllPoints();
			local extents = frame:GetWidth() + padding;
			local offset = alignIndex * extents;
			frame:SetPoint(point, container, point, offset * direction, 5);
			return extents;
		end;
		frame:SetShown(true);
		spellIndex = spellIndex + 1;
	end

	self:UpdateAlignment();
end
 
function CommentatorSpellPoolMixin:Release()
	self.framePool:ReleaseAll();
end

function CommentatorSpellPoolMixin:UpdateAlignment()
	local alignIndex = 0;
	local totalWidth = 0;
	for frame in self.framePool:EnumerateActive() do
		local extents = frame.aligner(alignIndex);
		totalWidth = totalWidth + extents;
		alignIndex = alignIndex + 1;
	end
	self.framePool.parent:SetWidth(totalWidth);
end

CommentatorSpellFrameMixin = {};

function CommentatorSpellFrameMixin:GetSpellID()
	return self.spellID;
end

function CommentatorSpellFrameMixin:GetIndirectSpellID()
	return self.indirectSpellID;
end

function CommentatorSpellFrameMixin:IsSpellActive()
	return self.isSpellActive;
end

function CommentatorSpellFrameMixin:Initialize(pool, spellID)
	self.pool = pool;
	self.spellID = spellID;
	self.indirectSpellID = C_Commentator.GetIndirectSpellID(spellID);

	self:Update();
end

-- derive
function CommentatorSpellFrameMixin:Update()
	local icon = select(3, GetSpellInfo(self.spellID));
	self.Icon:SetTexture(icon);
	
	self:SetSpellActive(self.pool:IsSpellActive(self.spellID));
end

-- derive
function CommentatorSpellFrameMixin:SetSpellActive(isSpellActive)
	self.isSpellActive = isSpellActive;
	self:UpdateCooldownSwipe();
end

-- derive
function CommentatorSpellFrameMixin:UpdateCooldownSwipe()
end

CommentatorCooldownFrameMixin = CreateFromMixins(CommentatorSpellFrameMixin);

function CommentatorCooldownFrameMixin:SetSpellActive(isSpellActive)
	CommentatorSpellFrameMixin.SetSpellActive(self, isSpellActive);

	self.ActiveGlow:SetShown(isSpellActive);
	self.Ants:SetShown(isSpellActive);
end

function CommentatorCooldownFrameMixin:Update()
	CommentatorSpellFrameMixin.Update(self);

	local teamIndex, playerIndex = self.pool:GetTeamAndPlayer();
	local charges, maxCharges, chargeStart, chargeDuration = C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, self:GetSpellID());
	local displayCharges = charges and maxCharges and maxCharges > 1;
	self.ChargesText:SetText(displayCharges and charges or "");
end

function CommentatorCooldownFrameMixin:UpdateCooldownSwipe()
	CommentatorSpellFrameMixin.UpdateCooldownSwipe(self);

	if self:IsSpellActive() then
		CooldownFrame_Clear(self.Cooldown);
	else
		local teamIndex, playerIndex = self.pool:GetTeamAndPlayer();
		local charges, maxCharges, chargeStart, chargeDuration = C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, self:GetSpellID());
		if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
			self.Charges:SetCooldown(chargeStart, chargeDuration);
		end
		
		local start, duration, enable = C_Commentator.GetPlayerCooldownInfo(teamIndex, playerIndex, self:GetSpellID());
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
	end
end

CommentatorDebuffFrameMixin = CreateFromMixins(CommentatorSpellFrameMixin);

function CommentatorDebuffFrameMixin:UpdateCooldownSwipe()
	CommentatorSpellFrameMixin.UpdateCooldownSwipe(self);

	local teamIndex, playerIndex = self.pool:GetTeamAndPlayer();
	local start, duration, enable = C_Commentator.GetPlayerAuraInfo(teamIndex, playerIndex, self:GetIndirectSpellID());
	CooldownFrame_Set(self.Cooldown, start, duration, enable);
end