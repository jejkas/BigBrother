BigBrother_ClassNumber = {};
BigBrother_ClassNumber["DRUID"] = 11;
BigBrother_ClassNumber["HUNTER"] = 3;
BigBrother_ClassNumber["MAGE"] = 8;
BigBrother_ClassNumber["PALADIN"] = 2;
BigBrother_ClassNumber["PRIEST"] = 5;
BigBrother_ClassNumber["ROGUE"] = 4;
BigBrother_ClassNumber["SHAMAN"] = 7;
BigBrother_ClassNumber["WARLOCK"] = 9;
BigBrother_ClassNumber["WARRIOR"] = 1; --- #1 class confirmed.

BigBrother_ClassTalentLists = {}
BigBrother_ClassTalentLists["DRUID"] = {};
BigBrother_ClassTalentLists["HUNTER"] = {};
BigBrother_ClassTalentLists["MAGE"] = {};
BigBrother_ClassTalentLists["PALADIN"] = {};
BigBrother_ClassTalentLists["PRIEST"] = {};
BigBrother_ClassTalentLists["ROGUE"] = {};
BigBrother_ClassTalentLists["SHAMAN"] = {};
BigBrother_ClassTalentLists["WARLOCK"] = {};
BigBrother_ClassTalentLists["WARRIOR"] = {};

BigBrother_LastAddonMessageTime = 0;
BigBrother_LastAddonMessageDelay = 2;

function BigBrother_OnUpdate()
	if BigBrother_LastAddonMessageTime + BigBrother_LastAddonMessageDelay <= GetTime()
	then
		if BigBrother_TableLength(BigBrother_AddonMessageBuffer) > 0
		then
			BigBrother_("Sending Addon message");
			local data = table.remove(BigBrother_AddonMessageBuffer, 1);
			
			local messageID = data["messageID"];
			local message = data["message"];
			local channel = data["channel"];
			BigBrother_LastAddonMessageTime = GetTime();
			SendAddonMessage(messageID, message, channel);
		end;
	end
end

BigBrother_LastResponsSent = 0;

function BigBrother_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "BigBrother"
	then
		if not BigBrother_Database
		then
			BigBrother_("Loading default save.");
			BigBrother_Database = {};
			BigBrother_Database["Talent"] = {}
			BigBrother_Database["Inventory"] = {}
		end
	end
	
	if event == "CHAT_MSG_ADDON"
	then
		-- /script BigBrother_SendAddonMessage("BigBrother_Talent_Request", "Rexwarrior", "GUILD");
		--
		-- TALENT EVENTS
		--
		if arg1 == "BigBrother_Talent_Request"
		then
			local requestName = arg2;
			if UnitName("Player") == requestName --or requestName == "all" -- All might be a bit laggy.
			then
				if BigBrother_LastResponsSent + 2 < GetTime()
				then
					local playerClass, englishClass = UnitClass("player");
					BigBrother_SendAddonMessage("BigBrother_Talent_Respond", englishClass .. "_" .. BigBrother_GetTalentString(), "GUILD");
					BigBrother_LastResponsSent = GetTime();
				end;
			end;
		end;
		
		if arg1 == "BigBrother_Talent_Respond"
		then
			local msg = arg2;
			local split = __strsplit("_",msg);
			local requestClass = split[1];
			local talentString = split[2];
			local senderUsername = arg4;
			
			BigBrother_Database["Talent"][senderUsername] = {}
			BigBrother_Database["Talent"][senderUsername]["class"] = requestClass;
			BigBrother_Database["Talent"][senderUsername]["talent"] = talentString;
			
			if BigBrother_RequestList[senderUsername] == true
			then
				BigBrother_URL_frame_textBox:SetText(BigBrother_GetTalentURL(talentString, requestClass));
				BigBrother_URL_frame:Show();
				BigBrother_RequestList[senderUsername] = false;
			end;
		end;
		
		
		
		
		--
		-- INVENTORY EVENTS
		--
		
		
		
		
		-- /script BigBrother_SendAddonMessage("BigBrother_Inventory_Request", "Rexwarrior", "GUILD");
		if arg1 == "BigBrother_Inventory_Request"
		then
			local requestName = arg2;
			if UnitName("Player") == requestName --or requestName == "all" -- All might be a bit laggy.
			then
				if BigBrother_LastResponsSent + 2 < GetTime()
				then
					local playerClass, englishClass = UnitClass("player");
					local d = BigBrother_MakeInventoryStrings(BigBrother_GetInventory());
					for k,v in pairs(d)
					do
						--BigBrother_(d[k]);
						BigBrother_SendAddonMessage("BigBrother_Inventory_Respond", d[k], "GUILD");
					end;
					BigBrother_LastResponsSent = GetTime();
				end;
			end;
		end;
		
		
		if arg1 == "BigBrother_Inventory_Respond"
		then
			local msg = arg2;
			local split = __strsplit("_",msg);
			local requestClass = split[1];
			local talentString = split[2];
			local senderUsername = arg4;
			
			if not BigBrother_Database["Inventory"][senderUsername]
			then
				BigBrother_Database["Inventory"][senderUsername] = {};
				BigBrother_Database["Inventory"][senderUsername]["lastUpdate"] = 0;
			end
			
			if BigBrother_Database["Inventory"][senderUsername]["lastUpdate"] + 10 < GetTime()
			then
				BigBrother_Database["Inventory"][senderUsername]["Items"] = {};
			end
			
			BigBrother_Database["Inventory"][senderUsername]["lastUpdate"] = GetTime();
			BigBrother_(msg);
			local items = BigBrother_BreakInventoryString(msg);
			--BigBrother_(items);
			
			for k,v in items
			do
				BigBrother_(v);
				table.insert(BigBrother_Database["Inventory"][senderUsername]["Items"], v);
			end;
		end;
	end;
end


BigBrother_AddonMessageBuffer = {};
function BigBrother_SendAddonMessage(messageID, message, channel)
	BigBrother_("Got request to send addon message");
	local data = {};
	data["messageID"] = messageID;
	data["message"] = message;
	data["channel"] = channel;
	table.insert(BigBrother_AddonMessageBuffer, data);
end;



function BigBrother_GetTalentString()
	local talentStr = "";
	local page = GetNumTalentTabs();
	for t=1, page do
	    local numTalents = GetNumTalents(t);
	    for i=1, numTalents do
			nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i);
			--BigBrother_(nameTalent);
			--BigBrother_(tier);
			--BigBrother_(column);
			--BigBrother_(currRank .. " / " .. maxRank);
			talentStr = talentStr .. currRank;
	    end
	end
	return talentStr;
end;

function BigBrother_GetTalentURL(talentStr, class)
	local 	url = "http://www.wowprovider.com/Old.aspx?talent=11215875_"; -- Core URL
			url = url .. BigBrother_ClassNumber[class]; -- Adding class number
			url = url .. "_8" .. talentStr; -- Not 100% sure here, but works on max level at least!
	return url;
end;



BigBrother_RequestList = {};
BigBrother_LastRequest = 0;

--/script BigBrother_RequestTalentsFrom("Rexwarrior")
function BigBrother_RequestTalentsFrom(unitName)
	-- Anti spam, only once per 2 sec.
	if BigBrother_LastRequest + 2 < GetTime()
	then
		BigBrother_SendAddonMessage("BigBrother_Talent_Request", unitName, "GUILD");
		BigBrother_RequestList[unitName] = true;
	end
end;

--/script BigBrother_RequestTalentsFrom("Rexwarrior")
function BigBrother_RequestInventoryFrom(unitName)
	-- Anti spam, only once per 2 sec.
	if BigBrother_LastRequest + 2 < GetTime()
	then
		BigBrother_SendAddonMessage("BigBrother_Inventory_Request", unitName, "GUILD");
	end
end;



-- /script BigBrother_GetInventory()
function BigBrother_GetInventory()
	local returnData = {};
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot);
			local item = GetContainerItemLink(bag,slot)
			if item
			then
				--local found, _, itemString = string.find(item, "^|%x+|Hitem\:(.+)\:%[.+%]");
				local a, b, color, itemID, name = string.find(item, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r")
				--BigBrother_(a .. " - " .. b .. " - " .. color .. " - " .. itemID .. " - " .. name);
				if a
				then
					if not returnData[itemID]
					then
						returnData[itemID] = {};
						returnData[itemID]["amount"] = 0;
					end
					returnData[itemID]["itemID"] = itemID;
					returnData[itemID]["color"] = color;
					returnData[itemID]["name"] = name;
					returnData[itemID]["amount"] = returnData[itemID]["amount"] + itemCount;
				end
			end
		end
	end
	return returnData;
end

-- /script BigBrother_MakeInventoryStrings(BigBrother_GetInventory())
function BigBrother_MakeInventoryStrings(itemData)
	local returnStrings = {};
	local itemString = "";
	for _,item in pairs(itemData)
	do
		local str = item["amount"]..";"..item["itemID"]..";"..item["color"]..";"..item["name"].."~";
		--BigBrother_(item);
		-- amount;itemID;color;name~
		if string.len(str) + string.len(itemString) > 200
		then
			table.insert(returnStrings, itemString)
			itemString = "";
		end
		itemString = itemString .. str;
	end;
	--BigBrother_(returnStrings);
	return returnStrings;
end

-- /script local d = BigBrother_MakeInventoryStrings(BigBrother_GetInventory()); for k,v in pairs(d) do BigBrother_BreakInventoryString(d[k]) end;
function BigBrother_BreakInventoryString(str)
	local items = __strsplit("~", str);
	--BigBrother_(items);
	
	local returnArr = {};
	
	for key,itemStr in pairs(items)
	do
		if string.len(itemStr) > 5
		then
			local item = __strsplit(";", itemStr);
			--BigBrother_(key);
			--BigBrother_(itemStr);
			--BigBrother_(item);
			local amount 	= item[1];
			local itemID 	= item[2];
			local color 	= item[3];
			local name 		= item[4];
			
			--BigBrother_(amount.."x |c"..color.."|Hitem:"..itemID.."|h["..name.."]|h|r");
			
			local tmp = {}
			tmp["amount"] = amount;
			tmp["itemID"] = itemID;
			tmp["color"] = color;
			tmp["name"] = name;
			
			table.insert(returnArr, tmp);
		end;
	end
	return returnArr;
end;






function BigBrother_TableLength(t)
	i = 0;
	for k,v in pairs(t)
	do
		i = i + 1;
	end
	
	return i;
end



function BigBrother_(str)
	local c = ChatFrame1;
	
	if str == nil
	then
		c:AddMessage('BigBrother: NIL'); --ChatFrame1
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('BigBrother: true');
		else
			c:AddMessage('BigBrother: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('BigBrother: array');
		BigBrother_printArray(str);
	else
		c:AddMessage('BigBrother: '..str);
	end;
end;

function BigBrother_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			BigBrother_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				BigBrother_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				BigBrother_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					BigBrother_(n .. "[\"" .. key .. "\"] = true");
				else
					BigBrother_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				BigBrother_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

function __strsplit(sep,str)
	if str == nil
	then
		return false;
	end;
	local arr = {}
	local tmp = "";
	
	--printDebug(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end



BigBrother = CreateFrame("FRAME", "BigBrother");
BigBrother:RegisterEvent("ADDON_LOADED");
BigBrother:RegisterEvent("PLAYER_LOGIN");
BigBrother:RegisterEvent("CHAT_MSG_SYSTEM");
BigBrother:RegisterEvent("CHAT_MSG_ADDON");
BigBrother:SetScript("OnUpdate", BigBrother_OnUpdate);
BigBrother:SetScript("OnEvent", BigBrother_OnEvent);
