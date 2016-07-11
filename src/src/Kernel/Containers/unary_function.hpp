
/******************************************************************************
* MODULE     : unary_function.hpp
* DESCRIPTION: unary functions
* COPYRIGHT  : (C) 2013  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef UNARY_FUNCTION_H
#define UNARY_FUNCTION_H
#include "tree.hpp"

#define TMPL template<typename T, typename S>

class tree;
TMPL class unary_function_rep;
TMPL class unary_function;
TMPL bool is_nil (unary_function<T,S> l);

TMPL
class unary_function_rep: public tm_obj<unary_function_rep<T,S> > {
public:
  inline unary_function_rep () {}
  inline virtual ~unary_function_rep () {}
  virtual T eval (const S& arg) = 0;
};

TMPL
class unary_function : public tm_null_ptr<unary_function_rep<T,S> > {
public:
  unary_function<T,S> (unary_function_rep<T,S>* p=NULL) : tm_null_ptr<unary_function_rep<T,S> > (p) {};
  inline T operator () (const S& arg);
};

TMPL inline T unary_function<T,S>::operator () (const S& arg) {
  return this->rep()->eval (arg); }

TMPL inline bool
operator == (unary_function<T,S> mw1, unary_function<T,S> mw2) {
  return mw1.rep == mw2.rep; }

#undef TMPL

#endif // defined UNARY_FUNCTION_H
