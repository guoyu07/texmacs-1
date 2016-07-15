
/******************************************************************************
* MODULE     : TMView.h
* DESCRIPTION: Main TeXmacs view
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "mac_cocoa.h"
#include "ns_widget.h"

class ns_simple_widget_rep;

@interface TMView : NSView  <NSTextInput>
{
  ns_simple_widget_rep *wid;
  NSString *workingText;
  BOOL processingCompose;
  NSMutableArray *delayed_rects;
}
- (void) setWidget:(ns_simple_widget_rep*) w;
- (ns_simple_widget_rep*) widget;
- (void) deleteWorkingText;
@end

// centering view from
// http://bergdesign.com/developer/index_files/88a764e343ce7190c4372d1425b3b6a3-0.html

@interface TMCenteringClipView : NSClipView
{
  NSPoint _lookingAt; // the proportion up and across the view, not coordinates.
}

-(void)centerDocument;

@end