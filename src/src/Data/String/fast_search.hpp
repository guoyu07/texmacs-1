
/******************************************************************************
* MODULE     : fast_search.hpp
* DESCRIPTION: Fast multiple searches in same string
* COPYRIGHT  : (C) 2014  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "string.hpp"
#include "array.hpp"
#include "hashmap.hpp"

#ifndef FAST_SEARCH_H
#define FAST_SEARCH_H

class string_searcher;
class string_searcher_rep: public tm_obj<string_searcher_rep> {
  string s;
  array<hashmap<int,array<int> > > a;
  array<int> search_sub (string what);

public:
  string_searcher_rep (string s);
  string get_string ();
  int search_next (string what, int pos);
  array<int> search_all (string what);
  friend class string_searcher;
  friend void get_longest_common (string s1, string s2,
                                  int& b1, int& e1, int& b2, int& e2);
};

class string_searcher : public tm_ptr<string_searcher_rep> {
public:
  inline string_searcher (): tm_ptr<string_searcher_rep> (tm_new<string_searcher_rep> ("")) {}
  inline string_searcher (string s): tm_ptr<string_searcher_rep> (tm_new<string_searcher_rep> (s)) {}
};

void get_longest_common (string s1, string s2,
                         int& b1, int& e1, int& b2, int& e2);

#endif // FAST_SEARCH_H
