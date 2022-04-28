#!/bin/bash

exe=/home/neoe/Downloads/magick.AppImage

for file in *.dds
do
    echo "$file" "->" "$(basename "$file" .dds).jpg"
    $exe "$file" "$(basename "$file" .dds).jpg"
done

