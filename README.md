# cbz-to-pdf-converter
this is a bash script highly optimised to convert ebooks from cbz format to pdf format, it takes a whole directroy as input and another as output



this script acts like a small automated factory pipeline. It takes a folder full of digital comic or manga archives (.cbr or .cbz), breaks them down into individual image pages, converts those images into a high-quality PDF book, and cleans up after itself.

Here is exactly what happens step-by-step when you run it:

The Step-by-Step Breakdown
Step 1: Gathering the Instructions
The script looks at the flags you typed in the terminal (-i for input and -o for output). It verifies that the folder containing your manga exists, and it automatically creates your destination folder (Domestic girlfirend pdf) if it isn't already there.

Step 2: Unmasking the Archive Files
Digital comic formats are actually just secret zip or rar folders:

A .cbz file is just a ZIP archive full of images.

A .cbr file is just a RAR archive full of images.

The script scans your folder for any .cbr or .cbz files and temporarily renames them to .rar and .zip so your Linux system knows exactly how to unpack them.

Step 3: Unpacking the Pages (The Loop)
The script goes through your comic volumes one by one. For each volume, it:

Creates a hidden, isolated temporary directory on your system (mktemp -d).

Extracts all the raw image files (JPEGs, PNGs, or WebPs) into that temporary folder.

Step 4: The Heavy Lifting (Converting & Merging)
This is where the magic happens, and it uses two ultra-fast tools instead of relying solely on heavy ImageMagick processes:

img2pdf (Individual Page Conversion): It scans all the extracted image pages. Using a progress bar (pv), it fires up 8 CPU cores simultaneously (xargs -P 8) to convert every single image page into its own individual single-page PDF. It does this because img2pdf is incredibly fast and lossless—it doesn't re-compress the manga art, keeping the images perfectly crisp.

pdftk (The Binder): It takes all those individual single-page PDFs and merges ("cats" or concatenates) them together into one single, beautifully ordered file named combined.pdf.

Step 5: The Delivery and Cleanup
The script takes that finished combined.pdf, renames it to match the original title of your volume (like Domestic Girlfriend Vol 1), and moves it over to your specified -o output folder.

It completely deletes the temporary working folder to free up your RAM and cache.

Crucial Note: It deletes the original .cbr/.cbz file (rm "$file") from the input folder once it finishes ensuring the PDF was successfully created, keeping your source directory clean.






When the script finishes, you are left with a folder of perfectly formatted PDFs ready to be dropped straight into your iPad's Apple Books app!
