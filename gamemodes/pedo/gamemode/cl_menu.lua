function GM:Menu()

	if !IsValid(pedobearMenuF) and !engine.IsPlayingDemo() then

		if IsValid(pedobearMenuBF) then

			pedobearMenuBF:Close()

		end

		pedobearMenuF = vgui.Create("DFrame")
		pedobearMenuF:SetPos(ScrW() / 2 - 320, ScrH() / 2 - 240)
		pedobearMenuF:SetSize(640, 480)
		pedobearMenuF:SetTitle((GAMEMODE.Name or "?") .. " V" .. (GAMEMODE.Version or "?") .. GAMEMODE:SeasonalEventStr() .. " | By " .. (GAMEMODE.Author or "?"))
		pedobearMenuF:SetVisible(true)
		pedobearMenuF:SetDraggable(true)
		pedobearMenuF:ShowCloseButton(true)
		pedobearMenuF:SetScreenLock(true)
		pedobearMenuF.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		pedobearMenuF.Think = function(self)

			if xpsc_anim and xpsc_anim:Active() then xpsc_anim:Run() end

			local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
			local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)

			if self.Dragging then

				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]

				-- Lock to screen bounds if screenlock is enabled
				if self:GetScreenLock() then

					x = math.Clamp(x, 0, ScrW() - self:GetWide())
					y = math.Clamp(y, 0, ScrH() - self:GetTall())

				end

				self:SetPos(x, y)

			end

			if self.Hovered and mousey < (self.y + 24) then
				self:SetCursor("sizeall")
				return
			end

			self:SetCursor("arrow")

			if self.y < 0 then
				self:SetPos(self.x, 0)
			end

		end
		pedobearMenuF:MakePopup()
		pedobearMenuF:SetKeyboardInputEnabled(false)

		pedobearMenuF.one = vgui.Create("DPanel")
		pedobearMenuF.one:SetParent(pedobearMenuF)
		pedobearMenuF.one:SetPos(10, 30)
		pedobearMenuF.one:SetSize(305, 215)

		local onelbl = vgui.Create("DLabel")
		onelbl:SetParent(pedobearMenuF.one)
		onelbl:SetText( "You're playing " .. (GAMEMODE.Name or "?") )
		onelbl:SetPos(10, 5)
		onelbl:SetDark(1)
		onelbl:SizeToContents()

		local xpucp = vgui.Create( "DButton" )
		xpucp:SetParent(pedobearMenuF.one)
		xpucp:SetText("Xperidia Account")
		xpucp:SetPos(20, 190)
		xpucp:SetSize(125, 20)
		xpucp.DoClick = function()
			gui.OpenURL("https://www.xperidia.com/UCP/")
			pedobearMenuF:Close()
		end

		local xpsteam = vgui.Create("DButton")
		xpsteam:SetParent(pedobearMenuF.one)
		xpsteam:SetText("Xperidia's Steam Group")
		xpsteam:SetPos(160, 190)
		xpsteam:SetSize(125, 20)
		xpsteam.DoClick = function()
			gui.OpenURL("https://xperi.link/XP-SteamGroup")
			pedobearMenuF:Close()
		end

		local add = 0

		if ConVarExists("sv_playermodel_selector_gamemodes") then

			local playermodelselection = vgui.Create("DButton")
			playermodelselection:SetParent(pedobearMenuF.one)
			playermodelselection:SetText("Select a playermodel")
			playermodelselection:SetPos(90, 165)
			playermodelselection:SetSize(125, 20)
			playermodelselection:SetEnabled(GetConVar("sv_playermodel_selector_gamemodes"):GetBool() or LocalPlayer():IsAdmin() or LocalPlayer():IsUserGroup("premium"))
			playermodelselection.DoClick = function()
				RunConsoleCommand("playermodel_selector")
				pedobearMenuF:Close()
			end

			add = 5

		end

		local beginmenubtn = vgui.Create("DButton")
		beginmenubtn:SetParent(pedobearMenuF.one)
		beginmenubtn:SetText("Welcome screen")
		beginmenubtn:SetPos(90, 145 - add)
		beginmenubtn:SetSize(125, 20)
		beginmenubtn.DoClick = function()
			GAMEMODE:BeginMenu()
			pedobearMenuF:Close()
		end

		local desclbl = vgui.Create("DLabel")
		desclbl:SetParent(pedobearMenuF.one)
		desclbl:SetText("Some controls:\n\n" .. GAMEMODE:CheckBind("gm_showhelp") .. ": This window\n"
		.. GAMEMODE:CheckBind("gm_showteam") .. ": Change team\n"
		.. GAMEMODE:CheckBind("gm_showspare1") .. ": Taunt menu\n"
		.. "1-9: Quick taunt\n"
		.. GAMEMODE:CheckBind("+menu") .. ": PedoVan (Shop)\n"
		.. GAMEMODE:CheckBind("+menu_context") .. ": Toggle thirdperson")
		desclbl:SetPos(20, 30)
		desclbl:SetDark(1)
		desclbl:SizeToContents()


		pedobearMenuF.config = vgui.Create("DPanel")
		pedobearMenuF.config:SetParent(pedobearMenuF)
		pedobearMenuF.config:SetPos(325, 30)
		pedobearMenuF.config:SetSize(305, 215)

		local configlbl = vgui.Create("DLabel")
		configlbl:SetParent(pedobearMenuF.config)
		configlbl:SetText("Configuration")
		configlbl:SetPos(10, 5)
		configlbl:SetDark(1)
		configlbl:SizeToContents()

		local disablexpsc = vgui.Create("DCheckBoxLabel")
		disablexpsc:SetParent(pedobearMenuF.config)
		disablexpsc:SetText("Disable Xperidia's Showcase")
		disablexpsc:SetPos(15, 30)
		disablexpsc:SetDark(1)
		disablexpsc:SetConVar("pedobear_cl_disablexpsc")
		disablexpsc:SetValue( GetConVar("pedobear_cl_disablexpsc"):GetBool() )
		disablexpsc:SizeToContents()

		local disabletc = vgui.Create("DCheckBoxLabel")
		disabletc:SetParent(pedobearMenuF.config)
		disabletc:SetText("Don't close the taunt menu after taunting")
		disabletc:SetPos(15, 50)
		disabletc:SetDark(1)
		disabletc:SetConVar("pedobear_cl_disabletauntmenuclose")
		disabletc:SetValue(GetConVar("pedobear_cl_disabletauntmenuclose"):GetBool())
		disabletc:SizeToContents()

		local jumpscare = vgui.Create("DCheckBoxLabel")
		jumpscare:SetParent(pedobearMenuF.config)
		jumpscare:SetText("Pedobear jumpscare")
		jumpscare:SetPos(15, 70)
		jumpscare:SetDark(1)
		jumpscare:SetConVar("pedobear_cl_jumpscare")
		jumpscare:SetValue(GetConVar("pedobear_cl_jumpscare"):GetBool())
		jumpscare:SetDisabled(GAMEMODE:IsSeasonalEvent("Halloween"))
		jumpscare:SizeToContents()

		local hud = vgui.Create("DCheckBoxLabel")
		hud:SetParent(pedobearMenuF.config)
		hud:SetText("Draw HUD (Caution! This is a Garry's Mod convar)")
		hud:SetPos(15, 90)
		hud:SetDark(1)
		hud:SetConVar("cl_drawhud")
		hud:SetValue(GetConVar("cl_drawhud"):GetBool())
		hud:SizeToContents()

		local disablehalo = vgui.Create("DCheckBoxLabel")
		disablehalo:SetParent(pedobearMenuF.config)
		disablehalo:SetText("Disable halos (Improve performance)")
		disablehalo:SetPos(15, 110)
		disablehalo:SetDark(1)
		disablehalo:SetConVar("pedobear_cl_disablehalos")
		disablehalo:SetValue(GetConVar("pedobear_cl_disablehalos"):GetBool())
		disablehalo:SizeToContents()

		--[[local censorwords = vgui.Create("DCheckBoxLabel")
		censorwords:SetParent(pedobearMenuF.config)
		censorwords:SetText("Word censoring")
		censorwords:SetPos(15, 130)
		censorwords:SetDark(1)
		censorwords:SetConVar("pedobear_cl_censorwords")
		censorwords:SetValue(GetConVar("pedobear_cl_censorwords"):GetBool())
		censorwords:SetDisabled(string.match(GetHostName(), "Ollie's Mod"))
		censorwords:SizeToContents()]]


		pedobearMenuF.MusicL = vgui.Create("DPanel")
		pedobearMenuF.MusicL:SetParent(pedobearMenuF)
		pedobearMenuF.MusicL:SetPos(10, 255)
		pedobearMenuF.MusicL:SetSize(305, 215)

		local pre = GAMEMODE.Vars.Round.PreStart

		local function CreateMusicList(pre)

			pedobearMenuF.MusicL.lbl = vgui.Create("DLabel")
			pedobearMenuF.MusicL.lbl:SetParent(pedobearMenuF.MusicL)
			pedobearMenuF.MusicL.lbl:SetText(Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "PedoRadio™", "Music") .. " list" .. Either(pre, " (Pre Round Musics)", ""))
			pedobearMenuF.MusicL.lbl:SetPos(10, 5)
			pedobearMenuF.MusicL.lbl:SetDark(1)
			pedobearMenuF.MusicL.lbl:SizeToContents()

			pedobearMenuF.MusicL.List = vgui.Create("DListView", pedobearMenuF.MusicL)
			pedobearMenuF.MusicL.List:SetPos(0, 20)
			pedobearMenuF.MusicL.List:SetSize(305, 195)
			pedobearMenuF.MusicL.List:SetMultiSelect(false)
			local name = pedobearMenuF.MusicL.List:AddColumn("Music")
			name:SetMinWidth(150)
			local mp = pedobearMenuF.MusicL.List:AddColumn("Pack")
			mp:SetMinWidth(30)
			local loc = pedobearMenuF.MusicL.List:AddColumn("Local")
			loc:SetMinWidth(30)
			loc:SetMaxWidth(30)
			local serv = pedobearMenuF.MusicL.List:AddColumn("Serv")
			serv:SetMinWidth(30)
			serv:SetMaxWidth(30)

			local localmusics = Either(pre, GAMEMODE.LocalMusics.premusics, GAMEMODE.LocalMusics.musics)

			local musiclist = {}

			for k, v in pairs(localmusics) do

				musiclist[v[1]] = { v[2], v[3], file.Exists("sound/pedo/" .. Either(pre, "premusics", "musics") .. "/" .. v[1], "GAME"), nil }

			end

			if Either(pre, GAMEMODE.Musics.premusics, GAMEMODE.Musics.musics) then

				for k, v in pairs(Either(pre, GAMEMODE.Musics.premusics, GAMEMODE.Musics.musics)) do

					if musiclist[v[1]] then
						musiclist[v[1]] = { v[2], v[3], musiclist[v[1]][3], true }
					else
						musiclist[v[1]] = { v[2], v[3], file.Exists("sound/pedo/" .. Either(pre, "premusics", "musics") .. "/" .. v[1], "GAME"), true }
					end

				end

			end

			for k, v in SortedPairs(musiclist) do

				pedobearMenuF.MusicL.List:AddLine(v[1] or GAMEMODE:PrettyMusicName(k), v[2], Either(string.match(k, "://"), "URL", Either(v[3], "✓", "❌")), Either(v[4], "✓", "❌"))

			end

		end
		CreateMusicList(pre)


		pedobearMenuF.MusicCFG = vgui.Create("DPanel")
		pedobearMenuF.MusicCFG:SetParent(pedobearMenuF)
		pedobearMenuF.MusicCFG:SetPos(325, 255)
		pedobearMenuF.MusicCFG:SetSize(305, 215)

		local musicmenulbl = vgui.Create("DLabel")
		musicmenulbl:SetParent(pedobearMenuF.MusicCFG)
		musicmenulbl:SetText( Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "PedoRadio™", "Music") .. " configuration")
		musicmenulbl:SetPos(10, 5)
		musicmenulbl:SetDark(1)
		musicmenulbl:SizeToContents()

		local enablemusic = vgui.Create("DCheckBoxLabel")
		enablemusic:SetParent(pedobearMenuF.MusicCFG)
		enablemusic:SetText(Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "Enable the PedoRadio™", "Enable music"))
		enablemusic:SetPos(15, 30)
		enablemusic:SetDark(1)
		enablemusic:SetConVar("pedobear_cl_music_enable")
		enablemusic:SetValue(GetConVar("pedobear_cl_music_enable"):GetBool())
		enablemusic:SizeToContents()

		local allowexternal = vgui.Create("DCheckBoxLabel")
		allowexternal:SetParent(pedobearMenuF.MusicCFG)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos(15, 50)
		allowexternal:SetDark(1)
		allowexternal:SetConVar("pedobear_cl_music_allowexternal")
		allowexternal:SetValue(GetConVar("pedobear_cl_music_allowexternal"):GetBool())
		allowexternal:SizeToContents()

		local visualizer = vgui.Create("DCheckBoxLabel")
		visualizer:SetParent(pedobearMenuF.MusicCFG)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos(15, 70)
		visualizer:SetDark(1)
		visualizer:SetConVar("pedobear_cl_music_visualizer")
		visualizer:SetValue(GetConVar("pedobear_cl_music_visualizer"):GetBool())
		visualizer:SizeToContents()

		local playmusic = vgui.Create("DButton")
		playmusic:SetParent(pedobearMenuF.MusicCFG)
		playmusic:SetText("Auto play local file")
		playmusic:SetPos(90, 190)
		playmusic:SetSize(125, 20)
		playmusic:SetDisabled(!GAMEMODE.Vars.Round.PreStart and !GAMEMODE.Vars.Round.Start)
		playmusic.DoClick = function()
			GAMEMODE:Music("", GAMEMODE.Vars.Round.PreStart)
		end

		local vollbl = vgui.Create("DLabel")
		vollbl:SetParent(pedobearMenuF.MusicCFG)
		vollbl:SetText("Volume")
		vollbl:SetPos(125, 140)
		vollbl:SetDark(1)
		vollbl:SizeToContents()

		local vol = GetConVar("pedobear_cl_music_volume")
		local musivol = vgui.Create("Slider")
		musivol:SetParent(pedobearMenuF.MusicCFG)
		musivol:SetPos(15, 150)
		musivol:SetSize(300, 40)
		musivol:SetValue(vol:GetFloat())
		musivol.OnValueChanged = function(panel, value)
			vol:SetFloat(value)
		end

		if !GetConVar("pedobear_cl_disablexpsc"):GetBool() then

			local xpsc = vgui.Create("DHTML")
			xpsc:SetParent(pedobearMenuF)
			xpsc:SetPos(10, 480)
			xpsc:SetSize(620, 128)
			xpsc:SetAllowLua(true)
			xpsc:OpenURL("https://xperidia.com/Showcase/?sys=pedobearMenu&zone=" .. tostring(GAMEMODE.Name) .. "&lang=" .. tostring(GetConVarString("gmod_language") or "en"))
			xpsc:SetScrollbars(false)

			xpsc_anim = Derma_Anim("xpsc_anim", pedobearMenuF, function(pnl, anim, delta, data)
				pnl:SetSize(640, 138 * delta + 480)
			end)

		end


	elseif IsValid(pedobearMenuF) then

		pedobearMenuF:Close()

	end

end

function pedobearSCLoaded()
	if IsValid(pedobearMenuF) then xpsc_anim:Start(0.25) end
	if IsValid(pedobearMenuBF) then xpsc_anim2:Start(0.25) end
end

function GM:BeginMenu()

	if !IsValid(pedobearMenuBF) and !engine.IsPlayingDemo() then

		pedobearMenuBF = vgui.Create("DFrame")
		pedobearMenuBF:SetPos(ScrW() / 2 - 320, ScrH() / 2 - 240)
		pedobearMenuBF:SetSize(640, 480)
		pedobearMenuBF:SetTitle("Welcome to " .. (GAMEMODE.Name or "?") .. " V" .. (GAMEMODE.Version or "?") .. GAMEMODE:SeasonalEventStr() .. " | By " .. (GAMEMODE.Author or "?"))
		pedobearMenuBF:SetVisible(true)
		pedobearMenuBF:SetDraggable(true)
		pedobearMenuBF:ShowCloseButton(true)
		pedobearMenuBF:SetScreenLock(true)
		pedobearMenuBF.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		pedobearMenuBF.Think = function(self)

			if xpsc_anim2 and xpsc_anim2:Active() then xpsc_anim2:Run() end

			local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
			local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)

			if self.Dragging then

				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]

				-- Lock to screen bounds if screenlock is enabled
				if self:GetScreenLock() then

					x = math.Clamp(x, 0, ScrW() - self:GetWide())
					y = math.Clamp(y, 0, ScrH() - self:GetTall())

				end

				self:SetPos(x, y)

			end

			if self.Hovered and mousey < (self.y + 24) then
				self:SetCursor("sizeall")
				return
			end

			self:SetCursor("arrow")

			if self.y < 0 then
				self:SetPos(self.x, 0)
			end

		end
		pedobearMenuBF:MakePopup()
		pedobearMenuBF:SetKeyboardInputEnabled(false)

		pedobearMenuBF.one = vgui.Create("DPanel")
		pedobearMenuBF.one:SetParent(pedobearMenuBF)
		pedobearMenuBF.one:SetPos(10, 30)
		pedobearMenuBF.one:SetSize(305, 215)

		local xpucp = vgui.Create("DButton")
		xpucp:SetParent(pedobearMenuBF.one)
		xpucp:SetText("Xperidia Account")
		xpucp:SetPos(20, 190)
		xpucp:SetSize(125, 20)
		xpucp.DoClick = function()
			gui.OpenURL("https://www.xperidia.com/UCP/")
		end

		local xpsteam = vgui.Create( "DButton" )
		xpsteam:SetParent(pedobearMenuBF.one)
		xpsteam:SetText("Xperidia's Steam Group")
		xpsteam:SetPos(160, 190)
		xpsteam:SetSize(125, 20)
		xpsteam.DoClick = function()
			gui.OpenURL("https://xperi.link/XP-SteamGroup")
		end

		local onelbl = vgui.Create( "DLabel" )
		onelbl:SetParent(pedobearMenuBF.one)
		onelbl:SetText("Welcome to " .. (GAMEMODE.Name or "?"))
		onelbl:SetPos(10, 5)
		onelbl:SetDark(1)
		onelbl:SizeToContents()

		local desclbl = vgui.Create("DLabel")
		desclbl:SetParent(pedobearMenuBF.one)
		desclbl:SetText("So you're on the Pedobear Gamemode by Xperidia!\n\nWhat could possibly go wrong?\n\nBy default you're playing as a victim which need to \nescape from Pedobear(s)\n\nThe Pedobears are automatically chosen by the \ngamemode and it should be fair enough so everyone \ncan play as a Pedobear")
		desclbl:SetPos(20, 30)
		desclbl:SetDark(1)
		desclbl:SizeToContents()

		local hflbl = vgui.Create("DLabel")
		hflbl:SetParent(pedobearMenuBF.one)
		hflbl:SetText("Have fun!")
		hflbl:SetPos(130, 170)
		hflbl:SetDark(1)
		hflbl:SizeToContents()


		pedobearMenuBF.controls = vgui.Create("DPanel")
		pedobearMenuBF.controls:SetParent(pedobearMenuBF)
		pedobearMenuBF.controls:SetPos(325, 30)
		pedobearMenuBF.controls:SetSize(305, 215)

		local controlslbl = vgui.Create("DLabel")
		controlslbl:SetParent(pedobearMenuBF.controls)
		controlslbl:SetText("Basic controls")
		controlslbl:SetPos(10, 5)
		controlslbl:SetDark(1)
		controlslbl:SizeToContents()

		local desclbl = vgui.Create("DLabel")
		desclbl:SetParent(pedobearMenuBF.controls)
		desclbl:SetText(GAMEMODE:CheckBind("+forward") .. ": Forward\n"
		.. GAMEMODE:CheckBind("+moveleft") .. ": Left\n"
		.. GAMEMODE:CheckBind("+moveright") .. ": Right\n"
		.. GAMEMODE:CheckBind("+back") .. ": Back\n"
		.. GAMEMODE:CheckBind("+duck") .. ": Duck\n"
		.. GAMEMODE:CheckBind("+jump") .. ": Jump\n"
		.. GAMEMODE:CheckBind("+speed") .. ": Sprint\n"
		.. GAMEMODE:CheckBind("gm_showhelp") .. ": Gamemode menu\n"
		.. GAMEMODE:CheckBind("gm_showteam") .. ": Change team\n"
		.. GAMEMODE:CheckBind("gm_showspare1") .. ": Taunt menu\n"
		.. "1-9: Quick taunt\n"
		.. GAMEMODE:CheckBind("+menu") .. ": PedoVan (Shop)\n"
		.. GAMEMODE:CheckBind("+menu_context") .. ": Toggle thirdperson" )
		desclbl:SetPos(20, 30)
		desclbl:SetDark(1)
		desclbl:SizeToContents()


		pedobearMenuBF.changelog = vgui.Create("DPanel")
		pedobearMenuBF.changelog:SetParent(pedobearMenuBF)
		pedobearMenuBF.changelog:SetPos(10, 255)
		pedobearMenuBF.changelog:SetSize(620, 215)

		local changeloglbl = vgui.Create("DLabel")
		changeloglbl:SetParent(pedobearMenuBF.changelog)
		changeloglbl:SetText("Changelog")
		changeloglbl:SetPos(10, 5)
		changeloglbl:SetDark(1)
		changeloglbl:SizeToContents()

		local changelog = vgui.Create("RichText", pedobearMenuBF.changelog)
		changelog:SetPos(0, 20)
		changelog:SetSize(620, 195)
		function changelog:PerformLayout()
			self:SetFontInternal("XP_Pedo_HUDname")
			self:SetFGColor(Color(0, 0, 0))
		end
		changelog:AppendText("							/!\\ This is a dev build! /!\\\n")
		changelog:AppendText("> Gamemode registration\n")
		changelog:AppendText("> Stamina won't drop during preparation time\n")
		changelog:AppendText("> Removed Word censoring\n")

		--[[local featuredbtn = vgui.Create("DButton")
		featuredbtn:SetParent(pedobearMenuBF.changelog)
		featuredbtn:SetText("Check the last dev vlog")
		featuredbtn:SetPos(90, 0)
		featuredbtn:SetSize(125, 20)
		featuredbtn.DoClick = function()
			gui.OpenURL("")
		end]]


		if !GetConVar("pedobear_cl_disablexpsc"):GetBool() then

			local xpsc = vgui.Create( "DHTML" )
			xpsc:SetParent(pedobearMenuBF)
			xpsc:SetPos(10, 480)
			xpsc:SetSize(620, 128)
			xpsc:SetAllowLua(true)
			xpsc:OpenURL("https://xperidia.com/Showcase/?sys=pedobearMenu&zone=" .. tostring(GAMEMODE.Name) .. "&lang=" .. tostring(GetConVarString("gmod_language") or "en"))
			xpsc:SetScrollbars(false)

			xpsc_anim2 = Derma_Anim("xpsc_anim2", pedobearMenuBF, function(pnl, anim, delta, data)
				pnl:SetSize( 640, 138 * delta + 480 )
			end)

		end

	end

end
