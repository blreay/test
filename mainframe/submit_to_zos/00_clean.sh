#!/bin/sh
find . -type f -name "*.log" | xargs rm -f
find . -type f -name "*.submit" | xargs rm -f
find . -type f -name "*.summary" | xargs rm -f

