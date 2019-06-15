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
 * 22 Aims to provide basic metadata editing capabilities.
 *  - Title
 *  - Author
 *  - Cover Image
 *  - ISBN (?)
 *  - Book Blurb (?)
 */

namespace App.Widgets {

    class MetadataEditor : Gtk.Grid {

        //  Details
        private Gtk.Label title;
        private Gtk.Label author;
        private Models.Book book;
        private File image_file;
        private Granite.AsyncImage image;

        //  Editing
        private Gtk.Entry title_entry;
        private Gtk.Entry author_entry;
        private Gtk.Button picture_button;

        //  Buttons
        public Gtk.Button save_button;
        public Gtk.Button cancel_button;
        public Gtk.Button edit_button;

        //  Content Switching Stack
        private Gtk.Stack stack;

        public signal void done_edit ();

        public Gtk.Window parent_window;

        public MetadataEditor(Gtk.Window parent_window) {
            Object  (
                row_spacing: 16,
                column_spacing: 16,
                margin_bottom: 8
            );
            this.parent_window = parent_window;

            //  FIXME: elementary theme default buttons screwed up
            //  Figure out how to use colorscheme's dark mode for specific widget
            get_style_context ().add_class ("metadata-editor");
        }

        construct {
            /************************
              Details Widgets
            ************************/
            title = new Gtk.Label ("");
            //  title.get_style_context ().add_class ("light-text");
            title.get_style_context ().add_class ("book-title");
            title.halign = Gtk.Align.START;
            title.wrap = true;
            title.set_justify (Gtk.Justification.FILL);
            title.margin_top = 16;
            title.set_hexpand (true);

            author = new Gtk.Label ("");
            //  author.get_style_context ().add_class ("light-text");
            author.halign = Gtk.Align.START;

            /************************
              Editing Widgets
            ************************/
            title_entry = new Gtk.Entry ();
            title_entry.margin_top = 16;
            title_entry.width_chars = 30;
            try {
                title_entry.set_icon_from_gicon (Gtk.EntryIconPosition.PRIMARY, Icon.new_for_string ("edit-symbolic"));
            } catch (Error e) {
                message ("Could not create title entry icon...");
            }

            author_entry = new Gtk.Entry ();
            author_entry.margin_top = 8;
            author_entry.width_chars = 30;
            author_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "avatar-default-symbolic");

            /************************
              Change Book Image Button
            ************************/
            //  Create Camera Button Icon
            picture_button = new Gtk.Button.from_icon_name ("emblem-photos", Gtk.IconSize.DIALOG);
            picture_button.get_style_context ().add_class ("image-select-button");
            picture_button.halign = Gtk.Align.CENTER;
            picture_button.valign = Gtk.Align.CENTER;
            picture_button.margin_start = 16;

            //  Create Image
            image = new Granite.AsyncImage ();
            image.can_focus = false;
            image.margin = 16;
            image.margin_end = 0;

            //  Create Overlay
            var overlay = new Gtk.Overlay ();
            overlay.can_focus = false;
            overlay.add_overlay (picture_button);
            overlay.add (image);

            /************************
              File Chooser Dialog
            ************************/

            var file_dialog = new Gtk.FileChooserDialog ("Select a new Book Cover",
                parent_window,
                Gtk.FileChooserAction.OPEN,
                "Cancel", Gtk.ResponseType.CANCEL,
                "Select", Gtk.ResponseType.ACCEPT);

            var filter = new Gtk.FileFilter ();
            filter.add_pattern ("*.png");
            filter.add_pattern ("*.jpg");
            filter.add_pattern ("*.jpeg");

            file_dialog.add_filter (filter);

            //  Don't destroy the dialog just hide it
            file_dialog.delete_event.connect (() => {
                file_dialog.hide_on_delete ();
            });

            //  Open the dialog on click
            picture_button.clicked.connect (() => {
              if (file_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    var tmp_img_path = file_dialog.get_file ().get_path ();

                    var tmp_img_file = File.new_for_path (tmp_img_path);
                    image.set_from_file_async (tmp_img_file, 200, 200, true);
               }

               file_dialog.close ();
            });

            /************************
              Control Buttons
            ************************/
            var button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            button_box.margin_end = 16;
            button_box.width_request = 150;

            edit_button = new Gtk.Button.with_label ("Edit Details");
            //  edit_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            edit_button.margin_top = 16;
            edit_button.clicked.connect (() => {
               show_edit_controls (!save_button.visible);
            });

            save_button = new Gtk.Button.with_label ("Save Changes");
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.margin_top = 16;

            save_button.clicked.connect (() => {
                done_edit ();
            });

            cancel_button = new Gtk.Button.with_label ("Cancel");
            cancel_button.clicked.connect (() => {
                done_edit ();
            });
            cancel_button.margin_top = 16;

            button_box.add (edit_button);
            button_box.add (cancel_button);
            button_box.add (save_button);

            /************************
              Layout
            ************************/
            var edit_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            edit_box.add (title_entry);
            edit_box.add (author_entry);

            var details_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            details_box.add (title);
            details_box.add (author);

            stack = new Gtk.Stack ();
            stack.add_named (details_box, "details");
            stack.add_named (edit_box, "edit");

            attach (overlay, 0, 0, 1, 6);
            attach (stack, 1, 0, 1, 6);
            attach (button_box, 2, 0, 1, 6);
        }

        /*
         * Populate the metadata editor details with specific book propertiesi
         */
        public void change_book (Models.Book book) {
            this.book = book;

            title.label = book.title;
            author.label = book.author;

            image_file = File.new_for_path (book.image_path);
            image.set_from_file_async (image_file, 200, 200, true);

            title_entry.text = book.title;
            author_entry.text = book.author;
        }

        /*
         * Show or hide the metadata editing fields and buttons
         */
        public void show_edit_controls (bool show) {
            save_button.visible = show;
            picture_button.visible = show;

            if (show) {
                stack.set_visible_child_name ("edit");
            } else {
                stack.set_visible_child_name ("details");
            }
        }
    }
}
