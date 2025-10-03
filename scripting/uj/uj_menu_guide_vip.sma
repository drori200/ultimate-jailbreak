#include <amxmodx>
#include <uj_menus>

new const PLUGIN_NAME[] = "UJ | Menu Entry - VIP Guide";
new const PLUGIN_AUTH[] = "Broduer40";
new const PLUGIN_VERS[] = "v0.1";

new const MENU_NAME[] = "VIP Guide";

new const GUIDE_VIP_URL[] = "http://www.factorialgaming.com/files/jailbreak/vip_guide.html";
new const GUIDE_VIP_FLAG = ADMIN_LEVEL_E;
new const GUIDE_ADMIN_FLAG = ADMIN_LEVEL_A;

new g_menuEntry;
new g_menuMain;

public plugin_init()
{
  register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

  // Register the menu entry
  g_menuEntry = uj_menus_register_entry(MENU_NAME)

  // Find the menu this should appear under
  g_menuMain = uj_menus_get_menu_id("Main Menu")
}

public uj_fw_menus_select_pre(playerID, menuID, entryID)
{
  // This is not our entry - do not block
  if (entryID != g_menuEntry)
    return UJ_MENU_AVAILABLE;

  // Do not show if it is not in this specific parent menu
  if (menuID != g_menuMain)
    return UJ_MENU_DONT_SHOW;

  // If user is missing the necessary flags
  if ( !((get_user_flags(playerID) & GUIDE_VIP_FLAG) ||
      (get_user_flags(playerID) & GUIDE_ADMIN_FLAG))) {
    return UJ_MENU_DONT_SHOW;
  }
  
  return UJ_MENU_AVAILABLE;
}

public uj_fw_menus_select_post(playerID, menuID, entryID)
{
  // This is not our item
  if (g_menuEntry != entryID)
    return;
  
  // Open up the rules
  show_motd(playerID, GUIDE_VIP_URL, "VIP Guide");
}
