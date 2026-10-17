---
type: "Bulletin"
title: "Using the Bulletin Template"
date: "July 1, 2026"
author: "Harry Hackerman"
distribution: "Nextcloud, notice board"
queries: "info@tampere.hacklab.fi"
signatory: "Harry Hackerman"
role: "Conscientious Hacker"
contact: "harry@hackerman.com"
---

# How to use the bulletin template

1. Copy this .MD file and rename it as you wish.
2. Change the bulletin details in the "front matter" at the top, following the existing format.
3. Write the bulletin normally using Markdown (i.e., the formatting of this Nextcloud editor, or save it to your own computer and use whatever editor you like).
4. When the bulletin is ready, save and close the document.
5. In the Nextcloud folder view, click the "..." button next to the document and select Manage tags -> add the "Tee PDF (Bulletin)" tag.
6. Wait for the background task to run. This happens every minute.
7. The PDF will be created next to the bulletin's .MD file with the same name.

If the .MD file is modified, the PDF will be updated to reflect the changes during the next background run.

# Things to note

Most of the fields in the front matter are optional. If they are missing, the PDF will either just have empty space in their place (e.g., author, distribution, additional info, signature fields) or some default value.

There is also a Finnish version of the bulletin template called "tiedote". For the convenience of Finnish-speaking writers, it has Finnish language metadata fields in the front matter. See the example file of that template for more information.
