/*
 * "$Id: config.h 1563 2008-05-29 21:46:19Z mike $"
 *
 *   Configuration file for HTMLDOC.
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
 *       Attn: ESP Licensing Information
 *       Easy Software Products
 *       44141 Airport View Drive, Suite 204
 *       Hollywood, Maryland 20636-3142 USA
 *
 *       Voice: (301) 373-9600
 *       EMail: info@easysw.com
 *         WWW: http://www.easysw.com
 */

/*
 * What is the version number for this software?
 */

#define SVERSION	"1.9-current"


/*
 * Limits for the output "engines"...
 */

#define MAX_CHAPTERS	1000	/* Maximum number of chapters or files */
#define MAX_COLUMNS	200	/* Maximum number of columns in a table */
#define MAX_HF_IMAGES	10	/* Maximum number of header/footer images */


/*
 * Memory allocation units for other stuff...
 */

#define ALLOC_FILES	10	/* Temporary/image files */
#define ALLOC_HEADINGS	50	/* Headings */
#define ALLOC_LINKS	100	/* Web links */
#define ALLOC_OBJECTS	100	/* PDF objects */
#define ALLOC_PAGES	10	/* PS/PDF pages */
#define ALLOC_ROWS	20	/* Table rows */


/*
 * Locations of files (overridden by the registry...)
 */

#define HTMLDOC_DOCDIR	"C:/Program Files/Easy Software Products/HTMLDOC/doc"
#define HTMLDOC_DATA	"C:/Program Files/Easy Software Products/HTMLDOC"


/*
 * Which encryption libraries do we have?
 */

#undef HAVE_CDSASSL
#undef HAVE_GNUTLS
#define HAVE_LIBSSL
#define HAVE_SSL


/*
 * Do we need to use <strings.h>?
 */

#undef HAVE_STRINGS_H


/*
 * Do we have the <locale.h> header file?
 */

#define HAVE_LOCALE_H


/*
 * Do we have some of the "standard" string functions?
 */

#define HAVE_STRCASECMP
#define HAVE_STRDUP
#undef HAVE_STRDUPF
#undef HAVE_STRLCAT
#undef HAVE_STRLCPY
#define HAVE_STRNCASECMP


/*
 * How about snprintf() and vsnprintf()?
 */

#define HAVE_SNPRINTF
#define HAVE_VSNPRINTF


/*
 * Does the "tm" structure contain the "tm_gmtoff" member?
 */

#undef HAVE_TM_GMTOFF


/*
 * Do we have hstrerror()?
 */

#undef HAVE_HSTRERROR


/*
 * Do we have getaddrinfo()?
 */

#define HAVE_GETADDRINFO


/*
 * Do we have getnameinfo()?
 */

#define HAVE_GETNAMEINFO


/*
 * Do we have the long long type?
 */

#undef HAVE_LONG_LONG

#ifdef HAVE_LONG_LONG
#  define HTMLDOC_LLFMT		"%lld"
#  define HTMLDOC_LLCAST	(long long)
#else
#  define HTMLDOC_LLFMT		"%ld"
#  define HTMLDOC_LLCAST	(long)
#endif /* HAVE_LONG_LONG */


/*
 * Do we have the strtoll() function?
 */

#undef HAVE_STRTOLL

#ifndef HAVE_STRTOLL
#  define strtoll(nptr,endptr,base) strtol((nptr), (endptr), (base))
#endif /* !HAVE_STRTOLL */


/*
 * End of "$Id: config.h 1563 2008-05-29 21:46:19Z mike $".
 */

