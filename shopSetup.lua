os.pullEvent = os.pullEventRaw

if fs.exists('/Modules/ss_tweaks.lua') then
    fs.delete('/Modules/ss_tweaks.lua')
end
shell.execute('wget', 'https://bit.ly/3x8xgvh', '/Modules/ss_tweaks.lua')
if fs.exists('/shop/.shopCode.lua') then
    fs.delete('/shop/.shopCode.lua')
end
shell.execute('wget', 'https://bit.ly/3eBzaOQ', '/shop/.shopCode.lua')
term.clear()
term.setCursorPos(1,1)
textutils.slowPrint("Thank you for using D.A.R Shopping Software!")
sleep(5)
shell.execute('shop/.shopCode.lua')
