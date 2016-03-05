import settings;

import std.conv;
import std.file;
import gobject.CClosure;
import gobject.Type;
import gobject.Signals;
import gtk.Label;
import gtk.Entry;
import gtk.Separator;

import gtk.Box;
class SettingWidget : Box{

	this(ref Setting _setting){
		super(Orientation.HORIZONTAL, 5);
		setting = &_setting;


		setTooltipMarkup(setting.description);

		auto nameLabel = new Label(setting.name);
		packStart(nameLabel, false, false, 0);

		//auto sep = new Separator(Orientation.HORIZONTAL);
		//packStart(sep, true, true, 0);

		SettingType type;
		type = setting.valueType.to!(SettingType);

		final switch(type) with(SettingType){
			case Folder:{
				import gtk.FileChooserButton;
				auto button = new FileChooserButton(
					"Select a folder for '"~setting.name~"'",
					FileChooserAction.SELECT_FOLDER);
				packEnd(button, false, false, 0);
				with(button){
					setLocalOnly(true);
					setCurrentFolderUri(setting.value);
					addOnSelectionChanged((fc){
						setting.value = fc.getUri;
					});
				}
			}break;
			case File:{
				import gtk.FileChooserButton;
				auto button = new FileChooserButton(
					"Select a file for '"~setting.name~"'",
					FileChooserAction.OPEN);
				packEnd(button, false, false, 0);
				with(button){
					setLocalOnly(true);
					setCurrentFolderUri(setting.value);
					addOnSelectionChanged((fc){
						setting.value = fc.getUri;
					});
				}
			}break;
			case Path, String:{
				import gtk.Entry : Entry;
				auto entry = new Entry;
				packEnd(entry, true, true, 0);
				if(type==Path){
					import gtk.EntryCompletion : EntryCompletion;
					auto cpl = new EntryCompletion;
					entry.setCompletion(cpl);
					//cpl.setInlineCompletion(true);
					cpl.setPopupCompletion(true);

					import gtk.ListStore : ListStore;
					auto model = new ListStore([GType.STRING]);
					cpl.setModel(model);
					cpl.setTextColumn(0);

					string lastDirCompletion = "";
					void completeFiles(in string directory){
						import gtk.TreeIter : TreeIter;

						if(directory == lastDirCompletion)
							return;
						lastDirCompletion = directory;

						//Build list
						model.clear;
						
						TreeIter iter;
						foreach(file ; DirEntry(directory).dirEntries(SpanMode.shallow)){
							model.append(iter);
							model.setValue(iter, 0, file);
						}
					}

					entry.addOnChanged((editable){
						with(cast(Entry)editable){
							import std.path : buildPath, pathSplitter;
							import std.array : array;

							auto file = getText;

							try{
								if(!file.exists){
									getStyleContext().addClass("invalid");
									setIconFromIconName(EntryIconPosition.SECONDARY, "dialog-warning-symbolic");
									setIconTooltipText(EntryIconPosition.SECONDARY, "Path doesn't exists");

									auto filesplit = file.pathSplitter.array;
									string parentFolder;
									if(filesplit.length>=1)
										parentFolder = buildPath(filesplit[0..$-1]);
									if(parentFolder=="")
										parentFolder=".";

									if(parentFolder.exists && parentFolder.isDir){
										completeFiles(parentFolder);
									}
									
								}
								else{
									getStyleContext().removeClass("invalid");
									setIconFromIconName(EntryIconPosition.SECONDARY, "");

									if(file.isDir)
										completeFiles(file);
								}
							}
							catch(FileException e){
								import std.stdio : stderr, writeln;
								writeln(e);
							}
						}
					});
				}

				if(setting.value !is null)
					entry.setText(setting.value);

				entry.addOnChanged((editable){
						setting.value = (cast(Entry)editable).getText;
					});

			}break;
			case Int:{
				setupArithmeticSetting!long();
			}break;
			case Float:{
				setupArithmeticSetting!double();
			}break;
			case Bool:{
				import gtk.Switch : Switch;
				auto sw = new Switch;
				packEnd(sw, false, false, 0);
				sw.setState(setting.value.to!bool);
				sw.addOnStateSet((newstate, but){
					setting.value = newstate.to!string;
					return false;
				});
			}break;
			case Combo:{
				//TODO
			}break;
		}
	}


private:
	static uint signalSettingChanged;
	Setting* setting;


	void setupArithmeticSetting(T)() if(__traits(isArithmetic, T)){
		import gtk.SpinButton : SpinButton;
		import gtk.Scale : Scale;

		static if(__traits(isFloating, T))
			auto min = setting.min==""? T.min_normal : setting.min.to!T;
		else
			auto min = setting.min==""? T.min : setting.min.to!T;
		auto max = setting.max==""? T.max : setting.max.to!T;

		auto spin = new SpinButton(min, max, 1);
		packEnd(spin, false, false, 0);
		with(spin){
			//Set value
			setValue(setting.value!T);
			setWidthChars(0);
			//setRange(min, max);
			
			//change callback
			addOnValueChanged((spin){
				import std.conv : to;
				static if(__traits(isFloating, T))
					setting.value = spin.getValue.to!string;
				else
					setting.value = spin.getValueAsInt.to!string;
			});
		}
		
		if(setting.min!="" &&  setting.max!=""){
			//Scale display only if min & max are specified
			auto scale = new Scale(Orientation.HORIZONTAL, min, max, 1);
			packEnd(scale, true, true, 0);
			with(scale){
				static if(__traits(isFloating, T))
					scale.setValue(setting.value!double);
				else
					scale.setValue(setting.value!long);

				setDrawValue(false);
				static if(__traits(isFloating, T))
					setDigits(2);
				else
					setDigits(0);
			}
			scale.addOnChangeValue((scrollType, newValue, rng){
				spin.setValue(newValue);
				return false;
			});
			spin.addOnValueChanged((spin){
				scale.setValue(spin.getValue);
			});
		}
	}

}

import gtk.ListBox;
class SettingsWidget : ListBox{
	this(Settings settings){
		super();
		getStyleContext().addClass("hud-settings-nobg");

		auto placeholder = new Label("No settings available");
		placeholder.show();
		setPlaceholder(placeholder);
		setSelectionMode(SelectionMode.NONE);

		//Fill
		foreach(ref setting ; settings){
			try{
				auto sw = new SettingWidget(setting);
				add(sw);
			}
			catch(Exception e){
				import std.stdio;
				stderr.writeln("EXCEPTION while creating setting widget. Setting has been skipped");
				stderr.writeln(e);
			}
		}
	}
}