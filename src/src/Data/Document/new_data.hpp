
/******************************************************************************
* MODULE     : new_data.hpp
* DESCRIPTION: Data attached to full buffers which are not necessarily
*              well represented by trees
* COPYRIGHT  : (C) 1999-2012  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NEW_DATA_H
#define NEW_DATA_H
#include "tree.hpp"
#include "hashmap.hpp"

class new_data;
class new_data_rep : public tm_obj<new_data_rep>  {
public:
  tree project;               // a project the document belongs to
  tree style;                 // the style of the buffer
  hashmap<string,tree> init;  // initial values of environment variables
  hashmap<string,tree> fin;   // final values of environment variables
  hashmap<string,tree> ref;   // all labels with references
  hashmap<string,tree> aux;   // auxiliary output: toc, bib, etc.
  hashmap<string,tree> att;   // attachments: LaTeX source, etc.

  inline new_data_rep ():
    project (""), style (tuple ("generic")),
    init ("?"), fin ("?"), ref ("?"), aux ("?"), att ("?") {}
};

class new_data : public tm_ptr<new_data_rep> {
public:
  inline new_data () : tm_ptr<new_data_rep> (tm_new<new_data_rep> ()) {}
};

tree attach_data (tree body, new_data data, bool no_aux= false);
tree detach_data (tree doc, new_data& data);

#endif // NEW_DATA_H
