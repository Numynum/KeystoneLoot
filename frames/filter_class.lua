local AddonName, Addon = ...;


Addon.SELECTED_CLASS_ID = 0;
Addon.SELECTED_SPEC_ID = 0;


local function SetFilter(classID, specID)
	Addon.SELECTED_CLASS_ID = classID;
	Addon.SELECTED_SPEC_ID = specID;
	Addon.API.UpdateLoot();

	local text;
	local classInfo = C_CreatureInfo.GetClassInfo(classID);
	local classColorStr = RAID_CLASS_COLORS[classInfo.classFile].colorStr;

	if (specID > 0) then
		local specName = GetSpecializationNameForSpecID(specID) or UNKNOWN;

		text = HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT:format(classColorStr, classInfo.className, specName);
	else
		text = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classInfo.className);
	end

	Addon.API.SetDropDownMenuText(text);
end
Addon.SetClassFilter = SetFilter;

local function InitDropDownMenu()
	local SELECTED_CLASS_ID = Addon.SELECTED_CLASS_ID;
	local SELECTED_SPEC_ID = Addon.SELECTED_SPEC_ID;
	local list = {};

	local numClasses = GetNumClasses();
	for i=1, numClasses do
		local classDisplayName, classFile, classID = GetClassInfo(i);
		local classColorStr = RAID_CLASS_COLORS[classFile].colorStr;

		if (classID == SELECTED_CLASS_ID and i ~= 1) then
			local info = {};
			info.divider = true;
			table.insert(list, info);
		end

		local info = {};
		info.text = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classDisplayName);
		info.checked = SELECTED_CLASS_ID == classID;
		info.notCheckable = info.checked;
		info.disabled = info.checked;
		info.args = { classID, 0 };
		info.func = SetFilter;
		info.keepShownOnClick = true;
		table.insert(list, info);

		if (classID == SELECTED_CLASS_ID) then
			for y=1, GetNumSpecializationsForClassID(classID) do
				local specID, specName = GetSpecializationInfoForClassID(classID, y);

				local info = {};
				info.leftPadding = 10;
				info.text = specName;
				info.checked = SELECTED_SPEC_ID == specID;
				info.disabled = info.checked;
				info.args = { classID, specID };
				info.func = SetFilter;
				table.insert(list, info);
			end

			local info = {};
			info.leftPadding = 10;
			info.text = ALL_SPECS;
			info.checked = (SELECTED_CLASS_ID == classID and SELECTED_SPEC_ID == 0);
			info.disabled = info.checked;
			info.args = { classID, 0 };
			info.func = SetFilter;
			table.insert(list, info);

			if (i ~= numClasses) then
				local info = {};
				info.divider = true;
				table.insert(list, info);
			end
		end
	end

	return list;
end


local Filter = Addon.CreateFilterButton('class', InitDropDownMenu);
Filter:SetPoint('TOP', -120, -35);

Addon.SELECTED_FILTER_BUTTON = Filter;