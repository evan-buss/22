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
                default_width: 640,
                default_height: 480,
                application: app
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
            //  var css_provider = new Gtk.CssProvider ();
            //  css_provider.load_from_resource ("/com/github/evan-buss/yin-yang/css/style.css");
            //  Gtk.StyleContext.add_provider_for_screen (
            //      Gdk.Screen.get_default (),
            //      css_provider,
            //      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            //  );

            /************************
                Header Bar
            ************************/
            var headerbar = new Gtk.HeaderBar ();
            headerbar.get_style_context ().add_class ("default-decoration");
            headerbar.show_close_button = true;
            set_titlebar (headerbar);
            title = _("22");

            /************************
              Create Views
            ************************/
            stack = new Gtk.Stack ();
            library_view = new Views.LibraryView ();
            stack.add_named (library_view, "main");

            add (stack);
        }
    }
}
