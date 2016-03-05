
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
import settings;
import settingswidgets;

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
		auto generalListBox = new ListBox;
		notebook.appendPage(generalListBox, "General");
		with(generalListBox){
			auto opacityBox = new Box(Orientation.HORIZONTAL, 10);
			add(opacityBox);
			with(opacityBox){
				packStart(new Label("Window opacity"), false, false, 0);

				import gtk.Scale;
				auto scale = new Scale(Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
				packEnd(scale, true, true, 0);
				with(scale){
					setValue(parent.getOpacity);//TODO: not very clean
					setDrawValue(true);
					setDigits(2);
					addOnChangeValue((scrollType, newValue, rng){
						parent.setOpacity(newValue);
						//TODO: set in config
						return false;
					});
				}
			}
		}

		//Providers
		auto providersCont = new Box(Orientation.HORIZONTAL, 0);
		notebook.appendPage(providersCont, "Providers");
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
							setActive(provider.enabled);

							addOnStateSet((newstate, but){
								new ListBox(cast(GtkListBox*)(but.getData("target")))
									.setSensitive(newstate);
								return false;
							});
						}
						
						enableButtonBox.add(new Label("Enable provider"));
					}
					

					auto settingsWidget = new SettingsWidget(provider.settings);
					packEnd(settingsWidget, true, true, 0);
					enableButton.setData("target", settingsWidget.getListBoxStruct);
					settingsWidget.setSensitive(enableButton.getState());
				}

				
				

			}
		}

		addOnDelete((event, win){
			import mainwindow;
			(cast(MainWindow)parent).updateEntriesList();
			return false;
		});

		showAll();
	}


private:
	Notebook notebook;

}

