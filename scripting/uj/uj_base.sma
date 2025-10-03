#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <uj_cells>
#include <uj_core>
#include <uj_days>
#include <uj_items>
#include <uj_menus>
#include <uj_requests>
#include <fg_colorchat>

new const PLUGIN_NAME[] = "UJ | Base";
new const PLUGIN_AUTH[] = "Broduer40";
new const PLUGIN_VERS[] = "v0.1";

// Menus
//new g_menuWeapons;
new g_menuLastRequest;

// Days
new g_dayFreeday;
new g_dayRatioFreeday;

// Enums
enum (+= 514)
{
  Task_InactivityFreeday,
  Task_RoundEndFreeday
}

// CVars
new g_roundTime;

new bool:g_cellDoorsOpened;

public plugin_init()
{
  register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

  // CVars
  g_roundTime = get_cvar_pointer("mp_roundtime");

  // Menus
  //g_menuWeapons = uj_menus_get_menu_id("Weapons");
  g_menuLastRequest = uj_menus_get_menu_id("Last Request");

  // Days
  g_dayFreeday = uj_days_get_id("Freeday");
  g_dayRatioFreeday = uj_days_get_id("Ratio Freeday");

  // New round
  register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
  // Player spawn
  RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
  // Round end
  register_logevent("LogeventRoundEnd",   2, "1=Round_End");
}

public event_new_round()
{
  // Find round time
  new Float:roundTime = get_pcvar_float(g_roundTime);
  g_cellDoorsOpened = false;

  if (is_ratio_off()) {
    fg_colorchat_print(0, FG_COLORCHAT_RED, "^3Ratio Warning!^1 Guards have^4 30 seconds^1 to fix ratio before a Ratio Freeday begins!");
    set_task(30.0, "declare_ratio_freeday");
  }
  else {
    // Start freeday timer
    new Float:flCellsOpenTime = (roundTime - 8.0) * 60.0;
    if(flCellsOpenTime > 0.0) {
      set_task(flCellsOpenTime, "declare_inactivity_freeday", Task_InactivityFreeday);
    }
  }

  // Auto-freeday when roundTime is up
  set_task((roundTime*60.0), "declare_roundend_freeday", Task_RoundEndFreeday);
}

public fwHamPlayerSpawnPost(playerID)
{
  if(is_user_alive(playerID)) {
    // Reset
    uj_core_strip_weapons(playerID);

    // Gun menu
    //if (cs_get_user_team(playerID) == CS_TEAM_CT) {
    //  uj_menus_show_menu(playerID, g_menuWeapons);
    //}

    // On player spawn, determine a player's max health and set that health
    new health;
    uj_core_determine_max_health(playerID, health);
    set_pev(playerID, pev_health, float(health));
  }
}

public LogeventRoundEnd()
{
  // End current day
  uj_days_end();

  // Remove tasks
  remove_task(Task_InactivityFreeday);
  remove_task(Task_RoundEndFreeday);

  // Strip all users of all items
  //uj_items_strip_item(0, UJ_ITEM_ALL_ITEMS);
}

public uj_fw_cells_doors_opened(activatorID)
{
  // Cell doors were opened, cancel freeday timer
  remove_task(Task_InactivityFreeday);

  if (!g_cellDoorsOpened) {

    g_cellDoorsOpened = true;

    if (1 <= activatorID <= 32) {
      new playerName[32];
      get_user_name(activatorID, playerName, charsmax(playerName));

      switch (cs_get_user_team(activatorID))
      {
        case CS_TEAM_T: {
          //uj_days_start(activatorID, g_dayFreeday);
          fg_colorchat_print(0, FG_COLORCHAT_RED, "A prisoner, ^3%s^1, has opened the cell doors! RUN FOR IT!", playerName);
        }
        case CS_TEAM_CT: {
          fg_colorchat_print(0, FG_COLORCHAT_BLUE, "A guard, ^3%s^1, has opened the cell doors! Time to plot out an escape!", playerName);
        }
      }
    }
  }
}

public uj_fw_requests_reached(playerID)
{
  // End any current day
  uj_days_end();

  // Show LR menu
  uj_menus_show_menu(playerID, g_menuLastRequest);
}

public is_ratio_off()
{
  // Check for ratio freeday
  new guardCount = uj_core_get_guard_count();
  new prisonerCount = uj_core_get_prisoner_count();

  // At least 3 people in the server, and guards outnumber prisoners more than double
  return (((guardCount+prisonerCount) > 3) && ((guardCount+guardCount) > prisonerCount));
}

public declare_ratio_freeday()
{
  if (is_ratio_off()) {
    uj_days_start(0, g_dayRatioFreeday);
  }
}

public declare_inactivity_freeday()
{
  fg_colorchat_print(0, FG_COLORCHAT_RED, "Cells were not opened before^4 8:00^1. It's now a ^3Freeday^1!");
  uj_days_start(0, g_dayFreeday);
}

public declare_roundend_freeday()
{
  // If an LR is not in effect, make today a freeday
  //new prisonerCount = uj_core_get_prisoner_count();

  if (uj_requests_get_current() == UJ_REQUEST_INVALID) {
  //if (prisonerCount > 1) {
    uj_days_end();
    fg_colorchat_print(0, FG_COLORCHAT_RED, "Round time is up! It's now a ^4Freeday^1!");
    uj_days_start(0, g_dayFreeday);
  }
}
