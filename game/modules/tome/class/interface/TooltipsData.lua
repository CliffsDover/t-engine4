-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"

module(..., package.seeall, class.make)


-------------------------------------------------------------
-- Ressources
-------------------------------------------------------------
TOOLTIP_GOLD = [[#GOLD#Gold#LAST#
Money!
With gold you can buy items in the various stores in town.
You can gain money by looting it from your foes, by selling items and by doing some quests.
]]

TOOLTIP_LIFE = [[#GOLD#Life#LAST#
This is your life force, when you take damage this is reduced more and more.
If it reaches below zero you die.
Death is usualy permanent so beware!
It is increased by Constitution.]]

TOOLTIP_AIR = [[#GOLD#Air#LAST#
The breath counter only appears when you are suffocating.
If it reaches zero you will die. Being stuck in a wall, being in deep water, ... all those kind of situations will decrease your air.
When you come back into a breathable atmosphere you will slowly regain your air level.
]]

TOOLTIP_STAMINA = [[#GOLD#Stamina#LAST#
Stamina represents your physical fatigue. Each physical ability used reduces it.
It regenerates slowly over time or when resting.
It is increased by Willpower.]]

TOOLTIP_MANA = [[#GOLD#Mana#LAST#
Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximum mana.
It is increased by Willpower.]]

TOOLTIP_POSITIVE = [[#GOLD#Positive#LAST#
Positive energy represents your reserve of positive "divine" power.
It slowly decreases and is replenished by using some talents.
]]

TOOLTIP_NEGATIVE = [[#GOLD#Negative#LAST#
Negative energy represents your reserve of negative "divine" power.
It slowly decreases and is replenished by using some talents.
]]

TOOLTIP_VIM = [[#GOLD#Vim#LAST#
Vim represents the amount of life energy/souls you have stolen. Each corruption talent requires some.
]]

TOOLTIP_EQUILIBRIUM = [[#GOLD#Equilibrium#LAST#
Equilibrium represents your standing in the grand balance of nature.
The closer it is to 0 the more in-balance you are. Being out of equilibrium will negatively affect your ability to use Wild Gifts.
]]

TOOLTIP_HATE = [[#GOLD#Hate#LAST#
Hate represents your inner rage against all that lives and dares face you.
It slowly decreases and is replenished by killing creatures.
All afflicted talents are based on Hate, the higher hate is the more effective the talents are.
]]

TOOLTIP_PARADOX = [[#GOLD#Paradox#LAST#
Paradox represents how much damage you've caused to the spacetime continuum.
As your Paradox grows your spells will cost more to use and have greater effect; but they'll also become more difficult to control.
Your control over chronomancy spells increases with your Willpower.
]]

TOOLTIP_PSI = [[#GOLD#Psi#LAST#
Psi represents how much energy your mind can harness. Like matter, it can be neither created nor destroyed.
It does not regenerate naturally. You must absorb energy through shields or through various other talents.
Your capacity for storing energy is determined by your Willpower.
]]

TOOLTIP_LEVEL = [[#GOLD#Level and experience#LAST#
Each time you kill a creature that is over your own level - 5 you gain some experience.
When you reach enough experience you advance to the next level. There is a maximum of 50 levels you can gain.
Each time you level you gain stat and talent points to use to improve your character.
]]

TOOLTIP_ENCUMBERED = [[#GOLD#Encumberance#LAST#
Each object you carry has an encumberance value, your maximun carrying capacity is determined by your strength.
You can not move while encumbered, drop some items.
]]

TOOLTIP_INSCRIPTIONS = [[#GOLD#Inscriptions#LAST#
The people of Eyal have found a way to create herbal infusions and runes that can be inscribed on the skin of a creature.
Those inscriptions give the bearer always accessible powers. Usualy most people have a simple regeneration infusion, but there are other kind of potion inscriptions.
]]

-------------------------------------------------------------
-- Stats
-------------------------------------------------------------
TOOLTIP_STR = [[#GOLD#Strength#LAST#
Strength defines your character's ability to apply physical force. It increases your melee damage, damage done with heavy weapons, your chance to resist physical effects, and carrying capacity.
]]
TOOLTIP_DEX = [[#GOLD#Dexterity#LAST#
Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks, and your damage with light weapons.
]]
TOOLTIP_CON = [[#GOLD#Constitution#LAST#
Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and physical resistance.
]]
TOOLTIP_MAG = [[#GOLD#Magic#LAST#
Magic defines your character's ability to manipulate the magical energy of the world. It increases your spell power, and the effect of spells and other magic items.
]]
TOOLTIP_WIL = [[#GOLD#Willpower#LAST#
Willpower defines your character's ability to concentrate. It increases your mana and stamina capacity, and your chance to resist mental attacks.
]]
TOOLTIP_CUN = [[#GOLD#Cunning#LAST#
Cunning defines your character's ability to learn, think, and react. It allows you to learn many worldly abilities, and increases your mental resistance and critical chance.
]]
TOOLTIP_STRDEXCON = "#AQUAMARINE#Physical stats#LAST#\n---\n"..TOOLTIP_STR.."\n---\n"..TOOLTIP_DEX.."\n---\n"..TOOLTIP_CON
TOOLTIP_MAGWILCUN = "#AQUAMARINE#Mental stats#LAST#\n---\n"..TOOLTIP_MAG.."\n---\n"..TOOLTIP_WIL.."\n---\n"..TOOLTIP_CUN

-------------------------------------------------------------
-- Melee
-------------------------------------------------------------
TOOLTIP_COMBAT_ATTACK = [[#GOLD#Attack chance#LAST#
Your attack value represents your chance to hit your opponents, it is measured directly against the target's defense rating.
It is improved by both Strength and Dexterity.
]]
TOOLTIP_COMBAT_DAMAGE = [[#GOLD#Damage#LAST#
This is the damage you inflict on your foes when you hit them.
This damage can be reduced by the target's armour or by percentile damage resistances.
It is improved by both Strength and Dexterity, some talents can change the stats that affect it.
]]
TOOLTIP_COMBAT_APR = [[#GOLD#Armour Penetration#LAST#
Armour penetration allows you to ignore a part of the target's armour (this only works for armour, not damage resistance).
This can never increase the damage you do beyond reducing armour, so it is only useful against armoured foes.
]]
TOOLTIP_COMBAT_CRIT = [[#GOLD#Critical chance#LAST#
Each time you deal damage you have a chance to make a critical hit that deals 150% of the normal damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_COMBAT_SPEED = [[#GOLD#Attack speed#LAST#
Attack speed represents how fast your attacks are compared to a normal turn.
The lower it is the faster your attacks are.
]]
TOOLTIP_COMBAT_RANGE = [[#GOLD#Firing range#LAST#
The maximun distance your weapon can reach.
]]
TOOLTIP_COMBAT_AMMO = [[#GOLD#Ammo remaining#LAST#
This is the amount of ammo you have left.
Bows and sling have a "basic" infinite ammo so you can fire even when this reaches 0.
Alchemists use gems to throw bombs, they require ammo.
]]

-------------------------------------------------------------
-- Defense
-------------------------------------------------------------
TOOLTIP_FATIGUE = [[#GOLD#Fatigue#LAST#
Fatigue is a percentile value that increases the cost of all your talents and spells.
It represents the fatigue created by wearing heavy equipment.
Not all talents are affected, notably Wild Gifts are not.
]]
TOOLTIP_ARMOR = [[#GOLD#Armour#LAST#
Armour value is a flat damage reduction substracted from every incoming melee and ranged physical attacks.
This is countered by armour penetration and is applied before all kinds of critical damage increase, talent multipliers and damage multiplier, thus making even small amounts have greater effects.
]]
TOOLTIP_DEFENSE = [[#GOLD#Defense#LAST#
Defense represents your chance to avoid being hit at all by a melee attack, it is measured against the attacker's attack chance.
]]
TOOLTIP_RDEFENSE = [[#GOLD#Ranged Defense#LAST#
Ranged defense represents your chance to avoid being hit at all by a ranged attack, it is measured against the attacker's attack chance.
]]
TOOLTIP_PHYS_SAVE = [[#GOLD#Physical saving throw#LAST#
This value represents your resistance against physical attacks induced special effects, like bleeding, stuns, knockbacks, ...
It is measured against your target's attack.
]]
TOOLTIP_SPELL_SAVE = [[#GOLD#Spell saving throw#LAST#
This value represents your resistance against spell attacks induced special effects, like freezes, knockbacks, ...
It is measured against your target's spellpower.
]]
TOOLTIP_MENTAL_SAVE = [[#GOLD#Mental saving throw#LAST#
This value represents your resistance against mental attacks induced special effects, like confusion, fear, ...
It is measured against your target's spellpower or mental power.
]]

-------------------------------------------------------------
-- Spells
-------------------------------------------------------------
TOOLTIP_SPELL_POWER = [[#GOLD#Spellpower#LAST#
Your spellpower value represents how effective/powerful your spells and magical effects are.
It is improved by both Magic, some talents can change the stats that affect it.
]]
TOOLTIP_SPELL_CRIT = [[#GOLD#Spell critical chance#LAST#
Each time you deal damage with a spell you have a chance to make a critical hit that deals 150% of the normal damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_SPELL_SPEED = [[#GOLD#Spellcasting speed#LAST#
Spellcasting speed represents how fast your spellcasting is compared to a normal turn.
The lower it is the faster it is.
]]

-------------------------------------------------------------
-- Damage and resists
-------------------------------------------------------------
TOOLTIP_INC_DAMAGE_ALL = [[#GOLD#Damage increase: all#LAST#
All damage you deal, through any means, is increased by this percentage.
This stacks with individual damage type increases.
]]
TOOLTIP_INC_DAMAGE = [[#GOLD#Damage increase: specific#LAST#
All damage of this type that you deal, through any means, is increased by this percentage.
]]
TOOLTIP_RESIST_ALL = [[#GOLD#Damage resistance: all#LAST#
All damage you receieve, through any means, is decreased by this percentage.
This stacks with individual damage type resistances.
]]
TOOLTIP_RESIST = [[#GOLD#Damage resistance: specific#LAST#
All damage of this type that you receive, through any means, is reduced by this percentage.
]]
TOOLTIP_SPECIFIC_IMMUNE = [[#GOLD#Effect resistance chance#LAST#
This represents your chance to completly avoid the effect in question.
]]
