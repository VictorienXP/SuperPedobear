--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

include("shared.lua")
include("cl_scoreboard.lua")
include("cl_menu.lua")
include("cl_tauntmenu.lua")
include("cl_voice.lua")
include("cl_deathnotice.lua")
include("cl_pedovan.lua")

DEFINE_BASECLASS("gamemode_base")

surface.CreateFont("SuperPedobear_TIME", {
	font = "Roboto",
	size = 75,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("SuperPedobear_RND", {
	font = "Roboto",
	size = 50,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("SuperPedobear_TXT", {
	font = "Roboto",
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("SuperPedobear_HT", {
	font = "Roboto",
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("SuperPedobear_HUDname", {
	font = "Roboto",
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

net.Receive("SuperPedobear_PlayerStats", function( len )
	GAMEMODE.Vars.victims = net.ReadInt(32)
	GAMEMODE.Vars.downvictims = net.ReadInt(32)
end)

net.Receive("SuperPedobear_Vars", function( len )
	GAMEMODE.Vars.Round.Start = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStart = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStartTime = net.ReadFloat()
	GAMEMODE.Vars.Round.Time = net.ReadFloat()
	GAMEMODE.Vars.Round.End = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Win = net.ReadInt(32)
	GAMEMODE.Vars.Rounds = net.ReadInt(32)
	GAMEMODE.Vars.Round.LastTime = net.ReadFloat()
end)

net.Receive("SuperPedobear_Music", function( len )
	local src = net.ReadString()
	local pre = net.ReadBool()
	local name = net.ReadString()
	GAMEMODE:Music(src, pre, name)
end)

net.Receive("SuperPedobear_AFK", function( len )
	GAMEMODE.Vars.AfkTime = net.ReadFloat()
	if GAMEMODE.Vars.AfkTime != 0 then system.FlashWindow() chat.PlaySound() end
end)

net.Receive("SuperPedobear_MusicList", function( len )
	GAMEMODE.Musics.musics = net.ReadTable()
	GAMEMODE.Musics.premusics = net.ReadTable()
end)

net.Receive("SuperPedobear_List", function( len )
	GAMEMODE.Vars.Pedos = net.ReadTable()
end)

net.Receive("SuperPedobear_MusicQueue", function(len)
	GAMEMODE.Vars.MusicQueue = net.ReadTable()
end)

hook.Add("HUDShouldDraw", "HideHUD", function( name )
	local HUDhide = {
		CHudHealth = true,
		CHudBattery = true,
		CHudDamageIndicator = true,
		CHudWeaponSelection = true,
		CHudZoom = true
	}
	if name == "CHudCrosshair" and LocalPlayer():Team() == TEAM_UNASSIGNED then
		return false
	elseif ( HUDhide[ name ] ) then
		return false
	end
end)

function GM:FormatTime(time)
	local timet = string.FormattedTime( time )
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
	local timet = string.FormattedTime( time )
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

function GM:LimitString(str, size, font)
	surface.SetFont(font)
	if surface.GetTextSize(str) <= size then
		return str
	end
	while surface.GetTextSize(str .. "...") >= size do
		str = string.Left(str, #str - 1)
	end
	return str .. "..."
end

function GM:HUDPaint()

	if GetConVarNumber("cl_drawhud") == 0 then return end

	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)

	--[[ THE INDEX ZONE ]]--

	local PreStartTime = GAMEMODE.Vars.Round.PreStartTime
	local PreStart = GAMEMODE.Vars.Round.PreStart
	local Time = GAMEMODE.Vars.Round.Time
	local End = GAMEMODE.Vars.Round.End
	local LastTime = GAMEMODE.Vars.Round.LastTime
	local Start = GAMEMODE.Vars.Round.Start
	local TempEnd = GAMEMODE.Vars.Round.TempEnd

	local function yay(a) return (math.sin(CurTime() * 6) + 1) / 2 * a end
	local ply = LocalPlayer()
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	local plyAlive = ply:Alive()
	local plyTeam = ply:Team()
	local splyAlive = sply:Alive()
	local splyTeam = sply:Team()
	local col = sply:GetPlayerColor():ToColor()
	if !splyAlive then col = team.GetColor( splyTeam ) end
	local wi = true
	if !splyAlive or (splyTeam != TEAM_PEDOBEAR and splyTeam != TEAM_VICTIMS) then
		wi = false
	end
	local welding = sply:GetNWEntity("PedoWelding")
	if welding == sply then
		welding = nil
	end
	local weldingstate = sply:GetNWInt("PedoWeldingState")
	local hudoffset = GetConVar("superpedobear_cl_hud_offset"):GetInt()


	--[[ THE CLOCK AND ROUND COUNT ]]--

	local TheTime = 0
	local rnd = GAMEMODE.Vars.Rounds or 0

	if PreStartTime and PreStartTime - CurTime() >= 0 then
		TheTime = PreStartTime - CurTime()
	elseif Time and Time - CurTime() >= 0 then
		TheTime = Time - CurTime()
	elseif End or TempEnd then
		TheTime = LastTime
	elseif !Start and !PreStart then
		TheTime = superpedobear_round_pretime:GetFloat()
	end

	if GAMEMODE.Vars.Rounds and GAMEMODE.Vars.Rounds > 999 then
		rnd = "∞"
	end

	draw.RoundedBox(0, ScrW() / 2 - 100, hudoffset, 200, 110, Color(0, 0, 0, 200))
	draw.DrawText(GAMEMODE:FormatTime(TheTime), "SuperPedobear_TIME", ScrW() / 2, hudoffset, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
	draw.DrawText("Round " .. rnd, "SuperPedobear_RND", ScrW() / 2, 60 + hudoffset, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)


	--[[ THE ROUND STATUS ]]--

	local rndtxth = 0
	local function addrndtxt(txt)
		surface.SetFont("SuperPedobear_RND")
		local w, h = surface.GetTextSize(txt)
		draw.RoundedBox(0, ScrW() / 2 - w / 2 - 8, 110 + hudoffset + rndtxth, w + 16, h, Color(0, 0, 0, 200))
		draw.DrawText(txt, "SuperPedobear_RND", ScrW() / 2, 110 + hudoffset + rndtxth, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		rndtxth = rndtxth + h
	end

	if Start and !PreStart and GAMEMODE.Vars.Pedos and #GAMEMODE.Vars.Pedos > 0 then

		addrndtxt((GAMEMODE.Vars.victims or 0) .. "|" .. (GAMEMODE.Vars.downvictims or 0))

		for k, v in pairs(GAMEMODE.Vars.Pedos) do
			if IsValid(v) and v:Alive() and GAMEMODE.PlayerEasterEgg[v:SteamID64()] and GAMEMODE.PlayerEasterEgg[v:SteamID64()][4] then
				addrndtxt(Format(GAMEMODE.PlayerEasterEgg[v:SteamID64()][4], v:Nick()))
			end
		end

	elseif !Start and !PreStart and GAMEMODE.Vars.victims < 2 then
		addrndtxt("Waiting for players")
	elseif PreStart then
		addrndtxt("Preparing...")
	end
	if End then
		local function winstr(WinTeam)
			if WinTeam == TEAM_VICTIMS then
				return "The victims wins!"
			elseif WinTeam == TEAM_PEDOBEAR then
				return "Pedobear captured everyone!"
			end
			return "Draw game!"
		end
		addrndtxt(winstr(GAMEMODE.Vars.Round.Win))
	end


	--[[ THE PEDOBEAR SHOWCASE ]]--

	if Start and !PreStart then

		local txt = ""
		local w, h = 0, 0

		if GAMEMODE.Vars.Pedos and #GAMEMODE.Vars.Pedos > 0 then
			for k, v in pairs(GAMEMODE.Vars.Pedos) do
				if IsValid(v) and v:Alive() and txt == "" then
					txt = Format(Either(#GAMEMODE.Vars.Pedos > 1, "%s is a Pedobear", "%s is the Pedobear"), v:Nick())
				elseif IsValid(v) and v:Alive() and txt != "" then
					txt = txt .. Format("\n%s is a Pedobear", v:Nick())
				end
			end
		end

		if txt != "" then
			surface.SetFont("SuperPedobear_HT")
			w, h = surface.GetTextSize(txt)
			draw.RoundedBox(0, hudoffset, hudoffset, w + 16, h + 16, Color(0, 0, 0, 200))
			draw.DrawText(txt, "SuperPedobear_HT", hudoffset + 8 + w / 2, hudoffset + 8, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end

	end


	--[[ THE AFK MESSAGE ]]--

	if GAMEMODE.Vars.AfkTime and GAMEMODE.Vars.AfkTime - CurTime() >= 0 then
		draw.RoundedBox(0, ScrW() / 2 - 300, 165, 600, 210, Color(0, 0, 0, 200))
		draw.DrawText("Hey you're kind of afk!\nIf you're still afk in " .. GAMEMODE:FormatTime(GAMEMODE.Vars.AfkTime - CurTime()) .. "\nYou will be kicked out\n of the role of Pedobear", "SuperPedobear_RND", ScrW() / 2, 165, Color(255, yay(255), yay(255), 255), TEXT_ALIGN_CENTER)
	end


	--[[ THE TIPS MESSAGES ]]--

	local w, h = 0, 0
	local tips = ""

	if (plyTeam == TEAM_VICTIMS and Start and !plyAlive) or plyTeam == TEAM_SPECTATOR then
		tips = GAMEMODE:CheckBind("+attack") .. " next player\n" .. GAMEMODE:CheckBind("+attack2") .. " previous player\n" .. GAMEMODE:CheckBind("+jump") .. " spectate mode (1st person/Chase/Free)"
	elseif plyAlive and !Start and plyTeam == TEAM_VICTIMS then
		tips = GAMEMODE:CheckBind("+attack") .. " to weld a prop to another\n" .. GAMEMODE:CheckBind("+attack2") .. " to unweld a prop\n" .. GAMEMODE:CheckBind("+reload") .. " to use your power-up"
	elseif plyAlive and plyTeam == TEAM_PEDOBEAR then
		tips = "You're a Pedobear!\n" .. GAMEMODE:CheckBind("+attack") .. " to break props\nNow start chasing some little girls! ( ͡° ͜ʖ ͡°)"
	end

	if tips != "" then
		surface.SetFont("SuperPedobear_HT")
		w, h = surface.GetTextSize(tips)
		draw.RoundedBox(0, ScrW() / 2 - w / 2 - 4, ScrH() - h - hudoffset, w + 8, h, Color(0, 0, 0, 200))
		draw.DrawText(tips, "SuperPedobear_HT", ScrW() / 2, ScrH() - h - hudoffset, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoTips™", "DermaDefault", ScrW() / 2 - w / 2, ScrH() - h, Color(255, 255, 255, 64), TEXT_ALIGN_LEFT) end
	end


	--[[ THE QUICK TIPS ]]--

	if plyTeam == TEAM_UNASSIGNED then
		draw.RoundedBox(0, ScrW() / 2 - 160, ScrH() / 2 - 20, 320, 40, Color(0, 0, 0, yay(200)))
		draw.DrawText("Press any key to join!", "SuperPedobear_TXT", ScrW() / 2, ScrH() / 2 - 20, Color(255, 255, 255, yay(255)), TEXT_ALIGN_CENTER)
	elseif plyTeam == TEAM_VICTIMS and !Start and !plyAlive then
		draw.RoundedBox(0, ScrW() / 2 - 200, ScrH() / 2 - 20, 400, 40, Color(0, 0, 0, yay(200)))
		draw.DrawText("Press any key to respawn!", "SuperPedobear_TXT", ScrW() / 2, ScrH() / 2 - 20, Color(255, 255, 255, yay(255)), TEXT_ALIGN_CENTER)
	end


	--[[ THE PERFORMING WELD MESSAGE ]]--

	if splyAlive and splyTeam == TEAM_VICTIMS then
		if weldingstate == 2 then
			draw.RoundedBox(0, ScrW() / 2 - 100, ScrH() / 2 + 100, 200, 26, Color(0, 0, 0, 200))
			draw.DrawText("This prop is too far", "SuperPedobear_HT", ScrW() / 2, ScrH() / 2 + 100, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
		elseif weldingstate == 3 then
			draw.RoundedBox(0, ScrW() / 2 - 150, ScrH() / 2 + 100, 300, 26, Color(0, 0, 0, 200) )
			draw.DrawText("The props are too far each other", "SuperPedobear_HT", ScrW() / 2, ScrH() / 2 + 100, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
		elseif IsValid(welding) then
			draw.RoundedBox(0, ScrW() / 2 - 100, ScrH() / 2 + 100, 200, 26, Color(0, 0, 0, yay(200)))
			draw.DrawText("Click another prop", "SuperPedobear_HT", ScrW() / 2, ScrH() / 2 + 100, Color(255, 255, 255, yay(255)), TEXT_ALIGN_CENTER)
		end
	end


	--[[ THE PLAYER STATUS AND FACE ]]--

	if splyTeam == TEAM_PEDOBEAR or splyTeam == TEAM_VICTIMS then

		local col = sply:GetPlayerColor():ToColor()
		if !splyAlive then col = team.GetColor(splyTeam) end
		local life = Either(splyAlive, 1, 0)
		local stamina = 200
		local powerup = 200
		local taunt = 200
		local sprintlock = false
		local fcolor = Color(col.r, col.g, col.b, 150 * life)
		local ib = 0

		if splyAlive and splyTeam == TEAM_VICTIMS then
			stamina = math.Remap(sply:GetNWInt("SprintV", 100), 0, 100, 1, 200)
			sprintlock = sply:GetNWInt("SprintLock", false)
		end

		if ply != sply and splyAlive then

			local LastTaunt = sply:GetNWInt("LastTaunt", 0)
			local TauntCooldown = sply:GetNWInt("TauntCooldown", 0) - CurTime()
			local TauntCooldownF = sply:GetNWInt("TauntCooldownF", 5)

			if LastTaunt > 0 and TauntCooldown > 0 then
				taunt = math.Remap(TauntCooldown, 0, TauntCooldownF, 200, 1)
			end

		elseif plyAlive and ply.LastTaunt and ply.TauntCooldown-CurTime() > 0 then
			taunt = math.Remap(ply.TauntCooldown - CurTime(), 0, ply.TauntCooldownF, 200, 1)
		end

		if splyAlive then
			local t = sply:GetNWInt("tnextpowerup", 0)
			local tt = sply:GetNWInt("ttnextpowerup", 0)
			if t != 0 and t > CurTime() then
				powerup = math.Remap(t - CurTime(), 0, tt, 200, 1)
			end
		end

		draw.RoundedBox(0, hudoffset, ScrH() - 200 - hudoffset, 200, 200, Color(0, 0, 0, 200))

		draw.RoundedBox(0, hudoffset, ScrH() - 200 - hudoffset, 200, 200, Color(col.r * life, col.g * life, col.b * life, 150 * life))

		local function MakeBar(name, value, nope)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(200 + hudoffset, ScrH() - 200 + 50 * ib - hudoffset, 200, 50)
			surface.SetDrawColor(fcolor)
			surface.DrawRect(200 + hudoffset, ScrH() - 200 + 50 * ib - hudoffset, value, 50)
			draw.DrawText(name, "SuperPedobear_TXT", 300 + hudoffset, ScrH() - 195 + 50 * ib - hudoffset, Either(nope, Color(255, 0, 0, 255), Color(255, 255, 255, 255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(200 + hudoffset, ScrH() - 200 + 50 * ib - hudoffset, 200, 50)
			ib = ib + 1
		end

		if splyAlive then
			if Start and splyTeam == TEAM_VICTIMS then
				MakeBar("STAMINA", stamina, sprintlock)
			end
			if splyTeam == TEAM_VICTIMS then --TODO: Stuff
				MakeBar("POWER-UP", powerup)
			end
			if taunt != 200 then
				MakeBar("TAUNT", taunt)
			end
		end

	end

	if wi and (sply:GetModel() == "models/player/pbear/pbear.mdl" or sply:GetModel() == "models/player/kuristaja/pbear/pbear.mdl") then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("superpedobear/pedobear"))
		surface.DrawTexturedRectUV(hudoffset, ScrH() - 200 - hudoffset, 200, 200, 0, 0, 1, 1)
	elseif plyTeam != TEAM_UNASSIGNED and splyTeam != TEAM_SPECTATOR then
		self:DrawHealthFace(sply, hudoffset, ScrH() - 200 - hudoffset)
	end

	if plyTeam != TEAM_UNASSIGNED and splyTeam != TEAM_SPECTATOR then
		local splynick = GAMEMODE:LimitString(sply:Nick(), 200, "SuperPedobear_HUDname")
		draw.DrawText(splynick, "SuperPedobear_HUDname", 100 + 1 + hudoffset, ScrH() - 200 + 1 - hudoffset, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(splynick, "SuperPedobear_HUDname", 100 + hudoffset, ScrH() - 200 - hudoffset, col, TEXT_ALIGN_CENTER)
	end

	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawOutlinedRect(hudoffset, ScrH() - 200 - hudoffset, 200, 200)


	--[[ THE GAMEMODE STATUS ]]--

	local txt = "Super Pedobear Early Access (" .. os.date("%d/%m/%Y", os.time()) .. ")"
	local w, h = 0, 0

	if txt != "" then

		surface.SetFont("SuperPedobear_HT")
		w, h = surface.GetTextSize(txt)
		draw.RoundedBox(0, ScrW() - 16 - w - hudoffset, hudoffset, w + 16, h + 16, Color(0, 0, 0, 200))
		draw.DrawText(txt, "SuperPedobear_HT", ScrW() - w - hudoffset - 8 + w / 2, hudoffset + 8, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

	end


	--[[ THE MUSICS STUFF ]]--

	if IsValid(GAMEMODE.Vars.Music) then

		local time = GAMEMODE.Vars.Music:GetTime()
		local totaltime = GAMEMODE.Vars.Music:GetLength()
		local left, right = GAMEMODE.Vars.Music:GetLevel()
		local function meh(mu) return math.Remap(mu, 0, 1, 0, 255) end
		local function volcolor(mu) return Color( meh(mu), 255-meh(mu), 0, 200 ) end
		local visuok = GetConVar("superpedobear_cl_music_visualizer"):GetBool() and GAMEMODE.Vars.Music:GetState() == GMOD_CHANNEL_PLAYING
		local visspace = 48
		if visuok then
			visspace = 0
		end

		if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoRadio™", "DermaDefault", ScrW(), ScrH() - 100 + visspace, Color(255, 255, 255, 64), TEXT_ALIGN_RIGHT) end

		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 100 + visspace - hudoffset, 256, 100 - visspace, Color(0, 0, 0, 200))

		local ctitle = GAMEMODE.Vars.CurrentMusicName
		local rtitle
		if ctitle and ctitle != "" then
			rtitle = ctitle
		else
			rtitle = GAMEMODE:PrettyMusicName(string.GetFileFromFilename(GAMEMODE.Vars.Music:GetFileName()))
		end

		local title = "♪ " .. GAMEMODE:LimitString(rtitle, 216, "SuperPedobear_HUDname") .. " ♪"
		draw.DrawText(title, "SuperPedobear_HUDname", ScrW() - 127 - hudoffset, ScrH() - 99 + visspace - hudoffset, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(title, "SuperPedobear_HUDname", ScrW() - 128 - hudoffset, ScrH() - 100 + visspace - hudoffset, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 80 + visspace - hudoffset, 256, 16, Color(0, 0, 0, 200)) --Timetrack
		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 77 + visspace - hudoffset, math.Remap(time, 0, totaltime, 0, 256), 10, Color(255, 255, 255, 200))

		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 64 + visspace - hudoffset, 256, 16, Color( 0, 0, 0, 200)) --Wub
		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 56 + visspace - hudoffset, math.Remap(left, 0, 1, 0, 256), 8, volcolor(left))
		draw.RoundedBox(0, ScrW() - 256 - hudoffset, ScrH() - 64 + visspace - hudoffset, math.Remap(right, 0, 1, 0, 256), 8, volcolor(right))

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(ScrW() - 256 - hudoffset, ScrH() - 64 + visspace - hudoffset, ScrW() - hudoffset, ScrH() - 64 + visspace - hudoffset)
		surface.DrawLine(ScrW() - 256 - hudoffset, ScrH() - 48 + visspace - hudoffset, ScrW() - hudoffset, ScrH() - 48 + visspace - hudoffset)

		local timetxt = GAMEMODE:FormatTimeTri(time) .. "/" .. GAMEMODE:FormatTimeTri(totaltime) --Time
		surface.SetFont("SuperPedobear_HUDname")
		local tw, _ = surface.GetTextSize(timetxt)
		draw.RoundedBox(0, ScrW() - 128 - tw / 2 - 4 - hudoffset, ScrH() - 80 + visspace - hudoffset, tw + 8, 16, Color(0, 0, 0, 220))
		draw.DrawText(timetxt, "SuperPedobear_HUDname", ScrW() - 127 - hudoffset, ScrH() - 81 + visspace - hudoffset, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(timetxt, "SuperPedobear_HUDname", ScrW() - 128 - hudoffset, ScrH() - 82 + visspace - hudoffset, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		if visuok then

			local eqd = {}

			GAMEMODE.Vars.Music:FFT(eqd, 0)

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(ScrW() - 256 - hudoffset, ScrH() - 48 - hudoffset, 256, 48)

			for k, v in pairs(eqd) do
				local on = math.Clamp(math.Remap(v, 0, 1 / k, 0, 48), 0, 48)
				local b = math.Clamp(math.Remap(v, 0, 1 / k, 0, 1), 0, 1)
				surface.SetDrawColor(volcolor(b))
				surface.DrawRect(ScrW() - 256 + (k - 1) * 2 - hudoffset, ScrH() - on - hudoffset, 2, on)
			end

		end

	end

	draw.DrawText(GAMEMODE.Name .. " V" .. GAMEMODE.Version, "DermaDefault", ScrW() / 2, hudoffset, Color(255, 255, 255, 64), TEXT_ALIGN_CENTER)

end

function GM:CreateHealthFace(ply)
	self.HealthFace = ClientsideModel(ply:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
	self.HealthFace:SetNoDraw(true)
	local iSeq = self.HealthFace:LookupSequence("idle_passive")
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("walk_all") end
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("WalkUnarmed_all") end
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("walk_all_moderate") end
	if (iSeq > 0) then
		self.HealthFace:SetSequence(iSeq)
		self.HealthFace:ResetSequenceInfo()
		self.HealthFace:SetCycle(0)
		self.HealthFace:SetPlaybackRate(1)
		self.LastSeq = iSeq
	end
	self.HealthFace.GetPlayerColor = function() return ply:GetPlayerColor() end

	local f = function (self) return self.PlayerColor or Vector(1, 0, 0) end
	self.HealthFace.GetPlayerColorOverride = f

	self.HealthFace:SetSkin(ply:GetSkin())

	for k,v in pairs(ply:GetBodyGroups()) do
		self.HealthFace:SetBodygroup(v["id"], ply:GetBodygroup(v["id"]))
	end

end

local function SameBodyGroups(self, ply)
	for k, v in pairs(self:GetBodyGroups()) do
		if self:GetBodygroup(v.id) != ply:GetBodygroup(v.id) then return false end
	end
	return true
end

function GM:DrawHealthFace(ply, x, y)

	local w, h = 200, 200

	if !IsValid(self.HealthFace) then
		self:CreateHealthFace(ply)
	end

	if IsValid(self.HealthFace) then

		if self.HealthFace:GetModel() != ply:GetModel() or self.HealthFace:GetSkin() != ply:GetSkin() or !SameBodyGroups(self.HealthFace, ply) then
			self:CreateHealthFace(ply)
		end

		local seq = ply:GetSequence()
		--[[local seqname = ply:GetSequenceName(seq)
		if seqname == "walk_all" or seqname == "run_all_01" or seqname == "swimming_all" then
			seq = ply:LookupSequence("menu_walk")
			seqname = ply:GetSequenceName(seq)
		end]]

		if !ply:Alive() and self.LastSeq != 0 then
			local iSeq = 0
			self.HealthFace:SetSequence(iSeq)
			self.HealthFace:ResetSequenceInfo()
			self.HealthFace:SetCycle(0)
			self.HealthFace:SetPlaybackRate(1)
			self.LastSeq = iSeq
		elseif ply:Alive() and self.LastSeq != seq then
			local iSeq = seq or 0
			self.HealthFace:SetSequence(iSeq)
			self.HealthFace:ResetSequenceInfo()
			self.HealthFace:SetCycle(0)
			self.HealthFace:SetPlaybackRate(1)
			self.LastSeq = iSeq
		end
		--print(ply:GetSequenceList()[ply:GetSequence()])
		--PrintTable(ply:GetSequenceList())

		if self.HealthFace.PlayerColor != ply:GetPlayerColor() then
			self.HealthFace.PlayerColor = ply:GetPlayerColor()
		end

		local bone = self.HealthFace:LookupBone("ValveBiped.Bip01_Head1")
		local pos = Vector(0, 0, 70)
		local bang = Angle()
		if bone then
			pos, bang = self.HealthFace:GetBonePosition(bone)
		end

		cam.Start3D(pos + Vector(19, 0, 2), Vector(-1, 0, 0):Angle(), 70, x, y, w, h, 5, 4096)
		cam.IgnoreZ(true)

		render.OverrideDepthEnable(false)
		render.SuppressEngineLighting(true)
		render.SetLightingOrigin(pos)
		local life = math.Remap(ply:Health(), 0, ply:GetMaxHealth(), 0, 1) or 0
		render.ResetModelLighting(life, life, life)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)

		self.HealthFace:DrawModel()

		render.SuppressEngineLighting(false)
		cam.IgnoreZ(false)
		cam.End3D()

	end

	render.SetStencilEnable(false)

	render.SetStencilWriteMask(0)
	render.SetStencilReferenceValue(0)
	render.SetStencilTestMask(0)
	render.SetStencilEnable(false)
	render.OverrideDepthEnable(false)
	render.SetBlend(1)

	cam.IgnoreZ(false)
end

net.Receive("SuperPedobear_Notif", function(len)

	local str = net.ReadString() or ""
	local ne = net.ReadInt(3) or 0
	local dur = net.ReadFloat() or 5
	local sound = net.ReadBit() or false

	GAMEMODE:Notif(str, ne, dur, sound)

end)
function GM:Notif(str, ne, dur, sound)
	notification.AddLegacy(str, ne, dur, sound)
	if !tobool(sound) then return end
	if ne == NOTIFY_HINT then
		surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
	elseif ne == NOTIFY_ERROR then
		surface.PlaySound("buttons/button10.wav")
	else
		chat.PlaySound()
	end
end

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
	local ply = LocalPlayer()
	if ply:GetObserverMode() == OBS_MODE_CHASE then return end

	local text = ""
	local font = "DermaLarge"

	if trace.Entity:IsPlayer() or trace.Entity:GetClass() == "superpedobear_dummy" then
		text = trace.Entity:Nick()
	end

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)

	local MouseX, MouseY = ScrW() / 2, ScrH() * 0.7

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 255))
	draw.SimpleText(text, font, x + 2, y + 2, Color(0, 0, 0, 126))
	if trace.Entity:IsPlayer() or trace.Entity:GetClass() == "superpedobear_dummy" then
		local col = trace.Entity:GetPlayerColor():ToColor()
		draw.SimpleText(text, font, x, y, col)
	elseif trace.Entity:IsPlayer() then
		draw.SimpleText(text, font, x, y, self:GetTeamColor(trace.Entity))
	end

end

function GM:PreDrawHalos()

	if GetConVar("superpedobear_cl_disablehalos"):GetBool() then return end

	local ply = LocalPlayer()
	local tab = {}
	local tab2 = {}
	local tab3 = {}
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	local welding = sply:GetNWEntity("PedoWelding")
	if welding == sply then
		welding = nil
	end

	if ply:Team() == TEAM_VICTIMS then

		if !ply:Alive() then

			for k,v in pairs(player.GetAll()) do
				if v:Team() == TEAM_VICTIMS and v:Alive() then
					table.insert(tab, v)
				end
			end
			halo.Add(tab, team.GetColor(TEAM_VICTIMS), 1, 1, 1, true, true)

			for k,v in pairs(ents.FindByClass("superpedobear_dummy")) do
				table.insert(tab3, v)
			end
			halo.Add(tab3, Color(0, 0, 255), 1, 1, 1, true, true)

		else

			for k,v in pairs(ents.FindByClass("superpedobear_dummy")) do
				if v:GetPlayer() == ply then
					table.insert(tab3, v)
				end
			end
			halo.Add(tab3, Color(0, 0, 255), 1, 1, 1, true, true)

		end

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab2, v)
			end
		end
		halo.Add(tab2, team.GetColor(TEAM_PEDOBEAR), 1, 1, 1, true, !ply:Alive())

		if IsValid(welding) then

			halo.Add({ welding }, Color(255, 255, 255), 1, 1, 1, true, false)

		end

	elseif ply:Team() == TEAM_PEDOBEAR then

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab, v)
			end
		end
		halo.Add(tab, team.GetColor(TEAM_PEDOBEAR), 1, 1, 1, true, true)

	elseif ply:Team() == TEAM_SPECTATOR then

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_VICTIMS and v:Alive() then
				table.insert(tab, v)
			end
		end

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab2, v)
			end
		end

		halo.Add(tab, team.GetColor(TEAM_VICTIMS), 1, 1, 1, true, true)
		halo.Add(tab2, team.GetColor(TEAM_PEDOBEAR), 2, 2, 2, true, true)

	end

end

function GM:ShowTeam()

	if !IsValid(self.TeamSelectFrame) then

		self.TeamSelectFrame = vgui.Create("DFrame")
		self.TeamSelectFrame:SetTitle("Pick Team")

		local AllTeams = team.GetAllTeams()
		local x = 4
		local y = 156
		for ID, TeamInfo in pairs (AllTeams) do

			if (ID != TEAM_CONNECTING and ID != TEAM_UNASSIGNED) and team.Joinable(ID) then

				local Team = vgui.Create("DButton", self.TeamSelectFrame)
				function Team.DoClick() self:HideTeam() RunConsoleCommand("changeteam", ID) end
				Team:SetPos(x, 24)
				Team:SetSize(256, 128)
				Team:SetText(TeamInfo.Name)
				Team:SetTextColor(TeamInfo.Color)
				Team:SetFont("DermaLarge")
				Team:SetExpensiveShadow(1, Color(0,0,0,255))

				if IsValid(LocalPlayer()) and LocalPlayer():Team() == ID then
					Team:SetDisabled(true)
					Team:SetTextColor(Color(40, 40, 40))
					Team.Paint = function(self, w, h)
						draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(0, 0, 0, 150))
					end
				else
					Team:SetTextColor(TeamInfo.Color)
					Team.Paint = function(self, w, h)
						draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(255, 255, 255, 150))
					end
				end

				x = x + 256

			end

		end

		if GAMEMODE.AllowAutoTeam then

			local Team = vgui.Create("DButton", self.TeamSelectFrame)
			function Team.DoClick() self:HideTeam() RunConsoleCommand("autoteam") end
			Team:SetPos(4 + x / 3, 280)
			Team:SetSize(x / 3 - 4, 32)
			Team:SetText("Auto")
			Team:SetTextColor(GAMEMODE.Colors_default)
			Team:SetFont("DermaLarge")
			Team.Paint = function(self, w, h)
				draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(255, 255, 255, 150))
			end

			y = y + 32

		end

		self.TeamSelectFrame:SetSize(x + 4, y)
		self.TeamSelectFrame:SetDraggable(true)
		self.TeamSelectFrame:SetScreenLock(true)
		self.TeamSelectFrame:SetPaintShadow(true)
		self.TeamSelectFrame:Center()
		self.TeamSelectFrame:MakePopup()
		self.TeamSelectFrame:SetKeyboardInputEnabled(false)
		self.TeamSelectFrame.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end

	else
		self.TeamSelectFrame:Close()
	end

end

function GM:Think()

	local ply = LocalPlayer()

	if ply:Alive() and (ply:Team() == TEAM_VICTIMS or ply:Team() == TEAM_PEDOBEAR) and !GAMEMODE.ChatOpen and !gui.IsGameUIVisible() then

		local inputs = { input.IsKeyDown(KEY_1), input.IsKeyDown(KEY_2), input.IsKeyDown(KEY_3), input.IsKeyDown(KEY_4), input.IsKeyDown(KEY_5), input.IsKeyDown(KEY_6), input.IsKeyDown(KEY_7), input.IsKeyDown(KEY_8), input.IsKeyDown(KEY_9) }
		local sel = 0

		for k,v in pairs(inputs) do

			if v == true then

				sel = k
				break

			end

		end

		GAMEMODE:StartTaunt(sel)

	end

	if ply:Team() == TEAM_VICTIMS and ply:Alive() and GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !GAMEMODE.Vars.Round.TempEnd then
		GAMEMODE:HeartBeat(ply)
	end

end

function GM:HeartBeat(ply)

	local distance
	local t
	local nextheartbeat = 1
	local volume = 1

	for k, v in pairs(team.GetPlayers(TEAM_PEDOBEAR)) do

		t = v:GetPos():Distance(ply:GetPos())

		if (!distance or distance < t) --[[and ply:Visible(v)]] then --TODO: Visibility only
			distance = t
		end

	end

	if distance and distance < 1000 then

		nextheartbeat = math.Remap(distance, 0, 1000, 0.30, 2)
		volume = math.Remap(distance, 1000, 0, 0.30, 1)

		if !ply.LastHeartBeat or ply.LastHeartBeat + nextheartbeat < CurTime() then
			ply:EmitSound(GAMEMODE.Sounds.HeartBeat, 0, 100, volume, CHAN_AUTO)
			ply.LastHeartBeat = CurTime()
		end

	end

end

function GM:StartTaunt(sel)

	local ply = LocalPlayer()

	if sel and sel != 0 and GAMEMODE.Sounds.Taunts[sel] and ( !ply.TauntCooldown or ply.TauntCooldown-CurTime() + 0.5 < 0 ) then

		if GAMEMODE.Sounds.Taunts[sel][3] != 0 and GAMEMODE.Sounds.Taunts[sel][3] != ply:Team() then return end

		net.Start( "SuperPedobear_Taunt" )
			net.WriteInt(sel,32)
		net.SendToServer()

		local cd = GAMEMODE.Sounds.Taunts[sel][4]

		if cd < 5 then
			cd = 5
		end

		ply.TauntCooldown = CurTime() + cd
		ply.TauntCooldownF = cd
		ply.LastTaunt = sel

	end

end

function GM:Music(src, pre, name, retry)

	if !retry then retry = 0 end

	GAMEMODE:BuildMusicIndex()

	GAMEMODE.Vars.CurrentMusic = src

	if IsValid(GAMEMODE.Vars.Music) and src == "play" then
		GAMEMODE.Vars.Music:Play()
	elseif IsValid(GAMEMODE.Vars.Music) and src == "pause" then
		GAMEMODE.Vars.Music:Pause()
	elseif IsValid(GAMEMODE.Vars.Music) then
		GAMEMODE.Vars.Music:Stop()
		GAMEMODE.Vars.CurrentMusicName = nil
		GAMEMODE.Vars.Music = nil
	end

	if src != "stop" and src != "pause" and src != "play" and GetConVar("superpedobear_cl_music_enable"):GetBool() then

		local exist = file.Exists(src, "GAME")
		local isurl = false
		local orisrc = nil

		if src != "" and !exist and GetConVar("superpedobear_cl_music_allowexternal"):GetBool() and string.match(src, "://") then

			isurl = true

		elseif src == "" or !exist then

			local tbl = file.Find("sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/*", "GAME")

			if #tbl > 0 then
				orisrc = src
				src = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. tbl[math.random(1,#tbl)]
			end

		end

		local function domusicstuff(mus, errorID, errorName)

			if IsValid(mus) then
				mus:SetVolume(GetConVar("superpedobear_cl_music_volume"):GetFloat())
				mus:EnableLooping(true)
				GAMEMODE.Vars.Music = mus
			end

			if errorID or errorName then
				GAMEMODE:Log("Error while starting music \"" .. src .. "\": " .. errorName .. " (" .. errorID .. ")")
				if retry < 5 then
					GAMEMODE:Log("Retrying with fallback...")
					GAMEMODE:Music("", pre, nil, retry + 1)
				else
					GAMEMODE:Log("Too many retries! Aborting fallback...")
				end
			elseif orisrc != nil then
				GAMEMODE:Log("Playing music \"" .. src .. "\"" .. Either(pre, " (pre round music)", "") .. " instead of " .. Either(orisrc != "", "\"" .. orisrc .. "\"", "nothing"))
				GAMEMODE.Vars.CurrentMusicName = ""
			else
				GAMEMODE:Log("Playing music \"" .. src .. "\"" .. Either(pre, " (pre round music)", ""))
			end

		end

		if !isurl and src != "" then
			sound.PlayFile(src, "noblock", domusicstuff)
		elseif isurl then
			GAMEMODE:Log("Downloading external music... \"" .. src .. "\"")
			sound.PlayURL(src, "noblock", domusicstuff)
		end

		GAMEMODE.Vars.CurrentMusicName = name

	end

end

function GM:StartChat(teamsay)
	GAMEMODE.ChatOpen = true
	return false
end

function GM:FinishChat()
	GAMEMODE.ChatOpen = false
end

function GM:GetTeamColor(ent)
	local team = TEAM_UNASSIGNED
	if ent.Team then team = ent:Team() end
	if ent:GetClass() == "superpedobear_dummy" then team = TEAM_VICTIMS end
	return GAMEMODE:GetTeamNumColor(team)
end

function GM:InitPostEntity()
	GAMEMODE:Stats()
end

function GM:Stats()

	local steamid = LocalPlayer():SteamID64()

	if !file.IsDir("superpedobear/stats", "DATA") then
		file.CreateDir("superpedobear/stats")
	end

	local needstat = !file.Exists("superpedobear/stats/" .. steamid .. ".txt", "DATA")

	if needstat then
		http.Post( "https://www.xperidia.com/UCP/stats.php", { steamid = steamid, zone = "pedo" },
		function( responseText, contentLength, responseHeaders, statusCode )
			if statusCode == 200 then
				file.Write("superpedobear/stats/" .. steamid .. ".txt", "")
				GAMEMODE:Log(responseText)
			else
				GAMEMODE:Log("Error while registering the gamemode (ERROR " .. statusCode .. ")")
			end
		end,
		function(errorMessage)
			GAMEMODE:Log(errorMessage)
		end)
	end

	local function welcomehandle()
		GAMEMODE:SplashScreen()
	end

	local info = file.Read("superpedobear/info.txt")

	if info then
		local tab = util.JSONToTable(info)
		if !tab or (tab.LastVersion and tab.LastVersion < GAMEMODE.Version) then
			welcomehandle()
		end
	else
		welcomehandle()
	end

end

function GM:ContextMenuOpen()
	return true
end

function GM:OnContextMenuOpen()
	LocalPlayer().ThirdPerson = !LocalPlayer().ThirdPerson
end

function GM:OnSpawnMenuOpen()
	GAMEMODE:PedoVan()
end

hook.Add("CalcView", "SuperPedobear_thirdperson", function(ply, pos, angles, fov)

	if ply:Alive() and ply.ThirdPerson and !ply:IsPlayingTaunt() and ply:Team() != TEAM_SPECTATOR then

		local view = {}

		local traceData = {}
		traceData.start = ply:EyePos()
		traceData.endpos = traceData.start + angles:Forward() * -100
		traceData.endpos = traceData.endpos + angles:Right()
		traceData.endpos = traceData.endpos + angles:Up()
		traceData.filter = ply

		local trace = util.TraceLine(traceData)

		pos = trace.HitPos

		if trace.Fraction < 1.0 then
			pos = pos + trace.HitNormal * 5
		end

		view.origin = pos
		view.angles = angles
		view.fov = fov
		view.drawviewer = true

		return view

	end

end)

function GM:CheckBind(cmd)
	if input.LookupBinding(cmd, true) then
		return string.upper(input.LookupBinding(cmd, true))
	end
	return "N/A"
end

function GM:OnPlayerChat(player, strText, bTeamOnly, bPlayerIsDead)

	local tab = {}

	if bPlayerIsDead then
		table.insert(tab, Color(255, 30, 40))
		table.insert(tab, "*DEAD* ")
	end

	if bTeamOnly then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "(TEAM) ")
	end

	if IsValid(player) then
		local rankid = player:GetNWInt("XperidiaRank", 0)
		local rankname = player:GetNWString("XperidiaRankName", "<Unknown rank name>")
		local rankcolor = player:GetNWString("XperidiaRankColor", "255 255 255 255")
		if rankid > 0 then
			print(string.ToColor(rankcolor))
			table.insert(tab, string.ToColor(rankcolor))
			table.insert(tab, "{Xperidia " .. rankname .. "} ")
		end
		if player:GetUserGroup() != "user" then
			table.insert(tab, Color(255, 255, 255))
			table.insert(tab, "[" .. string.upper(string.sub(player:GetUserGroup(), 1, 1)) .. string.sub(player:GetUserGroup(), 2) .. "] ")
		end
		table.insert(tab, player)
	else
		table.insert(tab, "Console")
	end

	table.insert(tab, Color(255, 255, 255))
	table.insert(tab, ": " .. strText)

	chat.AddText(unpack(tab))

	return true

end

function GM:CallJumpscare(jumpscare)
	GAMEMODE.Vars.Jumpscare = jumpscare or "superpedobear/pedoscare"
	GAMEMODE.Vars.JumpscareTime = CurTime() + 0.5
end

function GM:RenderScreenspaceEffects()

	local ravemode = false
	if GAMEMODE.Vars.Pedos and #GAMEMODE.Vars.Pedos > 0 then
		for k, v in pairs(GAMEMODE.Vars.Pedos) do
			if IsValid(v) and v:Alive() and v:SteamID64() == "76561198108011282" then
				ravemode = true
			end
		end
	end

	if ravemode then
		local x = CurTime() * 5
		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = (0.5 * math.sin(x - 1)) * 10,
			["$pp_colour_mulg"] = (0.5 * math.sin(x)) * 10,
			["$pp_colour_mulb"] = (0.5 * math.sin(x + 1)) * 10
		}
		DrawColorModify(tab)
	end

	if GAMEMODE.Vars.Jumpscare and GAMEMODE.Vars.JumpscareTime > CurTime() then
		DrawMaterialOverlay(GAMEMODE.Vars.Jumpscare, 0)
	end

	--DrawToyTown(2, ScrH() / 3) -- Pedo distance ?

end
