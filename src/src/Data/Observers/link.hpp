
/******************************************************************************
* MODULE     : link.cpp
* DESCRIPTION: Linking of trees
* COPYRIGHT  : (C) 2006  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef LINK_H
#define LINK_H
#include "tree.hpp"
#include "list.hpp"
#include "hashmap.hpp"

/******************************************************************************
* The soft_link class
******************************************************************************/

class soft_link;
class soft_link_rep: public tm_obj<soft_link_rep> {
public:
  tree t;

public:
  inline soft_link_rep (tree t2): t (t2) {}
  inline ~soft_link_rep () {}

  friend class soft_link;
};

class soft_link : public tm_ptr<soft_link_rep> {
public:
  inline soft_link (tree t):
    tm_ptr<soft_link_rep> (tm_new<soft_link_rep> (t)) {}
  inline friend bool operator == (soft_link ln1, soft_link ln2) {
    return ln1.rep() == ln2.rep(); }
  inline friend bool operator != (soft_link ln1, soft_link ln2) {
    return ln1.rep() != ln2.rep(); }
  inline friend tm_ostream& operator << (tm_ostream& out, soft_link ln) {
    return out << "soft_link (" << ln.rep() << ")"; }
};

/******************************************************************************
* Link repositories
******************************************************************************/

class link_repository_rep: public tm_obj<link_repository_rep> {
public:
  list<string> ids;
  list<observer> loci;
  list<soft_link> links;
  link_repository_rep ();
  ~link_repository_rep ();
  void insert_locus (string id, tree t);
  void insert_locus (string id, tree t, string cb);
  void insert_link (soft_link ln);
};

class link_repository : public tm_abs_null_ptr<link_repository_rep> {
public:
  link_repository(link_repository_rep* p=NULL) : tm_abs_null_ptr<link_repository_rep>(p) {}
  inline link_repository (bool active) :
    tm_abs_null_ptr<link_repository_rep>  (tm_new<link_repository_rep> ()) { (void) active; }
};

/******************************************************************************
* Routines for navigation
******************************************************************************/

list<string> get_ids (tree t);
list<tree> get_trees (string id);
list<tree> get_links (tree v);
list<string> all_link_types ();

void set_locus_rendering (string var, string val);
string get_locus_rendering (string var);
void declare_visited (string id);
bool has_been_visited (string id);

#endif // HARD_LINK_H
