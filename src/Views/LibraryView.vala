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
        public signal void show_details (Models.Book book);

        public LibraryView () {
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

            //  Load library on application start
            library_manager = LibraryManager.get_instance ();
            settings = Services.Settings.get_default ();
            load_library ();

            this.child_activated.connect ((child) => {
                //  message ("showing revealer??");
                var card = (Widgets.BookCard) child.get_child ();
                show_details (card.book);
            });

            // Retrieve selected children
            this.selected_children_changed.connect (() => {
                get_selected ();
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


        //  Load library from the current gsettings saved path
        public void load_library () {
            string uri = settings.library_path;

            if (uri == "") {
                return;
            }

            library_manager.get_library.begin (uri, (obj, res) => {
                var book_list = library_manager.get_library.end (res);
                message ("There were " + book_list.length.to_string () + " books");
                foreach (var book in book_list) {
                    this.add (new Widgets.BookCard (book));
                }
                this.show_all ();
            });
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
