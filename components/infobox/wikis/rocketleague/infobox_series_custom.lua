local Series = require('Module:Infobox/Series')
local Math = require('Module:Math')
local Language = mw.language.new('en')

local RocketLeagueSeries = {}

local _totalSeriesPrizepool = 0

function RocketLeagueSeries.run(frame)
    Series.addCustomCells = RocketLeagueSeries.addCustomCells
    Series.addToLpdb = RocketLeagueSeries.addToLpdb

    return Series:createInfobox(frame)
end

function RocketLeagueSeries.addToLpdb(series, lpdbData)
    lpdbData['prizepool'] = _totalSeriesPrizepool
    return lpdbData
end

function RocketLeagueSeries.addCustomCells(series, infobox, args)
    infobox:cell('Total prize money', RocketLeagueSeries._getSeriesPrizepools(series))
    return infobox
end

function RocketLeagueSeries._getSeriesPrizepools(series)
    local prizemoney = mw.ext.LiquipediaDB.lpdb('tournament', {
        conditions = '[[series::' .. series.name .. ']]',
        query = 'sum::prizepool'
    })

    prizemoney = tonumber(prizemoney[1]['sum_prizepool'])

    if prizemoney == nil or prizemoney == 0 then
        return nil
    end

    _totalSeriesPrizepool = prizemoney
    return '$' .. Language:formatNum(Math._round(prizemoney))
end

return RocketLeagueSeries
