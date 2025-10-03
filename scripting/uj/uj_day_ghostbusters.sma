#include <amxmodx>
#include <cstrike>
#include <fun>
#include <uj_menus>
#include <uj_chargers>
#include <uj_core>
#include <uj_days>
#include <uj_effects>

new const PLUGIN_NAME[] = "UJ | Day - Ghostbusters";
new const PLUGIN_AUTH[] = "Broduer40";
new const PLUGIN_VERS[] = "v0.1";

new const DAY_NAME[] = "Ghostbusters";
new const DAY_OBJECTIVE[] = "I aint afraid of no ghosts!";
new const DAY_SOUND[] = "";

new const GHOSTBUSTERS_AMMO[] = "400";
new const GHOSTBUSTERS_HEALTH[] = "400";

// Day variables
new g_day;
new bool:g_dayEnabled;

// Menu variables
new g_menuSpecial

// Cvars
new g_primaryAmmoPCVar;
new g_healthPCVar;

public plugin_init()
{
  register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

  // Find all valid menus to display this under
  g_menuSpecial = uj_menus_get_menu_id("Special Days");

  // CVars
  g_primaryAmmoPCVar = register_cvar("uj_day_ghostbusters_ammo", GHOSTBUSTERS_AMMO);
  g_healthPCVar = register_cvar("uj_day_ghostbusters_health", GHOSTBUSTERS_HEALTH);

  // Register day
  g_day = uj_days_register(DAY_NAME, DAY_OBJECTIVE, DAY_SOUND)
}

public uj_fw_days_select_pre(playerID, dayID, menuID)
{
  // This is not our day - do not block
  if (dayID != g_day) {
    return UJ_DAY_AVAILABLE;
  }

  // Only display if in the parent menu we recognize
  if (menuID != g_menuSpecial) {
    return UJ_DAY_DONT_SHOW;
  }

  // If we *can* show the menu, but it's already enabled,
  // then have it be unavailable
  if (g_dayEnabled) {
    return UJ_DAY_NOT_AVAILABLE;
  }

  return UJ_DAY_AVAILABLE;
}

public uj_fw_days_select_post(playerID, dayID)
{
  // This is not our item
  if (dayID != g_day)
    return;

  start_day();
}

public uj_fw_days_end(dayID)
{
  // If dayID refers to our day and our day is enabled
  if(dayID == g_day && g_dayEnabled) {
    end_day();
  }
}

start_day()
{
  if (!g_dayEnabled) {
    g_dayEnabled = true;

    // Find settings
    new primaryAmmoCount = get_pcvar_num(g_primaryAmmoPCVar);

    new players[32], playerID;
    new playerCount = uj_core_get_players(players, true, CS_TEAM_T);
    for (new i = 0; i < playerCount; ++i) {
      playerID = players[i];

      // Give user items
      uj_core_strip_weapons(playerID);
      give_item(playerID, "weapon_m249");
      cs_set_user_bpammo(playerID, CSW_M249, primaryAmmoCount);
    }

    new health = get_pcvar_num(g_healthPCVar);

    playerCount = uj_core_get_players(players, true, CS_TEAM_CT);
    for (new i = 0; i < playerCount; ++i) {
      playerID = players[i];

      // Set user up with noclip
      uj_core_strip_weapons(playerID);
      set_user_noclip(playerID, 1);
      set_user_health(playerID, health);
    }

    uj_core_block_weapon_pickup(0, true);
    uj_chargers_block_heal(0, true);
    uj_chargers_block_armor(0, true);
  }
}

end_day()
{
  new players[32], playerID;
  new playerCount = uj_core_get_players(players, true, CS_TEAM_T);
  for (new i = 0; i < playerCount; ++i) {
    playerID = players[i];
    uj_core_strip_weapons(playerID);
  }

  playerCount = uj_core_get_players(players, true, CS_TEAM_CT);
  for (new i = 0; i < playerCount; ++i) {
    playerID = players[i];
    set_user_noclip(playerID, 0);
  }

  uj_core_block_weapon_pickup(0, false);
  uj_chargers_block_heal(0, false);
  uj_chargers_block_armor(0, false);
  g_dayEnabled = false;
}
