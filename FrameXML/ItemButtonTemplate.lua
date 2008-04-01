
function SetItemButtonCount(button, count)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	if ( count > 1 or (button.isBag and count > 0) ) then
		if ( count > 999 ) then
			count = "*";
		end
		getglobal(button:GetName().."Count"):SetText(count);
		getglobal(button:GetName().."Count"):Show();
	else
		getglobal(button:GetName().."Count"):Hide();
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
		getglobal(button:GetName().."Stock"):SetText(format(MERCHANT_STOCK, numInStock));
		getglobal(button:GetName().."Stock"):Show();
	else
		getglobal(button:GetName().."Stock"):Hide();
	end
end

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end
	if ( texture ) then
		getglobal(button:GetName().."IconTexture"):Show();
	else
		getglobal(button:GetName().."IconTexture"):Hide();
	end
	getglobal(button:GetName().."IconTexture"):SetTexture(texture);
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	getglobal(button:GetName().."IconTexture"):SetVertexColor(r, g, b);
end

function SetItemButtonDesaturated(button, desaturated, r, g, b)
	if ( not button ) then
		return;
	end
	local icon = getglobal(button:GetName().."IconTexture");
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
	
	getglobal(button:GetName().."NormalTexture"):SetVertexColor(r, g, b);
end

function SetItemButtonNameFrameVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	getglobal(button:GetName().."NameFrame"):SetVertexColor(r, g, b);
end

function SetItemButtonSlotVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	getglobal(button:GetName().."SlotTexture"):SetVertexColor(r, g, b);
end
