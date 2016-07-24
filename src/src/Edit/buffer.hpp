//
//  buffer.hpp
//  TeXmacs
//
//  Created by Massimiliano Gubinelli on 21/07/16.
//  Copyright © 2016 TeXmacs.org. All rights reserved.
//

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
//CONCRETE_CODE(new_buffer);

inline buffer_info::buffer_info (const buffer_info& x):
rep(x.rep) { INC_COUNT (this->rep); }
inline buffer_info::~buffer_info () { DEC_COUNT (this->rep); }
inline buffer_info_rep* buffer_info::operator -> () {
  return rep; }
inline buffer_info& buffer_info::operator = (buffer_info x) {
  INC_COUNT (x.rep); DEC_COUNT (this->rep);
  this->rep=x.rep; return *this; }

/******************************************************************************
 * The abstract buffer class
 ******************************************************************************/

class buffer_rep;
typedef buffer_rep *buffer;

// abstract buffers

class buffer_rep {
public:
  buffer_info buf;         // file related information
  new_data data;          // data associated to document
  buffer prj;         // buffer which corresponds to the project
  path rp;                // path to the document's root in the_et

  inline buffer_rep (url name):
  buf (name), data (), prj (NULL), rp (new_document ())  {}
  
  virtual ~buffer_rep () { }
};


#endif /* ABS_BUFFER_HPP */
