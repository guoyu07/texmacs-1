
/******************************************************************************
* MODULE     : tm_server_windows.hpp
* DESCRIPTION: Window management
* COPYRIGHT  : (C) 1999-2012  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NEW_WINDOW_H
#define NEW_WINDOW_H
#include "tree.hpp"
#include "url.hpp"
#include "tm_server_views.hpp"


/******************************************************************************
 * Manage global list of windows
 ******************************************************************************/

extern int nr_windows;

class tm_window_rep;
typedef tm_window_rep* tm_window;


class tm_server_windows_rep: virtual public tm_server_views_rep {
  
  int last_window= 1;
  array<url> all_windows;
  
  hashmap<url,tm_window> tm_window_table;

protected:

  tm_server_windows_rep () :last_window (1), all_windows (), tm_window_table (NULL) {};
  ~tm_server_windows_rep () {};
  
  // Low level types and routines
  tm_window concrete_window ();
  tm_window concrete_window (url win);
  url       abstract_window (tm_window win);

public:
  
  array<url> windows_list ();
  array<url> buffer_to_windows (url name);
  int  get_nr_windows ();
  bool has_current_window ();
  url  get_current_window ();
  url  window_to_buffer (url win);
  void window_set_buffer (url win, url name);
  void window_focus (url win);
  
  url new_buffer_in_new_window (url name, tree t, tree geom= "");

  url  create_buffer ();
  void create_buffer (url name, tree doc);
  url  open_window (tree geom= "");
  void clone_window ();
  void kill_buffer (url name);
  void kill_window (url name);
  void kill_current_window_and_buffer ();

protected:

  url create_window_id ();
  void destroy_window_id (url win);

private:
  
  url new_window (bool map_flag= true, tree geom= "");
  bool delete_view_from_window (url win);
  void delete_window (url win_u);
  void new_buffer_in_this_window (url name, tree doc);
  
  
  friend class tm_window_rep;
};

#endif // defined NEW_WINDOW_H
