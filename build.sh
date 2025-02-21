rm -rf ./build
./create_icns.sh --create-placeholders-from-image icon.png
./create_icns.sh --create-extra-images icon.png
magick convert build/icon_images/32x32.png -alpha on -channel RGBA 32x32.png
./create_icns.sh --create-icns
./create_icns.sh --create-ico icon.png
mv build/icon_images/*.* ./build
mv build/extra_images/*.* ./build
rm -rf build/icon_images
rm -rf build/extra_images
rm -rf build/icon.iconset
open ./build