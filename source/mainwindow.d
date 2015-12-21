import std.stdio;
import std.path;
import std.algorithm;
import std.string;
import std.process;

import gtk.Box;
import gtk.Label;
import gtk.Widget;
import gdk.Event;
import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.TextView;
import gtk.ScrolledWindow;
import gtk.TextBuffer;

import provider;
import search;
import entry;
import settingswindow;


import gtk.MainWindow;
class MainWindow : gtk.MainWindow.MainWindow{

	this(){
		super("GtkHUD");
		setDecorated(false);
		setPosition(WindowPosition.CENTER_ALWAYS);
		setResizable(false);
		setSizeRequest(400, 600);

		//Transparency
		setVisual(getScreen.getRgbaVisual);
		setOpacity(0.95);

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
			auto placeholder = new Box(Orientation.VERTICAL, 10);
			with(placeholder){
				setValign(Align.CENTER);
				add(new Image("face-sad-symbolic", IconSize.DIALOG));
				add(new Label("Nothing matched your search"));
				showAll();
			}
			setPlaceholder(placeholder);

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
					return entryWidget1.id<entryWidget2.id? -1 : 1;
			}
			setSortFunc(&sortFunc, null, null);
		}
		listBoxScroll = new ScrolledWindow();
		listBoxScroll.add(listBox);
		maincont.packStart(listBoxScroll, true, true, 0);


		searchBox.getBuffer.addOnChanged((TextBuffer tb){
				listBox
					.getChildren
					.toArray!(ListBoxRow)
					.map!(a=>cast(EntryWidget)(a.getChild))
					.each!(a=>a.searchQuery(tb.getText));

				listBox.invalidateFilter;
				listBox.invalidateSort;

				selectRowAbsolute(0);
			});

		addOnKeyPress((Event e, Widget w){

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
					selectRowRelative(+1);
					return true;
				case GDK_Up:
					selectRowRelative(-1);
					return true;
				case GDK_Tab, GDK_ISO_Left_Tab:
					selectRowRelative(e.key.state&ModifierType.SHIFT_MASK? -1 : +1);
					return true;

				case GDK_Left://TODO: add entry to display window
					new SettingsWindow(this);//TODO: Construct the window earlier
					return true;

				default:
					return false;
			}
		});

		updateEntriesList();
		showAll();
	}


	void updateEntriesList(){
		import app;
		listBox.removeAll();
		listBoxLength = 0;

		foreach(uint i, e ; App.get.getAllEntries){
			auto wid = new EntryWidget(e, i);
			listBox.add(wid);
			listBoxLength++;
		}
		listBox.showAll();
		listBox.selectRow(listBox.getRowAtIndex(0));
	}


private:
	void selectRowRelative(int delta){
		if(listBoxLength==0) return;

		auto rows = listBox
			.getChildren
			.toArray!(ListBoxRow)
			.remove!(a=>!a.isDrawable);

		if(rows.length>0){
			int newIndex = cast(int)(listBox.getSelectedRow.getIndex)+delta;
			if(newIndex<=0)
				newIndex=0;
			else if(newIndex>=rows.length)
				newIndex=cast(int)(rows.length)-1;

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
	void selectRowAbsolute(int index){
		if(listBoxLength==0) return;

		auto rows = listBox
			.getChildren
			.toArray!(ListBoxRow)
			.remove!(a=>!a.isDrawable);

		if(rows.length>0){
			auto row = rows[index];
			listBox.selectRow(row);

			//scroll to selection
			int rowX, rowY;
			row.translateCoordinates(listBox, 0, 0, rowX, rowY);
			listBox.getAdjustment().clampPage(
				rowY,
				rowY+row.getAllocatedHeight);
		}
	}

	TextView searchBox;
	ListBox listBox;
	ScrolledWindow listBoxScroll;
	uint listBoxLength;

}





import gtk.Box;
class EntryWidget : Box{
	this(ref Entry _entry, uint _id){
		super(Orientation.HORIZONTAL, 0);
		entry = _entry;
		id = _id;
		import gtk.Box;
		import gtk.Label;

		lblName = new Label(entry.name);
		with(lblName){
			setHalign(Align.START);
			setLineWrap(true);
			getStyleContext().addClass("hud-entry-name");
		}
		lblPath = new Label(entry.fullName);
		with(lblPath){
			setHalign(Align.START);
			setLineWrap(true);
			getStyleContext().addClass("hud-entry-fullname");
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
	}

	void launch(){
		entry.provider.execute(entry);
	}

	void searchQuery(in string pattern){
		immutable fullNameDstring = entry.fullName.to!dstring;

		auto res = fuzzyMatch(fullNameDstring, pattern.to!dstring);
		m_searchStrength = res.strength;

		lblName.setText(entry.name~" ("~searchStrength.to!string~")");

		if(m_searchStrength>0){
			dstring markup;
			size_t lastIndex = 0;
			foreach(index ; res.indexes){
				markup ~= fullNameDstring[lastIndex .. index]
					~"<span bgcolor=\"#FF9800A0\">"
					~fullNameDstring[index]
					~"</span>";

				lastIndex = index+1;
			}
			markup ~= fullNameDstring[lastIndex .. $];

			lblPath.setMarkup(markup.to!string);
		}
		else{
			lblPath.setMarkup(entry.fullName);
		}
	}
	@property{
		uint searchStrength(){
			return m_searchStrength;
		}
	}

	Entry entry;
	immutable uint id;

private:
	import gtk.Label;

	Label lblName, lblPath, lblShortcut;
	uint m_searchStrength = 1;
}

