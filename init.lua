minetest.register_craftitem("roomba:spawn_egg", {
    description = "Roomba Spawn Egg",
    inventory_image = "roomba_item.png",
    on_use = function(itemstack, user, pointed_thing)
        -- Erzeuge einen Roboter wenn wir nicht ins Nichts klicken
        if not (pointed_thing.above == nil) then
            minetest.add_entity(pointed_thing.above, "roomba:robot")
        end
    end,
    on_place = function()
        -- Setze die UhrZeit zurück
        minetest.set_timeofday(0.3)
    end
})

minetest.register_craft({
	output = "roomba:spawn_egg",
	recipe = {
		{"", "default:wood", ""},
		{"default:wood", "default:apple", "default:wood"},
		{"", "default:wood", ""}
	}
})

minetest.register_entity("roomba:robot", {
    hp_max = 1,
    physical = true,
    collisionbox = {-0.4375,-0.4375,-0.4375, 0.4375,0.4375,0.4375},
    visual = "cube",
    visual_size = {x=.875, y=.875},
    textures = {
        "roomba_plate.png",
        "roomba_plate.png",
        "roomba_side.png",
        "roomba_side.png",
        "roomba_back.png",
        "roomba_front.png"
    },
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
    time_passed = 0,
    on_step = function(self, dtime)
        -- Zeit seit der letzten Roboterbewegung aufaddieren
        self.time_passed = self.time_passed + dtime
        -- Wenn die Zeit mindestens eine Sekunde ist
        if self.time_passed >= 1 then
            -- Zeitzähler zurücksetzen
            self.time_passed = 0
            -- Zukünftige Roboterposition bestimmen
            local newpos = self.object:get_pos()
            newpos.z = newpos.z - 1
            -- Nur etwas machen, wenn die zukünftige Roboterposition frei ist
            if minetest.get_node(newpos).name == "air" then
                -- Alle Objekte auf dem Feld des Roboters bestimmen und einzeln durchgehen
                local objects = minetest.get_objects_inside_radius(self.object:get_pos(), 1)
                local _,obj
                for _,obj in ipairs(objects) do
                    -- Nur etwas machen wenn das Objekt nicht der Spieler ist
                    if not obj:is_player() then
                        -- Nur etwas machen wenn das Objekt nicht der Roboter selbst ist
                        if not (obj:get_luaentity().name == "roomba:robot") then
                            -- Objekt auf die künftige Roboterposition verschieben
                            obj:setpos(newpos)
                        end
                    end
                end
                -- Roboter auf die künftige Roboterposition verschieben
                self.object:setpos(newpos)
            end
        end
    end
})