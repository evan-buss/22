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
    public class HeaderBar : Gtk.HeaderBar {

        public signal void open_settings ();

        public Gtk.Spinner spinner;
        public Gtk.Button settings_button;
        public Gtk.Popover settings_popover;
        public Gtk.Label book_count;
        public Gtk.SearchEntry search_entry;
        
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

            settings_button = new Gtk.Button ();
            settings_button.has_tooltip = true;
            settings_button.tooltip_text = (_("Settings"));
            settings_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic",
                Gtk.IconSize.SMALL_TOOLBAR));

            settings_button.clicked.connect (() => {
                open_settings ();
            });

            /************************
              Search Entry
            ************************/
            search_entry = new Gtk.SearchEntry ();

            /************************
              Left Side 
            ************************/

            book_count = new Gtk.Label ("");
            spinner = new Gtk.Spinner ();

            
            pack_start (spinner);
            pack_start (book_count);
            pack_end (settings_button);
            pack_end (search_entry);
        }

        public void update_book_count (int count) {
            message ("inside function");
            book_count.label = count.to_string () + " books";
        }

        public void show_spinner () {
            spinner.active = true;
            spinner.visible = true;
        }

        public void hide_spinner () {
            spinner.active = false;
            spinner.visible = false;
        }
    }
}
