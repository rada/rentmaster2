README.txt - 2008-01-05
-----------------------

INTRODUCTION

    This README file describes HTMLDOC, a HTML processing
    program that generates HTML, PostScript, and PDF files with
    a table of contents.

    HTMLDOC is copyright 1997-2008 by Easy Software Products.
    The source code is available under the GNU General Public
    License, version 2.  See the LEGAL STUFF section below for
    details.

    Documentation for HTMLDOC is available in the "doc"
    subdirectory and is been generated from HTML "source" files
    into HTML, PostScript, and PDF using HTMLDOC.

    HTMLDOC supports most HTML 4.0 elements, CSS1 and some CSS2
    stylesheet properties, and BMP, GIF, JPEG, and PNG images.
    The documentation in the "doc" directory provides details
    about the HTML and CSS supoprt in HTMLDOC.

    Please support continued HTMLDOC development by purchasing
    HTMLDOC on CD-ROM from the following page:

        http://www.easysw.com/htmldoc/


INTERNET RESOURCES

    For general discussions about HTMLDOC, subscribe to the
    HTMLDOC mailing list by opening the following page:

	http://lists.easysw.com/mailman/listinfo/htmldoc

    The HTMLDOC open source home page is located at:

        http://www.htmldoc.org/

    The HTMLDOC commercial home page is located at:

        http://www.easysw.com/htmldoc/


REQUIREMENTS

    HTMLDOC requires an average of 2MB of disk space for
    installation. Binary distributions are available to any
    HTMLDOC commercial user at the commercial download page:

        http://www.easysw.com/htmldoc/software.php

    See the file "COMPILE.txt" for instructions on compiling
    HTMLDOC from the source code.


USING HTMLDOC

    COMPLETE DOCUMENTATION FOR HTMLDOC IS AVAILABLE IN THE "doc"
    SUBDIRECTORY.  THE FOLLOWING PROVIDES BASIC INFORMATION ON
    USING HTMLDOC AT THE COMMAND-LINE AND DOES NOT DISCUSS THE
    GUI OR WEB SERVER FUNCTIONALITY.

    HTMLDOC accepts a list of HTML "source" files and will
    generate HTML, PostScript, or PDF output via command-line
    options.  A summary of command-line options can be shown
    with the "--help" option:

        htmldoc --help

    HTMLDOC normally expects "structured" documents, with
    chapters, etc.  Chapters begin with a <H1> markup and
    continue to the end of the listed HTML files or the next
    <H1> markup, whichever comes first.  To convert unstructured
    documents such as web pages, use the "--webpage" option to
    HTMLDOC:

        htmldoc --webpage ...

    To generate a Level 2 PostScript file you might use:

        htmldoc -f outfile.ps chapter1.html ... chapterN.html

    Similarly you can generate a PDF file of the same source
    files using:

        htmldoc -f outfile.pdf chapter1.html ... chapterN.html

    Finally, to generate HTML files for viewing (with a linked table-
    of-contents) do the following:

        htmldoc -t html -d outdir chapter1.html ... chapterN.html

    or:

        htmldoc -t html -f outfile.html chapter1.html ... chapterN.html

    A complete description of all command-line options and HTML
    guidelines can be found in the software users manual in the
    "doc" directory.


CURRENT LIMITATIONS

    - No support for HTML forms.
    - HTML 4.0 table elements and attributes are not supported
      (rules, THEAD, TFOOT, etc.)


CREDITS

    The table VALIGN and "HALF PAGE" code was contributed by D.
    Richard Hipp.

    The multiple header/footer image code was contributed by
    Lynn Pye.

    The RC4 encryption code is from librc4 1.1 by the folks at
    Carnegie Mellon University.

    The MD5 hash code is from L. Peter Deutsch at Aladdin
    Enterprises (creators of Ghostscript, among other things).


ENCRYPTION SUPPORT

    HTMLDOC includes code to encrypt PDF document files using
    the RC4 algorithm with up to a 128-bit key. While this
    software and code may be freely used and exported under
    current US laws, other countries may restrict your use and
    possession of this code and software.


LEGAL STUFF

    The Adobe Portable Document Format is Copyright 1985-2003 by
    Adobe Systems Incorporated. Adobe, FrameMaker, and
    PostScript are registered trademarks of Adobe Systems,
    Incorporated.

    The Graphics Interchange Format is the copyright and GIF is
    the service mark property of CompuServe Incorporated.

    Intel is a registered trademark of Intel Corporation.

    IRIX and sgi are registered trademarks of Silicon Graphics,
    Inc.

    Linux is a registered trademark of Linus Torvalds.

    Mac OS is a registered trademark of Apple Inc.

    Microsoft and Windows are registered trademarks of Microsoft
    Corporation.

    Solaris is a registered trademark of Sun Microsystems, Inc.

    SPARC is a registered trademark of SPARC International, Inc.

    UNIX is a registered trademark of the X/Open Company, Ltd.

    HTMLDOC is the trademark property of Easy Software Products.

    HTMLDOC is copyright 1997-2008 by Easy Software Products.
    See Appendix A of the HTMLDOC Software Users Manual or the
    files "COPYING.txt" and "htmldoc.eula" for the terms of use.

    This software is based in part on the work of the
    Independent JPEG Group.
