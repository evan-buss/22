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
    Represents a single book including:
        image
        popover menu
        actions
        format overlay
*/
namespace App.Widgets {
    class BookCard : Gtk.Box {

        public Models.Book book;
        public Granite.AsyncImage book_cover_image;
        public Gtk.Revealer revealer;

        public BookCard(Models.Book book) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 8
            );

            this.book = book;

            /************************
              Create Image
            ************************/
            book_cover_image = new Granite.AsyncImage ();
            var image_file = File.new_for_path (this.book.image_path);
            book_cover_image.set_from_file_async (image_file, 200, 200, true);

            /************************
              Book Formats Overlay
            ************************/
            var overlay = new Gtk.Overlay ();

            var book_formats_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            book_formats_box.halign = Gtk.Align.END;
            book_formats_box.valign = Gtk.Align.END;

            revealer = new Gtk.Revealer ();
            revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;

            var mobi_label = new Gtk.Label ("mobi");
            mobi_label.get_style_context ().add_class ("chip");
            mobi_label.get_style_context ().add_class ("chip__blue");

            var epub_label = new Gtk.Label ("epub");
            epub_label.get_style_context ().add_class ("chip");
            epub_label.get_style_context ().add_class ("chip__blue");

            //  Only show chips for book formats in library
            if (book.epub_path != null) book_formats_box.add (epub_label);
            if (book.mobi_path != null) book_formats_box.add (mobi_label);

            revealer.add (book_formats_box);

            overlay.add_overlay (revealer);
            overlay.add (book_cover_image);

            /************************
              Book Details
            ************************/
            var title_label = new Gtk.Label (book.title);
            title_label.tooltip_text = book.title;
            title_label.halign = Gtk.Align.CENTER;
            title_label.max_width_chars = 15;
            title_label.ellipsize = Pango.EllipsizeMode.END;

            var author_label = new Gtk.Label (book.author);
            author_label.tooltip_text = book.author;
            author_label.halign = Gtk.Align.CENTER;
            author_label.max_width_chars = 15;
            author_label.ellipsize = Pango.EllipsizeMode.END;

            add (overlay);
            add (title_label);
            add (author_label);
        }
    }
}
