local contents = {};
local issecure = issecure;

function SecureCapsuleGet(name)
	if ( not issecure() ) then
		return;
	end

	return contents[name];
end

-------------------------------
--Local functions for retaining.
-------------------------------

--Retains a copy of name
local function retain(name)
	if ( type(_G[name]) == "table" ) then
		contents[name] = CopyTable(_G[name]);
	else
		contents[name] = _G[name];
	end
end

--Takes name and removes it from the global environment (note: make sure that nothing else has saved off a copy)
local function take(name)
	contents[name] = _G[name];
	_G[name] = nil;
end


-------------------------------
--Things we actually want to save
-------------------------------

--For store
if ( IsGMClient() ) then
	retain("C_PurchaseAPI");
else
	take("C_PurchaseAPI");
end
retain("math");
retain("pairs");

--GlobalStrings
retain("BLIZZARD_STORE");
take("BLIZZARD_STORE_ON_SALE");
take("BLIZZARD_STORE_BUY");
take("BLIZZARD_STORE_PLUS_TAX");
take("BLIZZARD_STORE_PRODUCT_INDEX");
take("BLIZZARD_STORE_CANCEL_PURCHASE");
take("BLIZZARD_STORE_FINAL_BUY");
take("BLIZZARD_STORE_CONFIRMATION_TITLE");
take("BLIZZARD_STORE_CONFIRMATION_INSTRUCTION");
take("BLIZZARD_STORE_FINAL_PRICE_LABEL");
take("BLIZZARD_STORE_PAYMENT_METHOD");
take("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");
