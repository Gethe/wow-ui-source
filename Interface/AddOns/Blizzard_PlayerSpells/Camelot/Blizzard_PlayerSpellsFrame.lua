-- Camelot PlayerSpellsFrameMixin overrides

-- Keep these in sync with PlayerSpells XML spellbook width key values.
-- If changed, update XML on frame PlayerSpellsFrame:
--   - KeyValue spellBookMinimizedWidth
--   - KeyValue spellBookMaximizedWidth
--   - Size x
local MKB_SPELLBOOK_PLAYER_MIN_WIDTH = 577;
local MKB_SPELLBOOK_PLAYER_MAX_WIDTH = 1154;
local GAMEPAD_SPELLBOOK_PLAYER_MIN_WIDTH = 709;
local GAMEPAD_SPELLBOOK_PLAYER_MAX_WIDTH = 1518;

function PlayerSpellsFrameMixin:GetAssociatedMicroButtons()
	return { SpellbookMicroButton, TalentMicroButton };
end

function PlayerSpellsFrameMixin:GetDesiredMaximizedWidth(tabID)
	if tabID == self.spellBookTabID then
		if InputUtil.IsGamepadUIEnabled() then
			return GAMEPAD_SPELLBOOK_PLAYER_MAX_WIDTH;
		end

		return MKB_SPELLBOOK_PLAYER_MAX_WIDTH;
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
		if InputUtil.IsGamepadUIEnabled() then
			return GAMEPAD_SPELLBOOK_PLAYER_MIN_WIDTH;
		end

		return MKB_SPELLBOOK_PLAYER_MIN_WIDTH;
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

function PlayerSpellsFrameMixin:AreaAttributeForTab(frameTab)
	if frameTab == PlayerSpellsUtil.FrameTabs.SpellBook and self.isMinimizingEnabled then
		return "centerOrLeft";
	end

	return "center";
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

local BaseSetTabMinimized = PlayerSpellsFrameMixin.SetTabMinimized;
function PlayerSpellsFrameMixin:SetTabMinimized(tabID, shouldBeMinimized)
	if tabID == self.spellBookTabID then
		SetUIPanelAttribute(self, "area", shouldBeMinimized and "left" or "centerOrLeft");
	end

	BaseSetTabMinimized(self, tabID, shouldBeMinimized);
end

local BaseSetTab = PlayerSpellsFrameMixin.SetTab;
function PlayerSpellsFrameMixin:SetTab(tabID)
	if not self:IsShown() and tabID == self.spellBookTabID and not self.hasInitializedSpellBookOpenState then
		self.hasInitializedSpellBookOpenState = true;
		self:SetMinimizedOnNextShow(true);
	end

	return BaseSetTab(self, tabID);
end
