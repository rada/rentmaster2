//
// "$Id: stylefont.cxx 1531 2008-01-07 03:01:46Z mike $"
//
//   CSS font routines for HTMLDOC, a HTML document processing program.
//
//   Copyright 1997-2008 by Easy Software Products.
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
//   hdStyleFont::hdStyleFont()   - Create a new font record.
//   hdStyleFont::~hdStyleFont()  - Destroy a font record.
//   hdStyleFont::compare_kerns() - Compare two kerning pairs...
//   hdStyleFont::get_char()      - Get a character from a string.
//   hdStyleFont::get_kerning()   - Get the kerning list for a string.
//   hdStyleFont::get_num_chars() - Get the number of characters in the string.
//   hdStyleFont::get_width()     - Compute the width of a string.
//   hdStyleFont::load_widths()   - Load character widths for a font.
//   hdStyleFont::read_afm()      - Read a Type1 AFM file.
//   hdStyleFont::read_ttf()      - Read a TrueType font file.
//

//
// Include necessary headers.
//

#include "htmldoc.h"
#include "hdstring.h"
#include <stdlib.h>
#ifdef WIN32
#  include <io.h>
#else
#  include <unistd.h>
#endif // WIN32


//
// 'hdStyleFont::hdStyleFont()' - Create a new font record.
//

hdStyleFont::hdStyleFont(hdStyleSheet   *css,	// I - Stylesheet
        		 hdFontFace     t,	// I - Typeface
			 hdFontInternal s,	// I - Style
			 const char     *n)	// I - Font name
{
  int			i;			// Looping vars...
  char			filename[1024];		// Filename
  FILE			*fp;			// File pointer
  static const char	*styles[][2] =		// PostScript style suffixes
			{
			  { "-Roman",		"-Regular" },
			  { "-Bold",		"-Medium" },
			  { "-Italic",		"-Oblique" },
			  { "-BoldItalic",	"-BoldOblique" }
			};


//  printf("hdStyleFont(css=%p, t=%d, s=%d, n=\"%s\")\n", css, t, s, n);

  // Clear the structure...
  memset(this, 0, sizeof(hdStyleFont));

  // Initialize variables...
  typeface = t;
  style    = s;

  // Map font family to base font...
  if (!strcasecmp(n, "serif"))
    n = "Serif";
  else if (!strcasecmp(n, "sans") ||
           !strcasecmp(n, "sans-serif"))
    n = "Sans";
  else if (!strcasecmp(n, "monospace"))
    n = "Monospace";
  else if (!strcasecmp(n, "times"))
    n = "Times";
  else if (!strcasecmp(n, "arial") ||
           !strcasecmp(n, "helvetica"))
    n = "Helvetica";
  else if (!strcasecmp(n, "courier"))
    n = "Courier";
  else if (!strcasecmp(n, "dingbats"))
    n = "Dingbats";
  else if (!strcasecmp(n, "symbol"))
    n = "Symbol";
  else if (!strcasecmp(n, "cursive"))
    n = "ZapfChancery";

  // Now try to find the font...
  for (fp = NULL, i = 0; i < 2; i ++)
  {
    // Try a variation of the font name...
    snprintf(filename, sizeof(filename), "%s/fonts/%s%s.afm",
             _htmlData, n, styles[s][i]);
    if (!access(filename, 0))
      break;
  }

  if (i == 2)
  {
    // Use the font name without a suffix...
    snprintf(filename, sizeof(filename), "%s/fonts/%s.afm",
             _htmlData, n);
  }

  width_file = strdup(filename);

  // Change the extension to ".pfa" and save the font filename for later
  // use as needed...
  strcpy(filename + strlen(filename) - 4, ".pfa");
  font_file = strdup(filename);

  load_widths(css);
}


//
// 'hdStyleFont::~hdStyleFont()' - Destroy a font record.
//

hdStyleFont::~hdStyleFont()
{
  if (num_kerns)
    delete[] kerns;

  delete[] widths;

  if (ps_name)
    free(ps_name);

  if (full_name)
    free(full_name);

  if (font_file)
    free(font_file);

  if (width_file)
    free(width_file);
}


//
// 'hdStyleFont::compare_kerns()' - Compare two kerning pairs...
//

int						// O - Result of comparison
hdStyleFont::compare_kerns(hdFontKernPair *a,	// I - First kerning pair
                           hdFontKernPair *b)	// I - Second kerning pair
{
  if (a->first != b->first)
    return (b->first - a->first);
  else
    return (b->second - a->second);
}


//
// 'hdStyleFont::get_char()' - Get a character from a string.
//

int					// O  - Character from string
hdStyleFont::get_char(const hdChar *&s)	// IO - String pointer
{
  int	ch,				// Next character from string
	i,				// Looping var
	count;				// Number of bytes in UTF-8 encoding


  // Handle the easy cases...
  if (!s || !*s)
    return (0);
  else if (encoding == HD_FONT_ENCODING_8BIT)
    return (*s++);

  // OK, extract a single UTF-8 encoded char...  This code also supports
  // reading ISO-8859-1 characters that are masquerading as UTF-8.
  if (*s < 192)
    return (*s++);

  if ((*s & 0xe0) == 0xc0)
  {
    ch    = *s & 0x1f;
    count = 1;
  }
  else if ((*s & 0xf0) == 0xe0)
  {
    ch    = *s & 0x0f;
    count = 2;
  }
  else
  {
    ch    = *s & 0x07;
    count = 3;
  }

  for (i = 1; i <= count && s[i]; i ++)
    if (s[i] < 128 || s[i] > 191)
      break;
    else
      ch = (ch << 6) | (s[i] & 0x3f);

  if (i <= count)
  {
    // Return just the initial char...
    return (*s++);
  }
  else
  {
    // Return the decoded char...
    s += count + 1;
    return (ch);
  }
}


//
// 'hdStyleFont::get_kerning()' - Get the kerning list for a string.
//

int					// O - Number of kerning entries
hdStyleFont::get_kerning(
  const hdChar *s,			// I - String to kern
  float        &tk,			// O - Total kerning adjustment
  float        *&kl)			// O - Kerning adjustments
{
  int			i,		// Looping var
			first,		// First char from string
			second,		// Second char from string
			num_chars;	// Number of characters
  float			tadjust,	// Overall adjustment
			*adjusts;	// Array of adjustments...
  hdFontKernPair	key,		// Search key
			*pair;		// Kerning pair


  // Handle simple, empty strings and when there is no kerning info...
  tk = 0.0f;
  kl = NULL;

  if (num_kerns == 0 || (num_chars = get_num_chars(s)) < 2)
    return (0);

  // Then allocate the adjustment array and loop through...
  num_chars --; // only kerning *pairs*...
  adjusts = new float[num_chars];
  tadjust = 0.0f;

  for (i = 0, first = get_char(s); i < num_chars; i ++, first = second)
  {
    // Get the second character for the kerning...
    second = get_char(s);

    // See if we have a kerning entry...
    key.first  = first;
    key.second = second;

    pair = (hdFontKernPair *)bsearch(&key, kerns, num_kerns,
                                     sizeof(hdFontKernPair),
                                     (hdCompareFunc)compare_kerns);

    if (pair)
    {
      adjusts[i] = pair->adjust;
      tadjust    += pair->adjust;
    }
    else
      adjusts[i] = 0.0f;
  }

  // If there is no adjustment, delete the adjustment array and return 0...
  if (tadjust == 0.0f)
  {
    delete[] adjusts;
    return (0);
  }

  // Return the kerning adjustments...
  tk = tadjust;
  kl = adjusts;

  return (num_chars);
}


//
// 'hdStyleFont::get_num_chars()' - Get the number of characters in the string.
//

int					// O - Number of chars in string
hdStyleFont::get_num_chars(
  const hdChar *s)			// I - String
{
  int	num_chars;			// Number of characters


  // Handle the easy cases...
  if (!s || !*s)
    return (0);
  else if (encoding == HD_FONT_ENCODING_8BIT)
    return (strlen((char *)s));

  // OK, loop through the string, looking for chars in the range of
  // 1 to 127 and 192 to 255 which indicate the start of UTF-8
  // encoded char codes...
  for (num_chars = 0; *s; s ++, num_chars ++)
    if (*s > 191)
    {
      // This hack is necessary to support ISO-8859-1 encoded text
      // that is masquerading as UTF-8 text...
      int count;

      if ((*s & 0xe0) == 0xc0)
        count = 1;
      else if ((*s & 0xf0) == 0xe0)
        count = 2;
      else
        count = 3;

      for (; count > 0 && *s; count --, s ++)
        if (*s < 128 || *s > 191)
	  break;

      s --;
    }

  return (num_chars);
}


//
// 'hdStyleFont::get_width()' - Compute the width of a string.
//

float					// O - Unscaled width
hdStyleFont::get_width(const hdChar *s)	// I - String to measure
{
  int	ch;				// Character in string
  float	w;				// Current width
//  float	*adjusts;			// Adjustments array


//  printf("Width of \"%s\" is ", s);

#if 0
  if (get_kerning(s, w, adjusts) > 0)
    delete[] adjusts;
#else
  w = 0.0f;
#endif // 0

  while ((ch = get_char(s)) != 0)
    w += widths[ch];

//  printf("%.1f...\n", w);

  return (w);
}


//
// 'hdStyleFont::load_widths()' - Load character widths for a font.
//

void
hdStyleFont::load_widths(
    hdStyleSheet *css)			// I - Stylesheet
{
  FILE	*fp;				// File to read from


  // Free old font width data...
  if (num_kerns > 0)
    delete[] kerns;

  if (num_widths > 0)
    delete[] widths;

  if (ps_name)
    free(ps_name);

  if (full_name)
    free(full_name);

  // Initialize font width data...
  encoding     = css->encoding;
  ps_name      = NULL;
  full_name    = NULL;
  fixed_width  = false;
  ascender     = 0.0f;
  bbox[0]      = 0.0f;
  bbox[1]      = 0.0f;
  bbox[2]      = 0.0f;
  bbox[3]      = 0.0f;
  cap_height   = 0.0f;
  descender    = 0.0f;
  italic_angle = 0.0f;
  ul_position  = 0.0f;
  ul_thickness = 0.0f;
  x_height     = 0.0f;
  num_widths   = 256;
  widths       = new float[num_widths];
  num_kerns    = 0;
  kerns        = NULL;

  memset(widths, 0, sizeof(float) * num_widths);

  if ((fp = fopen(width_file, "rb")) != NULL)
  {
//    printf("    filename=\"%s\"\n", filename);

    // Read the AFM file...
    read_afm(fp, css);
    fclose(fp);
  }
}


//
// 'hdStyleFont::read_afm()' - Read a Type1 AFM file.
//

int					// O - 0 on success, -1 on error
hdStyleFont::read_afm(FILE         *fp,	// I - File to read from
                      hdStyleSheet *css)// I - Stylesheet
{
  char		line[255],		// Line from file
		*lineptr,		// Pointer into line
		value[32],		// String value in line
		value2[32];		// Second string value in line
  int		number,			// Numeric value in line
		glyph,			// Glyph index
		glyph2;			// Second glyph index
  int		alloc_kerns;		// Allocated kerning pairs...
  hdFontKernPair *temp;			// Pointer to kerning pairs...


  // Loop through the AFM file...
  alloc_kerns = 0;

  while (file_gets(line, sizeof(line), fp) != NULL)
  {
    // Get the initial keyword...
    if ((lineptr = strchr(line, ' ')) != NULL)
    {
      // Nul-terminate the keyword, and then skip any remaining whitespace...
      while (isspace(*lineptr))
        *lineptr++ = '\0';
    }

    // See what we have...
    if (!strcmp(line, "FontName"))
    {
      // Get PostScript font name...
      ps_name = strdup(lineptr);
    }
    else if (!strcmp(line, "FullName"))
    {
      // Human-readable font name...
      full_name = strdup(lineptr);
    }
    else if (!strcmp(line, "IsFixedPitch"))
    {
      // Fixed-pitch font?
      fixed_width = !strcmp(lineptr, "true");
    }
    else if (!strcmp(line, "UnderlinePosition"))
    {
      // Where to place the underline...
      ul_position = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "UnderlineThickness"))
    {
      // How thick to make the underline...
      ul_thickness = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "CapHeight"))
    {
      // How tall are uppercase letters?
      cap_height = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "XHeight"))
    {
      // How tall are lowercase letters?
      x_height = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "Descender"))
    {
      // How low do the descenders go?
      descender = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "Ascender"))
    {
      // How high do the ascenders go?
      ascender = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "ItalicAngle "))
    {
      // Angle for italic text...
      italic_angle = (float)atof(lineptr) * 0.001f;
    }
    else if (!strcmp(line, "FontBBox"))
    {
      // Bounding box for all characters...
      sscanf(lineptr, "%f%f%f%f", bbox + 0, bbox + 1, bbox + 2, bbox + 3);
      bbox[0] *= 0.001;
      bbox[1] *= 0.001;
      bbox[2] *= 0.001;
      bbox[3] *= 0.001;
    }
    else if (!strcmp(line, "C"))
    {
      // Get the character width and glyph name...
      if (sscanf(lineptr, "%*d%*s%*s%d%*s%*s%31s", &number, value) != 2)
        continue;

//      printf("glyphs=%p, value=\"%s\"...\n", css->glyphs, value);

      // Assign the width to all code points with this glyph...
      for (glyph = 0; glyph < 256; glyph ++)
        if (css->glyphs[glyph] && !strcmp(css->glyphs[glyph], value))
	{
//	  printf("\"%s\" (%02X) = %.3f...\n", value, glyph, number * 0.001f);
          widths[glyph] = number * 0.001f;
	}
    }
    else if (!strcmp(line, "KPX"))
    {
      // Get kerning data...
      if (sscanf(lineptr, "%31s%31s%d", value, value2, &number) != 3)
        continue;

      if ((glyph = css->get_glyph(value)) < 0)
        continue;

      if ((glyph2 = css->get_glyph(value2)) < 0)
        continue;

      if (num_kerns >= alloc_kerns)
      {
        // Allocate more kerning pairs...
	temp = new hdFontKernPair[alloc_kerns + 50];

	if (alloc_kerns)
	{
	  memcpy(temp, kerns, alloc_kerns * sizeof(hdFontKernPair));
	  delete[] kerns;
	}

        kerns       = temp;
        alloc_kerns += 50;
      }

      temp = kerns + num_kerns;
      num_kerns ++;

      temp->first  = glyph;
      temp->second = glyph2;
      temp->adjust = number * 0.001f;
    }
  }

  // Sort the kerning table as needed...
  if (num_kerns > 1)
    qsort(kerns, num_kerns, sizeof(hdFontKernPair),
          (hdCompareFunc)compare_kerns);

  // Make sure that non-breaking space has the same width as space...
  widths[160] = widths[32];
  num_widths  = 256;

  return (0);
}


//
// 'hdStyleFont::read_ttf()' - Read a TrueType font file.
//

int					// O - 0 on success, -1 on error
hdStyleFont::read_ttf(FILE       *fp,	// I - File to read from
                      hdStyleSheet *css)// I - Stylesheet
{
  return (0);
}


//
// End of "$Id: stylefont.cxx 1531 2008-01-07 03:01:46Z mike $".
//
