/*
 * "$Id: file.h,v 1.6.2.13 2005/11/03 21:10:24 mike Exp $"
 *
 *   Filename definitions for HTMLDOC, a HTML document processing program.
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

#ifndef _FILE_H_
#  define _FILE_H_

/*
 * Include necessary headers...
 */

#  include "hdstring.h"

#  ifdef __cplusplus
extern "C" {
#  endif /* __cplusplus */


/*
 * Prototypes...
 */

extern const char	*file_basename(const char *s);
extern void		file_cleanup(void);
extern void		file_cookies(const char *s);
extern const char	*file_directory(const char *s);
extern const char	*file_extension(const char *s);
extern const char	*file_find(const char *path, const char *s);
extern char		*file_gets(char *buf, int buflen, FILE *fp);
extern const char	*file_localize(const char *filename, const char *newcwd);
extern const char	*file_method(const char *s);
extern void		file_nolocal();
extern void		file_proxy(const char *url);
extern void		file_referer(const char *referer);
extern const char	*file_rlookup(const char *filename);
extern const char	*file_target(const char *s);
extern FILE		*file_temp(char *name, int len);

#  ifdef __cplusplus
}
#  endif /* __cplusplus */

#endif /* !_FILE_H_ */

/*
 * End of "$Id: file.h,v 1.6.2.13 2005/11/03 21:10:24 mike Exp $".
 */
