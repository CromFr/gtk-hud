import std.stdio;
import std.path;
import std.file;

void main(string[] args)
{
	import gtk.Main;
	import gtk.Version;

	writeln("Using GTK version ",Version.getMajorVersion(),".",Version.getMinorVersion(),".",Version.getMicroVersion());
	writeln("=================");

	Main.init(args);

	new App;
	
	Main.run();
}

import gtk.Application;
class App : Application{
	import std.algorithm;
	import std.array;
	import gtk.StyleContext;
	import gtk.CssProvider;
	import gdk.Screen;
	import mainwindow;
	public import provider;


	static App get(){
		return instance;
	}

	this(){
		super(null, ApplicationFlags.IS_LAUNCHER);
		instance = this;

		auto css = new CssProvider;
		css.loadFromData(q"{
			.hud-searchbox{
				font-size: 130%;
			}
			.hud-entry-shortcut{
				padding: 2px;
				font-family: "monospace";
				font-size: 75%;
				color: #CCC;
				background-color: #666;
			}
			.hud-entry-name{
				font-size: 110%;
				font-weight: bold;
			}
			.hud-entry-fullname{
				opacity: 0.5;
			}
			.hud-settings-bgdarker{
				background-color: darker (rgba(0,0,0,0.1));
			}
			.hud-settings-nobg{
				background-color: rgba(0,0,0,0);
			}
		}");
		StyleContext.addProviderForScreen(Screen.getDefault, css, 800);


		dirEntries("providers/", "*.lua", SpanMode.depth)
			.each!((file){
				providers ~= new Provider(file);
			});

		//TODO: Add keybind to launch manually
		new MainWindow;
		//setAccelsForAction()
	}

	Provider[] getProviders(){
		return providers;
	}

	Entry[] getAllEntries(){
		Entry[] ret;
		foreach(p ; providers){
			ret ~= p.entries;
		}
		return ret;
	}

private:
	static App instance=null;
	Provider[] providers;

}