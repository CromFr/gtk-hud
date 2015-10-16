#include "../provider.h"


MenuList* getMenuList(){

	MenuList* ret = new MenuList;
	ret->length = 14;
	ret->menus = new MenuEntry[ret->length];

	int i = 0;

	ret->menus[i].path = "/File/Open";
	ret->menus[i].shortcut = "CTRL+O";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/File/Close";
	ret->menus[i].shortcut = "CTRL+W";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/File/Save";
	ret->menus[i].shortcut = "CTRL+S";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/File/Save as";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/File/Quit";
	ret->menus[i].shortcut = "Escape";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Edit/Copy";
	ret->menus[i].shortcut = "CTRL+C";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Edit/Paste";
	ret->menus[i].shortcut = "CTRL+V";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Edit/Cut";
	ret->menus[i].shortcut = "CTRL+X";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Edit/Undo";
	ret->menus[i].shortcut = "CTRL+Z";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Help/About";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Help/Documentation";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Help/Get Started !";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Locale/Café";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;
	ret->menus[i].path = "/Locale/(╯°□°）╯︵ ┻━┻";
	ret->menus[i].shortcut = "";
	ret->menus[i].data = 0;
	i++;

	return ret;
}

void freeMenuList(MenuList* list){
	delete list->menus;
	delete list;
}


void execMenu(MenuEntry* menu){
	//TODO
}
