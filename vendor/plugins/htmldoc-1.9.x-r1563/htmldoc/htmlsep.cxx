//
// "$Id: htmlsep.cxx 1526 2008-01-06 01:55:59Z mike $"
//
//   Separated HTML export functions for HTMLDOC, a HTML document processing
//   program.
//
//   Copyright 1997-2006 by Easy Software Products.
//
//   These coded instructions, statements, and computer programs are the
//   property of Easy Software Products and are protected by Federal
//   copyright law.  Distribution and use rights are outlined in the file
//   "COPYING.txt" which should have been included with this file.  If this
//   file is missing or damaged please contact Easy Software Products
//   at:
//
//       Attn: HTMLDOC Licensing Information
//       Easy Software Products
//       516 Rio Grand Ct
//       Morgan Hill, CA 95037 USA
//
//       http://www.htmldoc.org/
//
// Contents:
//
//   htmlsep_export() - Export to separated HTML files.
//

//
// Include necessary headers.
//

#include "htmldoc.h"
#include <ctype.h>


//
// Named link structure...
//

typedef struct
{
  hdChar		*filename;	/* File for link */
  hdChar		name[124];	/* Reference name */
} hdLink;


//
// Local globals...
//

// Heading strings used for filenames...
static int	num_headings = 0,	// Number of headings
		alloc_headings = 0;	// Allocated headings
static hdChar	**headings;		// Heading strings

// Links in document - used to add the correct filename to the link
static int	num_links = 0,		// Number of links
		alloc_links = 0;	// Allocated links
static hdLink	*links;			// Links


//
// Local functions...
//

extern "C" {
typedef int	(*compare_func_t)(const void *, const void *);
}

static void	write_header(FILE **out, hdChar *filename, hdChar *title,
		             hdChar *author, hdChar *copyright, hdChar *docnumber,
			     int heading);
static void	write_footer(FILE **out, int heading);
static void	write_title(FILE *out, hdChar *title, hdChar *author,
		            hdChar *copyright, hdChar *docnumber);
static int	write_all(FILE *out, hdTree *t, int col);
static int	write_doc(FILE **out, hdTree *t, int col, int *heading,
		          hdChar *title, hdChar *author, hdChar *copyright,
			  hdChar *docnumber);
static int	write_node(FILE *out, hdTree *t, int col);
static int	write_nodeclose(FILE *out, hdTree *t, int col);
static int	write_toc(FILE *out, hdTree *t, int col);
static hdChar	*get_title(hdTree *doc);

static void	add_heading(hdTree *t);
static void	add_link(hdChar *name);
static hdLink	*find_link(hdChar *name);
static int	compare_links(hdLink *n1, hdLink *n2);
static void	scan_links(hdTree *t);
static void	update_links(hdTree *t, int *heading);


//
// 'htmlsep_export()' - Export to separated HTML files...
//

int					// O - 0 = success, -1 = failure
htmlsep_export(hdTree *document,	// I - Document to export
               hdTree *toc,		// I - Table of contents for document
	       hdTree *ind)		// I - Index of document
{
  int	i;				// Looping var
  int	heading;			// Current heading number
  hdChar	*title,				// Title text
	*author,			// Author name
	*copyright,			// Copyright text
	*docnumber;			// Document number
  FILE	*out;				// Output file


  // We only support writing to a directory...
  if (!OutputFiles)
  {
    progress_error(HD_ERROR_INTERNAL_ERROR, "Unable to generate separated HTML to a single file!");
    return (-1);
  }

  // Copy logo and title images...
  if (LogoImage[0])
    image_copy(LogoImage, file_find(LogoImage, Path), OutputPath);

  for (int hfi = 0; hfi < MAX_HF_IMAGES; hfi ++)
    if (HFImage[hfi][0])
      image_copy(HFImage[hfi], file_find(HFImage[hfi], Path), OutputPath);

  if (TitleImage[0] && TitlePage &&
#ifdef WIN32
      stricmp(file_extension(TitleImage), "bmp") == 0 ||
      stricmp(file_extension(TitleImage), "gif") == 0 ||
      stricmp(file_extension(TitleImage), "jpg") == 0 ||
      stricmp(file_extension(TitleImage), "png") == 0)
#else
      strcmp(file_extension(TitleImage), "bmp") == 0 ||
      strcmp(file_extension(TitleImage), "gif") == 0 ||
      strcmp(file_extension(TitleImage), "jpg") == 0 ||
      strcmp(file_extension(TitleImage), "png") == 0)
#endif // WIN32
    image_copy(TitleImage, file_find(TitleImage, Path), OutputPath);

  // Get document strings...
  title     = get_title(document);
  author    = htmlGetMeta(document, "author");
  copyright = htmlGetMeta(document, "copyright");
  docnumber = htmlGetMeta(document, "docnumber");

  // Scan for all links in the document, and then update them...
  num_links   = 0;
  alloc_links = 0;
  links       = NULL;

  scan_links(document);

//  printf("num_headings = %d\n", num_headings);
//  for (i = 0; i < num_headings; i ++)
//    printf("headings[%d] = \"%s\"\n", i, headings[i]);

  heading = -1;
  update_links(document, &heading);
  update_links(toc, NULL);

  // Generate title pages and a table of contents...
  out = NULL;
  if (TitlePage)
  {
    write_header(&out, (hdChar *)"index.html", title, author, copyright,
                 docnumber, -1);
    if (out != NULL)
      write_title(out, title, author, copyright, docnumber);

    write_footer(&out, -1);

    write_header(&out, (hdChar *)"toc.html", title, author, copyright,
                 docnumber, -1);
  }
  else
    write_header(&out, (hdChar *)"index.html", title, author, copyright,
                 docnumber, -1);

  if (out != NULL)
    write_toc(out, toc, 0);

  write_footer(&out, -1);

  // Then write each output file...
  heading = -1;
  write_doc(&out, document, 0, &heading, title, author, copyright, docnumber);

  if (out != NULL)
    write_footer(&out, heading);

  if (ind)
  {
    write_header(&out, (hdChar *)"idx.html", title, author, copyright,
        	 docnumber, -1);
    write_doc(&out, ind, 0, &heading, title, author, copyright, docnumber);
    write_footer(&out, -1);
  }

  // Free memory...
  if (title != NULL)
    free(title);

  if (alloc_links)
  {
    free(links);

    num_links   = 0;
    alloc_links = 0;
    links       = NULL;
  }

  if (alloc_headings)
  {
    for (i = 0; i < num_headings; i ++)
      free(headings[i]);

    free(headings);

    num_headings   = 0;
    alloc_headings = 0;
    headings       = NULL;
  }

  return (out == NULL);
}


/*
 * 'write_header()' - Output the standard "header" for a HTML file.
 */

static void
write_header(FILE   **out,		/* IO - Output file */
             hdChar  *filename,		/* I - Output filename */
	     hdChar  *title,		/* I - Title for document */
             hdChar  *author,		/* I - Author for document */
             hdChar  *copyright,	/* I - Copyright for document */
             hdChar  *docnumber,	/* I - ID number for document */
	     int    heading)		/* I - Current heading */
{
  char		realname[1024];		/* Real filename */
  const char	*basename;		/* Filename without directory */
  static const char *families[] =	/* Typeface names */
		{
		  "monospace",
		  "serif",
		  "sans-serif",
		  "monospace",
		  "serif",
		  "sans-serif",
		  "symbol",
		  "dingbats"
		};


  basename = file_basename((char *)filename);

  snprintf(realname, sizeof(realname), "%s/%s", OutputPath, basename);

  *out = fopen(realname, "wb");

  if (*out == NULL)
  {
    progress_error(HD_ERROR_WRITE_ERROR,
                   "Unable to create output file \"%s\" - %s.\n",
                   realname, strerror(errno));
    return;
  }

  fputs("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" "
        "\"http://www.w3.org/TR/REC-html40/loose.dtd\">\n", *out);
  fputs("<HTML>\n", *out);
  fputs("<HEAD>\n", *out);
  if (title != NULL)
    fprintf(*out, "<TITLE>%s</TITLE>\n", title);
  if (author != NULL)
    fprintf(*out, "<META NAME=\"author\" CONTENT=\"%s\">\n", author);
  if (copyright != NULL)
    fprintf(*out, "<META NAME=\"copyright\" CONTENT=\"%s\">\n", copyright);
  if (docnumber != NULL)
    fprintf(*out, "<META NAME=\"docnumber\" CONTENT=\"%s\">\n", docnumber);
  fprintf(*out, "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=iso-%s\">\n",
          _htmlStyleSheet->charset);

  fputs("<LINK REL=\"Start\" HREF=\"index.html\">\n", *out);

  if (TitlePage)
    fputs("<LINK REL=\"Contents\" HREF=\"toc.html\">\n", *out);
  else
    fputs("<LINK REL=\"Contents\" HREF=\"index.html\">\n", *out);

  if (heading >= 0)
  {
    if (heading > 0)
      fprintf(*out, "<LINK REL=\"Prev\" HREF=\"%s.html\">\n", headings[heading - 1]);

    if (heading < (num_headings - 1))
      fprintf(*out, "<LINK REL=\"Next\" HREF=\"%s.html\">\n", headings[heading + 1]);
  }

  fputs("<STYLE TYPE=\"text/css\"><!--\n", *out);
  fprintf(*out, "BODY { font-family: %s }\n", families[_htmlBodyFont]);
  fprintf(*out, "H1 { font-family: %s }\n", families[_htmlHeadingFont]);
  fprintf(*out, "H2 { font-family: %s }\n", families[_htmlHeadingFont]);
  fprintf(*out, "H3 { font-family: %s }\n", families[_htmlHeadingFont]);
  fprintf(*out, "H4 { font-family: %s }\n", families[_htmlHeadingFont]);
  fprintf(*out, "H5 { font-family: %s }\n", families[_htmlHeadingFont]);
  fprintf(*out, "H6 { font-family: %s }\n", families[_htmlHeadingFont]);
  fputs("SUB { font-size: smaller }\n", *out);
  fputs("SUP { font-size: smaller }\n", *out);
  fputs("PRE { font-family: monospace }\n", *out);

  if (!LinkStyle)
    fputs("A { text-decoration: none }\n", *out);

  fputs("--></STYLE>\n", *out);
  fputs("</HEAD>\n", *out);

  if (BodyImage[0])
    fprintf(*out, "<BODY BACKGROUND=\"%s\"", file_basename(BodyImage));
  else if (BodyColor[0])
    fprintf(*out, "<BODY BGCOLOR=\"%s\"", BodyColor);
  else
    fputs("<BODY", *out);

  fprintf(*out, " TEXT=\"#%02X%02X%02X\"",
          _htmlStyleSheet->def_style.color[0],
          _htmlStyleSheet->def_style.color[1],
          _htmlStyleSheet->def_style.color[2]);

  if (LinkColor[0])
    fprintf(*out, " LINK=\"%s\" VLINK=\"%s\" ALINK=\"%s\"", LinkColor,
            LinkColor, LinkColor);

  fputs(">\n", *out);

  if (heading >= 0)
  {
    if (LogoImage[0])
      fprintf(*out, "<IMG SRC=\"%s\">\n", file_basename(LogoImage));

    for (int hfi = 0; hfi < MAX_HF_IMAGES; ++hfi)
      if (HFImage[hfi][0])
        fprintf(*out, "<IMG SRC=\"%s\">\n", file_basename(HFImage[hfi]));

    if (TitlePage)
      fputs("<A HREF=\"toc.html\">Contents</A>\n", *out);
    else
      fputs("<A HREF=\"index.html\">Contents</A>\n", *out);

    if (heading > 0)
      fprintf(*out, "<A HREF=\"%s.html\">Previous</A>\n", headings[heading - 1]);

    if (heading < (num_headings - 1))
      fprintf(*out, "<A HREF=\"%s.html\">Next</A>\n", headings[heading + 1]);

    fputs("<HR NOSHADE>\n", *out);
  }
}


/*
 * 'write_footer()' - Output the standard "footer" for a HTML file.
 */

static void
write_footer(FILE **out,		/* IO - Output file pointer */
	     int  heading)		/* I  - Current heading */
{
  if (*out == NULL)
    return;

  fputs("<HR NOSHADE>\n", *out);

  if (heading >= 0)
  {
    if (LogoImage[0])
      fprintf(*out, "<IMG SRC=\"%s\">\n", file_basename(LogoImage));

    for (int hfi = 0; hfi < MAX_HF_IMAGES; ++hfi)
      if (HFImage[hfi][0])
        fprintf(*out, "<IMG SRC=\"%s\">\n", file_basename(HFImage[hfi]));

    if (TitlePage)
      fputs("<A HREF=\"toc.html\">Contents</A>\n", *out);
    else
      fputs("<A HREF=\"index.html\">Contents</A>\n", *out);

    if (heading > 0)
      fprintf(*out, "<A HREF=\"%s.html\">Previous</A>\n", headings[heading - 1]);

    if (heading < (num_headings - 1))
      fprintf(*out, "<A HREF=\"%s.html\">Next</A>\n", headings[heading + 1]);
  }

  fputs("</BODY>\n", *out);
  fputs("</HTML>\n", *out);

  progress_error(HD_ERROR_NONE, "BYTES: %ld", ftell(*out));

  fclose(*out);
  *out = NULL;
}


/*
 * 'write_title()' - Write a title page...
 */

static void
write_title(FILE  *out,			/* I - Output file */
            hdChar *title,		/* I - Title for document */
            hdChar *author,		/* I - Author for document */
            hdChar *copyright,		/* I - Copyright for document */
            hdChar *docnumber)		/* I - ID number for document */
{
  FILE		*fp;			/* Title file */
  const char	*title_file;		/* Location of title file */
  hdTree	*t;			/* Title file document tree */


  if (out == NULL)
    return;

#ifdef WIN32
  if (TitleImage[0] &&
      stricmp(file_extension(TitleImage), "bmp") != 0 &&
      stricmp(file_extension(TitleImage), "gif") != 0 &&
      stricmp(file_extension(TitleImage), "jpg") != 0 &&
      stricmp(file_extension(TitleImage), "png") != 0)
#else
  if (TitleImage[0] &&
      strcmp(file_extension(TitleImage), "bmp") != 0 &&
      strcmp(file_extension(TitleImage), "gif") != 0 &&
      strcmp(file_extension(TitleImage), "jpg") != 0 &&
      strcmp(file_extension(TitleImage), "png") != 0)
#endif // WIN32
  {
    // Find the title page file...
    if ((title_file = file_find(Path, TitleImage)) == NULL)
    {
      progress_error(HD_ERROR_FILE_NOT_FOUND,
                     "Unable to find title file \"%s\"!", TitleImage);
      return;
    }

    // Write a title page from HTML source...
    if ((fp = fopen(title_file, "rb")) == NULL)
    {
      progress_error(HD_ERROR_FILE_NOT_FOUND,
                     "Unable to open title file \"%s\" - %s!",
                     TitleImage, strerror(errno));
      return;
    }

    t = htmlReadFile(NULL, fp, file_directory(TitleImage));
    htmlFixLinks(t, t, file_directory(TitleImage));
    fclose(fp);

    write_all(out, t, 0);
    htmlDeleteTree(t);
  }
  else
  {
    // Write a "standard" title page with image...
    fputs("<CENTER>", out);

    if (TitleImage[0])
    {
      hdImage *img = image_load(TitleImage, !OutputColor);

      fprintf(out, "<IMG SRC=\"%s\" WIDTH=\"%d\" HEIGHT=\"%d\" "
	           "ALT=\"%s\"><BR>\n",
              file_basename((char *)TitleImage), img->width, img->height,
	      title ? (char *)title : "");
    }

    if (title != NULL)
      fprintf(out, "<H1>%s</H1><BR>\n", title);
    else
      fputs("\n", out);

    if (docnumber != NULL)
      fprintf(out, "%s<BR>\n", docnumber);

    if (author != NULL)
      fprintf(out, "%s<BR>\n", author);

    if (copyright != NULL)
      fprintf(out, "%s<BR>\n", copyright);

    fputs("<A HREF=\"toc.html\">Table of Contents</A>", out);
    fputs("</CENTER>\n", out);
  }
}


/*
 * 'write_all()' - Write all markup text for the given tree.
 */

static int				/* O - Current column */
write_all(FILE   *out,			/* I - Output file */
          hdTree *t,			/* I - Document tree */
          int    col)			/* I - Current column */
{
  if (out == NULL)
    return (0);

  while (t != NULL)
  {
    col = write_node(out, t, col);

    if (t->element != HD_ELEMENT_HEAD && t->element != HD_ELEMENT_TITLE)
      col = write_all(out, t->child, col);

    col = write_nodeclose(out, t, col);

    t = t->next;
  }

  return (col);
}


/*
 * 'write_doc()' - Write the entire document.
 */

static int				// O - Current column
write_doc(FILE   **out,			// I - Output file
          hdTree *t,			// I - Document tree
          int    col,			// I - Current column
          int    *heading,		// IO - Current heading
	  hdChar  *title,		// I  - Title
          hdChar  *author,		// I  - Author
	  hdChar  *copyright,		// I  - Copyright
	  hdChar  *docnumber)		// I  - Document number
{
  hdChar	filename[1024];		// Filename


  while (t != NULL)
  {
    if (t->element >= HD_ELEMENT_H1 && t->element < (HD_ELEMENT_H1 + TocLevels) &&
        htmlGetAttr(t, "_HD_OMIT_TOC") == NULL)
    {
      if (heading >= 0)
        write_footer(out, *heading);

      (*heading) ++;

      if (*heading >= 0)
      {
	snprintf((char *)filename, sizeof(filename), "%s.html",
	         headings[*heading]);
	write_header(out, filename, title, author, copyright, docnumber,
                     *heading);
      }
    }

    col = write_node(*out, t, col);

    if (t->element != HD_ELEMENT_HEAD && t->element != HD_ELEMENT_TITLE)
      col = write_doc(out, t->child, col, heading,
                      title, author, copyright, docnumber);

    col = write_nodeclose(*out, t, col);

    t = t->next;
  }

  return (col);
}


/*
 * 'write_node()' - Write a single tree node.
 */

static int				/* O - Current column */
write_node(FILE   *out,			/* I - Output file */
           hdTree *t,			/* I - Document tree node */
           int    col)			/* I - Current column */
{
  int		i;			/* Looping var */
  const hdChar	*ptr,			/* Pointer to output string */
		*src,			/* Source image */
		*realsrc;		/* Real source image */
  hdChar	newsrc[1024];		/* New source image filename */
  const char	*entity;		/* Entity string */


  if (out == NULL)
    return (0);

  switch (t->element)
  {
    case HD_ELEMENT_NONE :
        if (t->data == NULL)
	  break;

	if (t->style->white_space == HD_WHITE_SPACE_PRE)
	{
          for (ptr = t->data; *ptr; ptr ++)
            fputs(_htmlStyleSheet->get_entity(*ptr), out);

	  if (t->data[strlen((char *)t->data) - 1] == '\n')
            col = 0;
	  else
            col += strlen((char *)t->data);
	}
	else
	{
	  if ((col + strlen((char *)t->data)) > 72 && col > 0 &&
	      isspace(t->data[0] & 255))
	  {
            putc('\n', out);
            col = 0;
	  }

          for (ptr = t->data; *ptr; ptr ++)
            fputs(_htmlStyleSheet->get_entity(*ptr), out);

	  col += strlen((char *)t->data);

	  if (col > 72 && isspace(t->data[strlen((char *)t->data) - 1] & 255))
	  {
            putc('\n', out);
            col = 0;
	  }
	}
	break;

    case HD_ELEMENT_COMMENT :
    case HD_ELEMENT_UNKNOWN :
        fputs("\n<!--", out);
	for (ptr = t->data; *ptr; ptr ++)
	  fputs(_htmlStyleSheet->get_entity(*ptr), out);
	fputs("-->\n", out);
	col = 0;
	break;

    case HD_ELEMENT_AREA :
    case HD_ELEMENT_BODY :
    case HD_ELEMENT_DOCTYPE :
    case HD_ELEMENT_ERROR :
    case HD_ELEMENT_FILE :
    case HD_ELEMENT_HEAD :
    case HD_ELEMENT_HTML :
    case HD_ELEMENT_MAP :
    case HD_ELEMENT_META :
    case HD_ELEMENT_TITLE :
        break;

    case HD_ELEMENT_BR :
    case HD_ELEMENT_CENTER :
    case HD_ELEMENT_DD :
    case HD_ELEMENT_DL :
    case HD_ELEMENT_DT :
    case HD_ELEMENT_H1 :
    case HD_ELEMENT_H2 :
    case HD_ELEMENT_H3 :
    case HD_ELEMENT_H4 :
    case HD_ELEMENT_H5 :
    case HD_ELEMENT_H6 :
    case HD_ELEMENT_H7 :
    case HD_ELEMENT_H8 :
    case HD_ELEMENT_H9 :
    case HD_ELEMENT_H10 :
    case HD_ELEMENT_H11 :
    case HD_ELEMENT_H12 :
    case HD_ELEMENT_H13 :
    case HD_ELEMENT_H14 :
    case HD_ELEMENT_H15 :
    case HD_ELEMENT_HR :
    case HD_ELEMENT_LI :
    case HD_ELEMENT_OL :
    case HD_ELEMENT_P :
    case HD_ELEMENT_PRE :
    case HD_ELEMENT_TABLE :
    case HD_ELEMENT_TR :
    case HD_ELEMENT_UL :
        if (col > 0)
        {
          putc('\n', out);
          col = 0;
        }

    default :
	if (t->element == HD_ELEMENT_IMG && OutputFiles &&
            (src = htmlGetAttr(t, "SRC")) != NULL &&
            (realsrc = htmlGetAttr(t, "_HD_SRC")) != NULL)
	{
	 /*
          * Update and copy local images...
          */

          if (file_method((char *)src) == NULL &&
              src[0] != '/' && src[0] != '\\' &&
	      (!isalpha(src[0]) || src[1] != ':'))
          {
            image_copy((char *)src, (char *)realsrc, OutputPath);
            strlcpy((char *)newsrc, file_basename((char *)src), sizeof(newsrc));
            htmlSetAttr(t, "SRC", newsrc);
          }
	}

        if (t->element != HD_ELEMENT_EMBED)
	{
	  col += fprintf(out, "<%s", _htmlStyleSheet->get_element(t->element));
	  for (i = 0; i < t->nattrs; i ++)
	  {
            if (strncasecmp((char *)t->attrs[i].name, "_HD_", 4) == 0)
	      continue;

	    if (col > 72 && t->style->white_space != HD_WHITE_SPACE_PRE)
	    {
              putc('\n', out);
              col = 0;
	    }

            if (col > 0)
            {
              putc(' ', out);
              col ++;
            }

	    if (t->attrs[i].value == NULL)
              col += fprintf(out, "%s", t->attrs[i].name);
	    else
	    {
	      col += fprintf(out, "%s=\"", t->attrs[i].name);
	      for (ptr = t->attrs[i].value; *ptr; ptr ++)
	      {
		entity = _htmlStyleSheet->get_entity(*ptr);
		fputs(entity, out);
		col += strlen(entity);
	      }

	      putc('\"', out);
	      col ++;
	    }
	  }

	  putc('>', out);
	  col ++;

	  if (col > 72 && t->style->white_space != HD_WHITE_SPACE_PRE &&
	      t->style->display != HD_DISPLAY_INLINE)
	  {
	    putc('\n', out);
	    col = 0;
	  }
	}
	break;
  }

  return (col);
}


/*
 * 'write_nodeclose()' - Close a single tree node.
 */

static int				/* O - Current column */
write_nodeclose(FILE   *out,		/* I - Output file */
                hdTree *t,		/* I - Document tree node */
                int    col)		/* I - Current column */
{
  if (out == NULL)
    return (0);

  if (t->element != HD_ELEMENT_HEAD && t->element != HD_ELEMENT_TITLE)
  {
    if (col > 72 && t->style->white_space != HD_WHITE_SPACE_PRE &&
        t->style->display != HD_DISPLAY_INLINE)
    {
      putc('\n', out);
      col = 0;
    }

    switch (t->element)
    {
      case HD_ELEMENT_BODY :
      case HD_ELEMENT_ERROR :
      case HD_ELEMENT_FILE :
      case HD_ELEMENT_HEAD :
      case HD_ELEMENT_HTML :
      case HD_ELEMENT_NONE :
      case HD_ELEMENT_TITLE :

      case HD_ELEMENT_APPLET :
      case HD_ELEMENT_AREA :
      case HD_ELEMENT_BR :
      case HD_ELEMENT_COMMENT :
      case HD_ELEMENT_DOCTYPE :
      case HD_ELEMENT_EMBED :
      case HD_ELEMENT_HR :
      case HD_ELEMENT_IMG :
      case HD_ELEMENT_INPUT :
      case HD_ELEMENT_ISINDEX :
      case HD_ELEMENT_LINK :
      case HD_ELEMENT_META :
      case HD_ELEMENT_NOBR :
      case HD_ELEMENT_SPACER :
      case HD_ELEMENT_WBR :
      case HD_ELEMENT_UNKNOWN :
          break;

      case HD_ELEMENT_CENTER :
      case HD_ELEMENT_DD :
      case HD_ELEMENT_DL :
      case HD_ELEMENT_DT :
      case HD_ELEMENT_H1 :
      case HD_ELEMENT_H2 :
      case HD_ELEMENT_H3 :
      case HD_ELEMENT_H4 :
      case HD_ELEMENT_H5 :
      case HD_ELEMENT_H6 :
      case HD_ELEMENT_H7 :
      case HD_ELEMENT_H8 :
      case HD_ELEMENT_H9 :
      case HD_ELEMENT_H10 :
      case HD_ELEMENT_H11 :
      case HD_ELEMENT_H12 :
      case HD_ELEMENT_H13 :
      case HD_ELEMENT_H14 :
      case HD_ELEMENT_H15 :
      case HD_ELEMENT_LI :
      case HD_ELEMENT_OL :
      case HD_ELEMENT_P :
      case HD_ELEMENT_PRE :
      case HD_ELEMENT_TABLE :
      case HD_ELEMENT_TR :
      case HD_ELEMENT_UL :
          fprintf(out, "</%s>\n", _htmlStyleSheet->get_element(t->element));
          col = 0;
          break;

      default :
          col += fprintf(out, "</%s>", _htmlStyleSheet->get_element(t->element));
	  break;
    }
  }

  return (col);
}


/*
 * 'write_toc()' - Write all markup text for the given table-of-contents.
 */

static int				/* O - Current column */
write_toc(FILE   *out,			/* I - Output file */
          hdTree *t,			/* I - Document tree */
          int    col)			/* I - Current column */
{
  if (out == NULL)
    return (0);

  while (t != NULL)
  {
    if (htmlGetAttr(t, "_HD_OMIT_TOC") == NULL)
    {
      col = write_node(out, t, col);

      if (t->element != HD_ELEMENT_HEAD && t->element != HD_ELEMENT_TITLE)
	col = write_toc(out, t->child, col);

      col = write_nodeclose(out, t, col);
    }

    t = t->next;
  }

  return (col);
}


/*
 * 'get_title()' - Get the title string for the given document...
 */

static hdChar *				/* O - Title string */
get_title(hdTree *doc)			/* I - Document tree */
{
  hdChar	*temp;			/* Temporary pointer to title */


  while (doc != NULL)
  {
    if (doc->element == HD_ELEMENT_TITLE)
      return (htmlGetText(doc->child));
    else if (doc->child != NULL)
      if ((temp = get_title(doc->child)) != NULL)
        return (temp);

    doc = doc->next;
  }

  return (NULL);
}


//
// 'add_heading()' - Add a heading to the list of headings...
//

static void
add_heading(hdTree *t)			// I - Heading node
{
  int		i,			// Looping var
		count;			// Count of headings with this name
  hdChar	*heading,		// Heading text for this node
		*ptr,			// Pointer into text
		*ptr2,			// Second pointer into text
		s[1024],		// New text if we have a conflict
		**temp;			// New heading array pointer


  // Start by getting the heading text...
  heading = htmlGetText(t->child);
  if (!heading || !*heading)
    return;				// Nothing to do!

  // Sanitize the text...
  for (ptr = heading; *ptr;)
    if (!isalnum(*ptr))
    {
      // Remove anything but letters and numbers from the filename
      for (ptr2 = ptr; *ptr2; ptr2 ++)
        *ptr2 = ptr2[1];

      *ptr2 = '\0';
    }
    else
      ptr ++;

  // Now loop through the existing headings and check for dups...
  for (ptr = heading, i = 0, count = 0; i < num_headings; i ++)
    if (strcmp((char *)headings[i], (char *)ptr) == 0)
    {
      // Create a new instance of the heading...
      count ++;
      snprintf((char *)s, sizeof(s), "%s%d", heading, count);
      ptr = s;
    }

  // Now add the heading...
  if (num_headings >= alloc_headings)
  {
    // Allocate more headings...
    alloc_headings += ALLOC_HEADINGS;

    if (num_headings == 0)
      temp = (hdChar **)malloc(sizeof(hdChar *) * alloc_headings);
    else
      temp = (hdChar **)realloc(headings, sizeof(hdChar *) * alloc_headings);

    if (temp == NULL)
    {
      progress_error(HD_ERROR_OUT_OF_MEMORY,
	             "Unable to allocate memory for %d headings - %s",
	             alloc_headings, strerror(errno));
      alloc_headings -= ALLOC_HEADINGS;
      return;
    }

    headings = temp;
  }

  if (ptr == heading)
  {
    // Reuse the already-allocated string...
    headings[num_headings] = ptr;
  }
  else
  {
    // Make a copy of the string "s" and free the old heading string...
    headings[num_headings] = (hdChar *)strdup((char *)s);
    free(heading);
  }

  num_headings ++;
}


/*
 * 'add_link()' - Add a named link...
 */

static void
add_link(hdChar *name)			/* I - Name of link */
{
  hdChar	*filename;		/* File for link */
  hdLink	*temp;			/* New name */


  if (num_headings)
    filename = headings[num_headings - 1];
  else
    filename = (hdChar *)"noheading";

  if ((temp = find_link(name)) != NULL)
    temp->filename = filename;
  else
  {
    // See if we need to allocate memory for links...
    if (num_links >= alloc_links)
    {
      // Allocate more links...
      alloc_links += ALLOC_LINKS;

      if (num_links == 0)
        temp = (hdLink *)malloc(sizeof(hdLink) * alloc_links);
      else
        temp = (hdLink *)realloc(links, sizeof(hdLink) * alloc_links);

      if (temp == NULL)
      {
	progress_error(HD_ERROR_OUT_OF_MEMORY,
	               "Unable to allocate memory for %d links - %s",
	               alloc_links, strerror(errno));
        alloc_links -= ALLOC_LINKS;
	return;
      }

      links = temp;
    }

    // Add a new link...
    temp = links + num_links;
    num_links ++;

    strlcpy((char *)temp->name, (char *)name, sizeof(temp->name));
    temp->filename = filename;

    if (num_links > 1)
      qsort(links, num_links, sizeof(hdLink), (compare_func_t)compare_links);
  }
}


/*
 * 'find_link()' - Find a named link...
 */

static hdLink *				/* O - Matching link */
find_link(hdChar *name)			/* I - Name to find */
{
  hdChar	*target;		/* Pointer to target name portion */
  hdLink	key,			/* Search key */
		*match;			/* Matching name entry */


  if (name == NULL || num_links == 0)
    return (NULL);

  if ((target = (hdChar *)file_target((char *)name)) == NULL)
    return (NULL);

  strlcpy((char *)key.name, (char *)target, sizeof(key.name));
  key.name[sizeof(key.name) - 1] = '\0';
  match = (hdLink *)bsearch(&key, links, num_links, sizeof(hdLink),
                            (compare_func_t)compare_links);

  return (match);
}


/*
 * 'compare_links()' - Compare two named links.
 */

static int				/* O - 0 = equal, -1 or 1 = not equal */
compare_links(hdLink *n1,		/* I - First name */
              hdLink *n2)		/* I - Second name */
{
  return (strcasecmp((char *)n1->name, (char *)n2->name));
}


/*
 * 'scan_links()' - Scan a document for link targets, and keep track of
 *                  the files they are in...
 */

static void
scan_links(hdTree *t)			/* I - Document tree */
{
  hdChar	*name;			/* Name of link */


  while (t != NULL)
  {
    if (t->element >= HD_ELEMENT_H1 && t->element < (HD_ELEMENT_H1 + TocLevels) &&
        htmlGetAttr(t, "_HD_OMIT_TOC") == NULL)
      add_heading(t);

    if (t->element == HD_ELEMENT_A &&
        (name = htmlGetAttr(t, "NAME")) != NULL)
      add_link(name);

    if (t->child != NULL)
      scan_links(t->child);

    t = t->next;
  }
}


/*
 * 'update_links()' - Update links as needed.
 */

static void
update_links(hdTree *t,			/* I - Document tree */
             int    *heading)		/* I - Current heading */
{
  hdLink	*link;			/* Link */
  hdChar	*href;			/* Reference name */
  hdChar	newhref[1024];		/* New reference name */
  hdChar	*filename;		/* Current filename */


  // Scan the document, rewriting HREF's as needed...
  while (t != NULL)
  {
    if (t->element >= HD_ELEMENT_H1 && t->element < (HD_ELEMENT_H1 + TocLevels) &&
        htmlGetAttr(t, "_HD_OMIT_TOC") == NULL && heading)
      (*heading) ++;

    // Figure out the current filename based upon the current heading number...
    if (!heading || *heading < 0 || *heading >= num_headings)
      filename = (hdChar *)"noheading";
    else
      filename = headings[*heading];

    if (t->element == HD_ELEMENT_A &&
        (href = htmlGetAttr(t, "HREF")) != NULL)
    {
      // Update this link as needed...
      if (href[0] == '#' && (link = find_link(href)) != NULL)
      {
        // The filename in the link structure is a copy of the heading
	// pointer...
        if (filename != link->filename)
	{
	  // Rewrite using the new name...
	  snprintf((char *)newhref, sizeof(newhref), "%s.html%s",
	           link->filename, href);
	  htmlSetAttr(t, "HREF", newhref);
	}
      }
    }

    // Descend the tree as needed...
    if (t->child != NULL)
      update_links(t->child, heading);

    // Move to the next node at this level...
    t = t->next;
  }
}


//
// End of "$Id: htmlsep.cxx 1526 2008-01-06 01:55:59Z mike $".
//
