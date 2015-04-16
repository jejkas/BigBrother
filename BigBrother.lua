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





SLASH_BigBrother1 = "/BigBrother";


SlashCmdList["BigBrother"] = function(args)
	if args == ""
	then
		BigBrother_UI_frame:Show();
	elseif args == "lock"
	then
		
	elseif args == "hide"
	then
		
	end
end;


















function BigBrother_OnUpdate()
	if BigBrother_LastAddonMessageTime + BigBrother_LastAddonMessageDelay <= GetTime()
	then
		if BigBrother_TableLength(BigBrother_AddonMessageBuffer) > 0
		then
			--BigBrother_("Sending Addon message");
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
		end
		BigBrother_UI_CreateFrames();
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
				local playerClass, englishClass = UnitClass("player");
				local talString, shortTalent = BigBrother_GetTalentString();
				BigBrother_SendAddonMessage("BigBrother_Talent_Respond", englishClass .. "_" .. talString .. "_" .. shortTalent, "GUILD");
			end;
		end;
		
		if arg1 == "BigBrother_Talent_Respond"
		then
			local msg = arg2;
			local split = __strsplit("_",msg);
			local requestClass = split[1];
			local talentString = split[2];
			local shortTalent = split[3];
			local senderUsername = arg4;
			
			if not BigBrother_Database[senderUsername]
			then
				BigBrother_Database[senderUsername] = {};
			end
			
			BigBrother_Database[senderUsername]["Talent"] = {}
			BigBrother_Database[senderUsername]["Talent"]["class"] = requestClass;
			BigBrother_Database[senderUsername]["Talent"]["talent"] = talentString;
			BigBrother_Database[senderUsername]["Talent"]["shortTalent"] = shortTalent;
			BigBrother_UI_UserList_ApplyFilter();
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
		
		
		if arg1 == "BigBrother_Inventory_Respond"
		then
			local msg = arg2;
			local split = __strsplit("_",msg);
			local requestClass = split[1];
			local talentString = split[2];
			local senderUsername = arg4;
			
			if not BigBrother_Database[senderUsername]["Inventory"]
			then
				BigBrother_Database[senderUsername]["Inventory"] = {};
				BigBrother_Database[senderUsername]["Inventory"]["lastUpdate"] = 0;
			end
			
			if BigBrother_Database[senderUsername]["Inventory"]["lastUpdate"] + 10 < GetTime()
			then
				BigBrother_Database[senderUsername]["Inventory"]["Items"] = {};
			end
			
			BigBrother_Database[senderUsername]["Inventory"]["lastUpdate"] = GetTime();
			--BigBrother_(msg);
			local items = BigBrother_BreakInventoryString(msg);
			--BigBrother_(items);
			
			for k,v in items
			do
				--BigBrother_(v);
				table.insert(BigBrother_Database[senderUsername]["Inventory"]["Items"], v);
			end;
		end;
	end;
end


BigBrother_AddonMessageBuffer = {};
function BigBrother_SendAddonMessage(messageID, message, channel)
	--BigBrother_("Got request to send addon message");
	local data = {};
	data["messageID"] = messageID;
	data["message"] = message;
	data["channel"] = channel;
	table.insert(BigBrother_AddonMessageBuffer, data);
end;



function BigBrother_GetTalentString()
	local talentStr = "";
	local shortTalent = "";
	local page = GetNumTalentTabs();
	for t=1, page do
	    local numTalents = GetNumTalents(t);
		local points = 0;
	    for i=1, numTalents do
			nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i);
			--BigBrother_(nameTalent);
			--BigBrother_(tier);
			--BigBrother_(column);
			--BigBrother_(currRank .. " / " .. maxRank);
			talentStr = talentStr .. currRank;
			points = points + currRank;
	    end
		shortTalent = shortTalent .. points .. "/";
	end
	
	--BigBrother_(string.sub(shortTalent, 1, -2));
	
	return talentStr, string.sub(shortTalent, 1, -2); -- Why 2? not sure why, -1 gave me all.
end;

function BigBrother_GetTalentURL(talentStr, class)
	local 	url = "http://www.wowprovider.com/Old.aspx?talent=11215875_"; -- Core URL
			url = url .. BigBrother_ClassNumber[class]; -- Adding class number
			url = url .. "_8" .. talentStr; -- Not 100% sure here, but works on max level at least!
	return url;
end;



BigBrother_RequestList = {};
BigBrother_LastRequest = 0;

function BigBrother_RequestDataFrom(username)
	if BigBrother_LastRequest + 0.1 < GetTime()
	then
		BigBrother_RequestTalentsFrom(username);
		BigBrother_RequestInventoryFrom(username);
		BigBrother_LastRequest = GetTime();
	end;
end;


--/script BigBrother_RequestTalentsFrom("Rexwarrior")
function BigBrother_RequestTalentsFrom(username)
	local messageChannel = nil;
	
	if BigBrother_UserInGuild(username)
	then
		BigBrother_SendAddonMessage("BigBrother_Talent_Request", username, "GUILD");
		return true;
	end;
	
	if BigBrother_UserInRaid(username)
	then
		BigBrother_SendAddonMessage("BigBrother_Talent_Request", username, "RAID");
		return true;
	end;
	
	return false;
end;

function BigBrother_RequestTalentsUnit(unit)
	-- Anti spam, only once per 2 sec.
	local messageChannel = nil;
	
	if UnitInRaid(unit) or UnitInParty(unit)
	then
		messageChannel = "RAID";
	end;
	
	if GetGuildInfo(unit) == GetGuildInfo("player")
	then
		-- Keep data with in the guild.
		messageChannel = "GUILD";
	end;
	
	if messageChannel
	then
		BigBrother_SendAddonMessage("BigBrother_Talent_Request", UnitName(unit), messageChannel);
	end;
end;

function BigBrother_UserInRaid(username)
	local unitStr = "raid";
	local size = 40;
	if not UnitInRaid("player")
	then
		unitStr = "party";
		size = 5;
	end;
	
	for i = 1, size
	do
		local unit = unitStr..i;
		if UnitExists(unit) and string.lower(UnitName(unit)) == string.lower(username)
		then
			return true;
		end;
	end;
	return false;
end;

function BigBrother_UserInGuild(username)
	local i = 1;
	while GetGuildRosterInfo(i) ~= nil
	do
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i);
		if name and string.lower(name) == string.lower(username)
		then
			return true;
		end;
		i = i + 1;
	end;
	return false;
end;


--/script BigBrother_RequestInventoryFrom("Rexwarrior")
function BigBrother_RequestInventoryFrom(username)
	local messageChannel = nil;
	
	if BigBrother_UserInGuild(username)
	then
		BigBrother_SendAddonMessage("BigBrother_Inventory_Request", username, "GUILD");
		return true;
	end;
	
	if BigBrother_UserInRaid(username)
	then
		BigBrother_SendAddonMessage("BigBrother_Inventory_Request", username, "RAID");
		return true;
	end;
	
	return false;
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

--[[
	UI stuff down here
]]
function BigBrother_UI_MoveFrameStart(arg1, frame)
	if not frame.isMoving
	then
		if arg1 == "LeftButton" and frame:IsMovable()
		then
			frame:StartMoving();
			frame.isMoving = true;
		end
	end;
end;
function BigBrother_UI_MoveFrameStop(arg1, frame)
	if frame.isMoving
	then
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		--OoI_Settings["frameRelativePos"] = relativePoint;
		--OoI_Settings["frameXPos"] = xOfs;
		--OoI_Settings["frameYPos"] = yOfs;
		
		frame:StopMovingOrSizing();
		frame.isMoving = false;
	end
end;

function BigBrother_UI_UpdateAutorollListScrollBar(self)
	--BigBrother_("Scroll event triggered.");
	--DEFAULT_CHAT_FRAME:AddMessage("We're at "..FauxScrollFrame_GetOffset(BigBrother_UI_frame_AutorollList_ScrollBar));
	--DEFAULT_CHAT_FRAME:AddMessage("We're at "..FauxScrollFrame_GetOffset(BigBrother_UI_frame_InventoryList_ScrollBar));
end












BigBrother_UI_UserList_Data = {};
BigBrother_UI_UserList_ClassFilter = nil;

function BigBrother_UI_UserList_ApplyFilter()
	BigBrother_UI_UserList_Data = BigBrother_UI_UserList_GetData();
	local data = BigBrother_UI_UserList_Data;
	local dataLength = BigBrother_TableLength(data);
	
	-- Frame, amountOfLine, linesShown, lineHeightInPixels
	FauxScrollFrame_Update(BigBrother_UI_frame_AutorollList_ScrollBar,dataLength,10,18);
	
	BigBrother_UI_UserList_Render();
end


function BigBrother_UI_UserList_GetData()
	local filterFrame = BigBrother_UI_frame_AutorollListHeader_Filter;
	local filterString = filterFrame:GetText()
	local data = {};
	
	--BigBrother_UI_UserList_ClassFilter
	for username,d in pairs(BigBrother_Database)
	do
		if filterString
		then
			if string.find(string.lower(username), string.lower(filterString))
			then
				if (
					BigBrother_UI_UserList_ClassFilter
					and BigBrother_Database[username]["Talent"]
					and BigBrother_Database[username]["Talent"]["class"] == BigBrother_UI_UserList_ClassFilter
					)
					or
					not BigBrother_UI_UserList_ClassFilter
				then
					table.insert(data, username);
				end
			end
		else
			table.insert(data, username);
		end;
	end;
	
	--BigBrother_(data);
	
	return data;
end

function BigBrother_UI_UserList_Render()
	local data = BigBrother_UI_UserList_Data;
	local offset = FauxScrollFrame_GetOffset(BigBrother_UI_frame_AutorollList_ScrollBar);
	local dataLength = BigBrother_TableLength(data);
	for i = 1, 10, 1
	do
		local pos = i + offset;
		local frame = getglobal("BigBrother_UI_frame_AutorollList_Item"..i);
		local text = getglobal(frame:GetName().."_Text");
		local talentText = getglobal(frame:GetName().."_TalentText");
		local talent = getglobal(frame:GetName().."_Talent");
		--BigBrother_(i)
		
		if pos > dataLength
		then
			frame:Hide();
			frame.username = nil;
			text:SetText("NONE");
			talent:SetText("NONE");
			talentText:SetText("0/0/0");
		else
			local username = data[pos];
			
			text:SetText(username);
			if BigBrother_Database[username]["Talent"]
			then
				talentText:SetText(BigBrother_Database[username]["Talent"]["shortTalent"]);
				talent:SetText(
					BigBrother_GetTalentURL(
						BigBrother_Database[username]["Talent"]["talent"],
						BigBrother_Database[username]["Talent"]["class"]
					)
				);
			end
			frame.username = username;
			text:SetTextColor(0.5, 0.5, 0.5);
			frame:Show();
		end
	end
end












BigBrother_UI_ItemList_Data = {};
BigBrother_UI_InventoryUsername = nil;



function BigBrother_UI_ItemList_ApplyFilter()
	BigBrother_UI_ItemList_Data = BigBrother_GetNameSort(BigBrother_UI_ItemList_GetData());
	local data = BigBrother_UI_ItemList_Data;
	local dataLength = BigBrother_TableLength(data);
	
	--BigBrother_(dataLength);
	
	-- Frame, amountOfLine, linesShown, lineHeightInPixels
	FauxScrollFrame_Update(BigBrother_UI_frame_InventoryList_ScrollBar,dataLength,10,18);
	
	BigBrother_UI_ItemList_Render();
end


function BigBrother_UI_ItemList_GetData()
	local filterFrame = BigBrother_UI_frame_AutorollListHeader_FilterInventory;
	local filterString = filterFrame:GetText()
	local data = {};
	
	if not BigBrother_UI_InventoryUsername
	or not BigBrother_Database[BigBrother_UI_InventoryUsername]
	or not BigBrother_Database[BigBrother_UI_InventoryUsername]["Inventory"]
	or not BigBrother_Database[BigBrother_UI_InventoryUsername]["Inventory"]["Items"]
	then
		return data;
	end;
	
	for _,item in pairs(BigBrother_Database[BigBrother_UI_InventoryUsername]["Inventory"]["Items"])
	do
		if filterString
		then
			if string.find(string.lower(item["name"]), string.lower(filterString))
			then
				table.insert(data, item);
			end
		else
			table.insert(data, item);
		end;
	end;
	
	--BigBrother_(data);
	
	return data;
end

function BigBrother_UI_ItemList_Render()
	local data = BigBrother_UI_ItemList_Data;
	local offset = FauxScrollFrame_GetOffset(BigBrother_UI_frame_InventoryList_ScrollBar);
	local dataLength = BigBrother_TableLength(data);
	
	for i = 1, 10, 1
	do
		local pos = i + offset;
		local frame = getglobal("BigBrother_UI_frame_InventoryList_Item"..i);
		local amountFrame = getglobal(frame:GetName().."_Amount");
		local itemText = getglobal(frame:GetName().."_Text");
		--BigBrother_(i)
		
		if pos > dataLength
		then
			frame:Hide();
			frame.itemString = nil;
			itemText:SetText("NONE");
		else
			local item = data[pos];
			
			amountFrame:SetText(item["amount"] .. "x ");
			
			itemText:SetText("["..item["name"].."]");
			local r,g,b = BigBrother_HexToRGBPerc(string.sub(item["color"], 3, 8));
			itemText:SetTextColor(r, g, b);
			frame.itemString = item["itemID"];
			frame:Show();
		end
	end
end







-- /script BigBrother_GetNameSort(BigBrother_Database[BigBrother_UI_InventoryUsername]["Inventory"]["Items"])
-- /script BigBrother_(BigBrother_GetNameSort(BigBrother_Database[BigBrother_UI_InventoryUsername]["Inventory"]["Items"]))
function BigBrother_GetNameSort(tbl)
	local keys = {}
	for key,v in pairs(tbl) do
		table.insert(keys, v)
	end
	
	table.sort(keys, function(a, b)
		return a["name"] < b["name"]
	end)
	
	return keys
end


function BigBrother_HexToRGBPerc(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

function BigBrother_MakeClassDropDown()
	UIDropDownMenu_AddButton({
		text = "All";
		func = BigBrother_HandleClassDropDown;
		arg1 = nil;
	});
	
	for className,v in pairs(BigBrother_ClassNumber)
	do
		UIDropDownMenu_AddButton({
			text = className;
			func = BigBrother_HandleClassDropDown;
			arg1 = className;
		});
	end
end

function BigBrother_HandleClassDropDown()
	UIDropDownMenu_SetSelectedID(BigBrother_UI_frame_AutorollListHeader_UnitList_ClassFilter, this:GetID());
	BigBrother_UI_UserList_ClassFilter = this.arg1;
	BigBrother_UI_UserList_ApplyFilter();
end;

function BigBrother_UI_CreateFrames()
	BigBrother_UI_frame:SetScript("OnMouseDown", function() BigBrother_UI_MoveFrameStart(arg1, this); end)
	BigBrother_UI_frame:SetScript("OnMouseUp", function() BigBrother_UI_MoveFrameStop(arg1, this); end)
	BigBrother_UI_frame:SetMovable(true);
	BigBrother_UI_frame:EnableMouse(true);
	BigBrother_UI_frame:SetResizable(true);
	--BigBrother_UI_frame:Show();
	
	local ClassFilter = BigBrother_UI_frame_AutorollListHeader_UnitList_ClassFilter;
	
	UIDropDownMenu_Initialize(ClassFilter, BigBrother_MakeClassDropDown);
	UIDropDownMenu_SetSelectedID(ClassFilter, 1);
	--UIDropDownMenu_SetWidth(100, ClassFilter);
	
	
	
	BigBrother_UI_UserList_ApplyFilter();
	BigBrother_UI_ItemList_ApplyFilter();
end


BigBrother = CreateFrame("FRAME", "BigBrother");
BigBrother:RegisterEvent("ADDON_LOADED");
BigBrother:RegisterEvent("PLAYER_LOGIN");
BigBrother:RegisterEvent("CHAT_MSG_SYSTEM");
BigBrother:RegisterEvent("CHAT_MSG_ADDON");
BigBrother:SetScript("OnUpdate", BigBrother_OnUpdate);
BigBrother:SetScript("OnEvent", BigBrother_OnEvent);


