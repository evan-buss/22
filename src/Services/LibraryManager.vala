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

namespace App.Services {

    public class LibraryManager {

        private static LibraryManager instance = null;
        private Models.Book[] library;

        public LibraryManager () {
        }

        /*
         * Get the current instance of the library object (singleton)
         *
         * @return instantiated LibraryManager
         */
        public static LibraryManager get_instance () {
            if (instance == null) {
                instance = new LibraryManager ();
            }
            return instance;
        }

        /*
         * Reset the library (array of books)
         */
        public void reset_library () {
            library = null;
        }

        /*
         * Reload the library and return it
         *
         * @return Array of Model.Book objects
         */
        public async Models.Book[] get_library (string uri) {
            reset_library ();
            message ("library manager: before load library");
            yield load_library (uri);
            message ("library manager: library returned");
            message (library.length.to_string ());
            message ("library manager: before prune library");
            prune_library ();
            message ("library manager: after prune library");
            return library;
        }

        /* 
         * Removes all invalid books from the library.
         */
        public void prune_library () {
            message ("starting prune");
            Models.Book[] temp = null;
            foreach (var book in library) {
                if (book.is_valid ()) {
                    temp += book;
                }
            }
            message ("done looping");
            library = temp;
        }

        /*
         * Aysnchronously load all book objects contained within a given path
         * Books are saved to the "library" class property
         * Books are parsed at the lowest depth (no subdirectories)
         *
         * @future: save parsed books to a database
         *
         * @param string uri - URI of starting folder (may change to path)
        */
        //  FIXME: Change to path
        private async void load_library (string uri) {
            var dir = File.new_for_uri (uri);

            try {
                //  Get an enumerator of all files in the directory
                var e = yield dir.enumerate_children_async (
                    FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT, null);


                while (true) {
                    //  Get an array of FileInfo for 10 files at a time
                    var files = yield e.next_files_async (
                        10, Priority.DEFAULT, null);

                    //  Loop until all files have been parsed
                    if (files == null) {
                        break;
                    }

                    var found_folder = false;
                    string path = dir.get_path ();

                    foreach (var info in files) {
                        path = dir.resolve_relative_path (info.get_name ()).get_path ();

                        //  If file is directory, recursively run again
                        if (info.get_file_type () == FileType.DIRECTORY) {
                            found_folder = true;
                            var subdir_path = dir.resolve_relative_path (info.get_name ()).get_uri ();
                            yield load_library (subdir_path);
                        }
                    }

                    //  If there wasn't a single folder found, we are at the lowest subdirectory
                    if (!found_folder) {
                        var folder_path = File.new_for_path (path).get_parent ().get_path ();
                        library += yield get_book_data (folder_path);
                        // var book = yield get_book_data (folder_path);
                        // if (book != null) library += book;
                    }
                }
            } catch (Error err) {
                warning ("Error: %s\n", err.message);
            }
        }


        /*
         * Create and return a new book object from a given book's folder path
         *
         * @return new Book with parsed data
         */
        private async Models.Book? get_book_data (string path) {
            var book = new Models.Book (path);

            var file = File.new_for_path (path);

            // Use Glib mainloop to prevent return until async completes (HACKY)
            // https://mail.gnome.org/archives/vala-list/2016-January/msg00021.html
            // var loop = new MainLoop ();

            file.enumerate_children_async.begin (FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT, null, (obj, res) => {
                try {
                    FileEnumerator enumerator = file.enumerate_children_async.end (res);
                    FileInfo info;
                    while ((info = enumerator.next_file (null)) != null) {
                        var name = info.get_name ();
                        var item_path = file.resolve_relative_path (name).get_path ();
                        if (name.contains (".jpg") || name.contains (".png") || name.contains (".jpeg")) {
                            book.image_path = item_path;
                        } else if (name.contains (".opf")) {
                            book.metadata_path = item_path;
                        } else if (name.contains (".epub")) {
                            book.epub_path = item_path;
                        } else if (name.contains (".mobi")) {
                            book.mobi_path = item_path;
                        } else if (name.contains (".azw3")) {
                            book.azw_path = item_path;
                        } else {
                            book.unsupported = item_path;
                        }
                    }
                    // loop.quit();
                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                }
            });

            // loop.run ();
            // return book.is_valid () ? book : null;
            return book;
        }
    }
}
