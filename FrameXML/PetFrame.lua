--PET_WARNING_TIME = 55;
--PET_FLASH_ON_TIME = 0.5;
--PET_FLASH_OFF_TIME = 0.5;

function PetFrame_OnLoad()
	this.attackModeCounter = 0;
	this.attackModeSign = -1;
	--this.flashState = 1;
	--this.flashTimer = 0;
	PetFrame_Update();
	CombatFeedback_Initialize(PetHitIndicator, 30);
	this:RegisterEvent("UNIT_COMBAT");
	this:RegisterEvent("UNIT_SPELLMISS");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("PLAYER_PET_CHANGED");
	this:RegisterEvent("PET_ATTACK_START");
	this:RegisterEvent("PET_ATTACK_STOP");
	this:RegisterEvent("UNIT_HAPPINESS");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function PetFrame_Update()
	if ( UnitExists("pet") ) then
		if ( this:IsVisible() ) then
			UnitFrame_Update();
		else
			this:Show();
		end
		--this.flashState = 1;
		--this.flashTimer = PET_FLASH_ON_TIME;
		if ( UnitManaMax("pet") == 0 ) then
			PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
		else
			PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
		end

		PetFrame_SetHappiness();
	else
		this:Hide();
	end
end

function PetFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "UNIT_SPELLMISS" ) then
		if ( arg1 == "pet" ) then
			CombatFeedback_OnSpellMissEvent(arg2);
		end
	end
	if ( event == "UNIT_COMBAT" ) then
		if ( arg1 == "pet" ) then
			CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5);
		end
		return;
	end
	if ( event == "UNIT_AURA" ) then
		if ( arg1 == "pet" ) then
			PetFrame_RefreshBuffs();
		end
	end
	if ( event == "PLAYER_PET_CHANGED" ) then
		PetFrame_Update();
		PetAttackModeTexture:Hide();
		PetFrame_RefreshBuffs();
		return;
	end
	if ( event == "PET_ATTACK_START" ) then
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		PetAttackModeTexture:Show();
		return;
	end
	if ( event == "PET_ATTACK_STOP" ) then
		PetAttackModeTexture:Hide();
		return;
	end
	if ( event == "UNIT_HAPPINESS" ) then
		PetFrame_SetHappiness();
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		PetFrame_Update();
		return;
	end
end

function PetFrame_OnUpdate(elapsed)
	if ( PetAttackModeTexture:IsVisible() ) then
		local alpha = 255;
		local counter = this.attackModeCounter + elapsed;
		local sign    = this.attackModeSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			this.attackModeSign = sign;
		end
		counter = mod(counter, 0.5);
		this.attackModeCounter = counter;

		if ( sign == 1 ) then
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, alpha);
	end
	CombatFeedback_OnUpdate(elapsed);
	-- Expiration flash stuff
	--local petTimeRemaining = nil;
	--if ( GetPetTimeRemaining() ) then
	---	if ( this.flashState == 1 ) then
	--		this:SetAlpha(this.flashTimer/PET_FLASH_ON_TIME);
	--	else
	--		this:SetAlpha((PET_FLASH_OFF_TIME - this.flashTimer)/PET_FLASH_OFF_TIME);
	--	end
	--	petTimeRemaining = GetPetTimeRemaining() / 1000;
	--end
	--if ( petTimeRemaining and (petTimeRemaining < PET_WARNING_TIME) ) then
	--	PetFrame.flashTimer = PetFrame.flashTimer - elapsed;
	--	if ( PetFrame.flashTimer <= 0 ) then
	--		if ( PetFrame.flashState == 1 ) then
	--			PetFrame.flashState = 0;
	--			PetFrame.flashTimer = PET_FLASH_OFF_TIME;
	--		else
	--			PetFrame.flashState = 1;
	--			PetFrame.flashTimer = PET_FLASH_ON_TIME;
	--		end
	--	end
	--end
	
end

function PetFrame_OnClick(button)
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("pet");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("pet");
		else
			TargetUnit("pet");
		end
	else
		if(PetCanBeAbandoned()) then
			if(PetCanBeRenamed()) then
				UnitPopup_ShowMenu(this, "PET_RENAME", "pet");
			else
				UnitPopup_ShowMenu(this, "PET", "pet");
			end
		else
			UnitPopup_ShowMenu(this, "PET_NOABANDON", "pet");
		end
		UnitPopup:ClearAllPoints();
		UnitPopup:SetPoint("TOPLEFT", this:GetName(), "BOTTOMLEFT", 30, 24);
	end
end

function PetFrame_SetHappiness()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness();
	if ( not HasPetUI() ) then
		PetFrameHappiness:Hide();
		return;	
	end
	PetFrameHappiness:Show();
	if ( happiness == 1 ) then
		PetFrameHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif ( happiness == 2 ) then
		PetFrameHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif ( happiness == 3 ) then
		PetFrameHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end
	PetFrameHappiness.tooltip = getglobal("PET_HAPPINESS"..happiness);
	PetFrameHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
	if ( loyaltyRate < 0 ) then
		PetFrameHappiness.tooltipLoyalty = getglobal("LOSING_LOYALTY");
	elseif ( loyaltyRate > 0 ) then
		PetFrameHappiness.tooltipLoyalty = getglobal("GAINING_LOYALTY");
	else
		PetFrameHappiness.tooltipLoyalty = nil;
	end
end

function PetFrame_RefreshBuffs()
	local debuff, debuffButton;
	for i=1, MAX_PARTY_DEBUFFS do
		debuff = UnitDebuff("pet", i);
		if ( debuff ) then
			getglobal("PetDebuff"..i.."Icon"):SetTexture(debuff);
			getglobal("PetDebuff"..i):Show();
		else
			getglobal("PetDebuff"..i):Hide();
		end
	end
end