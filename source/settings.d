import std.conv;

import gobject.CClosure;
import gobject.Type;
import gobject.Signals;
import gtk.Label;
import gtk.Entry;

struct Setting{
	string name;
	string description;
	string valueType;
	string value;
	string min;
	string max;
	string code;
}
enum SettingType{
	Folder,
	File,
	Path,
	String,
	Int,
	Float,
	Bool,
}

import gtk.Box;
class SettingWidget : Box{
	//public static GType getType()
	//{
	//	return gtk_toggle_button_get_type();
	//}

	this(in Setting setting){
		super(Orientation.HORIZONTAL, 5);
		//Type.registerDynamic(GType parentType, string typeName, TypePluginIF plugin, GTypeFlags flags)

		//Static initialization
		static bool staticInit = false;
		if(staticInit==false){
			staticInit = true;
			signalSettingChanged = Signals.newv(
				"setting-changed",
				getType(),
				SignalFlags.RUN_FIRST,
				null, null, null,
				null, GType.NONE, [getType()]);

			//CClosure.marshalVOIDPOINTER
		}
		


		auto nameLabel = new Label(setting.name);
		packStart(nameLabel, false, false, 0);
		nameLabel.setTooltipMarkup(setting.description);

		auto type = setting.valueType.to!(SettingType);
		//TODO catch ConvException

		final switch(type) with(SettingType){
			case Folder:{
				import gtk.FileChooserButton;
				auto button = new FileChooserButton(
					"Select a folder for '"~setting.name~"'",
					FileChooserAction.SELECT_FOLDER);
				packEnd(button, true, true, 0);
				with(button){
					setLocalOnly(true);
					setCurrentFolderUri(setting.value);
					addOnSelectionChanged((fc){
						import std.stdio; stderr.writeln("TEEEEST");
						//provider.setSettingValue(setting.code, fc.getUri);
						import gobject.Value;
						auto thisValue = new Value;
						thisValue.setObject(cast(void*)this);
						auto params = [thisValue];

						auto valueret = new Value;
						Signals.emitv(params, signalSettingChanged, 0, valueret);
					});
				}
			}break;
			case File:{
				import gtk.FileChooserButton;
				auto button = new FileChooserButton(
					"Select a file for '"~setting.name~"'",
					FileChooserAction.SAVE);
				packEnd(button, true, true, 0);
				with(button){
					setLocalOnly(true);
					setCurrentFolderUri(setting.value);
					//addOnSelectionChanged((fc){
					//	provider.setSettingValue(setting.code, fc.getUri);
					//});
				}
			}break;
			case Path:{
				import gtk.Entry : Entry;
				auto entry = new Entry;
				packEnd(entry, true, true, 0);
				entry.setText(setting.value);
			}break;
			case String:{
				import gtk.Entry : Entry;
				auto entry = new Entry;
				packEnd(entry, true, true, 0);
				entry.setText(setting.value);
			}break;
			case Int:{

			}break;
			case Float:{

			}break;
			case Bool:{

			}break;
		}
	}


	void delegate(SettingWidget*)[] onSettingChanged;
	void addOnSettingChanged(void delegate(SettingWidget*) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if("setting-changed" !in connectedSignals)
		{
			Signals.connectData(
				this,
				"setting-changed",
				cast(GCallback)&callBackSettingChanged,
				cast(void*)cast(SettingWidget)this,
				null,
				connectFlags);
			connectedSignals["setting-changed"] = 1;
		}
		onSettingChanged ~= dlg;
	}
	extern(C) static void callBackSettingChanged(SettingWidget* settingWidget)
	{
		foreach ( void delegate(SettingWidget*) dlg; settingWidget.onSettingChanged )
		{
			dlg(settingWidget);
		}
	}


private:
	static uint signalSettingChanged;

}