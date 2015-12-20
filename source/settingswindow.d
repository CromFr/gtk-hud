
import gtk.Notebook;
import gtk.StackSidebar;
import gtk.ListBox;
import gtk.Label;
import gtk.Stack;
import gtk.Box;
import gtk.Separator;
import gtk.Entry;
import gtk.CheckButton;

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
		//TODO: move provider list to a GTKApplication (instead of MainWindow)
		auto providerList = new ProviderList("providers/");//TODO: bad design to fix
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
			
			foreach(provider ; providerList.providers){
				string name = provider.name;

				auto box = new Box(Orientation.VERTICAL, 0);
				stack.addTitled(box, name, name);
				with(box){
					auto enableButton = new CheckButton("Enable provider");
					add(enableButton);
					with(enableButton){
						//TODO: setActive(config value)
						
						addOnToggled((but){
							new ListBox(cast(GtkListBox*)(but.getData("target")))
								.setSensitive(but.getActive());
						});
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
					}


					//Update enable button
					enableButton.toggled();
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

		auto entry = new Entry;
		packEnd(entry, false, false, 0);
		entry.setText(setting.value);
	}
}