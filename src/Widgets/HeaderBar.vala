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

/* Application headerbar includes buttons to toggle view and maybe a search */

namespace App.Widgets {
    class HeaderBar : Gtk.HeaderBar {

        public signal void library_changed ();
        public Gtk.MenuButton settings_button;
        public Gtk.Popover settings_popover;
        private Services.Settings settings;

        public HeaderBar () {
            Object (
                show_close_button: true,
                title: "22"
            );

            get_style_context ().add_class ("default-decoration");
        }

        construct {

            settings = Services.Settings.get_default ();
            /************************
              Settings Button
            ************************/
            settings_button = new Gtk.MenuButton ();
            settings_button.has_tooltip = true;
            settings_button.tooltip_text = (_("Settings"));
            settings_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic",
                Gtk.IconSize.SMALL_TOOLBAR));


            /************************
              Settings Menu Popover
            ************************/
            var settings_menu = new Gtk.Grid ();
            settings_menu.row_spacing = 8;
            var library_location_selector =
                new Gtk.FileChooserButton ("Select Book Library", Gtk.FileChooserAction.SELECT_FOLDER);
            library_location_selector.margin_start = 4;
            library_location_selector.margin_end = 4;

            // Load file from preferences or set to default
            if (settings.library_path == "") {
                library_location_selector.set_current_folder_uri ("~/Documents");
            } else {
                library_location_selector.set_uri (settings.library_path);
            }

            // Save users's file selection choice.
            library_location_selector.file_set.connect (() => {
                settings.library_path = library_location_selector.get_uri ();
                library_changed ();
            });

            //  settings.schema.bind ("library-path", library_location_selector, "get_uri", SettingsBindFlags.DEFAULT);


            settings_menu.attach (new Gtk.Label ("Select Book Library"), 0, 0, 1, 1);
            settings_menu.attach (library_location_selector, 0, 1, 1, 1);
            settings_menu.show_all ();


            settings_popover = new Gtk.Popover (null);
            settings_popover.add (settings_menu);
            settings_button.popover = settings_popover;

            pack_end (settings_button);
        }
    }
}
