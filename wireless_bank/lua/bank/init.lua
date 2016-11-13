-- Created by Hackcraft STEAM_0:1:50714411
print("Loaded bank server side")
util.AddNetworkString( "hc_bank_notification" )
  
-- Add total money!
-- VIP get money in bank, normal get it in wallet
-- hackers can hack people's bank account but have to hold up for specific time from person they're hacking
  
/*
	Config
*/
local deposit_delay = 5 -- in minutes
local interest_percentage = 2 -- 500 at 5%(make sure no % sign) would be $25 in interest
local interest_percentage_vip = 5
local interest_rate = 60*60 -- in seconds, how often people get interest
bankHeistTake = 0.5 -- percentage of how much money they take from each person's bank (need to be global, using it in the bank box addon)
local StartingBankMoney = 12500
 
local keep_ondrop = 5000

/*
	Other
*/
deposit_delay = deposit_delay * 60 
interest_percentage = interest_percentage / 100
interest_percentage_vip = interest_percentage_vip / 100
bankHeistTake = bankHeistTake / 100
local globalBankMoney = 0
local Stored_ids = false
local CheckedIDs = false
local function validDatabase() return true end

/*
	Find bank money amount, (for bank addon to use)
*/
function getBankMoney()
	return math.Round(globalBankMoney)
end

/*
	Send amazing derma popup
*/
local function sendDermaPopup(ply, msg)
	net.Start("hc_bank_notification")
	net.WriteString(msg)
	net.Send(ply)
end

/*
	F2 To Open!
*/
local function ShowMenu( ply )
	ply:ConCommand("bank")
end
hook.Add("ShowTeam", "BankShowMenu", ShowMenu)

/*
	Update players on the amount
*/
local function sendBankHeistTake()
	BroadcastLua("BankRS_RewardCurrent = "..getBankMoney())
end

/*
	Find out bank amount to be stolen
*/ 
local function loadGlobalMoney(skip)
	local money = 0
	globalBankMoney = 0
	if skip or validDatabase() then
		for k, v in ipairs(Stored_ids) do 
			money = money + tonumber(util.GetPData(v, "hc_bank", 0))*bankHeistTake
		end 
		globalBankMoney = money
		sendBankHeistTake()
	end
	if globalBankMoney < 0 then 
		file.Append( "hacks_debug.txt", "You dun fucked: " .. os.date("%H:%M:%S - %d/%m/%Y" , os.time()) .. ". Table size: " .. #Stored_ids .. ". Attempted money: " .. globalBankMoney )
		globalBankMoney = 0
	end
--	print(globalBankMoney)
end

/*
	Load database
*/
local function LoadDataBase()
	if file.Exists("globalbankmoney.txt", "DATA") then
		Stored_ids = util.JSONToTable(file.Read("globalbankmoney.txt", "DATA"))
		CheckedIDs = {}
		for k, v in ipairs(Stored_ids) do
			CheckedIDs[v] = true
		end
		loadGlobalMoney(true)
	else
		Stored_ids = {}
		CheckedIDs = {}
	end
end
LoadDataBase()

/*
	Check database integrity
*/
local function validDatabase()
	if Stored_ids and CheckedIDs then
		return true
	else
		LoadDataBase()
		return true
	end	
end

local meta = FindMetaTable( "Player" )
-- Same as DarkRP's
function meta:canAffordBank(amount)
	if not amount then return end
	return math.floor(amount) >= 0 and self:GetNWInt("hc_bank") - math.floor(amount) >= 0
end

/*
	Handle bank change
*/
local function updatePlayersBalance(ply, amount)
	if !ply or !amount then return end
	local old = ply:GetNWInt("hc_bank", 0)
	if old > amount then -- if minus
		ply:SetPData("hc_bank", math.Round(amount))
		ply:SetNWInt("hc_bank", math.Round(amount))
		local diff = (old - amount)*bankHeistTake
		globalBankMoney = globalBankMoney - diff
	else -- if plus
		ply:SetPData("hc_bank", math.Round(amount))
		ply:SetNWInt("hc_bank", math.Round(amount))
		local diff = (amount - old)*bankHeistTake
		globalBankMoney = globalBankMoney + diff
	end
--	print(globalBankMoney)
	timer.Create("bank_hesit_send", 2, 1, function() sendBankHeistTake() end) -- makes sure people don't get spammed
end

/*
	Add id
*/
local function StoreSteamID(ply, id)
	if validDatabase() then
		table.insert(Stored_ids, id)
		file.Write("globalbankmoney.txt", util.TableToJSON(Stored_ids))
		if ply then
			ply:SetPData("hc_bank", StartingBankMoney)
			ply:SetNWInt("hc_bank", StartingBankMoney)
			ply:SetPData("hc_bank_ld", 0)
			ply:SetNWInt("hc_bank_ld", 0)
		end
	end
end

/*
	CheckID database
*/
local function AddIDIfNil(ply, id)
	if CheckedIDs == false then
		LoadDataBase()
		CheckedIDs[id] = true
		StoreSteamID(ply, id)
	else
		if CheckedIDs[id] == nil then
			CheckedIDs[id] = true
			StoreSteamID(ply, id)
			return true -- true for added
		end
		return false
	end
end
 
/*
	Load players balance
*/
hook.Add( "PlayerInitialSpawn", "Bank_SetBalance", function(ply)
	if CheckedIDs and validDatabase() and CheckedIDs[ply:SteamID()] then
		ply:SetNWInt("hc_bank", tonumber(ply:GetPData("hc_bank")))
		ply:SetNWInt("hc_bank_ld", tonumber(ply:GetPData("hc_bank_ld")))
	else
		if CheckedIDs == false then
			LoadDataBase()
		end
		AddIDIfNil(ply, ply:SteamID())
		timer.Simple(3, function() if IsValid(ply) then ply:ConCommand("bank_help") ply:SendLua("BankRS_RewardCurrent = "..getBankMoney()) end end)
	end
end)

/*
	Bank interest timer!
*/
timer.Create("Bank_Interest", interest_rate, 0, function()
	for k, v in ipairs(player.GetAll()) do
		local vip = table.HasValue({"networkowner", "trialmod", "admin", "moderator", "VIP", "owner", "co-owner", "staffmanager", "helper", "dev", "regulator", "superadmin"}, ply:GetNWString("usergroup"))
		if vip then
			local interest = math.floor(v:GetNWInt("hc_bank") * interest_percentage_vip)
		else
			local interest = math.floor(v:GetNWInt("hc_bank") * interest_percentage)
		end
		if !interest then return end
		updatePlayersBalance(v, v:GetNWInt("hc_bank")+interest)
		DarkRP.notify(v, 1, 2, "You got " .. DarkRP.formatMoney(interest) .. " in interest from your bank!")
	end
end)

/*
	Find bank money amount, (for bank addon to use)
*/
function BankMoneyStolen(ply)
	// might not be 100% in sync but the money it takes away will be close enough
	local money
	local minus
	local done = {}

	if validDatabase() then
		local stolen_money = getBankMoney()
		// online 1st
		for k, v in ipairs(player.GetAll()) do
			money = v:GetNWInt("hc_bank")
			minus = math.Round(money*bankHeistTake)
			updatePlayersBalance(v, money-minus)
			if v != ply then
				DarkRP.notify(v, 0, 5, ply:Nick().." stole " .. DarkRP.formatMoney(minus) .. " from your bank account!")
			else
				DarkRP.notify(v, 0, 5, "You stole " .. DarkRP.formatMoney(stolen_money) .. " from the bank!")
				updatePlayersBalance(v, money+stolen_money)
			end
			done[v:SteamID()] = true
		end
		// offline 2nd
		for k, v in ipairs(Stored_ids) do -- number, steamid
			if done[v] == nil then
				money = tonumber(util.GetPData(v, "hc_bank", 0))
				minus = tonumber(money*bankHeistTake)
				util.SetPData(v, "hc_bank", math.Round(money-minus))
			end
		end
	end
	
	loadGlobalMoney()
	
end

/*
	Drop money on death
*/
hook.Add("DoPlayerDeath", "BankSystem", function(ply, attacker, dmg)
	local amount = ply:getDarkRPVar("money")
	if amount > keep_ondrop then 
		amount = math.Round((amount - keep_ondrop)*0.2) -- anyhting over specified min amount (5k) -- 20% of it
		if amount >= 1 then
			ply:addMoney(-amount)
			DarkRP.createMoneyBag(ply:GetPos(), amount)
			DarkRP.notify(ply, 0, 5, "You dropped " .. DarkRP.formatMoney(amount) .. " from your wallet!")
		end
	end
end)

/*
	Re-set bank
*/
concommand.Add("clear_bank", function(ply)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end
	if validDatabase() then
		for k, v in ipairs(Stored_ids) do
			util.RemovePData(v, "hc_bank")
			util.RemovePData(v, "hc_bank_ld")
		end
	end
	CheckedIDs = {}
	Stored_ids = {}
	for k, v in ipairs(player.GetAll()) do
		AddIDIfNil(v, v:SteamID()) -- takes care of everything :D
	end
	file.Delete("globalbankmoney.txt")
	loadGlobalMoney()
end) 

/*
	Bank interest timer!
*/
timer.Create("Bank_Interest", interest_rate, 0, function()
	for k, v in ipairs(player.GetAll()) do
		AddIDIfNil(v, v:SteamID())
		local vip = table.HasValue({"networkowner", "trialmod", "admin", "moderator", "VIP", "owner", "co-owner", "staffmanager", "helper", "dev", "regulator", "superadmin"}, v:GetNWString("usergroup"))
		if vip then
			local interest = math.Round(v:GetNWInt("hc_bank") * interest_percentage_vip)
		else
			local interest = math.Round(v:GetNWInt("hc_bank") * interest_percentage)
		end
		if interest >= 1 then return end
		updatePlayersBalance(v, v:GetNWInt("hc_bank") + interest)
		DarkRP.notify(v, 1, 2, "You got " .. DarkRP.formatMoney(interest) .. " in interest from your bank!")
	end
end)

/*
	Deposit command
*/
concommand.Add("deposit", function(ply, cmd, args, argStr)
	if args[1] == nil then return end
	local money = tonumber(math.Round(math.abs(args[1])))
	if money == 0 or money == nil or !money then sendDermaPopup(ply, "You cannot deposit 0.") return end
	AddIDIfNil(ply, ply:SteamID())
	local time = os.time()
	local delay = time - (ply:GetNWInt("hc_bank_ld") + deposit_delay)
	if delay == deposit_delay then StoreSteamID(id) end -- fail safe
	if delay < 0 then sendDermaPopup(ply, "You cannot deposit this often, please wait " .. os.date( "%M:%S" , delay*-1)) return end
	if ply:canAfford(money) then
		ply:addMoney(-money)
		updatePlayersBalance(ply, ply:GetNWInt("hc_bank") + money)
		ply:SetPData("hc_bank_ld", time) 
		ply:SetNWInt("hc_bank_ld", time)
		sendDermaPopup(ply, "You have deposited " .. DarkRP.formatMoney(money) .. ". Your balance is now " .. DarkRP.formatMoney(ply:GetNWInt("hc_bank")) .. ".")
	else
		sendDermaPopup(ply, "You cannot deposit more money than is in your wallet.")
	end
end)

/*
	Withdraw command
*/
concommand.Add("withdraw", function(ply, cmd, args, argStr)
	if args[1] == nil then return end
	local money = tonumber(math.Round(math.abs(args[1])))
	if money == 0 or money == nil or !money then sendDermaPopup(ply, "You cannot withdraw 0.") return end
	AddIDIfNil(ply, ply:SteamID())
	if ply:canAffordBank(money) then
		ply:addMoney(money)
		updatePlayersBalance(ply, ply:GetNWInt("hc_bank") - money)
		sendDermaPopup(ply, "You have withdrawn " .. DarkRP.formatMoney(money) .. ". Your balance is now " .. DarkRP.formatMoney(ply:GetNWInt("hc_bank")) .. ".")
	else
		sendDermaPopup(ply, "You cannot withdraw more money than is in your bank account.")
	end
end)