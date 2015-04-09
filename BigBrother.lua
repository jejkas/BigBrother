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

BigBrother_TalenData = {};

function BigBrother_OnUpdate()
end

BigBrother_LastResponsSent = 0;

function BigBrother_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "BigBrother"
	then
		
	end
	
	if event == "CHAT_MSG_ADDON"
	then
		-- /script SendAddonMessage("BigBrother_Talent_Request", "Rexwarrior", "GUILD");
		if arg1 == "BigBrother_Talent_Request"
		then
			local requestName = arg2;
			if UnitName("Player") == requestName or requestName == "all"
			then
				if BigBrother_LastResponsSent + 2 < GetTime()
				then
					local playerClass, englishClass = UnitClass("player");
					SendAddonMessage("BigBrother_Talent_Respond", englishClass .. "_" .. BigBrother_GetTalentString(), "GUILD");
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
			local msgFromUser = arg4;
			
			BigBrother_TalenData[msgFromUser] = {}
			BigBrother_TalenData[msgFromUser]["class"] = requestClass;
			BigBrother_TalenData[msgFromUser]["talent"] = talentString;
			
			if BigBrother_RequestList[msgFromUser] == true
			then
				BigBrother_URL_frame_textBox:SetText(BigBrother_GetTalentURL(talentString, requestClass));
				BigBrother_URL_frame:Show();
				BigBrother_RequestList[msgFromUser] = false;
			end;
		end;
	end;
end


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
		SendAddonMessage("BigBrother_Talent_Request", unitName, "GUILD");
		BigBrother_RequestList[unitName] = true;
	end
end;















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
