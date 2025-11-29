local Config = require 'shared.config'

-- Function convert ke hari, jam, menit, detik
local function convert(second)
    local hari = math.floor(second / 86400)

    local detik = second % 86400
    local jam = math.floor(detik / 3600)

    detik = detik % 3600
    local menit = math.floor(detik / 60)

    detik = detik % 60

    return hari, jam, menit, detik
end

-- Command check playtime 20 besar
RegisterCommand(Config.command, function ()
    local pt = lib.callback.await('naufal-tophighplaytime:server:getplaytime')
    if not pt then return end

    local context = {
        id = 'upt',
        title = 'Top ' .. Config.top,
        options = {}
    }

    table.sort(pt, function (a, b)
        return a.total_time > b.total_time
    end)

    for i=1, #pt do
        local p = pt[i]
        local hari, jam, menit, detik = convert(p.total_time)

        if #context.options < Config.top then
            context.options[#context.options+1] = {
                title =  i .. ' | ' .. p.game_name,
                icon = 'user',
                description = hari .. ' hari ' .. jam .. ' jam ' .. menit .. ' menit ' .. detik .. ' detik'
            }
        end
    end

    lib.registerContext(context)
    lib.showContext('upt')
end, false)
