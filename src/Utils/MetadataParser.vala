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
 * MetadataParser reads a *.opf file and parses the relevant data.
 * It can also update and save the changes to the file.
 *
 * Relevant data:
 *  - Title
 *  - Author
 *  - Cover image location
*/

namespace App.Utils {

    class MetadataParser {

        //  MAKE AN ENUM FOR THE DIFFERENT PARSE TYPES
        //  REDUCES THE NUMBER OF DIFFERENT FUNCS WE HAVE TO HAVE
        //  search by tag
        //  search by content

        public MetadataParser () {}

        //  FIXME: This function has to go or stay when structure is changed...
        public static string get_tag_content (string file_path, string tag_name) {
            return parse_xml_file (file_path, tag_name);
        }

        /*
         * Generic function that simply loops through the XML from root
         */
        public static string parse_xml_file (string file_path, string tag_name) {

            Xml.Parser.init ();

            Xml.Doc* doc = Xml.Parser.parse_file (file_path);
            if (doc == null) {
                message ("Could not open xml file to parse!");
                return "FILE ERROR!";
            }

            // Get the root element
            Xml.Node * root = doc->get_root_element ();
            if (root == null) {
                delete doc;
                message ("Could not find root element!");
                return "NO ROOT!";
            }

            var response = parse_node (root, tag_name);

            delete doc;

            Xml.Parser.cleanup ();

            if (response != null) {
                return response;
            } else {
                return "NOT FOUND!";
            }
        }

        //  Retrieve the contents of a specific node
        private static string? parse_node (Xml.Node* node, string query) {
            string? value = null;
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                //  Check if iter is actually an XML node...
                if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                    continue;
                }

                //  Check if tag name is the one we want
                if (iter->name == query) {
                    return iter->get_content ();
                }

                value = parse_node (iter, query);
                if (value != null) {
                    return value;
                }
            //     parse_properties (iter);
            }
            //  Return null if tag was never found

            return null;
        }

        //  private static void parse_properties (Xml.Node* node) {
        //      // Loop over the passed node's properties (attributes)
        //      for (Xml.Attr* prop = node->properties; prop != null; prop = prop->next) {
        //          message (prop->name + " -> " + prop->children->content);
        //      }
        //  }
    }
}
