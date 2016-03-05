import std.stdio;
import std.path;
import std.file;
import config;

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
		css.loadFromData(readText(CFG_PATH_RES~"/style.css"));
		StyleContext.addProviderForScreen(Screen.getDefault, css, 800);

		if(!CFG_PATH_USERCFG.exists)
			mkdirRecurse(CFG_PATH_USERCFG);
		if(!(CFG_PATH_USERCFG~"/providers").exists)
			mkdirRecurse(CFG_PATH_USERCFG~"/providers");

		dirEntries(CFG_PATH_PROVIDERS, "*.lua", SpanMode.depth)
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