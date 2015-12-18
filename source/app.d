import std.stdio;
import mainwindow;

void main(string[] args)
{
	import gtk.Main;
	import gtk.Version;

	writeln("Using GTK version ",Version.getMajorVersion(),".",Version.getMinorVersion(),".",Version.getMicroVersion());
	writeln("=================");

	Main.init(args);

	new Window;
	
	Main.run();
}


