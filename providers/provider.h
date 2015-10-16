#ifndef _PROVIDER_H_INCLUDED
#define _PROVIDER_H_INCLUDED

extern "C" {
	
	struct MenuEntry{
		const char* path;    //ex: /File/Open
		const char* shortcut;//ex: CTRL+O
		void* data;          //custom data
	};

	struct MenuList{
		MenuEntry* menus;   //Menu list
		unsigned int length;//Number of menus in the list
	};

	//Allocates the menu list
	//TODO: window parameter
	MenuList* getMenuList();

	//Deallocate the menu list
	void freeMenuList(MenuList*);

	//Click on a menu
	void execMenu(MenuEntry*);

}

#endif