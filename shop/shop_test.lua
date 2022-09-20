-- External packets
local completion = require "cc.completion"
local pretty = require "cc.pretty"
local expect = require "cc.expect"
local expect, field = expect.expect, expect.field
local ss_tweaks = require "../Modules.ss_tweaks"
--#region Global values
local submenuPrefix = {b = "{\"", e = "\"}"}
local submenuCol = "blue"
local invs = { peripheral.find("inventory") }
local monitor = peripheral.find("monitor")
if not monitor then
    error('Monitor not found!')
end
local settings = '{"invNames": { "avbInvNames" : {}, "nAvbInvNames" : {} },"io" : {"ichest": "","ochest" : ""},"shopName" : "","shopColor" : "red","offers" : {}}'
settings = textutils.unserialiseJSON(settings, _, true, true)
os.pullEvent = os.pullEventRaw -- Disables termination
local lColors = { "white", "orange", "magenta", "lightBlue", "yellow", "lime", "pink", "gray", "lightGray", "cyan",
    "purple", "blue", "brown", "green", "red", "black" }
local cFilePath = "shop/.pass.json"
local cridentials = '{"superUser": {"pass" : "132", "login" : "su"} ,"user": {"pass" : "admin", "login" : "admin"}}'
cridentials = textutils.unserialiseJSON(cridentials, _, true, true)
local filePath = "shop/shop.json"
--#endregion

--#region Functions

--#region Gui Commands


--#region Commands for setup function

local function fillTableWithInvNames(tab)
    invs = { peripheral.find("inventory") }
    for i = 1, #invs do
        table.insert(tab, peripheral.getName(invs[i]))
    end
    return tab
end

local function checkFileContent(fileP,fileVar) -- Code is part of the setup function
    expect(1, fileP, 'string')
    expect(2, fileVar, "table")
    local fileR = fs.open(fileP, "r")
    if fileR.readAll() == "" then
        fileR.close()
        ss_tweaks.updateJSONFile(fileP,fileVar)
    else
        local fileR = fs.open(fileP, "r")
        fileVar = textutils.unserialiseJSON(fileR.readAll())
        fileR.close()
        return fileVar
    end
end

local function checkChestNumber() -- Code is part of the setup function
    if #invs < 3 then
        error("Not enough inventories found. At least 3 are needed!")
    end
end

local function updateAvailableInvs()
    local a = {}
    a = fillTableWithInvNames(a)
    local logic = {{save = true},{keep = false}}
    local counter = {a = 0,r = 0}
    local io = {false,false}
    for i = 1, #settings.invNames.avbInvNames do -- Removing old Inventories
        for j = 1, #a do
            if a[j] == settings.invNames.avbInvNames[i]  then
                logic.keep = true
            end
        end
        if not logic.keep then
            table.remove(settings.invNames.avbInvNames, i)
            counter.r = counter.r + 1
        end
        logic.keep = false
    end
    
    for i = 1, #settings.invNames.nAvbInvNames do
        for j = 1, #a do
            if a[j] == settings.invNames.nAvbInvNames[i] then
                logic.keep = true
            end
        end
        if not logic.keep then
            if settings.invNames.nAvbInvNames[i] == settings.io.ichest then
                settings.io.ichest = ""
                io[1] = true
            end
            if settings.invNames.nAvbInvNames[i] == settings.io.ochest then
                settings.io.ochest = ""
                io[2] = true
            end
            table.remove(settings.invNames.nAvbInvNames, i)
            counter.r = counter.r + 1
        end
        logic.keep = false
    end--
    for i = 1, #a do -- Adding new Inventories
        logic.save = true
        for j = 1, #settings.invNames.avbInvNames do
            if a[i] == settings.invNames.avbInvNames[j] then
                logic.save = false
            end
        end
        for j = 1, #settings.invNames.nAvbInvNames do
            if a[i] == settings.invNames.nAvbInvNames[j] then
                logic.save = false
            end
        end
        if logic.save then
            table.insert(settings.invNames.avbInvNames, a[i])
            counter.a = counter.a + 1
        end
    end--
    for i = 1, 3 do
        print("Checking Inventories. Please Wait!") 
        textutils.slowPrint('....', 3)
        ss_tweaks.resetTerm()
    end
    print('Checking finished!')
    if counter.a == 0 and counter.r == 0 then
        print("No removed or new inventories found!")
    else
        if counter.a > 0 then
            print('Found { '.. counter.a ..' } new inventories')
        end
        if counter.r > 0 then
            print('Removed { '.. math.abs(counter.r) ..' } old inventories')
            if io[1] then
                pretty.print(pretty.text('Warning: ', colors.red) .. "Input chest has been removed!")
            end
            if io[2] then
                pretty.print(pretty.text('Warning: ', colors.red) .. "Output chest has been removed!")
            end
        end
    end
    ss_tweaks.updateJSONFile(filePath,settings)
    sleep(5)
    ss_tweaks.resetTerm()
end

local function setup() -- Setups required files
    ss_tweaks.resetTerm()
    if not fs.exists(filePath) then
        local file = fs.open(filePath, "a")
        file.close()
    end
    if not fs.exists(cFilePath) then
        local file = fs.open(cFilePath, "a")
        file.close()
    end
    checkChestNumber()
    settings = checkFileContent(filePath,settings)
    cridentials = checkFileContent(cFilePath,cridentials)
    updateAvailableInvs()
end

--#endregion






local function addNewOffer() -- Not used yet
    if settings.io.ichest == "" and settings.io.ochest == "" then
        print("Please setup Shop IOs first!")
    else

    end
end

--#region Gui SubMenus

--#region ShopSettings SubMenus

local function setShopColor()
    while true do
        sleep(0)
        local exit = false
        settings.shopColor = read(_, _, function(text) return completion.choice(text, lColors) end)
        ss_tweaks.resetTerm()
        for i = 1, #lColors do
            if settings.shopColor == lColors[i] then
                exit = true
            end
        end
        if exit then
            break
        end
        print('Please select one of the auto complete options')
    end
end

local function setShopName()
    print("Please write your shop's name:")
    pretty.write(pretty.text("> ", colors.yellow))
    settings.shopName = read()
end

--#region ShopIOs SubMenus

--#region Commands for setupShopIO






local function setupShopIO()
    ss_tweaks.resetTerm()
    
    if settings.io.ichest ~= "" and settings.io.ochest ~= "" then
        if not (ss_tweaks.yNMenu("Shop IOs are already setup!\n Resetup Shop IOs?")) then
            return
        end
        ss_tweaks.resetTerm()
    end
    if #settings.invNames.avbInvNames == 0 and #settings.invNames.nAvbInvNames == 0 then
        settings.invNames.avbInvNames = fillTableWithInvNames()
    else
        if settings.io.ichest ~= "" then
            table.insert(settings.invNames.avbInvNames, settings.io.ichest)
        end
        if settings.io.ochest ~= "" then
            table.insert(settings.invNames.avbInvNames, settings.io.ochest)
        end
        
                       
        if settings.io.ichest ~= "" then
            _, settings.invNames.nAvbInvNames = ss_tweaks.removeElementFromTab(settings.invNames.nAvbInvNames, settings.io.ichest)
        end
        if settings.io.ochest ~= "" then
            _, settings.invNames.nAvbInvNames = ss_tweaks.removeElementFromTab(settings.invNames.nAvbInvNames, settings.io.ochest)
        end
       
    end
    print("Please select the input inventory:")
    settings.invNames.avbInvNames, settings.invNames.nAvbInvNames, settings.io.ichest = ss_tweaks.pickElementFromTable(settings.invNames.avbInvNames, settings.invNames.nAvbInvNames)
    print("Please select the output inventory:")
    settings.invNames.avbInvNames, settings.invNames.nAvbInvNames, settings.io.ochest = ss_tweaks.pickElementFromTable(settings.invNames.avbInvNames, settings.invNames.nAvbInvNames)
end



--#endregion


local function showCurrentIOs()
    pretty.print(pretty.text("Current input chest: ", colors.yellow) .. "[" .. settings.io.ichest .. "]")
    pretty.print(pretty.text("Current output chest: ", colors.yellow) .. "[" .. settings.io.ochest .. "]")
    print()
    print("Press enter to continue...")
    read()
end

local function ShopIOsSubMenu()
    while true do
        sleep(0)
        ss_tweaks.updateJSONFile(filePath,settings)
        local menuTab = {{text = "Setup_Shop_IOs", handler = setupShopIO},{text = "Show_Current_IOs", handler = showCurrentIOs}}
        if(ss_tweaks.menuHandler(menuTab,"Shop_IOs", submenuCol,submenuPrefix)) then
            return
        end
    end
    
end
--#endregion


local function setCridentials()
    ss_tweaks.resetTerm()
    if(ss_tweaks.yNMenu('Do you wish to set new cridentials?')) then
        local newL
        repeat
            ss_tweaks.resetTerm()
            print('Please set new login:')
            pretty.write(pretty.text('> ', colors.yellow))
            newL = tostring(read())
        until ss_tweaks.yNMenu('Your new login is:'  .. newL ..'\nDo you wish to set this as your new login?')
        cridentials.user.login = newL
        local newP
        repeat
            ss_tweaks.resetTerm()
            print('Please set new password:')
            pretty.write(pretty.text('> ', colors.yellow))
            newP = tostring(read())
        until ss_tweaks.yNMenu('Your new password is:'  .. newL .. '\nDo you wish to set this as your new password?')
        ss_tweaks.updateJSONFile(cFilePath,cridentials)
    end
end

--#endregion
local function shopSettingsSubMenu()
    local menuTab = {{ text = "Set_Shop_Name", handler = setShopName },
    { text = "Set_Shop_Color", handler = setShopColor }, { text = "Shop_IOs", handler = ShopIOsSubMenu },{text = "Update_Available_Inventories" , handler = updateAvailableInvs},{text = "Set_New_Cridentials", handler = setCridentials}}
    while true do
        sleep(0)
        if(ss_tweaks.menuHandler(menuTab,"Shop_Settings",submenuCol,submenuPrefix)) then
            return
        end
    end

end

local function offersSubMenu()
    local menuTab = {{text = "Add_New_offer"},{text = "Modify_Existing_Offers"}}
    while true do
        sleep(0)
        if(ss_tweaks.menuHandler(menuTab,"Offers",submenuCol,submenuPrefix)) then
            return
        end
    end
end

--#endregion

--#endregion
local function Gui()
    local guiMenu = { { text = "Shop_Settings", handler = shopSettingsSubMenu },
        { text = "Offers", handler = offersSubMenu },{text = "Logout"} }
    while true do
        ss_tweaks.resetTerm()
        sleep(0)
        ss_tweaks.updateJSONFile(filePath,settings)
        local a, but = ss_tweaks.menuHandler(guiMenu, settings.shopName, settings.shopColor)
        if(a) then
            if(but == "Exit") then
                return true
            else
                return false
            end
        end
    end
end

local function login()
    while true do
        local enter = false
        ss_tweaks.resetTerm()
        sleep(0)
        print("Welcome To D.A.R Shopping Software!")
        print()
        print("Press any key to begin the login process...")
        if(os.pullEventRaw('key')) then
            repeat
                print("Please enter your login: ")
                pretty.write(pretty.text('> ', colors.yellow))
                local inptL = read()
                if inptL == cridentials.user.login then
                    for i = 1, 3 do
                        ss_tweaks.resetTerm()
                        print('Please enter your password:')
                        pretty.write(pretty.text('> ', colors.yellow))
                        local inptP = read('*')
                        if(inptP == cridentials.user.pass) then
                            enter = true
                            break
                        end
                    end
                    
                elseif inptL == cridentials.superUser.login then
                    for i = 1, 3 do
                        ss_tweaks.resetTerm()
                        print('Please enter your password:')
                        pretty.write(pretty.text('> ', colors.yellow))
                        local inptP = read('*')
                        if(inptP == cridentials.superUser.pass) then
                            enter = true
                            break
                        end
                    end
                else
                    ss_tweaks.resetTerm()
                    print('User with that login does not exist!')
                end
            until enter
            if Gui() then
                return
            else
                enter = false
            end
        end
    end
end

--#endregion
local function Main()
    setup()
    login()
    --setupShopIO()

end

Main()
