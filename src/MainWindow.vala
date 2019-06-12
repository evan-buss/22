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
              Create Views
            ************************/
            var scroll_window = new Gtk.ScrolledWindow (null, null);

            stack = new Gtk.Stack ();
            scroll_window.add (stack);

            library_view = new Views.LibraryView ();
            stack.add_named (library_view, "library");

            add (scroll_window);
        }
    }
}
