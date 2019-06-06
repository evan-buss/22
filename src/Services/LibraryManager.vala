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
        private string[] library;

        public LibraryManager() {
        }

        public static LibraryManager get_instance () {
            if (instance == null) {
                instance = new LibraryManager ();
            }
            return instance;
        }

        public async string[] get_library (string path) {
            yield load_library(path);
            message ("library is " +  library.length.to_string ());
            return library;
        }

        /* Load all files found at specific path */
        private async void load_library (string path) {
            var dir = File.new_for_path (path);

            try {
                var e = yield dir.enumerate_children_async(
                    FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT, null);

                while (true) {
                    var files = yield e.next_files_async (
                        10, Priority.DEFAULT, null);

                    if (files == null) {
                        break;
                    }

                    foreach (var info in files) {
                        if (info.get_file_type () == FileType.DIRECTORY) {
                            var subdir_path = dir.resolve_relative_path (info.get_name ()).get_path ();
                            //  Recursively traverse subdirectories
                            yield load_library(subdir_path);
                            //  yield load_library.begin(subdir_path, (obj, res) => {
                            //      load_library.end (res);
                            //  });
                        } else {
                            var name = info.get_name ();
                            if (name.contains (".jpg") || name.contains (".png")) {
                                library += dir.resolve_relative_path (name).get_path ();;
                            }
                        }
                    }
                }
            } catch(Error err) {
                warning ("Error: %s\n", err.message);
            }
        }
    }
}
