
/******************************************************************************
* MODULE     : edit_delete.cpp
* DESCRIPTION: treat deletions
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "edit_text.hpp"

/******************************************************************************
* Getting the point where to delete
******************************************************************************/

void
edit_text_rep::get_deletion_point (
  path& p, int& last, int& rix, tree& t, tree& u, bool forward)
{
  // make right-glued positions left-glued
  p= tp;
  if (forward) {
    //cout << HRULE;
    if ((N(p) >= 2) &&
	is_concat (subtree (et, path_up (p, 2))) &&
	(last_item (p) == right_index (subtree (et, path_up (p)))) &&
	(last_item (path_up (p)) < (N (subtree (et, path_up (p, 2))) - 1)))
      {
	p= path_up (p);
	p= path_inc (p) * start (subtree (et, path_inc (p)), path ());
      }
    //cout << "p= " << p << "\n";
  }

  // get the position where to delete
  last= last_item (p);
  p   = path_up (p);
  t   = subtree (et, p);
  rix = right_index (t);
  //cout << "  t   = " << t << "\n";
  //cout << "  last= " << last << "\n";
  //cout << "  rix = " << rix << "\n";
  while (((forward && (last >= rix)) || ((!forward) && (last == 0))) &&
	 (!nil (p)) && is_format (subtree (et, path_up (p))))
    {
      last= last_item (p);
      p   = path_up (p);
      t   = subtree (et, p);
      rix = N(t) - 1;
      //cout << "  t   = " << t << "\n";
      //cout << "  last= " << last << "\n";
      //cout << "  rix = " << rix << "\n";
    }
  if (!nil (p)) u= subtree (et, path_up (p));
}

/******************************************************************************
* Normal deletions
******************************************************************************/

void
edit_text_rep::remove_text (bool forward) {
  path p;
  int  last, rix;
  tree t, u;
  get_deletion_point (p, last, rix, t, u, forward);

  // multiparagraph delete
  if (is_document (t)) {
    if ((forward && (last >= rix)) || ((!forward) && (last == 0))) {
      if (!nil(p)) {
	tree u= subtree (et, path_up (p));
	if (is_func (u, _FLOAT) || is_func (u, WITH) ||
	    is_func (u, STYLE_WITH) || is_func (u, VAR_STYLE_WITH) ||
	    is_extension (u))
	  {
	    if (is_extension (u) && (N(u) > 1)) {
	      int i, n= N(u);
	      bool empty= true;
	      for (i=0; i<n; i++)
		empty= empty && ((u[i]=="") || (u[i]==tree (DOCUMENT, "")));
	      if (!empty) {
		if (forward) {
		  if (last_item (p) == n-1) go_to (end (et, path_up (p)));
		  else go_to (start (et, path_inc (p)));
		}
		else {
		  if (last_item (p) == 0) go_to (start (et, path_up (p)));
		  else go_to (end (et, path_dec (p)));
		}
		return;
	      }
	    }
	    if (t == tree (DOCUMENT, "")) {
	      if (is_func (u, _FLOAT) || is_compound (u, "footnote", 1)) {
		assign (path_up (p), "");
		correct (path_up (p, 2));
	      }
	      else if (is_document (subtree (et, path_up (p, 2))))
		assign (path_up (p), "");
	      else assign (path_up (p), tree (DOCUMENT, ""));
	    }
	    else go_to_border (path_up (p), !forward);
	  }
      }
      return;
    }
    else {
      int l1= forward? last: last-1;
      int l2= forward? last+1: last;
      if (is_multi_paragraph (subtree (et, p * l1)) ||
	  is_multi_paragraph (subtree (et, p * l2)))
	{
	  if (subtree (et, p * l1) == "") remove (p * l1, 1);
	  else {
	    if (subtree (et, p * l2) == "") remove (p * l2, 1);
	    if (!forward) go_to_end (p * l1);
	    else if (last < N (subtree (et, p)) - 1) go_to_start (p * l2);
	  }
	}
      else remove_return (p * l1);
    }
    return;
  }

  // deleting text
  if (forward && is_atomic (t) && (last != rix)) {
    language lan= get_env_language ();
    int end= last;
    if (lan->enc->token_forward (t->label, end))
      fatal_error ("bad cursor position in string",
		   "edit_text_rep::remove_text");
    remove (p * last, end-last);
    correct (path_up (p));
    return;
  }

  if ((!forward) && is_atomic (t) && (last != 0)) {
    language lan= get_env_language ();
    int start= last;
    if (lan->enc->token_backward (t->label, start))
      fatal_error ("bad cursor position in string",
		   "edit_text_rep::remove_text");
    remove (p * start, last-start);
    correct (path_up (p));
    return;
  }

  // deletion governed by parent t
  if (last == (forward? 0: 1))
    switch (L(t)) {
    case RAW_DATA:
    case HSPACE:
    case VAR_VSPACE:
    case VSPACE:
    case SPACE:
    case HTAB:
    case LEFT:
    case MID:
    case RIGHT:
    case BIG:
      back_monolithic (p);
      return;
    case LPRIME:
    case RPRIME:
      back_prime (t, p, forward);
      return;
    case WIDE:
    case VAR_WIDE:
      go_to_border (p * 0, forward);
      return;
    case TFORMAT:
    case TABLE:
    case ROW:
    case CELL:
    case SUBTABLE:
      back_table (p, forward);
      return;
    case WITH:
    case STYLE_WITH:
    case VAR_STYLE_WITH:
      go_to_border (p * (N(t) - 1), forward);
      return;
    case VALUE:
    case QUOTE_VALUE:
    case ARG:
    case QUOTE_ARG:
      if (N(t) == 1) back_monolithic (p);
      else back_general (p, forward);
      return;
    default:
      back_general (p, forward);
      break;
    }

  // deletion depends on children u
  if (last == (forward? rix: 0)) {
    switch (L (u)) {
    case WIDE:
    case VAR_WIDE:
      back_in_wide (u, p, forward);
      return;
    case TREE:
      back_in_tree (u, p, forward);
      return;
    case TFORMAT:
    case TABLE:
    case ROW:
    case CELL:
    case SUBTABLE:
      back_in_table (u, p, forward);
      return;
    case WITH:
    case STYLE_WITH:
    case VAR_STYLE_WITH:
      back_in_with (u, p, forward);
      return;
    default:
      back_in_general (u, p, forward);
      break;
    }
  }
}

/******************************************************************************
* Structured deletions
******************************************************************************/

void
edit_text_rep::remove_structure (bool forward) {
  path p;
  int  last, rix;
  tree t, u;
  get_deletion_point (p, last, rix, t, u, forward);

  // multiparagraph delete
  if (nil (p)) {
    if (forward) {
      if (last >= rix) return;
      remove_return (path (last));
    }
    else {
      if (last == 0) return;
      remove_return (path (last-1));
    }
    return;
  }

  // deleting text
  if (is_atomic (t) && (last != (forward? rix: 0))) {
    language lan= get_env_language ();
    int start= last, end= last, pos;
    string s= t->label;
    while (true) {
      if (forward) {
	pos= start;
	(void) lan->advance (s, pos);
	if (pos <= last) break;
      }
      else {
	int pos= max (start-1, 0);
	(void) lan->advance (s, pos);
	if (pos < last) break;
      }
      end= pos;
      if (start == 0) break;
      start--;
    }
    if (forward) {
      start= min (start+1, last);
      while ((end < N(s)) && (s[end] == ' ')) end++;
    }
    else while ((start>0) && (s[start-1] == ' ')) start--;
    if (end>start) {
      remove (p * start, end-start);
      correct (path_up (p));
    }
    return;
  }

  // deleting structure
  if (forward) {
    if (is_concat (t) && (last < rix)) {
      remove (p * (last+1), 1);
      correct (path_up (p));
    }
    else if (is_compound (t) && (last == 0)) {
      assign (p, "");
      correct (path_up (p));
    }
    else remove_structure_upwards ();
  }
  else {
    if (last==1) {
      if (!is_concat (u)) assign (p, "");
      else remove (p, 1);
      correct (path_up (p));
    }
    else remove_structure_upwards ();
  }
}

/******************************************************************************
* Deletion of an object
******************************************************************************/

void
edit_text_rep::remove_structure_upwards () {
  path p= path_up (tp);
  while ((!nil (p)) && is_format (subtree (et, path_up (p)))) p= path_up (p);
  if (nil (p)) return;
  int last= last_item (p);
  p= path_up (p);
  tree st= subtree (et, p);
  bool recurse=
    is_func (st, TFORMAT) || is_func (st, TABLE) ||
    is_func (st, ROW) || is_func (st, CELL);
  remove (p * (last+1), N(st)-(last+1));
  remove (p * 0, last);

  do {
    rem_unary (p);
    last= last_item (p);
    p= path_up (p);
    st= subtree (et, p);
  } while (is_mod_active_once (st));

  if (is_document (st) && is_document (st[last])) {
    int very_last= 0;
    if ((N(tp) >= N(p)+2) && (tp[N(p)] == last)) very_last= tp[N(p)+1];
    tree left = st[last] (0, very_last);
    tree right= st[last] (very_last+1, N(st[last]));
    remove (p * path (last, very_last+1), N(st[last])- (very_last+1));
    remove (p * path (last, 0), very_last);
    rem_unary (p * last);
    insert (p * (last+1), right);
    insert (p * last, left);
  }
  else correct (p);

  if (recurse) remove_structure_upwards ();
}
