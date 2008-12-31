/*
 * "$Id: image.h 1526 2008-01-06 01:55:59Z mike $"
 *
 *   Image management definitions for HTMLDOC, a HTML document processing
 *   program.
 *
 *   Copyright 1997-2005 by Easy Software Products.
 *
 *   These coded instructions, statements, and computer programs are the
 *   property of Easy Software Products and are protected by Federal
 *   copyright law.  Distribution and use rights are outlined in the file
 *   "COPYING.txt" which should have been included with this file.  If this
 *   file is missing or damaged please contact Easy Software Products
 *   at:
 *
 *       Attn: HTMLDOC Licensing Information
 *       Easy Software Products
 *       516 Rio Grand Ct
 *       Morgan Hill, CA 95037 USA
 *
 *       http://www.htmldoc.org/
 */

#ifndef _IMAGE_H_
#  define _IMAGE_H_

/*
 * Include necessary headers.
 */

#  include <stdio.h>
#  include <stdlib.h>
#  include "hdstring.h"

#  include "types.h"

#  ifdef __cplusplus
extern "C" {
#  endif /* __cplusplus */


/*
 * Image structure...
 */

typedef struct				/**** Image structure ****/
{
  char		filename[1024];		/* Name of image file (for caching of images */
  int		width,			/* Width of image in pixels */
		height,			/* Height of image in pixels */
		depth,			/* 1 for grayscale, 3 for RGB */
		use,			/* Number of times this image was used */
		obj;			/* Object number */
  hdChar	*pixels;		/* 8-bit pixel data */
  hdChar	*mask;			/* 1-bit mask data, if any */
  int		maskwidth,		/* Byte width of mask data */
		maskscale;		/* Scaling of mask data */
} hdImage;


/*
 * Prototypes...
 */

extern void	image_copy(const char *src, const char *realsrc,
		           const char *destpath);
extern hdImage	*image_find(const char *filename, int load_data = 0);
extern void	image_flush_cache(void);
extern int	image_getlist(hdImage ***ptrs);
extern hdImage	*image_load(const char *filename, int gray, int load_data = 0);
extern void	image_unload(hdImage *img);

#  ifdef __cplusplus
}
#  endif /* __cplusplus */

#endif /* !_IMAGE_H_ */

/*
 * End of "$Id: image.h 1526 2008-01-06 01:55:59Z mike $".
 */
