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
 * Conversion wraps the "kindlegen" proprietary program from Amazon. It is able to
 * convert epub files to ereader compatable mobi files. Kindlegen files are
 * fully azw3 compatable and allow for custom fonts.
 *
 * Necessary Functionality:
 *  - Download binary from amazon servers
 *  - Convert given input file (epub) to output at specific directory
 */
namespace App.Utils {

    class Conversion {

        public Conversion() {

        }

        public static void download_and_install_kindlegen () {
            message ("Downloading now :)")
        }

        public static void convert_epub () {

        }
    }
}
