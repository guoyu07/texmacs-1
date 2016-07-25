
/******************************************************************************
* MODULE     : tm_window.hpp
* DESCRIPTION: TeXmacs main data structures (buffers, views and windows)
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef TM_WINDOW_H
#define TM_WINDOW_H
#include "server.hpp"
#include "editor.hpp"
#include "tm_buffer.hpp"
#include "tm_server.hpp"

class tm_window_rep {
public:
  tm_server_windows_rep *sv;
  widget win;
  widget wid;
  url    id;

public:
  hashmap<tree,tree> props;
  int                serial;
  double             zoomf;       // the zoom factor

protected:
  hashmap<int,object>    menu_current;
  hashmap<object,widget> menu_cache;
  string*  text_ptr;  // where the interactive string is returned
  command  call_back; // called when typing finished
  string   cur_title; // current window title

public:
  tm_window_rep (tm_server_windows_rep *sv2, widget wid2, tree geom);
  tm_window_rep (tm_server_windows_rep *sv2, tree doc, command quit);
  ~tm_window_rep ();
  void set_window_name (string s);
  void set_modified (bool flag);
  void set_window_url (url u);
  void map ();
  void unmap ();
  void refresh ();
  inline void set_property (scheme_tree what, scheme_tree val) {
    props (what)= val; }
  inline scheme_tree get_property (scheme_tree what) {
    return props [what]; }

  bool get_menu_widget (int which, string menu, widget& w);
  void menu_main (string menu);
  void update_menus ();
  void menu_icons (int which, string menu);
  void side_tools (int which, string tools);
  void bottom_tools (int which, string tools);
  void set_header_flag (bool flag);
  void set_icon_bar_flag (int which, bool flag);
  void set_side_tools_flag (int which, bool flag);
  void set_bottom_tools_flag (int which, bool flag);
  bool get_header_flag ();
  bool get_icon_bar_flag (int which);
  bool get_side_tools_flag (int which);
  bool get_bottom_tools_flag (int which);

  double get_window_zoom_factor ();
  void set_window_zoom_factor (double zoom);
  void get_visible (SI& x1, SI& y1, SI& x2, SI& y2);
  void get_extents (SI& x1, SI& y1, SI& x2, SI& y2);
  void set_extents (SI x1, SI y1, SI x2, SI y2);
  void set_scrollbars (int i);
  void get_scroll_pos (SI& x, SI& y);
  void set_scroll_pos (SI x, SI y);

  bool get_footer_flag ();
  void set_footer_flag (bool on);
  void set_footer (string l, string r);
  bool get_interactive_mode ();
  void set_interactive_mode (bool on);
  void interactive (string name, string type, array<string> def,
		    string& s, command cmd);
  void interactive_return ();
};

typedef tm_window_rep* tm_window;

class tm_view_rep {
public:
  tm_buffer buf;
  editor    ed;
  tm_window win;
  int       nr;
  tm_view_rep (tm_buffer buf2, editor ed2);
};

widget texmacs_output_widget (tree doc, tree style);
//widget texmacs_input_widget (tree doc, tree style, url wname);

int window_handle ();
void window_create (int win, widget wid, string name, bool plain);
void window_create (int win, widget wid, string name, command quit);
void window_delete (int win);
void window_show (int win);
void window_hide (int win);
scheme_tree window_get_size (int win);
void window_set_size (int win, int w, int h);
scheme_tree window_get_position (int win);
void window_set_position (int win, int x, int y);
void windows_refresh (string kind= "auto");

#endif // defined TM_WINDOW_H
