---
-- @Liquipedia
-- wiki=mobilelegends
-- page=Module:Infobox/Unit/Hero
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Unit = require('Module:Infobox/Unit')
local String = require('Module:StringUtils')
local Namespace = require('Module:Namespace')
local Template = require('Module:Template')
local Math = require('Module:Math')
local HeroWL = require('Module:HeroWL')
local Class = require('Module:Class')

local Injector = require('Module:Infobox/Widget/Injector')
local Cell = require('Module:Infobox/Widget/Cell')
local Center = require('Module:Infobox/Widget/Center')
local Title = require('Module:Infobox/Widget/Title')
local Header = require('Module:Infobox/Widget/Header')
local Breakdown = require('Module:Infobox/Widget/Breakdown')

local CustomHero = Class.new()

local CustomInjector = Class.new(Injector)

local _args

local _pagename = mw.title.getCurrentTitle().text
local _frame

local _BATTLE_POINTS_ICON = '[[File:Mobile_Legends_BP_icon.png|x16px|Battle Points|link=Battle Points]]'
local _DIAMONDS_ICON = '[[File:Mobile_Legends_Diamond_icon.png|Diamonds|x16px|link=Diamonds]]'

function CustomHero.run(frame)
	local unit = Unit(frame)
	_args = unit.args
	_frame = frame
	_args.informationType = 'Hero'

	unit.getWikiCategories = CustomHero.getWikiCategories
	unit.setLpdbData = CustomHero.setLpdbData
	unit.createWidgetInjector = CustomHero.createWidgetInjector

	return unit:createInfobox(frame)
end

function CustomInjector:addCustomCells()
	local widgets = {
		Cell{name = 'Resource Bar', content = {_args.secondarybar}},
		Cell{name = 'Secondary Bar', content = {_args.secondarybar1}},
		Cell{name = 'Secondary Attributes', content = {_args.secondaryattributes1}},
		Cell{name = 'Release Date', content = {_args.releasedate}},
		Cell{name = 'Species', content = {_args.species}},
		Cell{name = 'Year of birth', content = {_args.birth}},
		Cell{name = 'Faction(s)', content = {_args.factions}},
	}

	if not (
		String.isEmpty(_args.hp) and
		String.isEmpty(_args.hplvl) and
		String.isEmpty(_args.hpreg) and
		String.isEmpty(_args.hpreglvl)
	) then
		table.insert(widgets, Title{name = 'Base Statistics'})
	end

	table.insert(widgets, Cell{name = 'Health', content = {_args.hp}})
	table.insert(widgets, Cell{name = 'Health Regen', content = {_args.hpreg}})
	table.insert(widgets, Cell{name = 'Mana', content = {_args.mana}})
	table.insert(widgets, Cell{name = 'Mana Regen', content = {_args.manareg}})
	table.insert(widgets, Cell{name = 'Cooldown Reduction', content = {_args.cdr}})
	table.insert(widgets, Cell{name = 'Energy', content = {_args.energy}})
	table.insert(widgets, Cell{name = 'Energy Regen', content = {_args.energyreg}})
	table.insert(widgets, Cell{name = 'Attack Type', content = {_args.attacktype}})
	table.insert(widgets, Cell{name = 'Attack Damage', content = {_args.damage}})
	table.insert(widgets, Cell{name = 'Attack Speed', content = {_args.attackspeed}})
	table.insert(widgets, Cell{name = 'Attack Range', content = {_args.attackrange}})
	table.insert(widgets, Cell{name = 'Ability Power', content = {_args.ap}})
	table.insert(widgets, Cell{name = 'Armor', content = {_args.armor}})
	table.insert(widgets, Cell{name = 'Magic Resistance', content = {_args.magicresistance}})
	table.insert(widgets, Cell{name = 'Movement Speed', content = {_args.movespeed}})
	table.insert(widgets, Title{name = 'Esports Statistics'})

	local stats = HeroWL.create({hero = _args.heroname or _pagename})
	stats = mw.text.split(stats, ';')
	local winPercentage = (tonumber(stats[1]) or 0) / ((tonumber(stats[1]) or 0) + (tonumber(stats[2]) or 1))
	winPercentage = Math.round({winPercentage, 4}) * 100
	local statsDisplay = (stats[1] or 0) .. 'W : ' .. (stats[2] or 0) .. 'L (' .. winPercentage .. '%)'
	table.insert(widgets, Cell{name = 'Win Rate', content = {statsDisplay}})

	return widgets
end

function CustomInjector:parse(id, widgets)
	if id == 'header' then
		return {
			Header{
				name = _args.heroname,
				subHeader = _args.title,
				image = _args.image,
				imageDefault = _args.default,
				imageDark = _args.imagedark or _args.imagedarkmode,
				imageDefaultDark = _args.defaultdark or _args.defaultdarkmode,
			},
		}
	elseif id == 'caption' then
		table.insert(widgets, Center{content = {_args.quote}})
	elseif id == 'type' then
		local breakDownContents = {}
		local lane = _args.lane
		if not String.isEmpty(lane) then
			lane = '<b>Lane</b><br>' .. Template.safeExpand(_frame, 'Class icon', {lane}, '')
			table.insert(breakDownContents, lane)
		end
		local primaryRole = _args.primaryrole
		if not String.isEmpty(primaryRole) then
			primaryRole = '<b>Primary Role</b><br>' .. Template.safeExpand(_frame, 'Class icon', {primaryRole}, '')
			table.insert(breakDownContents, primaryRole)
		end
		local secondaryRole = _args.secondaryrole
		if not String.isEmpty(secondaryRole) then
			secondaryRole = '<b>Secondary Role</b><br>' .. Template.safeExpand(_frame, 'Class icon', {secondaryRole}, '')
			table.insert(breakDownContents, secondaryRole)
		end
		return {
			Breakdown{classes = {'infobox-center'}, content = breakDownContents},
			Cell{name = 'Real Name', content = {_args.realname}},
		}
	elseif id == 'cost' then
		local cost = ''
		if not String.isEmpty(_args.costbp) then
			cost = cost .. _args.costbp .. ' ' .. _BATTLE_POINTS_ICON
		end
		if not String.isEmpty(_args.costdia) then
			if cost ~= '' then
				cost = cost .. '&emsp;&ensp;'
			end
			cost = cost .. _args.costdia .. ' ' .. _DIAMONDS_ICON
		end
		return {
			Cell{name = 'Price', content = {cost}},
		}
	end

	return widgets
end

function CustomHero:createWidgetInjector()
	return CustomInjector()
end

function CustomHero.getWikiCategories()
	local categories = {}
	if Namespace.isMain() then
		categories = {'Heroes'}
		if not String.isEmpty(_args.attacktype) then
			table.insert(categories, _args.attacktype .. ' Heroes')
		end
		if not String.isEmpty(_args.primaryrole) then
			table.insert(categories, _args.primaryrole .. ' Heroes')
		end
	end
	return categories
end

function CustomHero.setLpdbData()
	local lpdbData = {
		type = 'hero',
		name = _args.heroname or _pagename,
		image = _args.image,
		extradata = mw.ext.LiquipediaDB.lpdb_create_json({
			releasedate = _args.releasedate,
		})
	}
	mw.ext.LiquipediaDB.lpdb_datapoint('hero_' .. (_args.heroname or _pagename), lpdbData)
end

return CustomHero
