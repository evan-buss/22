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

namespace App.Utils {

    class MetadataParser {

        public MetadataParser () {}

        public static void parse_xml_file (ref Models.Book book) {

            Xml.Parser.init ();

            Xml.Doc* doc = Xml.Parser.parse_file (book.metadata_path);
            if (doc == null) {
                message ("Could not open xml file to parse!");
                return;
            }

            // Get the root element
            Xml.Node * root = doc->get_root_element ();
            if (root == null) {
                delete doc;
                message ("Could not find root element!");
                return;
            }

            parse_node (root, ref book);

            delete doc;

            Xml.Parser.cleanup ();
        }

        private static void parse_node (Xml.Node* node, ref Models.Book book) {
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                    continue;
                }
                //  message (iter->name);
                if (iter->name == "title") {
                    book.title = iter->get_content ();
                } else if (iter->name == "creator") {
                    book.author = iter->get_content ();
                }
                //  parse_properties (iter);
                parse_node (iter, ref book);
            }
        }

        //  private static void parse_properties (Xml.Node* node) {
        //      // Loop over the passed node's properties (attributes)
        //      for (Xml.Attr* prop = node->properties; prop != null; prop = prop->next) {
        //          message (prop->name + " -> " + prop->children->content);
        //      }
        //  }
    }
}
