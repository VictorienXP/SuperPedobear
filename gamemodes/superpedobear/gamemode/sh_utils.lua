--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()

local v = include("semver.lua")

function GM:Log(str, hardcore)
	if not hardcore or spb_enabledevmode:GetBool() then
		Msg("[Super Pedobear] " .. (str or "This was a log message, but something went wrong") .. "\n")
	end
	if spb_enabledevmode:GetBool() then
		self:LogToFile(" [LOG] " .. str)
	end
end

function GM:ErrorLog(str)
	ErrorNoHalt("[Super Pedobear] " .. (str or "This was an error message, but something went wrong") .. "\n")
	if spb_enabledevmode:GetBool() then
		self:LogToFile(" [ERROR] " .. str)
	end
end

function GM:DebugLog(str)
	if spb_enabledevmode:GetBool() then
		Msg("[Super Pedobear] " .. (str or "This was a debug message, but something went wrong") .. "\n")
		self:LogToFile("\t[DEBUG]\t" .. str)
	end
end

function GM:LogToFile(str)
	file.Append("superpedobear/log.txt", SysTime() .. str .. "\n")
end

function GM:GetHost()
	if self.Vars.Host and IsValid(self.Vars.Host) then
		return self.Vars.Host
	end
	for _, v in pairs(player.GetAll()) do
		local host = v:GetNWBool("IsListenServerHost", false)
		if host then
			self.Vars.Host = v
			return v
		end
	end
	return nil
end

GM.PlayerMeta = GM.PlayerMeta or FindMetaTable("Player")

GM.PlayerMeta.RealNick = GM.PlayerMeta.RealNick or GM.PlayerMeta.Nick
function GM.PlayerMeta:Nick()
	if GAMEMODE:IsSeasonalEvent("LennyFaceDay") then return "( ͡° ͜ʖ ͡°)" end
	return self:RealNick()
end

function GM.PlayerMeta:GetPowerUP()
	if CLIENT then return self:GetNWString("spb_PowerUP", "none") end
	return self.SPB_PowerUP
end

function GM.PlayerMeta:HasPowerUP()
	if CLIENT then
		if self:GetNWString("spb_PowerUP", "none") ~= "none" then
			return true
		else
			return false
		end
	end
	if self.SPB_PowerUP and self.SPB_PowerUP ~= "none" then
		return true
	else
		return false
	end
end

function GM.PlayerMeta:IsCloaked()
	local var = self.spb_CloakTime or self:GetNWFloat("spb_CloakTime", nil)
	if not var then
		return nil
	end
	return var >= CurTime()
end

function GM:SelectRandomPowerUP(ply)
	for k, v in RandomPairs(self.PowerUps) do
		if not IsValid(ply) or v[2] == ply:Team() or v[2] == 0 then
			return k
		end
	end
	return nil
end

function GM:GetClosestPlayer(ply, pteam)
	local seeker
	local distance
	local t
	local list = team.GetPlayers(pteam)
	for k, v in pairs(list) do
		if v:Alive() and v:IsLineOfSightClear(ply) then
			t = v:GetPos():Distance(ply:GetPos())
			if (not distance or distance < t) then
				distance = t
				seeker = v
			end
		end
	end
	return seeker, distance
end

function GM:GetPowerUpPrice(id, ply, ignorereduc)
	local price = spb_shop_base_price:GetInt()
	local ignoreadd = false
	if price == 0 then
		return 0
	elseif price < 0 then
		price = price * -1
		ignoreadd = true
	end
	if not ignoreadd and self.PowerUps[id] and self.PowerUps[id][5] then
		price = price + self.PowerUps[id][5]
	end
	if not ignorereduc and ply:GetNWInt("XperidiaRank", 0) > 0 then
		price = price / 2
	end
	return math.Round(price)
end

function GM.PlayerMeta:IsGamemodeAuthor() --Credits
	return self:SteamID() == "STEAM_0:1:18280147"
end

function GM:IsSeasonalEvent(str)
	local Timestamp = os.time()
	for _, v in pairs(self.SeasonalEvents) do
		local i = 0
		if str == v[1] then
			while v[3 + i] do
				if (os.date("%d/%m", Timestamp) == v[3 + i]) then
					return true
				end
				i = i + 1
			end
		end
	end
	return false
end

function GM:SeasonalEventStr()
	local Timestamp = os.time()
	for _, v in pairs(self.SeasonalEvents) do
		local i = 0
		while v[3 + i] do
			if (os.date("%d/%m", Timestamp) == v[3 + i]) then
				return v[2]
			end
			i = i + 1
		end
	end
	return ""
end

function GM:FormatTime(time)
	local timet = string.FormattedTime(time)
	if timet.h >= 999 then
		return "∞"
	elseif timet.h >= 1 then
		return string.format("%02i:%02i", timet.h, timet.m)
	elseif timet.m >= 1 then
		return string.format("%02i:%02i", timet.m, timet.s)
	else
		return string.format("%02i.%02i", timet.s, math.Clamp(timet.ms, 0, 99))
	end
end

function GM:FormatTimeTri(time)
	local timet = string.FormattedTime(time)
	if timet.h > 0 then
		return string.format("%02i:%02i:%02i", timet.h, timet.m, timet.s)
	end
	return string.format("%02i:%02i", timet.m, timet.s)
end

function GM:PrettyMusicName(snd)
	local str = string.StripExtension(snd)
	str = string.Replace(str, "_", " ")
	str = string.Replace(str, "%20", " ")
	return string.gsub(str, "(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

function GM:BuildMusicIndex()

	local function ReadMusicInfo(pre)

		local mlist = {}

		local lua = file.Find("superpedobear/" .. Either(pre, "premusics", "musics") .. "/*.lua", "LUA")

		for _, v in pairs(lua) do
			local ft = include("superpedobear/" .. Either(pre, "premusics", "musics") .. '/' .. v)
			table.Add(mlist, ft)
		end

		local infos = file.Find("superpedobear/" .. Either(pre, "premusics", "musics") .. "/*.json", "DATA")

		for _, v in pairs(infos) do
			local fileml = file.Read("superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. v)
			local tmlist = util.JSONToTable(fileml)
			table.Add(mlist, tmlist)
		end

		return mlist

	end

	local musiclist = ReadMusicInfo()
	local premusiclist = ReadMusicInfo(true)

	if SERVER then
		self.Musics.musics = musiclist
		self.Musics.premusics = premusiclist
		if not game.IsDedicated() then self:SendMusicIndex() end
	else
		self.LocalMusics.musics = musiclist
		self.LocalMusics.premusics = premusiclist
	end

end

function GM:BuildTauntIndex()

	if SERVER then

		local function ReadTauntInfo()

			local taunt_list = {}

			local lua_taunts = file.Find("superpedobear/taunts/*.lua", "LUA")

			for _, v in pairs(lua_taunts) do
				local taunts = include("superpedobear/taunts/" .. v)
				table.Add(taunt_list, taunts)
			end

			local json_taunts = file.Find("superpedobear/taunts/*.json", "DATA")

			for _, v in pairs(json_taunts) do
				local taunt_file = file.Read("superpedobear/taunts/" .. v)
				local taunts = util.JSONToTable(taunt_file)
				table.Add(taunt_list, taunts)
			end

			return taunt_list

		end

		local tauntlist = ReadTauntInfo()

		self.Taunts = tauntlist
		if not game.IsDedicated() then self:SendTauntIndex() end

	end

end

function GM:VersionCompare(cur, last)
	if cur.major ~= last.major then return cur.major < last.major end
	if cur.minor ~= last.minor then return cur.minor < last.minor end
	if cur.patch ~= last.patch then return cur.patch < last.patch end
	return false
end

function GM:VersionEqual(cur, last)
	return	cur.major == last.major and
			cur.minor == last.minor and
			cur.patch == last.patch and
			cur.prerelease == last.prerelease
end

GM.LatestRelease = GM.LatestRelease or {}
function GM:CheckForNewRelease()
	if not self.Version then return nil end
	return HTTP({
		url			=	"https://api.github.com/repos/Xperidia/SuperPedobear/releases/latest",
		method		=	"GET",
		headers		=	{ Accept = "application/json, application/vnd.github.v3+json" },
		success		=	function(code, body, headers)
							if code == 200 then
								local result = util.JSONToTable(body)
								if result and result.tag_name then
									self.LatestRelease.Version = v(result.tag_name)
									self.LatestRelease.Name = result.name or nil
									self.LatestRelease.URL = result.html_url or nil
									self.LatestRelease.prerelease = result.prerelease or false
									self.LatestRelease.Newer = self:VersionCompare(self.Version, self.LatestRelease.Version)
								end
								self:Log("The latest release tag is v" .. tostring(self.LatestRelease.Version) .. ". " .. Either(self.LatestRelease.Newer, "You're on v" .. tostring(self.Version) .. "! An update is available!", "You're on the latest version (v" .. tostring(self.Version) .. ")."))
							else
								local state = headers.Status or code
								self:Log("Couldn't check for new release: " .. state)
							end
						end,
		failed		=	function(reason)
							self:Log("Couldn't check for new release: " .. reason)
						end
	})
end

function GM:FindOGGTag(tags, tag)
	for k, vtag in pairs(tags) do
		if string.StartWith(vtag, tag .. "=") then
			local title = string.sub(vtag, #tag + 2)
			if title and #title > 0 then
				return string.Trim(title)
			end
		end
	end
	return nil
end

function GM.AutoCompletePowerUP(cmd, args)

	args = string.Trim(args)
	args = string.lower(args)

	local tbl = {}

	for k, v in pairs(self.PowerUps) do

		if string.find(k, args) then

			k = cmd .. " " .. k

			table.insert(tbl, k)

		end

	end

	return tbl

end

-- This should probably only be called clientside.
function GM:FormatLangPhrase(phrase, ...)

	local args = {...}

	for k, v in pairs(args) do

		if isstring(v) then

			args[k] = self:GetCensoredPhrase(v)

		end

	end

	return string.format(self:GetCensoredPhrase(phrase), unpack(args))

end

function GM:GetCensoredPhrase(str)

	if not isstring(str) or #str < 1 then return str end

	if str[1] ~= "$" then
		--TODO: maybe implement actual global censoring
		return str
	end

	str = string.Right(str, #str - 1)

	if #str > 2 and string.Right(str, 2) == ".x" then

		local level = spb_censoring_level:GetInt()

		if level >= 0 and level <= 2 then
			str = string.Left(str, #str - 1) .. level
		else
			str = string.Left(str, #str - 1) .. "0"
		end

	end

	--[[	This library/function does not seems exist on SERVER
					so here is this check if it ever does			]]
	if not language or not language.GetPhrase then
		return str
	end

	return language.GetPhrase(str)

end

local a_load_scrn_urls = {
	["https://assets.xperidia.com/garrysmod/loading.html#auto-spb"] = true,
	["https://assets.xperidia.com/garrysmod/loading.html#auto"] = true,
	["https://xperidia.com/GMOD/loading/?auto"] = true,
}

local ls_url = "https://assets.xperidia.com/garrysmod/loading.html#auto-spb"

--[[----------------------------------------------------------------------------
	Use the Xperidia's loading screen if no other loading screen is defined...
	Because it shows more information than the current default of Garry's Mod...
------------------------------------------------------------------------------]]
function GM:SetAutoLoadingScreen()

	local c_url = GetConVar("sv_loadingurl"):GetString()

	if c_url ~= "" and not a_load_scrn_urls[c_url] then
		return
	end

	RunConsoleCommand("sv_loadingurl", ls_url)

end

--Put back the default Garry's Mod loading screen...
function GM:RemoveAutoLoadingScreen()

	if a_load_scrn_urls[GetConVar("sv_loadingurl"):GetString()] then
		RunConsoleCommand("sv_loadingurl", "")
	end

end
