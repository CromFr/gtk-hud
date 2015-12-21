
import gtk.Notebook;
import gtk.StackSidebar;
import gtk.ListBox;
import gtk.Label;
import gtk.Stack;
import gtk.Box;
import gtk.ButtonBox;
import gtk.Separator;
import gtk.Entry; alias GtkEntry=gtk.Entry.Entry;
import gtk.Switch;

import provider;

import gtk.Window;
class SettingsWindow : Window{

	this(Window parent){
		super("Settings");
		//setModal(true);
		setTransientFor(parent);

		notebook = new Notebook;
		add(notebook);

		//General
		//TODO
		notebook.appendPage(new Label("yolo"), "General");

		//Providers
		auto providersCont = new Box(Orientation.HORIZONTAL, 0);
		with(providersCont){
			auto stackSidebar = new StackSidebar;
			packStart(stackSidebar, false, false, 0);

			auto stack = new Stack;
			packStart(stack, true, true, 0);
			with(stack){
				getStyleContext().addClass("hud-settings-bgdarker");
				setTransitionType(StackTransitionType.SLIDE_UP_DOWN);
				stackSidebar.setStack(stack);
			}
			
			import app : App;
			foreach(provider ; App.get.getProviders){
				string name = provider.name;

				auto box = new Box(Orientation.VERTICAL, 0);
				stack.addTitled(box, name, name);
				with(box){
					Switch enableButton;

					auto enableButtonBox = new Box(Orientation.HORIZONTAL, 5);
					add(enableButtonBox);
					with(enableButtonBox){
						enableButton = new Switch;
						enableButtonBox.add(enableButton);
						with(enableButton){
							//TODO: setActive(config value)
							addOnStateSet((newstate, but){
								import std.stdio; writeln("Activated ",newstate);
								new ListBox(cast(GtkListBox*)(but.getData("target")))
									.setSensitive(newstate);
								return false;
							});
						}
						
						enableButtonBox.add(new Label("Enable provider"));
					}
					

					auto listBox = new ListBox;
					packEnd(listBox, true, true, 0);
					with(listBox){
						getStyleContext().addClass("hud-settings-nobg");

						auto placeholder = new Label("No settings for this provider");
						placeholder.show();
						setPlaceholder(placeholder);
						setSelectionMode(SelectionMode.NONE);

						//Fill
						foreach(setting ; provider.getSettings){
							auto se = new ProviderSettingWidget(setting);
							add(se);
						}

						enableButton.setData("target", listBox.getListBoxStruct);
						setSensitive(enableButton.getState());
					}
				}

				
				

			}
		}
		notebook.appendPage(providersCont, "Providers");

		showAll();
	}


private:
	Notebook notebook;

}

class ProviderSettingWidget : Box{
	this(ref Provider.Setting setting){
		super(Orientation.HORIZONTAL, 0);

		packStart(new Label(setting.name), true, true, 0);

		setTooltipMarkup(setting.description);

		auto entry = new GtkEntry;
		packEnd(entry, false, false, 0);
		entry.setText(setting.value);
	}
}