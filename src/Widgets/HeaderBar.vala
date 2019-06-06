
namespace App.Widgets {
    class HeaderBar : Gtk.HeaderBar {
        public HeaderBar() {
            Object (
                show_close_button: true,
                title: "22"
            );
        }

        construct {
            get_style_context ().add_class ("default-decoration");
        }
    }
}
