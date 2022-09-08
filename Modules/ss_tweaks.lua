local completion = require "cc.completion"
local pretty = require "cc.pretty"
local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local function resetTerm()
    term.clear()
    term.setCursorPos(1, 1)
end

local function updateJSONFile(fileP, txtVar)
    expect(1, fileP, "string")
    expect(2, txtVar, "table")
    local file = fs.open(fileP, "w")
    file.write(textutils.serialiseJSON(txtVar))
    file.close()
end

local function genMenu(menuTable, label, labelColor, prefix) -- Easy Menu create function using table
    expect(1,menuTable,"table")
    expect(2, label, "string", "nil")
    for i = 1, #menuTable do
        field(menuTable[i], "text", "string")
        field(menuTable[i], "textColor", "string","nil")
        field(menuTable[i], "handler", "function", "nil")
    end
    local baseTextColor = "white"
    if menuTable[#menuTable].text ~= "Exit" then
        table.insert(menuTable,{text = "Exit"})
    end
    if label then
        expect(3, labelColor, "string")
    else
        expect(3, labelColor, "string", "nil")
    end
    expect(4, prefix, "table", "nil")
    if prefix then
        field(prefix,"b", "string" )
        field(prefix,"e", "string")
    end
    local selected = 0
    local x, _ = term.getSize()
    x = x - #label
    local p = prefix or {b = "\"", e = "\""}
    x = math.floor((x - #p.b - #p.e)/2)
        local text = ""
        for i = 1, x do text = text .. "*" end
        text = text .. (p.b .. tostring(label) .. p.e) .. text
    while true do
        sleep(0)
        resetTerm()
        if label and labelColor then
            
            pretty.print(pretty.text(text, colors[labelColor]))
        end
        for i = 1, #menuTable do

            if i == selected + 1 then
                pretty.print(pretty.text("> ", colors.yellow) .. pretty.text(menuTable[i].text,colors[menuTable.textColor or baseTextColor]))
            else
                pretty.print(pretty.text(menuTable[i].text,colors[menuTable.textColor or baseTextColor]))
            end
        end
        print()
        local _, key, _ = os.pullEventRaw("key")
        if key == keys.down then selected = (selected + 1) % (#menuTable) end
        if key == keys.up then selected = (selected - 1) % (#menuTable) end
        if key == keys.enter then
            resetTerm()
            return menuTable[selected + 1]
        end
    end
end 

local function menuHandler(menuTab,label,labelColor, prefix) -- Handlers Menu logic
    expect(1,menuTab,"table")
    expect(2, label, "string", "nil")
    if label then
        expect(3, labelColor, "string")
    else
        expect(3, labelColor, "string", "nil")
    end
    expect(4, prefix, "table", "nil")
    if prefix then
        field(prefix,"b", "string" )
        field(prefix,"e", "string")
    end
    local menuSelect = genMenu(menuTab,label, labelColor, prefix)
        if (menuSelect.text == "Exit" or menuSelect.text == "Logout") then
            resetTerm()
            return true, menuSelect.text
        elseif menuSelect.handler then
            menuSelect.handler()
        end
end

local function yNMenu(msg)
    expect(1, msg, "string", "nil")
    local tab = {{name = "Yes", value = true},{name = "No", value = false}}
    local sel = 0
    while true do
        sleep(0)
        if(msg) then
            print(msg)
        end
        for i = 0, #tab-1 do
            if(i == sel) then
                write(" >" .. tab[i+1].name .. "< ")
            else
                write(" " .. tab[i+1].name .. " ")
            end
        end
        local _, key = os.pullEventRaw("key")
        if key == keys.right then sel = (sel + 1) % (#tab) end
        if key == keys.left then sel = (sel - 1) % (#tab) end
        if key == keys.enter then
            return tab[sel+1].value
        end
        resetTerm()
    end
end

local function findElementPosInTab(tab, e)
    for i = 1, #tab do
        if tab[i] == e then
            return true, i
        end
    end
    return false, "Element not found in table"
end

local function removeElementFromTab(tab, e)
    expect(1,tab,"table")
    expect(2,e,"not table")
    local a, pos = findElementPosInTab(tab, e)
    if (a) then
        table.remove(tab, pos)
        return true, tab
    else
        return false
    end
end

local function pickElementFromTable(tabI, tabO)
    expect(1, tabI, "table")
    expect(2, tabO, "table", "nil")
    local var
    while true do
        sleep(0)
        var = read(nil, nil, function(text) return completion.choice(text, tabI) end)
        local a, tabI = removeElementFromTab(tabI, var)
        if (a) then
            if (tabO) then
                table.insert(tabO, var)
            end
            return tabI, tabO, var
        end
        print('Please select one of the auto complete options')
    end
end

return {resetTerm = resetTerm,updateJSONFile = updateJSONFile, genMenu = genMenu, menuHandler = menuHandler, yNMenu = yNMenu, removeElementFromTab = removeElementFromTab, findElementPosInTab = findElementPosInTab,pickElementFromTable = pickElementFromTable}