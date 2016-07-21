
/******************************************************************************
* MODULE     : ns_utilities.mm
* DESCRIPTION: Utilities for Aqua
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "ns_utilities.h"
#include "dictionary.hpp"
#include "converter.hpp"
#include "analyze.hpp"
#include "colors.hpp" 

NSRect to_nsrect (coord4 p)
{
	float c = 1.0/PIXEL;
	return NSMakeRect(p.x1*c, -p.x4*c, (p.x3-p.x1)*c, (p.x4-p.x2)*c);
}

NSPoint to_nspoint (coord2 p)
{
	float c = 1.0/PIXEL;
	return NSMakePoint(p.x1*c,-p.x2*c);
}

NSSize to_nssize (coord2 p)
{
	float c = 1.0/PIXEL;
	return NSMakeSize(p.x1*c,p.x2*c);
}

coord4 from_nsrect (NSRect rect)
{
	SI c1, c2, c3, c4;
  c1= rect.origin.x * PIXEL;
  c2= -(rect.origin.y + rect.size.height) * PIXEL;
  c3= (rect.origin.x + rect.size.width) * PIXEL;
  c4= -rect.origin.y * PIXEL;
	return coord4 (c1, c2, c3, c4);
}

coord2 from_nspoint(NSPoint pt)
{
	SI c1, c2;
	c1 = pt.x*PIXEL;
	c2 = -pt.y*PIXEL;
	return coord2 (c1,c2)	;
}

coord2 from_nssize(NSSize s)
{
	SI c1, c2;
	c1 = s.width*PIXEL;
	c2 = s.height*PIXEL;
	return coord2 (c1,c2)	;
}


NSColor *to_nscolor(color c) {
  int r, g, b, a;
  get_rgb_color (c, r, g, b, a);
  if (get_reverse_colors ()) reverse (r, g, b);
  return [NSColor colorWithDeviceRed: r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

color to_color (NSColor *c) {
    float rr, gg, bb, aa;
    [c getRed:&rr green:&gg blue:&bb alpha:&aa];
    int r = rr*255.0, g=gg*255.0, b=bb*255.0, a=aa*255.0;
    if (get_reverse_colors ()) reverse (r, g, b);
    return rgb_color (r, g, b, a);
}

NSString *to_nsstring(string s)
{
	c_string p = c_string (s);
	NSString *nss = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
	return nss;
}

string from_nsstring(NSString *s)
{
	const char *cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
	return utf8_to_cork(string((char*)cstr));
}


NSString *to_nsstring_utf8(string s)
{
  s = cork_to_utf8 (s);
  c_string p = c_string (s);
  NSString *nss = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
  return nss;
}

string
ns_translate (string s) {
  string in_lan= get_input_language ();
  string out_lan= get_output_language ();
  return tm_var_encode (translate (s, in_lan, out_lan));
}

