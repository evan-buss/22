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

        //  Views and Stack
        private Gtk.Stack stack;
        public Views.LibraryView library_view;
        public Views.GreetingView greeting_view;

        private Services.Settings settings;

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
            settings = Services.Settings.get_default ();

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
            set_titlebar (headerbar);

            headerbar.open_settings.connect (() => {
                // headerbar.settings_button.active = true;
                stack.set_visible_child_name ("greeting");
            });

            /************************
              Metadata Editor
            ************************/

            var top_revealer = new Gtk.Revealer ();
            top_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

            var metadata_editor = new Widgets.MetadataEditor (this);

            top_revealer.add (metadata_editor);

            /************************
              Create Views
            ************************/
            var scroll_window = new Gtk.ScrolledWindow (null, null);
            var views_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);

            stack = new Gtk.Stack ();
            stack.set_homogeneous (false);
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            

            library_view = new Views.LibraryView (headerbar);
            greeting_view = new Views.GreetingView ();

            //  Load library when user selects a location
            greeting_view.library_changed.connect (() => {
                library_view.clean_list ();
                library_view.load_library ();
            });

            // Switch to library view when button pressed
            greeting_view.done.connect (() => {
                if (settings.first_run) {
                    settings.first_run = false;
                }
                stack.set_visible_child_name ("library");
            });

            views_container.add (top_revealer);
            views_container.add (stack);
            scroll_window.add (views_container);

            stack.add_named (greeting_view, "greeting");
            stack.add_named (library_view, "library");

            //  Switch to the library if the user has previously run the application
            if (!settings.first_run) {
                message ("first RUN");
                stack.set_visible_child_name ("library");
                library_view.show_all ();
            } 

            /************************
              Event Handling
            ************************/

            double orig_value;

            //  Activating a book card shows the metadata editor
            library_view.show_details.connect ((book) => {
                metadata_editor.show_edit_controls (false);
                metadata_editor.change_book (book);
                //  Save original scroll position and scroll to top
                orig_value = scroll_window.vadjustment.value;
                scroll_window.vadjustment.value = scroll_window.vadjustment.lower;
                top_revealer.reveal_child = true;
            });

            //  Scroll back to orig position when done
            metadata_editor.done_edit.connect (() => {
                scroll_window.vadjustment.value = orig_value;
                top_revealer.reveal_child = false;
            });

            add (scroll_window);
        }
    }
}
