-- Created by Hackcraft STEAM_0:1:50714411
local printConsole = "Loaded Hackcraft's (STEAM_0:1:50714411) banking system 0_o"
print("\n")
for i=1, #printConsole do
	MsgC(Color((255/#printConsole)*i, 255, 0), printConsole[i])
end
print("\n")

net.Receive( "hc_bank_notification", function(len)
	Derma_Message(net.ReadString(), "Bank notification", "OK")
end)

local xScreenRes = 1920
local yScreenRes = 1080
local wMod = ScrW() / xScreenRes     
local hMod = ScrH() / yScreenRes

local B = B or {}
local T = T or {}

timer.Create("bank_menu_update", 5, 0, function() -- changing screen res in-game support
	wMod = ScrW() / xScreenRes     
	hMod = ScrH() / yScreenRes
end)

surface.CreateFont( "Bank_smooth", { 
	font = "Trebuchet18", 
	size = wMod*18, 
	weight = 700, 
	antialias = true 
} )

concommand.Add("bank", function()
	
	B.Frame = vgui.Create("DFrame")
	B.Frame:SetSize(wMod*320, hMod*244)
	B.Frame:Center()
--	B.Frame:SetFont("Bank_smooth")
	B.Frame:SetTitle("Lawless Bank")
	B.Frame:SetVisible(true)
	B.Frame:SetDraggable(true)
	B.Frame:ShowCloseButton(true)
	B.Frame:MakePopup()
	B.Frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color( 45, 45, 45 ))
		draw.DrawText( "Balance: " .. DarkRP.formatMoney(LocalPlayer():GetNWInt("hc_bank")), "Bank_smooth", wMod*160, hMod*30, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER )
	end
	
		B.TextInput = false
		B.Text = vgui.Create("DTextEntry", B.Frame)
		B.Text:SetPos(wMod*9, hMod*64)
		B.Text:SetSize(wMod*302, hMod*51)
		B.Text:SetFont("Bank_smooth")
--		B.Text:SetText("Enter amount")
		B.Text:SetNumeric( true )
		B.Text.OnTextChanged = function(self)
			B.TextInput = self:GetValue()
		end
		B.Text.Paint = function(self)
			surface.SetDrawColor(200, 200, 200)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			if !B.TextInput then
				draw.DrawText("Enter amount", "Bank_smooth", wMod*150, hMod*16, Color( 75, 75, 75, 255 ), TEXT_ALIGN_CENTER)
			end
			self:DrawTextEntryText(Color(75, 75, 75), Color(30, 130, 255), Color(255, 255, 255))
		end
		
		B.But = vgui.Create("DButton", B.Frame)
		B.But:SetPos(wMod*9, hMod*123)
		B.But:SetSize(wMod*151, hMod*51)
		B.But:SetFont("Bank_smooth")
		B.But:SetText("Withdraw")
		B.But.DoClick = function()
			RunConsoleCommand("withdraw", B.TextInput)
		end
		
		B.But = vgui.Create("DButton", B.Frame)
		B.But:SetPos(wMod*160, hMod*123)
		B.But:SetSize(wMod*151, hMod*51)
		B.But:SetFont("Bank_smooth")
		B.But:SetText("Withdraw all")
		B.But.DoClick = function()
			RunConsoleCommand("withdraw", LocalPlayer():GetNWInt("hc_bank"))
		end
		
		B.But = vgui.Create("DButton", B.Frame)
		B.But:SetPos(wMod*9, hMod*182) 	--B.But:SetPos(wMod*9, hMod*182)
		B.But:SetSize(wMod*151, hMod*51)--B.But:SetSize(wMod*302, hMod*51)
		B.But:SetFont("Bank_smooth")
		B.But:SetText("Deposit")
		B.But.DoClick = function()
			RunConsoleCommand("deposit", B.TextInput)
		end
		
		B.But = vgui.Create("DButton", B.Frame)
		B.But:SetPos(wMod*160, hMod*182)
		B.But:SetSize(wMod*151, hMod*51)
		B.But:SetFont("Bank_smooth")
		B.But:SetText("Deposit all")
		B.But.DoClick = function()
			RunConsoleCommand("deposit", LocalPlayer():getDarkRPVar("money"))
		end
		
	
end)

concommand.Add("bank_help", function()

	T.Frame = vgui.Create("DFrame")
	T.Frame:SetSize(wMod*320, hMod*244)
	T.Frame:Center()
--	T.Frame:SetFont("Tank_smooth")
	T.Frame:SetTitle("Tutorial - Do NOT close until read!")
	T.Frame:SetVisible(true)
	T.Frame:SetDraggable(true)
	T.Frame:ShowCloseButton(true)
	T.Frame:MakePopup()
	T.Frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color( 45, 45, 45 ))
	end
	
	T.richtext = vgui.Create("RichText", T.Frame)
	T.richtext:Dock(FILL)
	function T.richtext:PerformLayout()
		self:SetFontInternal("Bank_smooth")
	end
	T.richtext:InsertColorChange(200, 200, 200, 255)
	T.richtext:AppendText("Your money has been transferred to your bank. You can access your bank by typing ") --!bank into chat or bank into console.\nYou will drop ALL money on death so it's important to use your bank and you have the added bonus of interest! However, be warned, there are criminals who will try and steal money from your bank.")
	T.richtext:InsertColorChange(200, 35, 35, 255)
	T.richtext:AppendText("!bank")
	T.richtext:InsertColorChange(200, 200, 200, 255)
	T.richtext:AppendText(" into chat or press ")
	T.richtext:InsertColorChange(200, 35, 35, 255)
	T.richtext:AppendText("F2")
	T.richtext:InsertColorChange(200, 200, 200, 255)
	T.richtext:AppendText(" or type ")
	T.richtext:InsertColorChange(200, 35, 35, 255)
	T.richtext:AppendText("bank")
	T.richtext:InsertColorChange(200, 200, 200, 255)
	T.richtext:AppendText(" into console.\nYou will drop 20% of your money over ")
	T.richtext:InsertColorChange(200, 35, 35, 255)
	T.richtext:AppendText("5k")
	T.richtext:InsertColorChange(200, 200, 200, 255)
	T.richtext:AppendText(" on death so it's important to use your bank and you have the added bonus of interest! However, be warned, there are criminals who will try and steal money from your bank.")
	
end)

/*
	Chat command
*/
local lp = LocalPlayer()
hook.Add( "OnPlayerChat", "HelloCommand", function( ply, strText, bTeam, bDead )
	strText = string.lower( strText )
	
	if strText == "!bank" then 
		if LocalPlayer() == ply then 
			RunConsoleCommand("bank")
		end
		return true 
	end
end)
