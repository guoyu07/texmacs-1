
/******************************************************************************
* MODULE     : ns_menu.h
* DESCRIPTION: Aqua menu proxies
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NS_MENU_H
#define NS_MENU_H

#include "ns_widget.h"
#include "promise.hpp"

NSMenu* to_nsmenu(widget w);
NSMenuItem* to_nsmenuitem(widget w);


@interface TMMenuItem : NSMenuItem
{
  command_rep *cmd;
  ns_simple_widget_rep* wid;// an eventual box widget (see tm_button.cpp)
}
- (void)setCommand:(command_rep *)_c;
- (void)setWidget:(ns_simple_widget_rep *)_w;
- (void)doit;
@end

@interface TMLazyMenu : NSMenu <NSMenuDelegate>
{
  promise_rep<widget> *pm;
  BOOL forced;
}
- (void)setPromise:(promise_rep<widget> *)p;
@end


#endif // defined NS_MENU_H
