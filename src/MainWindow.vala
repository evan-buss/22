/*
* Copyright (c) 2011-2019 Evan Buss (https://evanbuss.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Evan Buss <evan.buss28@gmail.com>
*/

namespace App {

    public class MainWindow : Gtk.ApplicationWindow {

        public Views.LibraryView library_view;
        private Gtk.Stack stack;

        public MainWindow (Application app) {
            Object (
                default_width: 800,
                default_height: 600,
                application: app,
                icon_name: "com.github.evan-buss.22"
            );
        }

        construct {
            /************************
              Load Existing Preferences
            ************************/
            //  settings = Services.Settings.get_default ();

            /************************
              Load External CSS
            ************************/
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/evan-buss/22/css/style.css");
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            /************************
                Header Bar
            ************************/
            var headerbar = new Widgets.HeaderBar ();

            headerbar.library_changed.connect (() => {
                library_view.load_library ();
            });

            set_titlebar (headerbar);

            /************************
              Metadata Editor
            ************************/
            //  connect to some event...
            var metadata_revealer = new Gtk.Revealer ();
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            metadata_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            var but = new Gtk.Button.with_label ("Save Changes");
            var meta_title = new Gtk.Label ("");
            box.add (meta_title);
            box.add (but);
            metadata_revealer.add (box);


            /************************
              Create Views
            ************************/
            var view_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 8);
            var scroll_window = new Gtk.ScrolledWindow (null, null);

            stack = new Gtk.Stack ();


            library_view = new Views.LibraryView ();
            stack.add_named (library_view, "library");

            view_box.add (metadata_revealer);
            view_box.add (stack);

            scroll_window.add (view_box);

            double orig_value;

            library_view.show_details.connect ((book) => {
                meta_title.label = book.title;
                //  Save original scroll position
                orig_value = scroll_window.vadjustment.value;
                //  Scroll to the top of the page
                scroll_window.vadjustment.value = scroll_window.vadjustment.lower;
                metadata_revealer.reveal_child = true;
            });

            but.clicked.connect (() => {
                scroll_window.vadjustment.value = orig_value;
                metadata_revealer.reveal_child = false;
            });


            add (scroll_window);
        }
    }
}
