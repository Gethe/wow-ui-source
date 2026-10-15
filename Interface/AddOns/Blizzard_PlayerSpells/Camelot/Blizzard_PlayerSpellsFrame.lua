-- Camelot PlayerSpellsFrameMixin overrides

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
PlayerSpellsFrameMixin.useFooterJumpHints = true;

-- Text to display next to jump hints on other frames, if the jump takes them here
function PlayerSpellsFrameMixin:GetJumpHintLabel()
	local tabID = self:GetTab();
	if tabID == self.specTabID then
		return SPECIALIZATION;
	elseif tabID == self.talentTabID then
		return TALENTS;
	else --if tabID == self.spellBookTabID
		return SPELLBOOK;
	end
end

function PlayerSpellsFrameMixin:GetAssociatedMicroButtons()
	return { SpellbookMicroButton, TalentMicroButton };
end

function PlayerSpellsFrameMixin:GetDesiredMaximizedWidth(tabID)
	if tabID == self.spellBookTabID then
		return self.spellBookMaximizedWidth;
	else
		return self.talentsWidth;
	end
end

function PlayerSpellsFrameMixin:GetDesiredMaximizedHeight(tabID)
	if tabID == self.spellBookTabID then
		return self.spellBookHeight;
	else
		return self.talentsHeight;
	end
end

function PlayerSpellsFrameMixin:GetDesiredMinimizedWidth(tabID)
	if tabID == self.spellBookTabID then
		return self.spellBookMinimizedWidth;
	else
		return self.talentsWidth;
	end
end

function PlayerSpellsFrameMixin:GetDesiredMinimizedHeight(tabID)
	if tabID == self.spellBookTabID then
		return self.spellBookHeight;
	else
		return self.talentsHeight;
	end
end

function PlayerSpellsFrameMixin:IsTabSystemAvailable()
	-- Preserve the overall mainline structure that the Spellbook and Class Talents Frames are part
	-- of PlayerSpellsFrame but keep the functionality and player experience like classic, where they
	-- are different frames toggled from the menu micro buttons.
	return false;
end

function PlayerSpellsFrameMixin:UpdatePortrait()
	local tabID = self:GetTab();
	if tabID == self.spellBookTabID then
		self:SetSpellBookPortrait();
	else
		self:SetTalentPortrait();
	end
end

function PlayerSpellsFrameMixin:SetSpellBookPortrait()
	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.General);
	if skillLineInfo then
		self:SetPortraitTexCoord(0, 1, 0, 1);
		self:SetPortraitToAsset(skillLineInfo.iconID);
	end
end

function PlayerSpellsFrameMixin:SetTalentPortrait()
	local classID = self:GetClassID();
	self:SetPortraitToClassIcon(C_CreatureInfo.GetClassInfo(classID).classFile);
end

function PlayerSpellsFrameMixin:AreaAttributeForTab(frameTab)
	if frameTab == PlayerSpellsUtil.FrameTabs.SpellBook then
		if self.isMinimizingEnabled then
			return "centerOrLeft";
		end

		return "center";			
	elseif frameTab == PlayerSpellsUtil.FrameTabs.ClassTalents then
		return "center"
	end
end
