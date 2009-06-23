
function SetItemButtonCount(button, count)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	if ( count > 1 or (button.isBag and count > 0) ) then
		if ( count > (button.maxDisplayCount or 9999) ) then
			count = "*";
		end
		_G[button:GetName().."Count"]:SetText(count);
		_G[button:GetName().."Count"]:Show();
	else
		_G[button:GetName().."Count"]:Hide();
	end
end

function SetItemButtonStock(button, numInStock)
	if ( not button ) then
		return;
	end

	if ( not numInStock ) then
		numInStock = "";
	end

	button.numInStock = numInStock;
	if ( numInStock > 0 ) then
		_G[button:GetName().."Stock"]:SetFormattedText(MERCHANT_STOCK, numInStock);
		_G[button:GetName().."Stock"]:Show();
	else
		_G[button:GetName().."Stock"]:Hide();
	end
end

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end
	if ( texture ) then
		_G[button:GetName().."IconTexture"]:Show();
	else
		_G[button:GetName().."IconTexture"]:Hide();
	end
	_G[button:GetName().."IconTexture"]:SetTexture(texture);
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."IconTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonDesaturated(button, desaturated, r, g, b)
	if ( not button ) then
		return;
	end
	local icon = _G[button:GetName().."IconTexture"];
	if ( not icon ) then
		return;
	end
	local shaderSupported = icon:SetDesaturated(desaturated);

	if ( not desaturated ) then
		r = 1.0;
		g = 1.0;
		b = 1.0;
	elseif ( not r or not shaderSupported ) then
		r = 0.5;
		g = 0.5;
		b = 0.5;
	end
	
	icon:SetVertexColor(r, g, b);
end

function SetItemButtonNormalTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."NormalTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonNameFrameVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."NameFrame"]:SetVertexColor(r, g, b);
end

function SetItemButtonSlotVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."SlotTexture"]:SetVertexColor(r, g, b);
end

function HandleModifiedItemClick(link)
	if ( IsModifiedClick("CHATLINK") ) then
		if ( ChatEdit_InsertLink(link) ) then
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		DressUpItemLink(link);
		return true;
	end
	return false;
end
