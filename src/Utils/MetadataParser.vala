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

    public enum MetadataTag { 
        TITLE,
        AUTHOR,
        COVER_LOCATION
    }

    class MetadataParser {

        public MetadataParser () {}

        /*
         * Retrieves the content contained at a specific tag
         * 
         * Params: string file_path - path to a valid XML file
         *         MetadataTag tag - tag to retrieve from XML file
         * 
         * Returns: The value that is found or an error string if it wasn't 
         *          found
         */
        public static string get_tag_content (string file_path, MetadataTag tag) {
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

            string? response = null;
            if (tag == MetadataTag.TITLE) {
                response = parse_node (root, "title");
            } else if (tag == MetadataTag.AUTHOR) {
                response = parse_node (root, "creator");
            }

            delete doc;

            Xml.Parser.cleanup ();

            if (response != null) {
                return response;
            } else {
                return "NOT FOUND!";
            }
        }

        /*
         * Recursively search through XML nodes until a tag matching QUERY is 
         * found
         * 
         * Params: Xml.Node* node - node to search
         *         string query - the tag to search for
         * 
         * Returns: The contents of the tag or null if not found
         */
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
            }
            //  Return null if tag was never found
            return null;
        }


        /*
         * Set the content at a specific XML tag and save the file.
         * 
         * Params: string file_path - path to a valid XML file
         *         MetadataTag tag - tag where the content should be set
         *         string content - the new value of the given XML tag
         */
        public static void set_tag_content (string file_path, MetadataTag tag, string content) {

            Xml.Parser.init ();
            
            Xml.Doc* doc = Xml.Parser.parse_file (file_path);
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
            
            if (tag == MetadataTag.TITLE) {
                //  The TITLE is stored in two places
                //  <dc:title>TITLE</dc:title>
                //  <meta content="TITLE" name="calibre:title_sort"/>
                edit_node_content (root, "title", content);
                edit_node_attribute (root, "meta", "name", "calibre:title_sort", "content",  content);
            } else if (tag == MetadataTag.AUTHOR) {
                //  The AUTHOR is stored in three places
                //  <dc:creator opf:file-as="LAST, FIRST" opf:role="aut">AUTHOR</dc:creator>
                //  <meta content="{&quot;AUTHOR&quot;: &quot;&quot;}" name="calibre:author_link_map"/>
                edit_node_content (root, "creator", content);

                var first_last = content.split(" ");
                edit_node_attribute (root, "creator", "role", "aut", "opf:file-as",  first_last[1] + ", " + first_last[0]);

                edit_node_attribute (root, "meta", "name", "calibre:author_link_map", "content", "{\"" + content + "\": \"\"}");
            }
            
            doc->save_format_file (file_path, 1);
            delete doc;
            
            Xml.Parser.cleanup ();
        }
        
        /*
         *  Edit the content of a specific node
         * 
         *  Params: Xml.Node* node - the node that should be searched
         *          string tag - tag to search for
         *          string content - the content to set for the given tag
         */
        private static void edit_node_content (Xml.Node* node, string tag, string content) {
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                //  Check if iter is actually an XML node...
                if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                    continue;
                }
        
                //  Check if tag name is the one we want
                if (iter->name == tag) {
                    message ("found the tag :)");
                    iter->set_content (content);
                    return;
                }
        
                edit_node_content (iter, tag, content);
            }
        }
        

        /*
         * Edit an attribute of a spefic node.
         * 
         * Because there are some duplicate nodes, you must enter an   
         *  attribute to refine the search.
         * Ex) 
         *  <meta content="{&quot;David Mitchell&quot;: &quot;&quot;}"   
         *  name="calibre:author_link_map"/>
         *  <meta content="4" name="calibre:rating"/>
         *  <meta content="2017-06-23T07:56:26+00:00" name="calibre:timestamp"/>
         *  <meta content="Cloud Atlas" name="calibre:title_sort"/>
         *  <meta name="calibre:user_metadata:#formats" content=
         *  
         * Params: Xml.Node* node - the node to search
         *         string tag - tag to search for
         *         string attribute - 
         */
        private static void edit_node_attribute (
            Xml.Node* node, 
            string tag, 
            string search_atr, 
            string search_atr_content, 
            string atr_to_edit,
            string atr_to_edit_content) 
            {
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                //  Check if iter is actually an XML node...
                if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                    continue;
                }
        
                //  Check if tag name is the one we want
                if (iter->name == tag) {
                    //  Get the contents of the attributae
                    var found_content = iter->get_prop (search_atr);
                    //  If it is found and it is equal to the property we are searching for
                    if (found_content != null && found_content == search_atr_content) {
                        message ("found the attribute");
                        //  Set the "content" field 
                        iter->set_prop (atr_to_edit, atr_to_edit_content);
                        return;
                    }
                }
        
                edit_node_attribute (iter, 
                    tag, 
                    search_atr, 
                    search_atr_content, 
                    atr_to_edit, 
                    atr_to_edit_content);
            }
        }
    }
}
