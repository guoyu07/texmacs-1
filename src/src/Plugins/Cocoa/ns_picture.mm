
/******************************************************************************
* MODULE     : ns_picture.mm
* DESCRIPTION: NS pictures
* COPYRIGHT  : (C) 2013 Massimiliano Gubinelli, Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "analyze.hpp"
#include "image_files.hpp"
#include "file.hpp"
#include "image_files.hpp"
#include "scheme.hpp"
//#include "frame.hpp"
#include "colors.hpp"

#include "ns_picture.h"
#include "ns_utilities.h"

// from https://www.mikeash.com/pyblog/friday-qa-2012-08-31-obtaining-and-interpreting-image-data.html

NSBitmapImageRep *ImageRepFromImage(NSImage *image)
{
  int width = [image size].width;
  int height = [image size].height;
  
  if(width < 1 || height < 1)
    return nil;
  
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                           initWithBitmapDataPlanes: NULL
                           pixelsWide: width
                           pixelsHigh: height
                           bitsPerSample: 8
                           samplesPerPixel: 4
                           hasAlpha: YES
                           isPlanar: NO
                           colorSpaceName: NSCalibratedRGBColorSpace
                           bytesPerRow: width * 4
                           bitsPerPixel: 32];
  
  NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: ctx];
  [image drawAtPoint: NSZeroPoint fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];
  [ctx flushGraphics];
  [NSGraphicsContext restoreGraphicsState];
  
  return rep;
}

/*
 struct Pixel { uint8_t r, g, b, a; };
struct Pixel *pixels = (struct Pixel *)[rep bitmapData];
 int index = x + y * width;
 NSLog(@"Pixel at %d, %d: R=%u G=%u B=%u A=%u",
 x, y
 pixels[index].r,
 pixels[index].g,
 pixels[index].b,
 pixels[index].a);
 */

/******************************************************************************
* Abstract NS pictures
******************************************************************************/

ns_picture_rep::ns_picture_rep (NSImage* im, int ox2, int oy2):
  image (im), rep(nil), w ([im size].width), h ([im size].height), ox (ox2), oy (oy2) {
    [image retain];
    rep = [ImageRepFromImage (image) retain];
  }

ns_picture_rep::~ns_picture_rep () {
  [image release]; [rep release];
}

picture_kind ns_picture_rep::get_type () { return picture_native; }
void* ns_picture_rep::get_handle () { return (void*) this; }

int ns_picture_rep::get_width () { return w; }
int ns_picture_rep::get_height () { return h; }
int ns_picture_rep::get_origin_x () { return ox; }
int ns_picture_rep::get_origin_y () { return oy; }
void ns_picture_rep::set_origin (int ox2, int oy2) { ox= ox2; oy= oy2; }

color
ns_picture_rep::internal_get_pixel (int x, int y) {
  struct Pixel { uint8_t r, g, b, a; };
  struct Pixel *pixels = (struct Pixel *)[rep bitmapData];
  int index = x + (h - 1 - y) * w;

  Pixel& pixel = pixels[index];
  return rgb_color (pixel.r, pixel.g, pixel.b, pixel.a);
}

void
ns_picture_rep::internal_set_pixel (int x, int y, color c) {
  struct Pixel { uint8_t r, g, b, a; };
  struct Pixel *pixels = (struct Pixel *)[rep bitmapData];
  int index = x + (h - 1 - y) * w;

  int r,g,b,a;
  get_rgb_color (c, r, g, b, a);
  Pixel pixel = { r, g, b, a};
  *(pixels + index) = pixel;
}

picture
ns_picture (NSImage* im, int ox, int oy) {
  return (picture) tm_new<ns_picture_rep> (im, ox, oy);
}

picture
as_ns_picture (picture pic) {
  if (pic->get_type () == picture_native) {
    return pic;
  } else {
    NSImage* img = [[[NSImage alloc] initWithSize: NSMakeSize(pic->get_width(), pic->get_height())] autorelease];
    picture ret= ns_picture (img, pic->get_origin_x (), pic->get_origin_y ());
    ret->copy_from (pic);
    return ret;
  }
}

picture
as_native_picture (picture pict) {
  return as_ns_picture (pict);
}

NSImage*
xpm_image (url file_name) {
  picture p = load_xpm (file_name);
  NSImage* img = [[[NSImage alloc] init] autorelease];
  [img addRepresentation: ((ns_picture_rep*) p->get_handle ())->rep];
  return img;
}

picture
native_picture (int w, int h, int ox, int oy) {
  NSImage* img = [[[NSImage alloc] initWithSize: NSMakeSize(w, h)] autorelease];
  return ns_picture (img, ox, oy);
}

void
ns_renderer_rep::draw_picture (picture p, SI x, SI y, int alpha) {
  p= as_ns_picture (p);
  ns_picture_rep* pict= ((ns_picture_rep*) p->get_handle ());
  int x0= pict->ox, y0= pict->h - 1 - pict->oy;
  decode (x, y);
  ensure_context ();
  NSRect r = NSMakeRect(x - x0, y - y0, pict->get_width(), pict->get_height());
  NSRect r0 = NSMakeRect(0, 0, pict->get_width(), pict->get_height());
  [pict->rep drawInRect: r fromRect: r0 operation: NSCompositeSourceOver fraction: alpha/255.0 respectFlipped:YES hints:nil];
}

/******************************************************************************
* Rendering on images
******************************************************************************/

ns_image_renderer_rep::ns_image_renderer_rep (picture p, double zoom):
  ns_renderer_rep (p->get_width(), p->get_height()), pict (p)
{
  zoomf  = zoom;
  shrinkf= (int) tm_round (std_shrinkf / zoomf);
  pixel  = (SI)  tm_round ((std_shrinkf * PIXEL) / zoomf);
  thicken= (shrinkf >> 1) * PIXEL;

  int pw = p->get_width ();
  int ph = p->get_height ();
  int pox= p->get_origin_x ();
  int poy= p->get_origin_y ();

  ox = pox * pixel;
  oy = poy * pixel;
  cx1= 0;
  cy1= 0;
  cx2= pw * pixel;
  cy2= ph * pixel;

  ns_picture_rep* handle= (ns_picture_rep*) pict->get_handle ();
  NSBitmapImageRep* im  = handle->rep;
  NSGraphicsContext* cntx = [NSGraphicsContext graphicsContextWithBitmapImageRep: im];
  begin (cntx);
#if 0
  im.fill (QColor (0, 0, 0, 0));
#endif
}

ns_image_renderer_rep::~ns_image_renderer_rep () {
  end ();
}

void
ns_image_renderer_rep::set_zoom_factor (double zoom) {
  renderer_rep::set_zoom_factor (zoom);
}

void*
ns_image_renderer_rep::get_data_handle () {
  return (void*) this;
}

renderer
picture_renderer (picture p, double zoomf) {
  return (renderer) tm_new<ns_image_renderer_rep> (p, zoomf);
}

/******************************************************************************
* Loading pictures
******************************************************************************/

NSString*
utf8_to_nsstring (const string& s) {
  c_string p (s);
  NSString* nss= [[[NSString alloc] initWithBytes: p length: N(s) encoding: NSUTF8StringEncoding] autorelease];
  return nss;
}

bool
ns_supports (url u) {
  static NSArray<NSString *>* formats = nil;
  if (!formats) formats = [NSImage imageFileTypes];
  string suf=suffix (u);
  bool ans = [formats containsObject: to_nsstring(suf)];
  //if (DEBUG_CONVERT) {debug_convert <<"QT valid format:"<<((ans)?"yes":"no")<<LF;}
  return ans;
}

bool
qt_image_size (url image, int& w, int& h) {// w, h in points
  if (DEBUG_CONVERT) debug_convert << "qt_image_size :" <<LF;
  NSImage* img = [[NSImage alloc] initWithContentsOfFile: utf8_to_nsstring (concretize (image))];
  if (![img isValid]) {
    convert_error << "Cannot read image file '" << image << "'"
    << " in qt_image_size" << LF;
    w= 35; h= 35;
    return false;
  }
  else {
    NSSize sz = [img size];
    w= sz.width; // (sz.width*2834)/im.dotsPerMeterX();
    h= sz.height; // (sz.height*2834)/im.dotsPerMeterY();
    if (DEBUG_CONVERT) debug_convert <<"QT dotsPerMeter: "
      <<w<<" x "<<h<<LF;
    return true;
  }
}

NSImage*
get_image (url u, int w, int h) {
  
  NSImage* img = nil;
  if (ns_supports (u))
    img = [[NSImage alloc] initWithContentsOfFile: utf8_to_nsstring (concretize (u))];
  else {
    url temp= url_temp (".png");
    image_to_png (u, temp, w, h);
    img = [[NSImage alloc] initWithContentsOfFile: utf8_to_nsstring (concretize (temp))];
    remove (temp);
  }
  if (![img isValid]) {
      cout << "TeXmacs] warning: cannot render " << concretize (u) << "\n";
      return nil;
  }
  NSSize sz = [img size];
  if (sz.width != w || sz.height != h) {
    NSImage *img2 = [[[NSImage alloc] initWithSize: NSMakeSize(w, h)] autorelease];
    [img2 lockFocus];
    [img drawInRect: NSMakeRect(0, 0, w, h) fromRect: NSMakeRect(0, 0, sz.width
                                                                 , sz.height) operation: NSCompositeCopy  fraction: 1.0];
    [img2 unlockFocus];
    img = img2;
  }
  return img;
}

picture
load_picture (url u, int w, int h) {
  NSImage* im= get_image (u, w, h);
  if (im == nil) return error_picture (w, h);
  return ns_picture (im, 0, 0);
}

picture
ns_load_xpm (url file_name) {
  string sss;
  if (retina_icons > 1 && suffix (file_name) == "xpm") {
    url png_equiv= glue (unglue (file_name, 4), "_x2.png");
    load_string ("$TEXMACS_PIXMAP_PATH" * png_equiv, sss, false);
  }
  if (sss == "" && suffix (file_name) == "xpm") {
    url png_equiv= glue (unglue (file_name, 3), "png");
    load_string ("$TEXMACS_PIXMAP_PATH" * png_equiv, sss, false);
  }
  if (sss == "")
    load_string ("$TEXMACS_PIXMAP_PATH" * file_name, sss, false);
  if (sss == "")
    load_string ("$TEXMACS_PATH/misc/pixmaps/TeXmacs.xpm", sss, true);
  c_string buf (sss);
  NSData* data = [[NSData dataWithBytes: buf length: N(sss)] autorelease];
  NSImage* img = [[[NSImage alloc] initWithData: data] autorelease];
  return ns_picture (img, 0, 0);
}


