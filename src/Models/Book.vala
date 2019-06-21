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
    Each book has a few associated details
        - Folder Path
            - Image path
            - epub Path
            - mobi Path
            - metadata.opf path
*/

namespace App.Models {
    public class Book {
        public string title { get; set; }
        public string author { get; set; }
        public string folder_path { get; set; }
        public string? image_path { get; set; }
        public string? epub_path { get; set; }
        public string? mobi_path { get; set; }
        public string? azw_path { get; set; }
        private string? _metadata_path = null;
        public string? unsupported { get; set; }


        //  Parse the metadata file when found
        public string? metadata_path {
            get {
                return _metadata_path;
            }
            set {
                _metadata_path = value;
                title = Utils.MetadataParser.get_tag_content (metadata_path, "title");
                author = Utils.MetadataParser.get_tag_content (metadata_path, "creator");
            }
        }

        public Book (string folder_path) {
            this.folder_path = folder_path;
        }

        /**
         *  Determine if the book is valid.
         *  A valid book has atleast a single ebook format
         */
        public bool is_valid () {
            return epub_path != null || mobi_path != null || azw_path != null;
        }

        public string to_string () {
            return @"Folder: $folder_path\n" +
                @"Image: $image_path\n" +
                @"ePub: $epub_path \n" +
                @"mobi: $mobi_path\n" +
                @"metadata: $metadata_path\n";
        }
    }
}
