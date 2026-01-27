--- Danh sách PlaceId của Blox Fruits
local BF = {
    [2753915549] = true,
    [4442272183] = true,
    [7449423635] = true
}

-- Kiểm tra có phải Blox Fruits không
if BF[game.PlaceId] then

    -- Đợi game load xong
    repeatwait()until game:IsLoaded() and game.Players.LocalPlayer

    -- Lấy code script
    local scriptCode = game:HttpGet("https://raw.githubusercontent.com/diquyetdinh25-glitch/Vcheem/main/CheemHub_VERSION1_obf.lua")

    -- Biên dịch & chạy
    local run = loadstring(scriptCode)
    if run then
        run()
    else
        warn("Load script thất bại")
    end

else
    warn("Game này không được hỗ trợ")
end
