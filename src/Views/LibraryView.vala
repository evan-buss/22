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

using App.Services;

namespace App.Views {

    public class LibraryView : Gtk.FlowBox {

        public LibraryView () {
            Object (
                margin_end: 10,
                margin_start: 10,
                selection_mode: Gtk.SelectionMode.NONE,
                activate_on_single_click: false,
                homogeneous: false
            );

            var library_manager = LibraryManager.get_instance ();
            library_manager.get_library.begin(Environment.get_home_dir () + "/Downloads/Books", (obj, res) => {
                var book_list = library_manager.get_library.end(res);
                foreach (var book in book_list) {
                    add_image_from_path (book);
                }
                this.show_all();
            });
        }

        construct {}

        private void add_image_from_path (string path) {
            var image = new Granite.AsyncImage ();
            var file = File.new_for_path (path);
            image.set_from_file_async(file, 200, 200, true);
            this.add (image);
        }
    }
}
