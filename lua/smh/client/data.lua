
local SaveDir = "smh/";

local function RefreshEaseOptions(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		container.ShowEaseOptions = false;
		return;
	end

	container.EaseIn = frame.EaseIn;
	container.EaseOut = frame.EaseOut;
	container.ShowEaseOptions = true;

end

local function EaseInChanged(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		return;
	end

	if value ~= frame.EaseIn then
		frame.NewEaseIn = value;
		container.EditedFrame = frame;
	end

end

local function EaseOutChanged(container, key, value)

	local position = container.Position;
	local frames = container.ActiveFrames;

	local frame = table.First(frames, function(item) return item.Position == position; end);
	if not frame then
		return;
	end

	if value ~= frame.EaseOut then
		frame.NewEaseOut = value;
		container.EditedFrame = frame;
	end

end

local function ShowSettingsMenu(container, key)
	if not container.ShowSettings then
		container.ShowSettings = true;
	end
end

local function ShowHelpMenu(container, key)
	if not container.ShowHelp then
		container.ShowHelp = true;
	end
end

local function ShowSaveMenu(container, key)
	if not container.ShowSave then
		container.ShowSave = true;
	end
end

local function ShowLoadMenu(container, key)
	if not container.ShowLoad then
		container.ShowLoad = true;
	end
end

local function RefreshSaveList(container, key, value)

	if value == false then
		return;
	end

	local files, dirs = file.Find(SaveDir .. "*.txt", "DATA");

	local saves = {};
	for _, file in pairs(files) do
		table.insert(saves, file:sub(1, -5));
	end

	container.SaveFiles = saves;

end

local function LoadFileChanged(container, key, value)

	if not value or value == "" then
		container.LoadFileEntities = {};
		return;
	end

	local path = SaveDir .. value .. ".txt";
	if not file.Exists(path, "DATA") then
		container.LoadFileEntities = {};
		return;
	end

	local json = file.Read(path);
	local data = util.JSONToTable(json);
	if not data then
		container.LoadFileEntities = {};
		return;
	end

	local ents = {};
	for _, ent in pairs(data.Entities) do
		table.insert(ents, ent.Model);
	end

	container.LoadFileEntities = ents;

end

local function LoadEntityChanged(container, key, value)

	local loadFile = container.LoadFileName;

	if not value or value == "" then
		container.LoadData = {};
		return;
	end

	local path = SaveDir .. "/" .. loadFile .. ".txt";
	if not file.Exists(path, "DATA") then
		container.LoadData = {};
		return;
	end

	local json = file.Read(path);
	local data = util.JSONToTable(json);
	if not data then
		container.LoadData = {};
		return;
	end

	local eData = table.First(data.Entities, function(item) return item.Model == value; end);
	if not eData then
		container.LoadData = {};
		return;
	end

	container.LoadData = eData;

end

local function SaveDataChanged(container, key, value)

	local fileName = container.SaveFileName;

	if not value or not fileName or fileName == "" then
		return;
	end

	if not file.Exists(SaveDir, "DATA") or not file.IsDir(SaveDir, "DATA") then
		file.CreateDir(SaveDir);
	end

	local path = SaveDir .. "/" .. fileName .. ".txt";
	file.Write(path, value);

	container[key] = nil;

	container.SaveFileName = "";
	RefreshSaveList(container, key, true);

end

local function ToggleOnionSkin(container, key, value)
	if value then
		SMH.EnableOnionSkin();
	else
		SMH.DisableOnionSkin();
	end
end

local function OnionDataChanged(container, key, value)
	if container.OnionSkin and table.Count(value) > 0 then
		SMH.EnableOnionSkin();
	end
end

function SMH.SetupData()

	local defaults = table.Copy(SMH.DefaultData);
	defaults.ShowSettingsMenu = ShowSettingsMenu;
	defaults.ShowHelpMenu = ShowHelpMenu;
	defaults.ShowSaveMenu = ShowSaveMenu;
	defaults.ShowLoadMenu = ShowLoadMenu;

	local data = BiValues.New(LocalPlayer(), "SMHData", {UseSync = true, AutoApply = true}, defaults);

	data:_Listen("Position", RefreshEaseOptions);
	data:_Listen("ActiveFrames", RefreshEaseOptions);
	data:_Listen("EaseIn", EaseInChanged);
	data:_Listen("EaseOut", EaseOutChanged);

	data:_Listen("ShowLoad", RefreshSaveList);
	data:_Listen("LoadFileName", LoadFileChanged);
	data:_Listen("LoadFileEntity", LoadEntityChanged);

	data:_Listen("ShowSave", RefreshSaveList);
	data:_Listen("SaveData", SaveDataChanged);

	data:_Listen("OnionSkin", ToggleOnionSkin);
	data:_Listen("OnionSkinData", OnionDataChanged);

	SMH.Data = data;

end