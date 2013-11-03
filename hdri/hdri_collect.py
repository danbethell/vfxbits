#!/usr/bin/env python

"""
Script to collect and combine bracketed exposure photos.
Requires: luminance-hdr, libimage-exiftool-perl packages
"""

# Usage: hdri_collect <source_files>
import sys, subprocess

# Gather files
file_args = sys.argv[1:]

# Set some defaults
photos = sorted(file_args)
num_photos = len(photos)
brackets = [-4,-3,-2,-1,0,1,2,3,4]
num_brackets = len(brackets)
mid_exposure = 5
sets = int(num_photos/9)
bracket_string = []
for b in brackets:
	bracket_string.append(str(b))
bracket_cmd = "--ev %s" % ','.join(bracket_string)

# Loop through sets combining HDRI and restoring EXIF
print "Processing ", num_photos, "files."
for i in range(1,sets+1):
	set_photos = photos[(i-1)*num_brackets:i*num_brackets]
	print "======\nSet ", i
	print "======"
	filename = "hdri.%04d.exr" % i
	cmd = "luminance-hdr-cli %s --save %s" % (bracket_cmd, filename)
	for j in range(num_brackets):
		print brackets[j], ": ", set_photos[j]
		cmd = "%s %s" % (cmd, set_photos[j])
	print "=====\nCombining HDRI"
	subprocess.call(cmd, shell=True)
	# print "=====\nRestoring EXIF Information"
	# exif_src = set_photos[mid_exposure-1]
	# cmd = "exiftool -TagsFromFile %s %s" % (exif_src, filename)
	# subprocess.call(cmd, shell=True)
print "====="
