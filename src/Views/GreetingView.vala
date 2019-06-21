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

/*
    This view prompts the user to set up the necessary settings on first app load.
    Options List:
        - Library Location
        - Enable book conversions
            - Choose backend
                - Calibre utils
                    - Make sure they have calibre installed
                - Kindlegen utils
                    - User agrees to amazon's policy (link to page)
                    - Download binary from internet
*/
namespace App.Views {

    public class GreetingView : Gtk.Grid {

        private Services.Settings settings;
        private Gtk.Stack view_stack;

        public signal void library_changed ();

        public GreetingView(Gtk.Stack view_stack) {
            Object (
                halign: Gtk.Align.CENTER,
                valign: Gtk.Align.CENTER
            );
            this.view_stack = view_stack;
        }

        construct  {
            settings = Services.Settings.get_default ();

            /************************
              Heading
            ************************/

            var heading = new Gtk.Label ("Welcome to 22");
            heading.get_style_context ().add_class ("greeting-title");
            heading.margin_bottom = 8;
            var heading_description = new Gtk.Label ("A lightweight ebook manager that is fully compatible with existing Calibre libraries. You can use them interchangably.");
            heading_description.margin_bottom = 16;

            /************************
              Library Location Selector
            ************************/

            var library_label = new Gtk.Label ("First, select your library folder or create a new one");
            library_label.get_style_context ().add_class ("book-title");
            library_label.margin_bottom = 8;

            var library_location_selector =
                new Gtk.FileChooserButton ("Select Book Library", Gtk.FileChooserAction.SELECT_FOLDER);
            library_location_selector.margin_start = 4;
            library_location_selector.margin_end = 4;
            library_location_selector.halign = Gtk.Align.CENTER;

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

            /************************
              Converter Selection
            ************************/
            var backend_grid = new Gtk.Grid ();
            backend_grid.row_spacing = 8;
            backend_grid.column_spacing = 8;
            backend_grid.margin_top = 8;
            backend_grid.margin_start = 64;
            backend_grid.margin_end = 64;

            string[] col_headings = {"Name", "Description", "Formats", "Status"};

            for (int i = 0; i < col_headings.length; i++) {
                var label = new Gtk.Label(col_headings[i]);
                label.get_style_context ().add_class ("heading");
                backend_grid.attach (label, i, 0, 1, 1);
            }
            var convert_label = new Gtk.Label ("Next, select a backend for book conversions.");
            convert_label.get_style_context ().add_class ("book-title");
            convert_label.margin_top = 16;

            /************************
              Calibre Converter
            ************************/

            var calibre_button = new Gtk.RadioButton.with_label (null, "Calibre's ebook-convert");

            calibre_button.toggled.connect (handle_converter_select);

            var calibre_description = new Gtk.Label ("Calibre's open-source ebook conversion utility. Supports many different formats, but requires prior installation of Calibre.");
            calibre_description.wrap = true;
            var calibre_formats = new Gtk.Label ("epub, mobi, azw3");

            backend_grid.attach (calibre_button, 0, 1, 1, 1);
            backend_grid.attach (calibre_description, 1, 1, 1, 1);
            backend_grid.attach (calibre_formats, 2, 1, 1, 1);
            backend_grid.attach (program_exists ("ebook-convert") ? new Gtk.Label ("Installed"): new Gtk.Label ("Not Installed"), 3, 1, 1, 1);

            /************************
              Kindlegen Converter
            ************************/

            var kindlegen_button = new Gtk.RadioButton.with_label (calibre_button.get_group (), "Amazon's KindleGen");

            kindlegen_button.toggled.connect (handle_converter_select);

            var kindlegen_description = new Gtk.Label ("Proprietary conversion utility that can convert from epub to an enhanced mobi format that supports traditional mobi functionality as well as Kindle's azw3 format. Will be downloaded and installed to your path. Selection denotes agreement to the terms and conditions");

            kindlegen_description.wrap = true;
            var kindlegen_prompt = new Gtk.Label ("Kindlegen requires you to agree to their terms and conditions");
            var kindlegen_formats = new Gtk.Label ("epub, mobi");

            backend_grid.attach (program_exists ("kindlegen") ? new Gtk.Label ("Installed"): new Gtk.Label ("Not Installed"), 3, 2, 1, 1);


            foreach (var button in kindlegen_button.get_group ()) {
                button.set_active (false);
            }

            backend_grid.attach (kindlegen_button, 0, 2, 1, 1);
            backend_grid.attach (kindlegen_description, 1, 2, 1, 1);
            backend_grid.attach (kindlegen_formats, 2, 2, 1, 1);

            /************************
              Layout
            ************************/

            var done_button = new Gtk.Button.with_label ("Take me to my library");
            done_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            done_button.halign = Gtk.Align.END;
            done_button.margin = 32;

            done_button.clicked.connect (() => {
                message ("setting library view...");
                view_stack.set_visible_child_name ("library");
            });

            attach (heading, 0, 0, 1, 1);
            attach (heading_description, 0, 1, 1, 1);
            attach (library_label, 0, 2, 1, 1);
            attach (library_location_selector, 0, 3, 1, 1);
            attach (convert_label, 0, 5, 1, 1);
            attach (backend_grid, 0, 6, 1, 1);
            attach (done_button, 0, 7, 1, 1);
        }

        private void handle_converter_select (Gtk.ToggleButton radio) {
            if (radio.get_active ()) {
                if (radio.label == "Amazon's KindleGen") {
                    message ("kindlegen");
                } else {
                    message ("calibre");
                }
            }
        }

        private bool program_exists (string prog_name) {
            return Environment.find_program_in_path ("kindlegen") != null;
        }
    }
}
