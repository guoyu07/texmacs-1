
/******************************************************************************
 * MODULE     : buffer.hpp
 * DESCRIPTION: basic buffers and file related informations about buffers
 * COPYRIGHT  : (C) 1999-2012  Joris van der Hoeven
 *******************************************************************************
 * This software falls under the GNU general public license version 3 or later.
 * It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
 * in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
 ******************************************************************************/

#ifndef ABS_BUFFER_HPP
#define ABS_BUFFER_HPP

#include "new_document.hpp"
#include "new_data.hpp"

/******************************************************************************
 * file related information about buffers
 ******************************************************************************/

class buffer_info;
class buffer_info_rep: public concrete_struct {
public:
  url name;               // full name
  url master;             // base name for linking and navigation
  string fm;              // buffer format
  string title;           // buffer title (for menus)
  bool read_only;         // buffer is read only?
  bool secure;            // is the buffer secure?
  int last_save;          // last time that the buffer was saved
  time_t last_visit;      // time that the buffer was visited last
  
  inline buffer_info_rep (url name2):
  name (name2), master (name2),
  fm ("texmacs"), title (as_string (tail (name))),
  read_only (false), secure (is_secure (name2)),
  last_save (- (int) (((unsigned int) (-1)) >> 1)),
  last_visit (texmacs_time ()) {}
};

class buffer_info;
class buffer_info {
  CONCRETE(buffer_info);
  inline buffer_info (url name): rep (tm_new<buffer_info_rep> (name)) {}
};

CONCRETE_CODE(buffer_info);

/******************************************************************************
 * The abstract buffer class
 ******************************************************************************/

class buffer_rep;
typedef buffer_rep *buffer;

// abstract buffers

class buffer_rep {
public:
  buffer_info buf;       // file related information
  new_data data;         // data associated to document
  buffer prj;            // buffer which corresponds to the project
  path rp;               // path to the document's root in the_et

  inline buffer_rep (url name):
  buf (name), data (), prj (NULL), rp (new_document ())  {}
  
  virtual ~buffer_rep () { }
};


#endif /* ABS_BUFFER_HPP */
