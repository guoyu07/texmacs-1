
/******************************************************************************
* MODULE     : tm_server_buffers.hpp
* DESCRIPTION: File related information for buffers
* COPYRIGHT  : (C) 1999-2012  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NEW_BUFFER_H
#define NEW_BUFFER_H
#include "tree.hpp"
#include "hashmap.hpp"
#include "url.hpp"
#include "timer.hpp"
#include "server.hpp"
#include "new_data.hpp"

class tm_buffer_rep;
typedef tm_buffer_rep* tm_buffer;
class tm_view_rep;
typedef tm_view_rep* tm_view;
class tm_window_rep;
typedef tm_window_rep* tm_window;


class tm_server_buffers_rep: virtual public server_rep {
  
  /******************************************************************************
  * Low level types and routines
  ******************************************************************************/

protected:
  
  array<tm_buffer> bufs;
  
  tm_buffer concrete_buffer (url name);
  tm_buffer concrete_buffer_insist (url name);
  
  tm_server_buffers_rep () : bufs(), document_inclusions("") {};
  ~tm_server_buffers_rep () {};
  
  
  // implementation of the following pure functions depends on further data
  // we postpone them to concrete subclasses
  
  virtual tm_view   concrete_view (url name) = 0;
  virtual url       abstract_view (tm_view vw) = 0;
  virtual tm_window concrete_window () = 0;
  virtual tm_window concrete_window (url win) = 0;
  virtual url       abstract_window (tm_window win) = 0;


  
  /******************************************************************************
  * High level routines
  ******************************************************************************/
  
public:

  url new_buffer_in_new_window (url name, tree t, tree geom= "") = 0;

  array<url> get_all_buffers ();
  url  make_new_buffer ();
  void remove_buffer (url name);
  int  number_buffers ();
  url  get_current_buffer ();
  url  get_current_buffer_safe ();
  url  path_to_buffer (path p);
  void rename_buffer (url name, url new_name);
  url get_master_buffer (url name);
  void set_master_buffer (url name, url master);
  void set_title_buffer (url name, string title);
  string get_title_buffer (url name);
  void set_buffer_tree (url name, tree doc);
  tree get_buffer_tree (url name);
  void set_buffer_body (url name, tree body);
  tree get_buffer_body (url name);
  int  get_last_save_buffer (url name);
  void set_last_save_buffer (url name, int t);
  bool is_aux_buffer (url name);
  double last_visited (url name);
  bool buffer_modified (url name);
  bool buffer_modified_since_autosave (url name);
  void pretend_buffer_modified (url name);
  void pretend_buffer_saved (url name);
  void pretend_buffer_autosaved (url name);
  void attach_buffer_notifier (url name);
  bool buffer_has_name (url name);
  bool buffer_import (url name, url src, string fm);
  bool buffer_load (url name);
  bool buffer_export (url name, url dest, string fm);
  bool buffer_save (url name);
  tree import_loaded_tree (string s, url u, string fm);
  tree import_tree (url u, string fm);
  bool export_tree (tree doc, url u, string fm);
  tree load_style_tree (string package);
  
  // projects
  
  void project_attach (string prj_name= "");
  bool project_attached ();
  url  project_get ();

  
  // latex
  
  tree latex_expand (tree doc);
  tree latex_expand (tree doc, url name);

  /******************************************************************************
   * internal routines
   ******************************************************************************/

private:
  void insert_buffer (url name);
  void remove_buffer (tm_buffer buf);
  string propose_title (string old_title, url u, tree doc);
  void set_buffer_data (url name, new_data data);
  
  bool is_implicit_project (tm_buffer buf);
  
  /******************************************************************************
   * Loading inclusions
   ******************************************************************************/

  hashmap<string,tree> document_inclusions;

public:
  tree load_inclusion (url name);

protected:
  void reset_inclusions ();
  void reset_inclusion (url name);
};

#endif // NEW_BUFFER_H
