import std.stdio;
import std.path;
import std.algorithm;
import std.string;
import std.process;

import provider;
import search;


void main(string[] args)
{
	import gtk.Main;
	import gtk.Version;
	import xcb.xcb;

	writeln("Using GTK version ",Version.getMajorVersion(),".",Version.getMinorVersion(),".",Version.getMicroVersion());
	writeln("=================");

	//executeShell("notify-send `xdotool getactivewindow getwindowname`");
	xcb_connection_t* connection = xcb_connect(null, null);
	xcb_screen_t* screen = xcb_setup_roots_iterator(xcb_get_setup(connection)).data;

	Main.init(args);

	new Window;
	
	Main.run();
}






import gtk.MainWindow;
class Window : MainWindow{
	import gtk.ListBox;
	import gtk.ListBoxRow;
	import gtk.TextView;
	import gtk.ScrolledWindow;

	this(){
		import gtk.Box;
		import gtk.Label;
		import gtk.Widget;
		import gtk.StyleContext;
		import gtk.CssProvider;
		import gdk.Event;

		super("GtkHUD");
		setDecorated(false);
		setPosition(WindowPosition.CENTER_ALWAYS);
		setResizable(false);
		setSizeRequest(300, 500);

		setVisual(getScreen.getRgbaVisual);
		setOpacity(0.95);

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
			.hud-entry-path{
				opacity: 0.5;
			}
		}");
		StyleContext.addProviderForScreen(getScreen, css, 800);

		auto maincont = new Box(Orientation.VERTICAL, 0);
		add(maincont);
		searchBox = new TextView();
		with(searchBox){
			setWrapMode(WrapMode.NONE);
			setAcceptsTab(false);
			setProperty("border-width", 5);
			getStyleContext().addClass("hud-searchbox");
		}
		maincont.packStart(searchBox, false, false, 0);

		listBox = new ListBox();
		with(listBox){
			setActivateOnSingleClick(true);
			import gtk.Image;
			setPlaceholder(new Image("face-sad-symbolic", IconSize.DIALOG));//TODO: not visible
			addOnRowActivated((ListBoxRow row, ListBox lb){
					(cast(EntryWidget)(row.getChild)).launch();
					close();
				});

			extern(C)
			int filterFunc(GtkListBoxRow* row, void* userData){

				auto entryWidget = cast(EntryWidget)(new ListBoxRow(row).getChild);
				return entryWidget.searchStrength;
			}
			setFilterFunc(&filterFunc, null, null);


			extern(C)
			int sortFunc(GtkListBoxRow* row1, GtkListBoxRow* row2, void* userData){
				auto entryWidget1 = cast(EntryWidget)(new ListBoxRow(row1).getChild);
				auto entryWidget2 = cast(EntryWidget)(new ListBoxRow(row2).getChild);

				if(entryWidget1.searchStrength<entryWidget2.searchStrength)
					return 1;
				else if(entryWidget1.searchStrength>entryWidget2.searchStrength)
					return -1;
				else
					return 0;
			}
			setSortFunc(&sortFunc, null, null);
		}
		listBoxScroll = new ScrolledWindow();
		listBoxScroll.add(listBox);
		maincont.packStart(listBoxScroll, true, true, 0);


		searchBox.getBuffer.addOnChanged((TextBuffer tb){
				immutable pattern = tb.getText;
				listBox
					.getChildren
					.toArray!(ListBoxRow)
					.map!(a=>cast(EntryWidget)(a.getChild))
					.each!(a=>a.searchQuery(pattern));

				listBox.invalidateFilter;
				listBox.invalidateSort;
			
			});

		addOnKeyPress((Event e, Widget w){
			void moveSelection(int delta){
				if(listBoxLength==0) return;

				auto rows = listBox
					.getChildren
					.toArray!(ListBoxRow)
					.remove!(a=>!a.getChild.isDrawable);

				if(rows.length>0){
					int newIndex = cast(int)(listBox.getSelectedRow.getIndex)+delta;
					writeln(newIndex);
					if(newIndex<=0)
						newIndex=0;
					else if(newIndex>=rows.length)
						newIndex=cast(int)(rows.length)-1;

					writeln(newIndex);
					auto row = rows[newIndex];
					listBox.selectRow(row);

					//scroll to selection
					int rowX, rowY;
					row.translateCoordinates(listBox, 0, 0, rowX, rowY);
					listBox.getAdjustment().clampPage(
						rowY,
						rowY+row.getAllocatedHeight);

				}
			}

			import gdk.Keysyms;
			uint keyval;
			e.getKeyval(keyval);
					
			switch(keyval)with(GdkKeysyms){
				case GDK_Escape:
					close();
					return true;
				case GDK_Return, GDK_KP_Enter:
					listBox.getSelectedRow.activate;
					return true;

				case GDK_Down:
					moveSelection(+1);
					return true;
				case GDK_Up:
					moveSelection(-1);
					return true;
				case GDK_Tab, GDK_ISO_Left_Tab:
					moveSelection(e.key.state&ModifierType.SHIFT_MASK? -1 : +1);
					return true;

				default:
					return false;
			}
		});

		auto prov = new ProviderList("/home/crom/GitProjects/gtk-hud/providers/");//TODO
		auto menuList = prov.menuList;
		
		populateListBox(menuList.list);
		showAll();
	}

	TextView searchBox;
	ListBox listBox;
	ScrolledWindow listBoxScroll;
	uint listBoxLength;

private:
	import gtk.TextBuffer;
	void populateListBox(ref MenuEntry[] db){

		listBox.removeAll();
		listBoxLength = 0;

		db
			.each!((e){
				auto wid = new EntryWidget(cast(immutable)e);
				listBox.add(wid);
				listBoxLength++;
			});
		listBox.showAll();
		listBox.selectRow(listBox.getRowAtIndex(0));
	}
}





import gtk.Box;
class EntryWidget : Box{
	this(in immutable MenuEntry e){
		super(Orientation.HORIZONTAL, 0);
		entry = e;
		import gtk.Box;
		import gtk.Label;

		lblName = new Label(entry.path.baseName);
		with(lblName){
			setHalign(Align.START);
			getStyleContext().addClass("hud-entry-name");
		}
		lblPath = new Label(entry.path);
		with(lblPath){
			setHalign(Align.START);
			getStyleContext().addClass("hud-entry-path");
		}

		if(entry.shortcut!=null){
			lblShortcut = new Label(entry.shortcut);
			with(lblShortcut){
				getStyleContext().addClass("hud-entry-shortcut");
			}

			auto shortcutCont = new Box(Orientation.VERTICAL, 0);
			shortcutCont.setHomogeneous(true);
			shortcutCont.packStart(lblShortcut, false, false, 0);
			packEnd(shortcutCont, false, false, 0);
		}

		auto contB = new Box(Orientation.VERTICAL, 0);
		contB.add(lblName);
		contB.add(lblPath);

		packStart(contB, true, true, 0);


		//import gtk.Popover;
		//auto popover = new Popover(this);
		//popover.setPosition(GtkPositionType.RIGHT);
		//popover.add(new Label("yoloooo"));
		//popover.setModal(false);
		//popover.showAll();


	}

	void launch(){
		writeln("Activated ",lblPath.getText);
		//TODO
	}

	void searchQuery(in string pattern){
		auto res = fuzzyMatch(entry.path, pattern);
		m_searchStrength = res.strength;

		lblName.setText(entry.path.baseName~" ("~searchStrength.to!string~")");

		if(m_searchStrength>0){
			string markup;
			size_t lastIndex = 0;
			foreach(index ; res.indexes){
				markup ~= entry.path[lastIndex .. index]
					~"<span bgcolor=\"#FF9800A0\">"
					~entry.path[index]
					~"</span>";

				lastIndex = index+1;
			}
			markup ~= entry.path[lastIndex .. $];

			lblPath.setMarkup(markup);
		}
		else{
			lblPath.setMarkup(entry.path);
		}
	}
	@property{
		uint searchStrength(){
			return m_searchStrength;
		}
	}

	immutable MenuEntry entry;

private:
	import gtk.Label;

	Label lblName, lblPath, lblShortcut;
	uint m_searchStrength = 1;
}

