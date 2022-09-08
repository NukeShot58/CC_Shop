os.pullEvent = os.pullEventRaw

if fs.exists('/Modules/ss_tweaks.lua') then
    fs.delete('/Modules/ss_tweaks.lua')
end
shell.execute('pastebin', 'get', 'UyrRb5hf', '/Modules/ss_tweaks.lua')
if fs.exists('/Modules/ss_tweaks.lua') then
    fs.delete('/shop/.shopCode.lua')
end
shell.execute('pastebin', 'get', 't707V832', '/shop/.shopCode.lua')
term.clear()
term.setCursorPos(1,1)
textutils.slowPrint("Thank you for using D.A.R Shopping Software!")
sleep(5)
shell.execute('shop/.shopCode.lua')
