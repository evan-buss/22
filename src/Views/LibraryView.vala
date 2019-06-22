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

        private LibraryManager library_manager;
        private Services.Settings settings;
        public signal void show_details (ref Widgets.BookCard card);

        private Widgets.HeaderBar headerbar;

        public LibraryView (Widgets.HeaderBar headerbar) {
            Object (
                margin: 10,
                selection_mode: Gtk.SelectionMode.MULTIPLE,
                activate_on_single_click: false,
                homogeneous: true,
                valign: Gtk.Align.START,
                row_spacing: 10,
                column_spacing: 10,
                orientation: Gtk.Orientation.HORIZONTAL
            );

            this.headerbar = headerbar;

            //  Load library on application start
            library_manager = LibraryManager.get_instance ();
            settings = Services.Settings.get_default ();
            load_library ();


            /************************
              Event Handling
            ************************/

            //  Double clicking a book shows its details
            this.child_activated.connect ((child) => {
                //  message ("showing revealer??");
                var card = (Widgets.BookCard) child.get_child ();
                show_details (ref card);
            });

            // Retrieve selected children
            this.selected_children_changed.connect (() => {
                get_selected ();
            });

            //  Handle book searches
            headerbar.search_entry.search_changed.connect (() => {
                //  message (headerbar.search_entry.get_text ());
                this.set_filter_func (filter_func);
            });

            //  key_press_event.connect ((e) => {
            //      if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
            //          if (e.keyval == Gdk.Key.d) {
            //              create_a_document_from_a_string ();
            //              return true;
            //          }
            //      }
            //     return false;
            //  });
        }

        // Load library from the current gsettings saved path
        // Returns: Number of books loaded
        public void load_library () {
            string uri = settings.library_path;

            if (uri == "") {
                return;
            }

            headerbar.show_spinner ();
            library_manager.get_library.begin (uri, (obj, res) => {
                var book_list = library_manager.get_library.end (res);
                headerbar.update_book_count (book_list.length);
                foreach (var book in book_list) {
                    this.add (new Widgets.BookCard (book));
                }
                headerbar.hide_spinner ();
                this.show_all ();
            });
        }

        /*
         * Filter the books by title and author
         */
        public bool filter_func (Gtk.FlowBoxChild book) {
            var bookcard = (Widgets.BookCard) book.get_child ();
            var text = headerbar.search_entry.get_text ();
            
            if (bookcard.book.title.down ().contains (text.down ()) 
                || bookcard.book.author.down ().contains (text.down ())) {
                return true;
            }
            return false;
        }

        /*
         *  Remove and destroy all widgets from the FlowBox
         */
        public void clean_list () {
            this.@foreach ( (widget) => {
                widget.destroy ();
            });
        }

        /*
         * Retrieve all selected widgets from the flowbox
         */
        private void get_selected () {
            this.@foreach ((widget) => {
                var flow = (Gtk.FlowBoxChild) widget;
                var book_card = (Widgets.BookCard) flow.get_child ();
                if (flow.is_selected ()) {
                    book_card.formats_revealer.set_reveal_child (true);
                } else {
                    book_card.formats_revealer.set_reveal_child (false);
                }
            });
        }
    }
}
