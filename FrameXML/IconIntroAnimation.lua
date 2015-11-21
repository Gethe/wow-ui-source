

--This File is responsible for animating spells to the actionbar
MULTIBOTTOMLEFTINDEX = 6;

function IconIntroTracker_OnLoad(self)
	self.iconList = {};
	self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
end


function IconIntroTracker_OnEvent(self, event, ...)
	if event == "SPELL_PUSHED_TO_ACTIONBAR" then
		local spellID, slotIndex, slotPos = ...;
		MarkNewActionHighlight(slotIndex, true);

		local page = math.floor((slotIndex - 1) / NUM_ACTIONBAR_BUTTONS) + 1;
		local currentPage = GetActionBarPage();
		
		local bonusBarIndex = GetBonusBarIndex();
		if (HasBonusActionBar() and bonusBarIndex ~= 0) then
			currentPage = bonusBarIndex;
		end

		if (page ~= currentPage and page ~= MULTIBOTTOMLEFTINDEX) then
			return;
		end
		
		local _, _, icon = GetSpellInfo(spellID);
		local freeIcon;
	
		for a,b in pairs(self.iconList) do
			if b.isFree then
				freeIcon = b;
			end
		end
		
		if not freeIcon then -- Make a new one
			freeIcon = CreateFrame("FRAME", self:GetName().."Icon"..(#self.iconList+1), UIParent, "IconIntroTemplate");
			self.iconList[#self.iconList+1] = freeIcon;
		end
	
		freeIcon.icon.icon:SetTexture(icon);
		freeIcon.icon.slot = slotIndex;
		freeIcon.icon.pos = slotPos;
 		freeIcon:ClearAllPoints();

		
		if (page == MULTIBOTTOMLEFTINDEX) then
			freeIcon:SetPoint("CENTER", _G["MultiBarBottomLeftButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["MultiBarBottomLeftButton"..slotPos]:GetFrameLevel()+1);
			freeIcon.icon.multibar = true;
		else
			freeIcon:SetPoint("CENTER", _G["ActionButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["ActionButton"..slotPos]:GetFrameLevel()+1);
			freeIcon.icon.multibar = false;
		end
		
		freeIcon.icon.flyin:Play(1);
		freeIcon.isFree = false;
	end
end
