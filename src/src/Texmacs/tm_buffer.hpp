
/******************************************************************************
* MODULE     : tm_buffer.hpp
* DESCRIPTION: TeXmacs main data structures (buffers, views and windows)
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef TM_BUFFER_H
#define TM_BUFFER_H
#include "buffer.hpp"
#include "link.hpp"
#include "new_data.hpp"

class tm_buffer_rep;
class tm_view_rep;
typedef tm_buffer_rep* tm_buffer;
typedef tm_view_rep*   tm_view;

path new_document ();
void delete_document (path rp);
void set_document (path rp, tree t);
url  create_window_id ();
void destroy_window_id (url);

class tm_buffer_rep : public buffer_rep {
public:
  array<tm_view> vws;     // views attached to buffer
  link_repository lns;    // global links
  bool notify;            // notify modifications to scheme

  inline tm_buffer_rep (url name): buffer_rep (name),
    vws (0), notify (false) {}

  virtual ~tm_buffer_rep () { delete_document (rp); }

  void attach_notifier ();
  bool needs_to_be_saved ();
  bool needs_to_be_autosaved ();
};

inline tm_buffer nil_buffer () { return (tm_buffer) NULL; }
inline bool is_nil (tm_buffer buf) { return buf == NULL; }

#endif // defined TM_BUFFER_H
