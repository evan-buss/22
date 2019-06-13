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

namespace App.Widgets {

    class MetadataEditor : Gtk.Grid {

        private Gtk.Label title;
        public Gtk.Button save_button;
        public Gtk.Button cancel_button;
        public signal void done_edit ();

        private Models.Book book;
        private File image_file;
        private Granite.AsyncImage book_cover_image;

        public MetadataEditor() {
            Object  (
                row_spacing: 16,
                column_spacing: 16,
                margin_bottom: 8
            );

            this.get_style_context ().add_class ("metadata_editor");
        }

        construct {
            /************************
              Book Details
            ************************/
            title = new Gtk.Label ("");
            title.get_style_context ().add_class (Gtk.STYLE_CLASS_HEADER);

            book_cover_image = new Granite.AsyncImage ();
            book_cover_image.margin_top = 16;
            book_cover_image.margin_start = 16;
            //  image_file = File.new_for_path (book.image_path);
            //  book_cover_image.set_from_file_async (image_file, 200, 200, true);

            /************************
              Control Buttons
            ************************/
            cancel_button = new Gtk.Button.with_label ("Cancel");
            cancel_button.clicked.connect (() => {
                done_edit ();
            });
            cancel_button.margin_bottom = 16;
            cancel_button.margin_start = 16;


            save_button = new Gtk.Button.with_label ("Save Changes");
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.clicked.connect (() => {
                done_edit ();
            });
            save_button.margin_bottom = 16;

            /************************
              Grid Layout
            ************************/
            attach (book_cover_image, 0, 0, 1, 1);
            attach (title, 1, 0, 1, 1);
            attach (cancel_button, 0, 1, 1, 1);
            attach (save_button, 1, 1, 1, 1);
        }

        public void change_book (Models.Book book) {
            this.book = book;
            title.label = book.title;

            image_file = File.new_for_path (book.image_path);
            book_cover_image.set_from_file_async (image_file, 200, 200, true);
        }
    }
}
