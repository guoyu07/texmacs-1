
/******************************************************************************
* MODULE     : server.hpp
* DESCRIPTION: Main current graphical interface for user applications
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef SERVER_H
#define SERVER_H
#include "url.hpp"
#include "widget.hpp"
#include "scheme.hpp"
#include "editor.hpp"

class server_rep: public abstract_struct {
public:
  server_rep ();
  virtual ~server_rep ();
  virtual server_rep* get_server () = 0;

  /* Control global server parameters */
  
  virtual void   set_font_rules (scheme_tree rules) = 0;
  virtual bool   kbd_get_command (string s, string& help, command& cmd) = 0;
  virtual void   insert_kbd_wildcard (string key, string im,
				      bool post, bool l, bool r) = 0;
  virtual string kbd_pre_rewrite (string l) = 0;
  virtual string kbd_post_rewrite (string l, bool var_flag= true) = 0;
  virtual tree   kbd_system_rewrite (string l) = 0;
  virtual void   set_variant_keys (string var, string unvar) = 0;
  virtual void   get_keycomb (string& s, int& status,
			      command& cmd, string& sh, string& help) = 0;

  // current window properties
  
  virtual int  get_window_serial () = 0;
  virtual void set_window_property (scheme_tree what, scheme_tree val) = 0;
  virtual void set_bool_window_property (string what, bool val) = 0;
  virtual void set_int_window_property (string what, int val) = 0;
  virtual void set_string_window_property (string what, string val) = 0;
  virtual scheme_tree get_window_property (scheme_tree what) = 0;
  virtual bool get_bool_window_property (string what) = 0;
  virtual int get_int_window_property (string what) = 0;
  virtual string get_string_window_property (string what) = 0;

  // current window UI and infos
  
  virtual void show_footer   (bool flag) = 0;
  virtual void show_header (bool flag) = 0;
  virtual void show_icon_bar (int which, bool flag) = 0;
  virtual void show_side_tools (int which, bool flag) = 0;
  virtual void show_bottom_tools (int which, bool flag) = 0;
  virtual bool visible_footer () = 0;
  virtual bool visible_header () = 0;
  virtual bool visible_icon_bar (int which) = 0;
  virtual bool visible_side_tools (int which) = 0;
  virtual bool visible_bottom_tools (int which) = 0;

  virtual void set_message (tree left, tree right, bool temp= false) = 0;
  virtual void recall_message () = 0;

  virtual void set_window_modified (bool flag) = 0;
  virtual void set_window_zoom_factor (double zoom) = 0;
  virtual double get_window_zoom_factor () = 0;
  virtual void full_screen_mode (bool on, bool edit) = 0;
  virtual bool in_full_screen_mode () = 0;
  virtual bool in_full_screen_edit_mode () = 0;
  virtual void get_window_position (SI& x, SI& y) = 0;

  // interaction with user
  
  virtual void dialogue_start (string name, widget wid) = 0;
  virtual void dialogue_inquire (int i, string& arg) = 0;
  virtual void dialogue_end () = 0;
  virtual void choose_file (object fun, string title, string type,
			    string prompt, url name) = 0;
  virtual void interactive (object fun, scheme_tree p) = 0;
  virtual void keyboard_focus_on (string field) = 0;
  
  // candidate methods for deletion (they are used only by edit to interact with widgets)
  
  virtual void menu_widget (string menu, widget& w) = 0;
  virtual void update_menus () = 0;
  virtual void menu_main (string menu) = 0;
  virtual void menu_icons (int which, string menu) = 0;
  virtual void side_tools (int which, string menu) = 0;
  virtual void bottom_tools (int which, string menu) = 0;
  virtual void set_scrollbars (int sb) = 0;
  virtual void get_visible (SI& x1, SI& y1, SI& x2, SI& y2) = 0;
  virtual void scroll_where (SI& x, SI& y) = 0;
  virtual void scroll_to (SI x, SI y) = 0;
  virtual void set_extents (SI x1, SI y1, SI x2, SI y2) = 0;
  virtual void get_extents (SI& x1, SI& y1, SI& x2, SI& y2) = 0;
  virtual void set_footer (string l, string r) = 0;
 
  // buffers
  
  virtual array<url> get_all_buffers () = 0;
  virtual url  make_new_buffer () = 0;
 // virtual void remove_buffer (url name) = 0;
  virtual int  number_buffers () = 0;
  virtual url  get_current_buffer () = 0;
  virtual url  get_current_buffer_safe () = 0;
  virtual url  path_to_buffer (path p) = 0;
  virtual void rename_buffer (url name, url new_name) = 0;
  virtual url get_master_buffer (url name) = 0;
  virtual void set_master_buffer (url name, url master) = 0;
  virtual void set_title_buffer (url name, string title) = 0;
  virtual string get_title_buffer (url name) = 0;
  virtual void set_buffer_tree (url name, tree doc) = 0;
  virtual tree get_buffer_tree (url name) = 0;
  virtual void set_buffer_body (url name, tree body) = 0;
  virtual tree get_buffer_body (url name) = 0;
  virtual url new_buffer_in_new_window (url name, tree t, tree geom= "") = 0;
  virtual int  get_last_save_buffer (url name) = 0;
  virtual void set_last_save_buffer (url name, int t) = 0;
  virtual bool is_aux_buffer (url name) = 0;
  virtual double last_visited (url name) = 0;
  virtual bool buffer_modified (url name) = 0;
  virtual bool buffer_modified_since_autosave (url name) = 0;
  virtual void pretend_buffer_modified (url name) = 0;
  virtual void pretend_buffer_saved (url name) = 0;
  virtual void pretend_buffer_autosaved (url name) = 0;
  virtual void attach_buffer_notifier (url name) = 0;
  virtual bool buffer_has_name (url name) = 0;
  virtual bool buffer_import (url name, url src, string fm) = 0;
  virtual bool buffer_load (url name) = 0;
  virtual bool buffer_export (url name, url dest, string fm) = 0;
  virtual bool buffer_save (url name) = 0;
  virtual tree import_loaded_tree (string s, url u, string fm) = 0;
  virtual tree import_tree (url u, string fm) = 0;
  virtual bool export_tree (tree doc, url u, string fm) = 0;
  virtual tree load_style_tree (string package) = 0;

  // projects
  
  virtual void project_attach (string prj_name= "") = 0;
  virtual bool project_attached () = 0;
  virtual url  project_get () = 0;

  // views
  
  virtual  array<url> get_all_views () = 0;
  virtual  array<url> buffer_to_views (url name) = 0;
  virtual  editor get_current_editor () = 0;
  virtual  editor view_to_editor (url u) = 0;
  virtual  bool has_current_view () = 0;
  virtual  void set_current_view (url u) = 0;
  virtual  url  get_current_view () = 0;
  virtual  url  get_current_view_safe () = 0;
  virtual  url  window_to_view (url win) = 0;
  virtual  url  view_to_buffer (url u) = 0;
  virtual  url  view_to_window (url u) = 0;
  virtual  url  get_new_view (url name) = 0;
  virtual  url  get_recent_view (url name) = 0;
  virtual  url  get_passive_view (url name) = 0;
  virtual  void delete_view (url u) = 0;
  virtual  void notify_rename_before (url old_name) = 0;
  virtual  void notify_rename_after (url new_name) = 0;
  virtual  void window_set_view (url win, url new_u, bool focus) = 0;
  virtual  void switch_to_buffer (url name) = 0;
  virtual  void focus_on_editor (editor ed) = 0;
  virtual  bool focus_on_buffer (url name) = 0;
  
  // windows
  
  virtual  array<url> windows_list () = 0;
  virtual  array<url> buffer_to_windows (url name) = 0;
  virtual  int  get_nr_windows () = 0;
  virtual  bool has_current_window () = 0;
  virtual  url  get_current_window () = 0;
  virtual  url  window_to_buffer (url win) = 0;
  virtual  void window_set_buffer (url win, url name) = 0;
  virtual  void window_focus (url win) = 0;
  
  virtual  url  create_buffer () = 0;
  virtual  void create_buffer (url name, tree doc) = 0;
  virtual  url  open_window (tree geom= "") = 0;
  virtual  void clone_window () = 0;
  virtual  void kill_buffer (url name) = 0;
  virtual  void kill_window (url name) = 0;
  virtual  void kill_current_window_and_buffer () = 0;

  // miscellaneous routines
  
  virtual void   style_clear_cache () = 0;
  virtual void   refresh () = 0;
  virtual void   interpose_handler () = 0;
  virtual void   wait_handler (string message, string arg) = 0;
  virtual void   set_script_status (int i) = 0;
  virtual void   set_printing_command (string s) = 0;
  virtual void   set_printer_page_type (string s) = 0;
  virtual string get_printer_page_type () = 0;
  virtual void   set_printer_dpi (string dpi) = 0;
  virtual void   set_default_zoom_factor (double zoom) = 0;
  virtual double get_default_zoom_factor () = 0;
  virtual void   inclusions_gc (string which= "*") = 0;
  virtual void   typeset_update (path p) = 0;
  virtual void   typeset_update_all () = 0;
  virtual bool   is_yes (string s) = 0;
  virtual void   quit () = 0;
  virtual void   shell (string s) = 0;
  
  // the following routines should maybe be removed from the server interface
  
  virtual tree   latex_expand (tree doc) = 0;
  virtual tree   latex_expand (tree doc, url name) = 0;
  
  virtual tree   load_inclusion (url name) = 0;
  virtual widget texmacs_input_widget (tree doc, tree style, url wname) = 0;
  
};

class server {
  ABSTRACT(server);
  server ();
};
ABSTRACT_CODE(server);


// the following are needed in the scheme interface (but not in editor)
server get_server ();
bool in_rescue_mode ();
void gui_set_output_language (string lan);



#endif // defined SERVER_H
