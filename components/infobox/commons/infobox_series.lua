local Class = require('Module:Class')
local Cell = require('Module:Infobox/Cell')
local Template = require('Module:Template')
local Table = require('Module:Table')
local Namespace = require('Module:Namespace')
local Locale = require('Module:Locale')
local ReferenceCleaner = require('Module:ReferenceCleaner')
local Localisation = require('Module:Localisation')
local Links = require('Module:Links')
local Flags = require('Module:Flags')._Flag
local BasicInfobox = require('Module:Infobox/Basic')

local Series = Class.new(BasicInfobox)

function Series.run(frame)
    local series = Series(frame)
    return series:createInfobox(frame)
end

function Series:createInfobox(frame)
    local infobox = self.infobox
    local args = self.args

    infobox :name(args.name)
            :image(args.image, args.default)
            :centeredCell(args.caption)
            :header('Series Information', true)
            :cell('Liquipedia Tier', self:createTier(
                args.liquipediatier, (args.liquipediatiertype or args.tiertype)))
            :fcell(Cell:new('Organizer'):options({makeLink = true}):content(
                                                                        args.organizer,
                                                                        args.organizer2,
                                                                        args.organizer3,
                                                                        args.organizer4,
                                                                        args.organizer5,
                                                                        args.organizer6,
                                                                        args.organizer7
                                                                    ):make())
            :fcell(Cell:new('Location'):options({}):content(self:_createLocation(args.country, args.city)):make())
            :cell('Date', args.date)
            :cell('Start Date', args.sdate or args.launched)
            :cell('End Date', args.edate or args.defunct)
            :cell('Sponsor(s)', args.sponsor)
    self:addCustomCells(infobox, args)

    local links = Links.transform(args)
    infobox :header('Links', not Table.isEmpty(links))
            :links(links)

    if Namespace.isMain() then
        self:addCustomVariables(args)

        local lpdbData = {
            name = self.name,
            image = args.image,
            abbreviation = args.abbreviation or args.acronym,
            icon = args.icon,
            game = args.game,
            type = args.type,
            location = Locale.formatLocation({city = args.city, country = args.country}),
            location2 = Locale.formatLocation({city = args.city2, country = args.country2}),
            previous = args.previous,
            previous2 = args.previous2,
            next = args.next,
            next2 = args.next2,
            prizepool = args.prizepool,
            liquipediatier = args.liquipediatier,
            publishertier = args.publishertier,
            launcheddate = ReferenceCleaner.clean(args.launcheddate or args.sdate),
            defunctdate = ReferenceCleaner.clean(args.defunctdate or args.edate),
            defunctfate = ReferenceCleaner.clean(args.defunctfate),
            organizers = mw.ext.LiquipediaDB.lpdb_create_json({
                organizer1 = args.organizer or args.organizer1,
                organizer2 = args.organizer2,
                organizer3 = args.organizer3,
                organizer4 = args.organizer4,
                organizer5 = args.organizer5,
            }),
            sponsors = mw.ext.LiquipediaDB.lpdb_create_json({
                sponsor1 = args.sponsor1,
                sponsor2 = args.sponsor2,
                sponsor3 = args.sponsor3,
                sponsor4 = args.sponsor4,
                sponsor5 = args.sponsor5,
            }),
            links = mw.ext.LiquipediaDB.lpdb_create_json({
                discord = Links.makeFullLink('discord', args.discord),
                facebook = Links.makeFullLink('facebook', args.facebook),
                instagram = Links.makeFullLink('instagram', args.instagram),
                twitch = Links.makeFullLink('twitch', args.twitch),
                twitter = Links.makeFullLink('twitter', args.twitter),
                website = Links.makeFullLink('website', args.website),
                weibo = Links.makeFullLink('weibo', args.weibo),
                vk = Links.makeFullLink('vk', args.vk),
                youtube = Links.makeFullLink('youtube', args.youtube),
            }),
        }

        lpdbData = self:addToLpdb(lpdbData)
        mw.ext.LiquipediaDB.lpdb_series('series_' .. self.name, lpdbData)

        infobox:categories(
            'Tournament series',
            self:_setCountryCategories(args.country),
            self:_setCountryCategories(args.country2),
            self:_setCountryCategories(args.country3),
            self:_setCountryCategories(args.country4),
            self:_setCountryCategories(args.country5)
        )
    end

    return infobox:build()
end

--- Allows for overriding this functionality
function Series:addToLpdb(lpdbData)
    return lpdbData
end

--- Allows for overriding this functionality
function Series:createTier(tier, tierType)
    if tier == nil or tier == '' then
        return ''
    end

    local output = ''

    local hasTierType = tierType ~= nil and tierType ~= ''

    if hasTierType then
        local tierTypeDisplay = Template.safeExpand(self.infobox.frame, 'TierDisplay/' .. tierType)
        output = output .. '[[' .. tierTypeDisplay .. '_Tournaments|' .. tierTypeDisplay .. ']]'
        output = output .. '&nbsp;('

    end

    local tierDisplay = Template.safeExpand(self.infobox.frame, 'TierDisplay/' .. tier)
    output = output .. '[[' .. tierDisplay .. '_Tournaments|' .. tierDisplay .. ']]'

    if hasTierType then
        output = output .. ')'
    end

    return output
end

function Series:_createLocation(country, city)
    if country == nil or country == '' then
        return ''
    end

    return Flags(country) .. '&nbsp;' .. (city or country)
end

function Series:_setCountryCategories(country)
    if country == nil or country == '' then
        return ''
    end

    local countryAdjective = Localisation.getLocalisation({ shouldReturnSimpleError = true }, country)
    if countryAdjective == 'error' then
        return 'Unrecognised Country||' .. country
    end

    return countryAdjective .. ' Tournaments'
end

return Series
