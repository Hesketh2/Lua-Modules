---
-- @Liquipedia
-- wiki=mobilelegends
-- page=Module:Infobox/Item/Custom
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Item = require('Module:Infobox/Item')
local String = require('Module:StringUtils')
local Namespace = require('Module:Namespace')
local Template = require('Module:Template')
local Table = require('Module:Table')
local Class = require('Module:Class')

local Injector = require('Module:Infobox/Widget/Injector')
local Cell = require('Module:Infobox/Widget/Cell')
local Center = require('Module:Infobox/Widget/Center')
local Title = require('Module:Infobox/Widget/Title')
local Breakdown = require('Module:Infobox/Widget/Breakdown')

local CustomItem = Class.new()

local CustomInjector = Class.new(Injector)

local _args
local _frame
local _categories = {}

local _CATEGORY_DISPLAY = {
	['tier 1'] = 'Tier 1 [[Category:Tier 1 Items]]',
	['tier 2'] = 'Tier 2 [[Category:Tier 2 Items]]',
	['tier 3'] = 'Tier 3 [[Category:Tier 3 Items]]',
	basic = 'Basic [[Category:Basic Items]]',
	boot = 'Boot [[Category:Boots]]',
	enchantment = 'Enchantment [[Category:Enchantments]]',
}

local _DEFAULT_ATTRIBUTE_DISPLAY_FUNCTION = '_positiveConcatedArgsForBase'

function CustomItem.run(frame)
	local item = Item(frame)
	_args = item.args
	_frame = frame

	item.nameDisplay = CustomItem.nameDisplay
	item.getWikiCategories = CustomItem.getWikiCategories
	--item.setLpdbData = CustomItem.setLpdbData--to be added later
	item.createWidgetInjector = CustomItem.createWidgetInjector

	return item:createInfobox(frame)
end

function CustomInjector:parse(id, widgets)
	if id == 'header' then
		if String.isNotEmpty(_args.itemcost) then
			table.insert(
				widgets,
				Breakdown{
					content = CustomItem._getCostDisplay(),
					classes = {
						'infobox-header',
						'wiki-backgroundcolor-light',
						'infobox-header-2',
						'infobox-gold'
					}
				}
			)
		end
		if String.isNotEmpty(_args.itemname) then
			local iconImage = Template.safeExpand(_frame, 'ItemIcon', {string.lower(_args.itemname)}, '')
			if String.isNotEmpty(_args.itemtext) then
				iconImage = iconImage .. '<br><i>' .. _args.itemtext .. '</i>'
			end
			table.insert(widgets, Center{content = {iconImage}})
		end
		return widgets
	elseif id == 'attributes' then
		widgets = {}
		if
			String.isNotEmpty(_args.str) or
			String.isNotEmpty(_args.agi) or
			String.isNotEmpty(_args.int)
		then
			table.insert(widgets, Breakdown{classes = {'infobox-center'}, content = {
				CustomItem._attributeIcons('str'),
				CustomItem._attributeIcons('agi'),
				CustomItem._attributeIcons('int'),
			}})
		end

		local attributeCells = {
			{name = 'Health', parameter = 'hp'},
			{name = 'Max Health', parameter = 'maxhealth'},
			{name = 'Health Regen', parameter = 'hpregen'},
			{name = 'Mana', parameter = 'mana'},
			{name = 'Mana Regen', parameter = 'manaregen'},
			{name = 'Lifesteal', parameter = 'lifesteal'},
			{name = 'Physical Lifesteal', parameter = 'physsteal'},
			{name = 'Magical Lifesteal', parameter = 'magicsteal'},
			{name = 'Armor', parameter = 'armor'},
			{name = 'Evasion', parameter = 'evasion', funct = '_positivePercentDisplay'},
			{name = 'Magic Resistance', parameter = 'magicresist'},
			{name = 'Status Resistance', parameter = 'statusresist', funct = '_positivePercentDisplay'},
			{name = 'Attack Speed', parameter = 'attackspeed'},
			{name = 'Cooldown Reduction', parameter = 'cdreduction'},
			{name = 'Magic Power', parameter = 'mp'},
			{name = 'Attack Damage', parameter = 'ad'},
			{name = 'Physical Attack', parameter = 'physatk'},
			{name = 'Physical Penetration', parameter = 'physpen'},
			{name = 'Magical Penetration', parameter = 'magicpen'},
			{name = 'Cooldown Reduction', parameter = 'critchance'},
			{name = 'Critical Chance', parameter = 'critreduction'},
			{name = 'Movement Speed', funct = '_movementSpeedDisplay'},	
		}
		widgets = CustomItem._getAttributeCells(attributeCells, widgets)
		if not Table.isEmpty(widgets) then
			table.insert(widgets, 1, Title{name = 'Attributes'})
		end
		return widgets
	elseif id == 'ability' then
		if
			String.isNotEmpty(_args.use) or
			String.isNotEmpty(_args.active) or
			String.isNotEmpty(_args.passive)
		then
			table.insert(widgets, Cell{name = 'Use', content = {
				_args.use
			}})
			table.insert(widgets, Cell{name = 'Active', content = {
				_args.active
			}})
			table.insert(widgets, Cell{name = 'Passive', content = {
				_args.passive,
				_args.passive2
			}})
		else return {} end
	elseif id == 'availability' then
		if
			String.isNotEmpty(_args.category) or
			String.isNotEmpty(_args.shop) or
			String.isNotEmpty(_args.drop)
		then
			return {
				Title{name = 'Item Tier'},
				Cell{name = 'Category', content = {CustomItem._categoryDisplay()}},
				Cell{name = 'Bought From', content = CustomItem._shopDisplay()},
				Cell{name = 'Dropped From', content = {_args.drop}},
			}
		else return {} end
	elseif id == 'maps' then
		if
			String.isNotEmpty(_args.sr) or
			String.isNotEmpty(_args.ha)
		then
			table.insert(widgets, Cell{name = '[[Summoner\'s Rift]]', content = {_args.sr}})
			table.insert(widgets, Cell{name = '[[Howling Abyss]]', content = {_args.ha}})
		else return {} end
	elseif id == 'recipe' then
		if String.isNotEmpty(_args.recipe) then
			table.insert(widgets, Center{content = {_args.recipe}})
		else return {} end
	elseif id == 'info' then return {}
	end

	return widgets
end

function CustomItem:createWidgetInjector()
	return CustomInjector()
end

function CustomItem.getWikiCategories()
	if Namespace.isMain() then
		if
			String.isNotEmpty(_args.str) or
			String.isNotEmpty(_args.agi) or
			String.isNotEmpty(_args.int)
		then
			table.insert(_categories, 'Attribute Items')
		end

		if not (String.isEmpty(_args.movespeed) and String.isEmpty(_args.movespeedmult)) then
			table.insert(_categories, 'Movement Speed Items')
		end

		local possibleCategories = {
			['Strength Items'] = 'str',
			['Agility Items'] = 'agi',
			['Intelligence Items'] = 'int',
			['Health Items'] = 'hp',
			['Mana Pool Items'] = 'mana',
			['Health Regeneration Items'] = 'hpregen',
			['Mana Regeneration Items'] = 'manaregen',
			['Armor Bonus Items'] = 'armor',
			['Evasion Items'] = 'evasion',
			['Magic Resistance Items'] = 'magicresist',
			['Damage Items'] = 'damage',
			['Items with Active Abilities'] = 'active',
			['Items with Passive Abilities'] = 'passive',
		}
		for category, requiredArg in pairs(possibleCategories) do
			if String.isNotEmpty(_args[requiredArg]) then
				table.insert(_categories, category)
			end
		end

		return _categories
	end
end

function CustomItem.nameDisplay()
	return _args.itemname
end

function CustomItem._getCostDisplay()
	local costs = Item:getAllArgsForBase(_args, 'itemcost')

	local innerDiv = mw.html.create('div')
		:css('display', 'inline-block')
		:css('padding', '0px 3px')
		:css('border-radius', '4px')
		:addClass('placement-darkgrey')
		:wikitext(table.concat(costs, '&nbsp;/&nbsp;'))
	local outerDiv = mw.html.create('div')
		:wikitext(Template.safeExpand(
				_frame,
				'icons',
				{'gold', size = '21px'},
				''
			) .. ' ' .. tostring(innerDiv)
		)
	local display = tostring(outerDiv)

	if String.isNotEmpty(_args.recipecost) then
		innerDiv = mw.html.create('div')
			:css('display', 'inline-block')
			:css('padding', '0px 3px')
			:css('border-radius', '4px')
			:addClass('placement-darkgrey')
			:wikitext('(' .. _args.recipecost .. ')')
		outerDiv = mw.html.create('div')
			:css('padding-top', '3px')
			:wikitext(Template.safeExpand(
					_frame,
					'icons',
					{'recipe', size = '21px'},
					''
				) .. ' ' .. tostring(innerDiv)
			)
		display = display .. tostring(outerDiv)
	end

	return {display}
end

function CustomItem._attributeIcons(attributeType)
	_args[attributeType] = _args[attributeType] or 0
	local attributes = Item:getAllArgsForBase(_args, attributeType)
	return Template.safeExpand(_frame, 'AttributeIcon', {attributeType}, '')
		.. '<br><b>+ ' .. table.concat(attributes, '/ ') .. '</b>'
end

function CustomItem._positiveConcatedArgsForBase(base)
	if String.isNotEmpty(_args[base]) then
		local foundArgs = Item:getAllArgsForBase(_args, base)
		return '+ ' .. table.concat(foundArgs, '&nbsp;/&nbsp;')
	end
end

function CustomItem._negativeConcatedArgsForBase(base)
	if String.isNotEmpty(_args[base]) then
		local foundArgs = Item:getAllArgsForBase(_args, base)
		return '- ' .. table.concat(foundArgs, '&nbsp;/&nbsp;')
	end
end

function CustomItem._positivePercentDisplay(base)
	if String.isNotEmpty(_args[base]) then
		local number = tonumber(_args[base])
		number = number * 100
		return '+ ' .. number .. '%'
	end
end

function CustomItem._manaLossDisplay()
	local display = ''
	if String.isNotEmpty(_args['mana loss']) then
		display = (tonumber(_args['mana loss']) + 100) .. '%'
	end
	if String.isNotEmpty(_args.manaloss) then
		display = display .. (tonumber(_args.manaloss) + 100) .. '%'
	end
	if display ~= '' then
		return '+ ' .. display
	end
end

function CustomItem._movementSpeedDisplay()
	local display = ''
	if String.isNotEmpty(_args.movespeed) then
		display = _args.movespeed
	end
	if String.isNotEmpty(_args.movespeedmult) then
		display = display .. (tonumber(_args.movespeedmult) + 100) .. '%'
	end
	if display ~= '' then
		return '+ ' .. display
	end
end

function CustomItem._categoryDisplay()
	local display = _CATEGORY_DISPLAY[string.lower(_args.category or '')]
	if display then
		return display
	else
		table.insert(_categories, 'Unknown Type')
	end
end

function CustomItem._shopDisplay()
	local contents = {}
	local index = 1
	_args.shop1 = _args.shop1 or _args.shop
	while String.isNotEmpty(_args['shop' .. index]) do
		local shop = Template.safeExpand(_frame, 'Shop', {_args['shop' .. index]})
		table.insert(contents, shop)
		index = index + 1
	end
	return contents
end

function CustomItem._getAttributeCells(attributeCells, widgets)
	for _, attribute in ipairs(attributeCells) do
		local funct = attribute.funct or _DEFAULT_ATTRIBUTE_DISPLAY_FUNCTION
		table.insert(widgets, Cell{name = attribute.name, content = {
			CustomItem[funct](attribute.parameter)
		}})
	end

	return widgets
end

return CustomItem
