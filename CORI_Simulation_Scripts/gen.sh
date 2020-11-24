#!/bin/bash
python3 createSimFiles.py
rm inputlist.txt
for filename in ./GMS*tcl; do
    echo "run.sh $PWD/$filename" >> inputlist.txt

done
